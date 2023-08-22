classdef DetectorInfo<handle

    properties(Constant,Access=private)
        MklDnnTargetLib='mkldnn';
        CodeGenObjectDetectorClasses={'yolov2ObjectDetector','ssdObjectDetector','yolov3ObjectDetector','yolov4ObjectDetector'};
    end


    properties(SetAccess=private)
DetectorToLoad
TimeStamp
IsObjectDetector
IsCodeGenObjectDetector
ObjectDetectorClass
        Classes=categorical();
        NumLoads=0;
ThresholdSupported
NumStrongestRegionsSupported
MinSizeSupported
MaxSizeSupported
RatioTypeDefault
UseThresholdAsOverlap
    end


    properties(Access=private)
        MatlabCoderSpkgInstalled;
        GpuCoderSpkgInstalled;
        SimSupportedMap;
InputLayerSizes
    end


    methods(Access=public)

        function obj=DetectorInfo(detectorToLoad,timeStamp)
            obj.MatlabCoderSpkgInstalled=dlcoder_base.internal.isMATLABCoderDLTargetsInstalled;
            obj.GpuCoderSpkgInstalled=dlcoder_base.internal.isGpuCoderDLTargetsInstalled;
            obj.DetectorToLoad=detectorToLoad;
            obj.TimeStamp=timeStamp;
            detector=obj.loadDetector();
            obj.ObjectDetectorClass=class(detector);
            obj.IsCodeGenObjectDetector=deep.blocks.internal.DetectorInfo.isCodeGenObjectDetector(detector);
            obj.Classes=categorical(detector.ClassNames,detector.ClassNames);

            if isa(detector,'yolov4ObjectDetector')
                setDetectorProperties(obj);
            elseif isa(detector,'yolov3ObjectDetector')
                setDetectorProperties(obj);
            elseif isa(detector,'yolov2ObjectDetector')
                setDetectorProperties(obj);
            elseif isa(detector,'ssdObjectDetector')
                setDetectorProperties(obj);
            elseif isa(detector,'rcnnObjectDetector')
                obj.ThresholdSupported=false;
                obj.NumStrongestRegionsSupported=true;
                obj.MinSizeSupported=false;
                obj.MaxSizeSupported=false;
                obj.RatioTypeDefault='Min';
                obj.UseThresholdAsOverlap=false;
            else
                obj.ThresholdSupported=true;
                obj.NumStrongestRegionsSupported=true;
                obj.MinSizeSupported=true;
                obj.MaxSizeSupported=true;
                obj.RatioTypeDefault='Min';
                obj.UseThresholdAsOverlap=false;
            end

            network=detector.Network;
            if isa(network,'dlnetwork')
                [inputLayers,~]=deep.blocks.internal.getIOLayers(network);
                exampleInputs=network.getExampleInputs();
                if isempty(exampleInputs)
                    obj.InputLayerSizes=cellfun(...
                    @(layer)layer.InputSize,inputLayers,'UniformOutput',false);
                else
                    obj.InputLayerSizes=cellfun(...
                    @(placeholder)size(placeholder),exampleInputs,'UniformOutput',false);
                end
            else
                obj.InputLayerSizes=network.getInternalDAGNetwork().InputSizes;
            end
        end


        function supported=isSimSupported(obj,simTargetLib,simTargetLang)
            if strcmpi(simTargetLang,'c')||~obj.IsCodeGenObjectDetector
                supported=false;
            else
                matlabCoderSpkgInstalled=dlcoder_base.internal.isMATLABCoderDLTargetsInstalled;
                gpuCoderSpkgInstalled=dlcoder_base.internal.isGpuCoderDLTargetsInstalled;
                simTargetLib=obj.sanitizeSimTargetLib(simTargetLib);
                isMklDnn=any(strcmp(simTargetLib,obj.MklDnnTargetLib));

                if isMklDnn
                    supported=matlabCoderSpkgInstalled;
                else
                    supported=gpuCoderSpkgInstalled;
                end
            end
        end
    end


    methods(Access=private)

        function detector=loadDetector(obj)
            detector=deep.blocks.internal.loadObjectDetector(obj.DetectorToLoad);
            obj.NumLoads=obj.NumLoads+1;
        end


        function setDetectorProperties(obj)
            obj.ThresholdSupported=true;
            obj.NumStrongestRegionsSupported=false;
            obj.MinSizeSupported=true;
            obj.MaxSizeSupported=true;
            obj.RatioTypeDefault='Union';
            obj.UseThresholdAsOverlap=false;
        end
    end


    methods(Access=private,Static)

        function isCodeGenDetector=isCodeGenObjectDetector(detector)
            detectorClass=class(detector);
            isCodeGenDetector=any(strcmp(detectorClass,...
            deep.blocks.internal.DetectorInfo.CodeGenObjectDetectorClasses));
        end


        function sanitizedSimTargetLib=sanitizeSimTargetLib(simTargetLib)
            sanitizedSimTargetLib=lower(simTargetLib);
            if strcmp(sanitizedSimTargetLib,'mkl-dnn')
                sanitizedSimTargetLib='mkldnn';
            end
        end
    end
end

