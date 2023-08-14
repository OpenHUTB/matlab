classdef networks
    methods(Static=true)
        function net=getAlexNetwork()
            net=alexnet();
        end
        function net=getDigitsNetwork()
            n=load(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','networks','dnnfpga_digits','digitsNetwork.mat'));
            net=n.net;
        end
        function data=getLaneDetectionData()
            if exist('trainedLaneData.mat','file')==0
                url='https://ssd.mathworks.com/supportfiles/gpucoder/cnn_models/lane_detection/trainedLaneNet.mat';
                websave('trainedLaneData.mat',url);
            end
            data=load('trainedLaneData.mat');
        end
        function net=getLaneDetectionNetwork()
            data=dnnfpga.networks.getLaneDetectionData();
            net=data.laneNet;
        end
        function data=getLogoData()
            if exist('LogoNet.mat','file')==0
                url='https://ssd.mathworks.com/supportfiles/gpucoder/cnn_models/logo_detection/LogoNet.mat';
                websave('LogoNet.mat',url);
            end
            data=load('LogoNet.mat');
        end
        function net=getLogoNetwork()
            data=dnnfpga.networks.getLogoData();
            net=data.convnet;
        end
        function data=getPedestrianData()
            if exist('PedNet.mat','file')==0
                url='https://ssd.mathworks.com/supportfiles/gpucoder/cnn_models/pedestrian_net/PedNet.mat';
                websave('PedNet.mat',url);
            end
            data=load('PedNet.mat');
        end
        function net=getPedestrianNetwork()
            data=dnnfpga.networks.getPedestrianData();
            net=data.PedNet;
        end
        function filename=saveLaneDetectionVideoFile(destination)
            if nargin==0
                destination='./caltech_cordova1.avi';
            end
            if~exist(destination,'file')
                url='https://ssd.mathworks.com/supportfiles/gpucoder/media/caltech_cordova1.avi';
                websave(destination,url);
            end
            filename=destination;
        end
    end
end
