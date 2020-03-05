#!/bin/sh

CLUSTER="dut=nslrack11-100G,nic=0+1 server=nslrack12-100G,nic=0 client=nslrack14-100G,nic=1"
GLOBAL="--use-last --show-full --no-build"

#Ensure CPU freq
sudo cpupower frequency-set -u 3700M -d 1000M

#motivation
./npf-compare.py local:Forward local+nat:+NAT local+nat,haproxy:+HAProxy local+nat,snort,haproxy:+Snort local+nat,snort,squid,haproxy:+Squid --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --variables FSIZE=8 --tags motivation --graph-size 6 2.5 --output --graph-filename ~/workspace/middleclick-paper/figs/motivation/fnt.pdf $(echo "$GLOBAL")

#motivation -profiling
taskset --cpu-list 15 ./npf-compare.py local:Forward local+nat:+NAT local+nat,haproxy:+HAProxy local+nat,haproxy,snort:+Snort local+nat,haproxy,snort,squid:+Squid --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --variables FSIZE=8 --tags motivation --graph-size 6 2.5 --graph-filename ~/workspace/middleclick-paper/figs/motivation/fnt-profile-ka0-nolinger.pdf --tags perf --config n_runs=1 --variables "PERF_CLASS_MAP=../libs/perf/kernel.map ../libs/perf/kernel_flow.map ../libs/perf/haproxy.map ../libs/perf/snort.map ../libs/perf/squid.map" $(echo "$GLOBAL")

#Motivation - profiling - pipeline (decomissioned, just create noise)
taskset --cpu-list 15 ./npf-compare.py local:Forward local+nat:+NAT local+nat,haproxy,pipeline,PERF_CPU=2:+HAProxy local+nat,haproxy,snort,pipeline,PERF_CPU=3:+Snort local+nat,haproxy,snort,squid,pipeline,PERF_CPU=4:+Squid --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --variables FSIZE=8 --tags motivation --graph-size 6 2.5 --graph-filename ~/workspace/middleclick-paper/figs/motivation/fnt-pipeline-profile.pdf --tags perf --config n_runs=1 --variables "PERF_CLASS_MAP=../libs/perf/kernel.map ../libs/perf/kernel_flow.map ../libs/perf/haproxy.map ../libs/perf/snort.map ../libs/perf/squid.map" $(echo "$GLOBAL")

#Figure not published, FWD, NAT, NAT+LB and IDS in Linux vs FastClick vs MiddleClick
#./npf-compare.py local:Linux local+nat:Linux local+nat,haproxy:Linux local+nat,haproxy,snort:Linux fastclick:FastClick fastclick+nat:FastClick fastclick+nat,lb:FastClick middleclick-dev:MiddleClick middleclick-dev+nat:MiddleClick middleclick-dev+nat,lb:MiddleClick middleclick-dev+nat,lb,tcp,ids:MiddleClick --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --variables FSIZE=8 --config n_runs=3 --show-full $(echo "$GLOBAL")


#Traffic class -firewall
#Older, not shown
#./npf-compare.py "fastclick+dpdk:FastClick" "fastclick+dpdk,nodrop:FastClick" "middleclick-static+dpdk,middleclick:MiddleClick" "middleclick-static+dpdk,middleclick,nodrop:MiddleClick" "middleclick-static+dpdk,middleclick,hw:MiddleClick-HW" "middleclick-static+dpdk,hw,middleclick,nodrop:MiddleClick-HW" --testie ${CONFIG_PATH}/firewall-delay-single.testie --cluster $(echo "$CLUSTER") --tags nobind --config n_runs=3 --no-conntest --variables checksum=true --show-full --tags matchall --graph-size 5 2.1 --output --graph-filename ~/workspace/middleclick-paper/figs/firewall/firewall-delay-single.pdf --tags paper $(echo "$GLOBAL")
#Combined
./npf-compare.py "fastclick+dpdk:FastClick" "fastclick+dpdk,nodrop:FastClick" "middleclick-static+dpdk,middleclick:MiddleClick" "middleclick-static+dpdk,middleclick,nodrop:MiddleClick" "middleclick-static+dpdk,middleclick,hw:MiddleClick-HW" "middleclick-static+dpdk,hw,middleclick,nodrop:MiddleClick-HW" "fastclick+dpdk,fwout,router:FastClick" "fastclick+dpdk,nodrop,fwout,router:FastClick" "middleclick-static+dpdk,middleclick,fwout,router:MiddleClick" "middleclick-static+dpdk,middleclick,nodrop,fwout,router:MiddleClick" "middleclick-static+dpdk,middleclick,hw,fwout,router:MiddleClick-HW" "middleclick-static+dpdk,hw,middleclick,nodrop,fwout,router:MiddleClick-HW" --testie ${CONFIG_PATH}/firewall-delay-single.testie --cluster dut=nslrack11-100G,nic=1+0 client=nslrack12-100G,nic=0 --tags nobind --config n_runs=3 --no-conntest --variables checksum=true --show-full --tags matchall --graph-size 7 2.5 --output --graph-filename ~/workspace/middleclick-paper/figs/firewall/firewall-delay-single-combined.pdf --tags paper --config graph_show_values=1 $(echo "$GLOBAL")

