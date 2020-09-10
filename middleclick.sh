#!/bin/sh

#CLUSTER="dut=nslrack11-100G,nic=0+1 server=nslrack12-100G,nic=0 client=nslrack14-100G,nic=1"
GLOBAL="--use-last --show-full --no-build"
NPF_PATH=/home/tom/npf/
CONFIG_PATH=/home/tom/workspace/middleclick-config/
MIDDLECLICK_REPO=middleclick-2
CPUFREQ=2300
#CLUSTER="dut=nslrack14-100G,nic=0+1 server=nslrack28-100G,nic=0 client=nslrack17-100G,nic=0 client=nslrack18-100G,nic=0 client=nslrack16-100G,nic=0"
CLUSTER="dut=nslrack14-100G,nic=0+1 server=nslrack28-100G,nic=0 client=nslrack26-100G,nic=0"
N_RUNS=3

#HTTP, multiple VNF motivation experiment
${NPF_PATH}/npf-compare.py "middleclick-2+reclass:Indepedent stateful" "middleclick-2:Combined stateful" "middleclick-2+hw,agg,aggcache:Accelerated stateful" "middleclick-2+reclass,tcp:Indepedent TCP stack" "middleclick-2+tcp:Combined TCP stack" "middleclick-2+hw,agg,aggcache,tcp:Accelerated TCP stack" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --graph-size 6 2.8 --config n_runs=${N_RUNS} --output --graph-filename ~/workspace/middleclick-paper/figs/chain.pdf --variables FSIZE=8 "CPU=1" CPUFREQ=2300000 --tags evaluation cpufreq nobind noka chain --config "graph_lines={-,-,-,:,:,:}" "graph_color={2,2,2,3,3,3}" "graph_markers={o,d,D,o,d,D}" --show-full --variables "NB_NF=[0-5]" $(echo "$GLOBAL")

#Context
${NPF_PATH}/npf-compare.py "${MIDDLECLICK_REPO}+wm,tcpstate:TCP State" "local+mos,wm,proxy:TCP State" "${MIDDLECLICK_REPO}+wm,tcp:TCP Stream" "local+snort,dpdk,wm:TCP Stream" "local+nginxlb,wm,wm_none:TCP Stream" "${MIDDLECLICK_REPO}+wm,tcp,wm_alert:Alert" "local+snort,dpdk,wm,wm_alert:Alert" "${MIDDLECLICK_REPO}+wm,tcp,wm_replace:Mask" "local+snort,dpdk,wm,wm_replace:Mask" "local+nginxlb,wm,wm_replace:Mask" "${MIDDLECLICK_REPO}+wm,tcp,http,wm_remove:Remove" "local+nginxlb,wm,wm_remove:Remove" "${MIDDLECLICK_REPO}+wm,tcp,http,wm_full:Replace" "local+nginxlb,wm,wm_full:Replace" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --config n_runs=${N_RUNS} --graph-size 6 2.3 --variables FSIZE=8 --tags hw aggcache context noka --output --graph-filename ~/workspace/middleclick-paper/figs/context/context-compare-ka0.pdf $(echo "$GLOBAL")

#LB (single NF)
${NPF_PATH}/npf-compare.py fastclick+fwd:Forwarding local+haproxy:HAProxy local+nginxlb:NGINX fastclick+lb:FastClick ${MIDDLECLICK_REPO}+fulllb:MiddleClick "${MIDDLECLICK_REPO}+fulllb,aggcache:MiddleClick Cache" "${MIDDLECLICK_REPO}+hw,fulllb:MiddleClick HW" "${MIDDLECLICK_REPO}+hw,aggcache,fulllb:MiddleClick HW+Cache" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind evaluation loadbalancer --graph-size 6 2.4 --config "graph_color={3,1,1,2,5,5,5,5}" "legend_loc=outer center" "legend_ncol=3" --output --graph-filename ~/workspace/middleclick-paper/figs/loadbalancer/loadbalancer_ka0.pdf $(echo "$GLOBAL")

