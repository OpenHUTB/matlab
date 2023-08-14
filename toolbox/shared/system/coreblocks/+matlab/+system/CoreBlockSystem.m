classdef CoreBlockSystem<matlab.system.SystemAdaptorCoreBlock...
    &matlab.system.SystemProp






    methods
        function obj=CoreBlockSystem(libraryName)
            obj@matlab.system.SystemAdaptorCoreBlock(libraryName);
        end
    end

    methods(Hidden)
        function y=supportsUnboundedIO(~)
            y=false;
        end
        function y=callTerminateAfterCodegen(~)





            y=false;
        end
    end

    methods(Static,Hidden,Sealed)
        function obj=loadobj(s)
            if isfield(s,'ClassNameForLoadTimeEval')
                obj=eval(s.ClassNameForLoadTimeEval);
                matlab.system.SFunSystem.loadCPPObjectData(obj,s);
            else


                obj=s;
            end
        end
    end

    methods(Static,Hidden)
        function y=hasEmptyGeneratedTerminateFcn(~)




            y=false;
        end
        function y=allocatePortBuffersInCodegen




            y=false;
        end
    end

    methods(Hidden,Sealed)
        function a=saveobj(obj)









            childClassData=saveObjectImpl(obj);
            if isfield(childClassData,'Description')
                childClassData=rmfield(childClassData,'Description');
            end

            a.ClassNameForLoadTimeEval=class(obj);

            [a.MajorVersionNumber,a.MinorVersionNumber]=getVersionNumber(obj);
            a.ChildClassData=childClassData;
            if isFullSaveLoadEnabled(obj,a.ChildClassData)
                a.SuperClassData=saveSFunctionObjectData(obj);
            end
            if isfield(a.ChildClassData,'SaveLockedData')
                a.ChildClassData=rmfield(a.ChildClassData,'SaveLockedData');
            end

            if isfield(a,'ChildClassData')&&isfield(a.ChildClassData,'isInMATLABSystemBlock')
                a.ChildClassData.isInMATLABSystemBlock=0;
            end
        end

        function dTypeID=getInputDataTypeID(obj)

            dTypeID=getInputDataTypeIDSFunctionObject(obj);
        end
    end

    methods(Hidden)
        function s=getCompiledFixedPointInfo(obj,props)

            s=struct;
            for idx=1:length(props)



                s.(props{idx})=numerictype(getCompiledDataInfo(obj,props{idx}));
            end
        end
    end

    methods(Access=protected)
        function varargout=isInputDirectFeedthroughImpl(obj,varargin)

            [varargout{1:nargout}]=isInputDirectFeedthroughImpl@matlab.system.SystemAdaptor(obj,varargin{:});
        end
        function obj=cloneImpl(other)
            s=saveobj(other);
            obj=other.loadobj(s);
        end
        function out=getDiscreteStateImpl(~)
            out=struct();
            matlab.system.internal.error('MATLAB:system:getDiscreteStateNotSupported');
        end
        function out=getContinuousStateImpl(~)
            out=struct();
            matlab.system.internal.error('MATLAB:system:getContinuousStateNotSupported');
        end
        function setDiscreteStateImpl(~,~)
            matlab.system.internal.error('MATLAB:system:setDiscreteStateNotSupported');
        end
        function setContinuousStateImpl(~,~)
            matlab.system.internal.error('MATLAB:system:setContinuousStateNotSupported');
        end
    end
end