#LB
./npf-compare.py fastclick+fwd:Forwarding local+haproxy:HAProxy local+nginxlb:NGINX fastclick+lb:FastClick middleclick-dev+fulllb:MiddleClick "middleclick-dev+fulllb,aggcache:MiddleClick Cache" "middleclick-dev+hw,fulllb:MiddleClick HW" "middleclick-dev+hw,aggcache,fulllb:MiddleClick HW+Cache" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind evaluation --graph-size 7 2.5 --config "var_lim+={THROUGHPUT:0-70}" "graph_color={3,1,1,2,5,5,5,5}" "legend_loc=outer center" "legend_ncol=3" "legend_bbox={0,1,1,.15}" --output --graph-filename ~/workspace/middleclick-paper/figs/loadbalancer/loadbalancer_ka0.pdf $(echo "$GLOBAL")
#rate 8k
#./npf-compare.py fastclick+fwd:Forwarding local+haproxy:HAProxy local+nginxlb:NGINX fastclick+lb:FastClick middleclick-dev+fulllb:MiddleClick "middleclick-dev+fulllb,aggcache:MiddleClick Cache" "middleclick-dev+hw,fulllb:MiddleClick HW" "middleclick-dev+hw,aggcache,fulllb:MiddleClick HW+Cache" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind evaluation wrkrate cdflat --graph-size 7 2 --show-full --output --graph-filename ~/workspace/middleclick-paper/figs/loadbalancer/loadbalancer_rate_ka0_8K.pdf --variables GEN_RATE=8000 FSIZE=8 --config "graph_color={3,1,1,2,5,5,5,5}" --variables GEN_TIME=10 $(echo "$GLOBAL")


#SCchain
./npf-compare.py "local+nat:Linux NAT" "local+mos,nat:mOS NAT" "local+mos,stats:mOS Stream Stats" "fastclick+nat:FastClick NAT" "fastclick+nat,stats:FastClick NAT+Stats" "middleclick-dev+nat:MiddleClick NAT" "middleclick-dev+nat,stats:+Stats" "middleclick-dev+nat,stats,tcp:+TCP" "middleclick-dev+nat,stats,fc,tcp:+Stream stats" "middleclick-dev+nat,stats,fc,tcp,lb:+LB" "middleclick-dev+nat,stats,tcp,fc,lb,crc:+CRC" "middleclick-dev+nat,stats,tcp,fc,lb,crc,ids:+IDS" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --graph-size 7 3 --config "var_lim+={THROUGHPUT:0-45}" "graph_color={8,4,4,1,1,3,3,5,5,5,5,7}" "legend_loc=outer center" "legend_ncol=3" "legend_bbox={0,1,1,.17}" --show-full --output --graph-filename ~/workspace/middleclick-paper/figs/schain/schain_all_ka0.pdf --variables FSIZE=8 "CPU=[1-4]" CPUFREQ=2400000 --tags nobind evaluation cpufreq aggcache hw schain cpufreq noka --config n_runs=3  --no-graph-time $(echo "$GLOBAL")

./npf-compare.py "local+nat:Linux NAT" "local+mos,nat:mOS NAT" "local+mos,stats:mOS Stream Stats" "fastclick+nat:FastClick NAT" "fastclick+nat,stats:FastClick NAT+Stats" "middleclick-dev+nat:MiddleClick NAT" "middleclick-dev+nat,stats:+Stats" "middleclick-dev+nat,stats,tcp:+TCP" "middleclick-dev+nat,stats,fc,tcp:+Stream stats" "middleclick-dev+nat,stats,fc,tcp,lb:+LB" "middleclick-dev+nat,stats,tcp,fc,lb,crc:+CRC" "middleclick-dev+nat,stats,tcp,fc,lb,crc,ids:+IDS" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --graph-size 7 3 --config n_runs=3 "graph_legend=0" --output --graph-filename ~/workspace/middleclick-paper/figs/schain/schain_all_rate_ka0.pdf --variables FSIZE=8 "CPU=1" CPUFREQ=2400000 --tags evaluation cpufreq aggcache hw wrkrate schain nobind noka --no-graph-time $(echo "$GLOBAL")


#end of CPU FREQ !
sudo cpupower frequency-set -u 3700M -d 1000M

#Context
./npf-compare.py "middleclick-dev+wm:Forward" "middleclick-dev+wm,tcpstate:TCP State" "local+mos,wm,proxy:TCP State" "middleclick-dev+wm,tcp:TCP Order" "middleclick-dev+wm,tcp,wm_alert:Alert" "middleclick-dev+wm,tcp,wm_replace:Mask" "local+nginxlb,wm,wm_replace:Mask" "middleclick-dev+wm,tcp,http,wm_remove:Remove" "local+nginxlb,wm,wm_remove:Remove" "middleclick-dev+wm,tcp,http,wm_full:Replace" "local+nginxlb,wm,wm_full:Replace" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --config n_runs=3 --graph-size 7 2.5 --variables FSIZE=8 --tags hw aggcache context noka --output --graph-filename ~/workspace/middleclick-paper/figs/context/context-compare-ka0.pdf $(echo "$GLOBAL")