#SCchain
${NPF_PATH}/npf-compare.py "local+nat:Linux NAT" "local+mos,nat:mOS NAT" "local+mos,stats:mOS Stream Stats" "fastclick+nat:FastClick NAT" "fastclick+nat,stats:FastClick NAT+Stats" "${MIDDLECLICK_REPO}+nat:MiddleClick NAT" "${MIDDLECLICK_REPO}+nat,stats:+Stats" "${MIDDLECLICK_REPO}+nat,stats,tcp:+TCP" "${MIDDLECLICK_REPO}+nat,stats,fc,tcp:+Stream stats" "${MIDDLECLICK_REPO}+nat,stats,fc,tcp,lb:+LB" "${MIDDLECLICK_REPO}+nat,stats,tcp,fc,lb,crc:+CRC" "${MIDDLECLICK_REPO}+nat,stats,tcp,fc,lb,crc,ids:+IDS" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --graph-size 6 2.8 --config "var_lim+={THROUGHPUT:0-45}" "graph_color={8,4,4,1,1,3,3,5,5,5,5,7}" "legend_loc=outer center" "legend_ncol=3" "legend_bbox={0,1,1,.17}" --show-full --output --graph-filename ~/workspace/middleclick-paper/figs/schain/schain_all_ka0.pdf --variables FSIZE=8 "CPU=[1-4]" CPUFREQ=${CPUFREQ}000 --tags nobind evaluation cpufreq aggcache hw schain cpufreq noka --config n_runs=${N_RUNS}  --no-graph-time $(echo "$GLOBAL")

${NPF_PATH}/npf-compare.py "local+nat:Linux NAT" "local+mos,nat:mOS NAT" "local+mos,stats:mOS Stream Stats" "fastclick+nat:FastClick NAT" "fastclick+nat,stats:FastClick NAT+Stats" "${MIDDLECLICK_REPO}+nat:MiddleClick NAT" "${MIDDLECLICK_REPO}+nat,stats:+Stats" "${MIDDLECLICK_REPO}+nat,stats,tcp:+TCP" "${MIDDLECLICK_REPO}+nat,stats,fc,tcp:+Stream stats" "${MIDDLECLICK_REPO}+nat,stats,fc,tcp,lb:+LB" "${MIDDLECLICK_REPO}+nat,stats,tcp,fc,lb,crc:+CRC" "${MIDDLECLICK_REPO}+nat,stats,tcp,fc,lb,crc,ids:+IDS" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --graph-size 6 2.8 --config n_runs=${N_RUNS} "graph_legend=0" --output --graph-filename ~/workspace/middleclick-paper/figs/schain/schain_all_rate_ka0.pdf --variables FSIZE=8 "CPU=1" CPUFREQ=${CPUFREQ}000 --tags evaluation cpufreq aggcache hw wrkrate schain nobind noka --no-graph-time $(echo "$GLOBAL")


# OLD tests that should still work

#motivation
#${NPF_PATH}/npf-compare.py local:Forward local+nat:+NAT local+nat,haproxy:+HAProxy local+nat,snort,haproxy:+Snort local+nat,snort,squid,haproxy:+Squid --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --variables FSIZE=8 --tags motivation --graph-size 6 2.5 --output --graph-filename ~/workspace/middleclick-paper/figs/motivation/fnt.pdf $(echo "$GLOBAL")

#motivation -profiling
#taskset --cpu-list 15 ${NPF_PATH}/npf-compare.py local:Forward local+nat:+NAT local+nat,haproxy:+HAProxy local+nat,haproxy,snort:+Snort local+nat,haproxy,snort,squid:+Squid --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --variables FSIZE=8 --tags motivation --graph-size 6 2.5 --graph-filename ~/workspace/middleclick-paper/figs/motivation/fnt-profile-ka0-nolinger.pdf --tags perf --config n_runs=1 --variables "PERF_CLASS_MAP=../libs/perf/kernel.map ../libs/perf/kernel_flow.map ../libs/perf/haproxy.map ../libs/perf/snort.map ../libs/perf/squid.map" $(echo "$GLOBAL")

#Motivation - profiling - pipeline (decomissioned, just create noise)
#taskset --cpu-list 15 ${NPF_PATH}/npf-compare.py local:Forward local+nat:+NAT local+nat,haproxy,pipeline,PERF_CPU=2:+HAProxy local+nat,haproxy,snort,pipeline,PERF_CPU=3:+Snort local+nat,haproxy,snort,squid,pipeline,PERF_CPU=4:+Squid --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --variables FSIZE=8 --tags motivation --graph-size 6 2.5 --graph-filename ~/workspace/middleclick-paper/figs/motivation/fnt-pipeline-profile.pdf --tags perf --config n_runs=1 --variables "PERF_CLASS_MAP=../libs/perf/kernel.map ../libs/perf/kernel_flow.map ../libs/perf/haproxy.map ../libs/perf/snort.map ../libs/perf/squid.map" $(echo "$GLOBAL")

