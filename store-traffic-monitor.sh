#!/bin/bash
 
if [ ! -d "/opt/intel/openvino_2019.1.094" ]
then
	echo "incorrect version. Please install OpenVINO_2019.1.094"	
fi
		
uname -a 	


sudo apt update

if [ ! -d "/usr/share/ffmpeg" ]
then 
	sudo apt install ffmpeg
fi

cd $HOME
cd /opt/intel/openvino/deployment_tools/tools/model_downloader/
if [ ! -d "/opt/intel/openvino/deployment_tools/tools/model_downloader/" ]
then 
	sudo ./downloader.py --name mobilenet-ssd
fi

cd $HOME
cd /opt/intel/openvino/deployment_tools/model_optimizer/ 

./mo_caffe.py --input_model /opt/intel/openvino/deployment_tools/tools/model_downloader/object_detection/common/mobilenet-ssd/caffe/mobilenet-ssd.caffemodel  -o $HOME/store-traffic-monitor-python/resources/FP32 --data_type FP32 --scale 256 --mean_values [127,127,127]

cd $HOME/store-traffic-monitor-python 




python3 video_downloader.py








source /opt/intel/openvino/bin/setupvars.sh -pyver 3.5

cd $HOME/store-traffic-monitor-python

############################################################################

while [ flag==0 ]
do
	echo "Enter specified target device : 'CPU','GPU-16','GPU-32','FPGA','MYRIAD','HHDL'"
	read t_d
	
if [[ ! $t_d =~ ^(CPU|GPU-16|GPU-32|FPGA|MYRIAD|HHDL)$ ]]; then	 # =~ returns 0 if true, $match end of the line, ^match 
	echo "bad input, try again"
	flag=0
else
	flag=1
	break
fi
done
#############################################################################

case $t_d in 
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

###############################################################################





	
