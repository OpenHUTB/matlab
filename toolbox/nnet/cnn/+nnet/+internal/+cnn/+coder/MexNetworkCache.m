classdef MexNetworkCache<handle

    properties(SetAccess=private)

MexNetworkMap

        GenerationFolder=[]
    end


    properties(Access=private)
        GPUDeviceIndex=[]
    end


    methods
        function this=MexNetworkCache()
            this.MexNetworkMap=containers.Map;
        end

        function[mexNetwork,key]=getMexNetwork(this,network,mexNetworkConfig)

            import nnet.internal.cnn.coder.MexNetwork

            key=getKey(mexNetworkConfig);
            initializeGenerationDirectoryIfNeeded(this);
            manageGPUDevice(this);

            if this.isMexNetworkValid(key)
                mexNetwork=this.MexNetworkMap(key);
            else
                mexNetwork=MexNetwork(network,this.GenerationFolder,mexNetworkConfig);
                this.MexNetworkMap(key)=mexNetwork;
            end
            if~contains(path,this.GenerationFolder)
                addpath(this.GenerationFolder);
            end
        end


        function delete(this)
            for k=keys(this.MexNetworkMap)
                key=k{:};
                mexNetwork=this.MexNetworkMap(key);
                removeGeneratedFiles(mexNetwork);
                this.MexNetworkMap.remove(key);
            end
            if~isempty(this.GenerationFolder)
                S=warning('off','MATLAB:rmpath:DirNotFound');
                rmpath(this.GenerationFolder);
                warning(S);

                [~]=rmdir(this.GenerationFolder,'s');
            end
        end
    end


    methods(Access=private)

        function initializeGenerationDirectoryIfNeeded(this)

            if isempty(this.GenerationFolder)
                this.GenerationFolder=tempname;
            end
            if~exist(this.GenerationFolder,'dir')
                [status,mess,messid]=mkdir(this.GenerationFolder);
                if status==0
                    switch lower(messid)
                    case 'matlab:mkdir:directoryexists'
                        error(message('gpucoder:cnncodegen:directoryfailure',this.GenerationFolder));
                    case 'matlab:mkdir:oserror'
                        error(message('gpucoder:cnncodegen:newdirectoryfailure',this.GenerationFolder));
                    otherwise
                        error(messid,'%s',mess);
                    end
                end
            end
        end


        function manageGPUDevice(this)
            currentDevice=gpuDevice();
            currentDeviceIdx=currentDevice.Index;

            if isempty(this.GPUDeviceIndex)
                this.GPUDeviceIndex=currentDeviceIdx;
            else
                if currentDeviceIdx~=this.GPUDeviceIndex

                    this.GPUDeviceIndex=currentDeviceIdx;
                end
            end
        end

        function tf=isMexNetworkValid(this,key)

            if this.MexNetworkMap.isKey(key)
                mexNetwork=this.MexNetworkMap(key);
                if mexNetwork.isValid()
                    tf=true;
                else
                    removeGeneratedFiles(mexNetwork);
                    this.MexNetworkMap.remove(key);
                    tf=false;
                end
            else
                tf=false;
            end
        end
    end


    methods(Static)
        function mexNetworkCache=getCacheFromNetwork(network)
            mexNetworkCache=network.getMexNetworkCache();
        end
    end
end
