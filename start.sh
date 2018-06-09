#!/bin/bash

work_dir=$HOME
steamcmd_dir="$work_dir/steamcmd"
install_dir="$work_dir/dst_server"
cluster_name="Cluster_1"
dontstarve_dir="$work_dir/.klei/DoNotStarveTogether"

function fail()
{
        echo Error: "$@" >&2
        exit 1
}

function check_for_file()
{
    if [ ! -e "$1" ]; then
            fail "Missing file: $1"
    fi
}

cd "$steamcmd_dir" || fail "Missing $steamcmd_dir directory!"

mkdir -p "$dontstarve_dir/$cluster_name/Master"
mkdir -p "$dontstarve_dir/$cluster_name/Caves"

echo "[GAMEPLAY]
game_mode = survival
max_players = 12
pvp = false
pause_when_empty = true
#vote_enabled = true


[NETWORK]
#tick_rate = 30
lan_only_cluster = false
cluster_intention = cooperative
cluster_description = 
cluster_name = 903291576的世界
offline_cluster = false
cluster_password = 123456


[MISC]
max_snapshots = 6
console_enabled = true


[SHARD]
shard_enabled = true
bind_ip = 127.0.0.1
master_ip = 127.0.0.1
master_port = 10120
cluster_key = defaultPass" > "$dontstarve_dir/$cluster_name/cluster.ini"

echo "[NETWORK]
server_port = 10119

[SHARD]
is_master = true

[ACCOUNT]
encode_user_path = true" > "$dontstarve_dir/$cluster_name/Master/server.ini"

echo "[NETWORK]
server_port = 10118

[SHARD]
is_master = false
name = Caves
id = 1942550586

[ACCOUNT]
encode_user_path = true

#[STEAM]
#master_server_port = 27017
#authentication_port = 8767" > "$dontstarve_dir/$cluster_name/Caves/server.ini"

token=${token:="pds-g^KU_CZ2CklcP^Ucg+7D+7o4vXQYgV8HhetJA33hBXEttgVUJvtGfZ8sA="}
echo $token > "$dontstarve_dir/$cluster_name/cluster_token.txt"

remote_url=${remote_url:="http://7xio1d.com1.z0.glb.clouddn.com"}
function download_and_check()
{
    tmp_path="$dontstarve_dir/$cluster_name/$2"
    curl -H 'Cache-Control: no-cache' -L -o $tmp_path $1
    check_for_file $tmp_path
}

check_for_file "steamcmd.sh"
# download_and_check "$remote_url/adminlist.txt" "adminlist.txt"
# download_and_check "$remote_url/modoverrides.lua" "Master/modoverrides.lua"
# download_and_check "$remote_url/modoverrides.lua" "Caves/modoverrides.lua"
check_for_file "$dontstarve_dir/$cluster_name/cluster.ini"
check_for_file "$dontstarve_dir/$cluster_name/Master/server.ini"
check_for_file "$dontstarve_dir/$cluster_name/Caves/server.ini"

# ./steamcmd.sh +force_install_dir "$install_dir" +login anonymous +app_update 343050 validate +quit
./steamcmd.sh +force_install_dir "$install_dir" +login anonymous +app_update 343050 +quit

game_path="$install_dir"
cd "$game_path/bin" || fail 

# https://steamcommunity.com/sharedfiles/filedetails/?id=1383995661
collection=${collection:="1383995661"}
echo "ServerModCollectionSetup(\"$collection\")" > "$game_path/mods/dedicated_server_mods_setup.lua"

run_shared=(./dontstarve_dedicated_server_nullrenderer)
run_shared+=(-console)
run_shared+=(-cluster "$cluster_name")
run_shared+=(-monitor_parent_process $$)

"${run_shared[@]}" -shard Caves  | sed 's/^/Caves:  /' &
"${run_shared[@]}" -shard Master | sed 's/^/Master: /'