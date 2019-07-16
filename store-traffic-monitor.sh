#!/bin/bash
 
version = "16.04.1-Ubuntu"
str = $(uname -a)
	if [ "${str/$version}" = "$str"] ; then 
		echo "incorrect version. Please use 16.04.01-Ubuntu"
	else
		echo "Using correct version"	
	fi
		
#uname -a

	
sudo apt update
sudo apt install ffmpeg
cd $HOME
cd /opt/intel/openvino/deployment_tools/tools/model_downloader/
sudo ./downloader.py --name mobilenet-ssd
cd $HOME
cd /opt/intel/openvino/deployment_tools/model_optimizer/ 

./mo_caffe.py --input_model /opt/intel/openvino/deployment_tools/tools/model_downloader/object_detection/common/mobilenet-ssd/caffe/mobilenet-ssd.caffemodel  -o $HOME/store-traffic-monitor-python/resources/FP32 --data_type FP32 --scale 256 --mean_values [127,127,127]

cd $HOME/store-traffic-monitor-python 
python3 video_downloader.py


source /opt/intel/openvino/bin/setupvars.sh -pyver 3.5

cd $HOME/store-traffic-monitor-python

echo "Enter specified target device : 'CPU','GPU-16','GPU-32','FPGA','MYRIAD','HHDL'"
read target_device


case $target_device in 
	CPU) 
		echo "targeting CPU" 	
		#cd $HOME/store-traffic-monitor-python 		
		./store-traffic-monitor.py -d CPU -m resources/FP32/mobilenet-ssd.xml -l resources/labels.txt -e /opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/libcpu_extension_avx2.so

		;;
	GPU-16) 		
		echo "targeting GPU-16"
		./store-traffic-monitor.py -d GPU -m resources/FP16/mobilenet-ssd.xml -l resources/labels.txt
		;;
	GPU-32)
		echo " targeting GPU-32"	
		./store-traffic-monitor.py -d GPU -m resources/FP32/mobilenet-ssd.xml -l resources/labels.txt
		;;
	MYRIAD)	
		echo "targeting Intel Neural Compute Stick"
		./store-traffic-monitor.py -d MYRIAD -m resources/FP16/mobilenet-ssd.xml -l resources/labels.txt
		;;
	HHDL)
		echo "targeting HHDL"
		./store-traffic-monitor.py -d HETERO:HDDL,CPU -m resources/FP16/mobilenet-ssd.xml -l resources/labels.txt -e /opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/libcpu_extension_avx2.so
		;;
	*)	
esac



	
