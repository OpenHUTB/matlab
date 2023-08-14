classdef(Sealed)DeepLearningConfigController<coderapp.internal.config.AbstractController



    methods
        function initArmComputeVersion(this)
            this.import('AllowedValues',getArmComputeVersions());
        end

        function updateEnableDeepLearning(this,gpuEnabled)


            this.set('DefaultValue',gpuEnabled);
        end

        function updateTargetLib(this,gpuEnabled,buildType,hasMatlabSpkg,hasGpuSpkg)
            import coderapp.internal.dl.DeepLearningTargetLibrary;

            default=DeepLearningTargetLibrary.None.Option.Value;
            if gpuEnabled
                allowed=[DeepLearningTargetLibrary({'cudnn','tensorrt'}).Option];
                if hasGpuSpkg
                    default='cudnn';
                    enable=true(size(allowed));
                else
                    enable=false(size(allowed));
                end
            else
                allowed=[DeepLearningTargetLibrary({'mkldnn','armcompute','cmsisnn'}).Option];
                enable=[...
                hasMatlabSpkg,...
                (hasMatlabSpkg&&~strcmpi(buildType,'mex')),...
                (hasMatlabSpkg&&~any(strcmpi(buildType,{'mex','dll'}))),...
                ];
            end

            for i=1:numel(allowed)
                allowed(i).Enabled=enable(i);
            end
            allowed=[DeepLearningTargetLibrary.None.Option,allowed];

            this.set('AllowedValues',allowed);
            if~ismember(this.get(),{allowed([allowed.Enabled]).Value})
                this.set('none');
            end
            this.set('DefaultValue',default);
        end

        function updateNumCalibrationBatches(this,isTensorRt,dataType)

            if isTensorRt&&strcmp(dataType,'int8')
                this.set(50);
            elseif~isTensorRt
                this.set('DefaultValue',0);
            else
                this.set(0);
            end
        end

        function updateDataPath(this,isTensorRt,dataType)

            if isTensorRt&&~strcmp(dataType,'int8')
                this.set('');
            else
                this.set('DefaultValue','');
            end
        end
    end
end


function result=getArmComputeVersions()
    persistent versions;
    if~iscell(versions)
        versions={};
        try
            dlc=coder.DeepLearningConfig(TargetLibrary='arm-compute');
        catch
            dlc=[];
        end
        if~isempty(dlc)
            versions=dlc.getARMComputeSupportedVersions();
        end
    end
    result=versions;
end