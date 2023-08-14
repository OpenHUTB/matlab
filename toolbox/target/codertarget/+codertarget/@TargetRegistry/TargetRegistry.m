classdef(Sealed=true,Hidden)TargetRegistry<handle





    properties(SetAccess='private')
        Tag;
        Targets;
    end

    properties(SetAccess='private',GetAccess='private')
        FcnHandles={};
    end

    methods(Access='private')
        function This=TargetRegistry
        end
    end

    methods(Static=true,Hidden)
        function SingleObj=manageInstance(action,varargin)


            mlock;
            persistent LocalStaticObj;
            narginchk(1,2);
            Idx=0;
            if nargin>1
                Tag=varargin{1};
                for i=1:length(LocalStaticObj)
                    if isequal(Tag,LocalStaticObj(i).Handle.Tag)
                        Idx=i;
                        break;
                    end
                end
            else
                assert(isequal(action,'destroy'));
                Idx=-1;
            end
            switch action
            case{'create','getFast'}
                if Idx==0
                    Idx=length(LocalStaticObj)+1;
                    LocalStaticObj(Idx).Handle=codertarget.TargetRegistry;
                    LocalStaticObj(Idx).Handle.Tag=Tag;
                end
                SingleObj=LocalStaticObj(Idx).Handle;
            case{'get'}
                if Idx==0
                    Idx=length(LocalStaticObj)+1;
                    LocalStaticObj(Idx).Handle=codertarget.TargetRegistry;
                    LocalStaticObj(Idx).Handle.Tag=Tag;
                    if Idx==1
                        RTW.TargetRegistry.get();
                    end
                end
                SingleObj=LocalStaticObj(Idx).Handle;
                if~isempty(SingleObj.FcnHandles)
                    SingleObj.runAllTargetFcns();
                end
            case 'destroy'
                if Idx>0
                    LocalStaticObj(Idx)=[];
                elseif Idx<0
                    LocalStaticObj=[];
                end
                SingleObj=[];
            otherwise
                SingleObj=[];
                return;
            end
        end
    end

    methods(Static=true)
        function out=addToTargetRegistry(func,doNotAddOnSimulinkStartup)
            if nargin<2
                doNotAddOnSimulinkStartup=true;
            end
            out=codertarget.TargetRegistry.manageInstance('create','CoderTarget');
            out.registerTarget(func,doNotAddOnSimulinkStartup);
        end
    end
    methods(Access='private')
        function idx=getTargetIdx(reg,targetName)

            idx=[];
            for i=1:numel(reg.Targets)
                if isequal(targetName,reg.Targets(i).Name)
                    idx=i;
                    return;
                end
            end
        end
        function runAllTargetFcns(reg)
            for ii=1:numel(reg.FcnHandles)
                thisTarget=feval(reg.FcnHandles{ii});
                for jj=1:numel(thisTarget)
                    TargetName=thisTarget(jj).Name;
                    TargetFolder=thisTarget(jj).TargetFolder;
                    if isfield(thisTarget(jj),'ShortName')
                        ShortName=thisTarget(jj).ShortName;
                    else
                        ShortName='';
                    end
                    if isfield(thisTarget(jj),'TargetType')
                        TargetType=thisTarget(jj).TargetType;
                    else
                        TargetType=-1;






                    end
                    if isfield(thisTarget(jj),'TargetVersion')
                        TargetVersion=thisTarget(jj).TargetVersion;
                    else
                        TargetVersion=1;


                    end
                    ReferenceTargets={};
                    if isfield(thisTarget(jj),'ReferenceTargets')
                        ReferenceTargets=thisTarget(jj).ReferenceTargets;
                    end
                    AliasNames={};
                    if isfield(thisTarget(jj),'AliasNames')
                        AliasNames=thisTarget(jj).AliasNames;
                    end
                    if isTargetRegistered(reg,TargetName)
                        continue
                    end
                    len=length(reg.Targets);
                    reg.Targets(len+1).Name=TargetName;
                    reg.Targets(len+1).TargetFolder=TargetFolder;
                    reg.Targets(len+1).TargetType=TargetType;
                    reg.Targets(len+1).TargetVersion=TargetVersion;
                    reg.Targets(len+1).ReferenceTargets=ReferenceTargets;
                    reg.Targets(len+1).ShortName=ShortName;
                    reg.Targets(len+1).AliasNames=AliasNames;
                end
            end

            reg.FcnHandles={};
        end
    end

end
