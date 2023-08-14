classdef networksForTest
    methods(Static=true)
        function net=getMnistNetwork()
            n=load(fullfile(matlabroot,'test','toolbox','hdlcoder','deeplearning','cnn_testtools','MnistFiles','mnist_example.mat'));
            net=n.net;
        end
        function data=getLaneDetectionData()
            largeTestDataRoot=getenv('LARGE_TEST_DATA_ROOT');
            cnnMatFile=fullfile(largeTestDataRoot,'gpucoder','laneDetect','v000','trainedLaneNet.mat');
            data=load(cnnMatFile);
        end
        function net=getLaneDetectionNetwork()
            data=dnnfpga.networksForTest.getLaneDetectionData();
            net=data.laneNet;
        end
    end
end
