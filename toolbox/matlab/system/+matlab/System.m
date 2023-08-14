classdef(Abstract)System<matlab.system.SystemInterface&matlab.system.SystemProp













    methods(Access=protected)
        function dc=inputDimensionConstraint(~,varargin)
            dc=matlab.system.InputDimensionConstraint(varargin{:});
        end
        function dc=outputDimensionConstraint(~,varargin)
            dc=matlab.system.OutputDimensionConstraint(varargin{:});
        end
    end

    methods(Access=private,Static)
        function name=matlabCodegenRedirect(target)
            coder.allowpcode('plain');
            if strcmp(target,'hdl')||strcmp(target,'Dvo')
                name='matlab.system.hdlcoder.System';
            else
                name='matlab.system.coder.System';
            end
        end
    end

    methods(Static,Sealed,Hidden)
        function obj=loadObject(s)

            if isfield(s,'ClassNameForLoadTimeEval')



                loadMethod=sprintf('%s.loadobj',s.ClassNameForLoadTimeEval);
                obj=feval(loadMethod,s);
            else
                obj=loadobj(s);
            end
        end

        function s=saveObject(obj)
            s=saveobj(obj);
        end

        function obj=loadobj(s)
            if isfield(s,'ClassNameForLoadTimeEval')
                obj=feval(s.ClassNameForLoadTimeEval);
                if isa(obj,'matlab.system.CoreBlockSystem')||...
                    isa(obj,'matlab.system.SFunSystem')
                    matlab.system.SFunSystem.loadCPPObjectData(obj,s);
                    return;
                end
                promotedState=[];
                if isfield(s,'SuperClassData')
                    if isfield(s.SuperClassData,'isInMATLABSystemBlock')
                        obj.isInMATLABSystemBlock=s.SuperClassData.isInMATLABSystemBlock;
                    end
                    promotedState=loadSystemObjectData(obj,s.SuperClassData);
                end
                wasLocked=isfield(s,'SuperClassData')&&~isempty(s.SuperClassData)&&...
                isfield(s.SuperClassData,'Locked')&&~isempty(s.SuperClassData.Locked)&&...
                s.SuperClassData.Locked==true;
                if isfield(s,'ChildClassData')
                    if isstruct(s.ChildClassData)&&~isempty(promotedState)&&isstruct(promotedState)
                        names=fieldnames(promotedState);
                        for n=1:numel(names)
                            if~isfield(s.ChildClassData,names{n})
                                s.ChildClassData.(names{n})=promotedState.(names{n});
                            end
                        end
                    end
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
                    'EnumList','ClassNameForLoadTimeEval'};
                    s=rmfield(s,intersect(fieldnames(s),rfn));
                    loadObjectImpl(obj,s,wasLocked);
                end
                restoreLockStatus(obj,wasLocked);
            else


                obj=s;
            end
        end
    end

    methods(Hidden,Sealed)
        function a=saveobj(obj)









            childClassData=saveObjectImpl(obj);
            if isLocked(obj)&&isFullSaveLoadEnabled(obj,childClassData)
                if obj.getSaveLoadNotImplementedWarnStatus
                    warning(message('MATLAB:system:saveObjectImplNotImplemented',class(obj)));
                end
            end

            a.ClassNameForLoadTimeEval=class(obj);

            [a.MajorVersionNumber,a.MinorVersionNumber]=getVersionNumber(obj);

            a.ChildClassData=childClassData;
            if isFullSaveLoadEnabled(obj,a.ChildClassData)
                a.SuperClassData=saveSystemObjectData(obj);
            end

            if isfield(a.ChildClassData,'SaveLockedData')
                a.ChildClassData=rmfield(a.ChildClassData,'SaveLockedData');
            end

            if isfield(a,'SuperClassData')&&~isempty(a.SuperClassData)
                a.SuperClassData.isInMATLABSystemBlock=obj.isInMATLABSystemBlock;
            elseif isfield(a.ChildClassData,'isInMATLABSystemBlock')
                a.ChildClassData.isInMATLABSystemBlock=obj.isInMATLABSystemBlock;
            end
        end

        function flag=isInputSizeMutable(obj,i)
            flag=logical(isInputSizeMutableImpl(obj,i));
        end
    end


    methods(Hidden,Sealed,Access=public)

        function flag=getExecPlatformIndex(obj)
            flag=obj.isInMATLABSystemBlock;
        end
        function setExecPlatformIndex(obj,flag)
            obj.isInMATLABSystemBlock=flag;
        end
    end

    methods(Access=protected)
        function obj=cloneImpl(other)
            s=saveobj(other);
            obj=other.loadobj(s);
        end
    end

    methods(Hidden)









        function[glList,glMethods]=getGlobalsForFunctions(~)
            glList={};
            glMethods={};
        end
    end
end
