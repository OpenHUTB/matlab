classdef SFunSystem<matlab.system.SystemAdaptorSFun...
    &matlab.system.SystemProp






    methods
        function obj=SFunSystem(libraryName)
            obj=obj@matlab.system.SystemAdaptorSFun(libraryName);

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

    methods(Static,Hidden)
        function obj=loadobj(s)
            if isfield(s,'ClassNameForLoadTimeEval')
                obj=eval(s.ClassNameForLoadTimeEval);
                obj.loadCPPObjectData(obj,s);
            else


                obj=s;
            end
        end

        function loadCPPObjectData(obj,s)

            wasLocked=isfield(s,'SuperClassData')&&~isempty(s.SuperClassData);
            superClassData=[];

            if isfield(s,'SuperClassData')
                superClassData=s.SuperClassData;
                loadSystemObjectData(obj,superClassData);
            end

            if isfield(s,'ChildClassData')
                loadObjectImpl(obj,s.ChildClassData,wasLocked);
            else



                if isfield(s,'MajorVersionNumber')&&...
                    isfield(s,'MinorVersionNumber')&&...
                    s.MajorVersionNumber==1&&...
                    (s.MinorVersionNumber==1||s.MinorVersionNumber==2)
                    fn=fieldnames(s);
                    for ii=1:length(fn)
                        if~isempty(regexp(fn{ii},'^Custom\w*DataType$','once'))&&...
                            iscell(s.(fn{ii}))
                            s.(fn{ii})=numerictype(s.(fn{ii}){:});
                        end
                    end
                end

                rfn={'MajorVersionNumber','MinorVersionNumber',...
                'EnumList','ClassNameForLoadTimeEval',...
                'SuperClassData'};%#ok<*EMCA>
                s=rmfield(s,intersect(fieldnames(s),rfn));
                loadObjectImpl(obj,s,wasLocked);
            end

            if isfield(s,'SuperClassData')

                loadSFunctionObjectData(obj,superClassData);
            end
        end
        function y=hasEmptyGeneratedTerminateFcn(~)




            y=false;
        end
        function y=allocatePortBuffersInCodegen




            y=false;
        end
    end

    methods(Hidden)
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
        function s=getCompiledFixedPointInfo(obj,~)

            tmpStruct=getCompiledDataInfo(obj,'all');




            fn=fieldnames(tmpStruct);
            for idx=1:numel(fn)
                s.(fn{idx})=numerictype(tmpStruct.(fn{idx}));
            end
        end
    end

    methods(Access=protected)
        function obj=cloneImpl(other)
            s=saveobj(other);
            obj=other.loadobj(s);
        end
    end

    methods(Access=protected)
        function varargout=isInputDirectFeedthroughImpl(obj,varargin)

            [varargout{1:nargout}]=isInputDirectFeedthroughImpl@matlab.system.SystemAdaptor(obj,varargin{:});
        end
        function out=getDiscreteStateImpl(~)
            out=struct();
            matlab.system.internal.error('MATLAB:system:getDiscreteStateNotSupported');
        end
        function out=getContinuousStateImpl(~)
            out=0;
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