#Figure not published, FWD, NAT, NAT+LB and IDS in Linux vs FastClick vs MiddleClick
#${NPF_PATH}/npf-compare.py local:Linux local+nat:Linux local+nat,haproxy:Linux local+nat,haproxy,snort:Linux fastclick:FastClick fastclick+nat:FastClick fastclick+nat,lb:FastClick ${MIDDLECLICK_REPO}:MiddleClick ${MIDDLECLICK_REPO}+nat:MiddleClick ${MIDDLECLICK_REPO}+nat,lb:MiddleClick ${MIDDLECLICK_REPO}+nat,lb,tcp,ids:MiddleClick --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind --variables FSIZE=8 --config n_runs=3 --show-full $(echo "$GLOBAL")


#Traffic class -firewall
#Older, not shown
#${NPF_PATH}/npf-compare.py "fastclick+dpdk:FastClick" "fastclick+dpdk,nodrop:FastClick" "middleclick-static+dpdk,middleclick:MiddleClick" "middleclick-static+dpdk,middleclick,nodrop:MiddleClick" "middleclick-static+dpdk,middleclick,hw:MiddleClick-HW" "middleclick-static+dpdk,hw,middleclick,nodrop:MiddleClick-HW" --testie ${CONFIG_PATH}/firewall-delay-single.testie --cluster $(echo "$CLUSTER") --tags nobind --config n_runs=3 --no-conntest --variables checksum=true --show-full --tags matchall --graph-size 5 2.1 --output --graph-filename ~/workspace/middleclick-paper/figs/firewall/firewall-delay-single.pdf --tags paper $(echo "$GLOBAL")

#Combined
#${NPF_PATH}/npf-compare.py "fastclick+dpdk:FastClick" "fastclick+dpdk,nodrop:FastClick" "middleclick-static+dpdk,middleclick:MiddleClick" "middleclick-static+dpdk,middleclick,nodrop:MiddleClick" "middleclick-static+dpdk,middleclick,hw:MiddleClick-HW" "middleclick-static+dpdk,hw,middleclick,nodrop:MiddleClick-HW" "fastclick+dpdk,fwout,router:FastClick" "fastclick+dpdk,nodrop,fwout,router:FastClick" "middleclick-static+dpdk,middleclick,fwout,router:MiddleClick" "middleclick-static+dpdk,middleclick,nodrop,fwout,router:MiddleClick" "middleclick-static+dpdk,middleclick,hw,fwout,router:MiddleClick-HW" "middleclick-static+dpdk,hw,middleclick,nodrop,fwout,router:MiddleClick-HW" --testie ${CONFIG_PATH}/firewall-delay-single.testie --cluster dut=nslrack11-100G,nic=1+0 client=nslrack12-100G,nic=0 --tags nobind --config n_runs=3 --no-conntest --variables checksum=true --show-full --tags matchall --graph-size 7 2.5 --output --graph-filename ~/workspace/middleclick-paper/figs/firewall/firewall-delay-single-combined.pdf --tags paper --config graph_show_values=1 $(echo "$GLOBAL")


#rate 8k
#${NPF_PATH}/npf-compare.py fastclick+fwd:Forwarding local+haproxy:HAProxy local+nginxlb:NGINX fastclick+lb:FastClick ${MIDDLECLICK_REPO}+fulllb:MiddleClick "${MIDDLECLICK_REPO}+fulllb,aggcache:MiddleClick Cache" "${MIDDLECLICK_REPO}+hw,fulllb:MiddleClick HW" "${MIDDLECLICK_REPO}+hw,aggcache,fulllb:MiddleClick HW+Cache" --testie ${CONFIG_PATH}/fullchain.conf --cluster $(echo "$CLUSTER") --tags nobind evaluation wrkrate cdflat --graph-size 6 2 --show-full --output --graph-filename ~/workspace/middleclick-paper/figs/loadbalancer/loadbalancer_rate_ka0_8K.pdf --variables GEN_RATE=8000 FSIZE=8 --config "graph_color={3,1,1,2,5,5,5,5}" --variables GEN_TIME=10 $(echo "$GLOBAL")



