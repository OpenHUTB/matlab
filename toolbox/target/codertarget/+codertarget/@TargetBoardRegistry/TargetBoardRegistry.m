classdef(Sealed=true,Hidden)TargetBoardRegistry<matlab.mixin.SetGet




    properties(SetAccess='private')
        Tag;
        TargetBoards;
    end

    properties(SetAccess='private',GetAccess='private')
        FcnHandles={};
    end

    methods(Access='private')
        function This=TargetBoardRegistry
        end
    end

    methods(Access='public')
        function registerTargetBoards(reg,targetBoards)
            if isempty(targetBoards)
                return;
            end
            if(isa(targetBoards,'function_handle'))
                reg.addTargetBoards(targetBoards);
            elseif isa(targetBoards,'codertarget.targethardware.TargetHardwareRegEntry')
                for i=1:length(targetBoards)
                    reg.addTargetBoards(targetBoards(i));
                end
            else
                assert(false,'registerTargetBoards must take in arguments of type function_handle or codertarget.targethardware.TargetHardwaerRegEntry');
            end
        end
    end

    methods(Static=true,Hidden)
        function setSlTargetsLoadedState(value)
            codertarget.TargetBoardRegistry.manageSlTargetsLoadedState(value);
        end
        function out=isSimulinkInstalled()
            persistent simulinkInstalled;
            if isempty(simulinkInstalled)
                simulinkInstalled=license('test','SIMULINK')&&exist('sl_refresh_customizations','file');
            end
            out=simulinkInstalled;
        end
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
                    LocalStaticObj(Idx).Handle=codertarget.TargetBoardRegistry;
                    LocalStaticObj(Idx).Handle.Tag=Tag;
                end
                SingleObj=LocalStaticObj(Idx).Handle;
            case{'get'}
                if Idx==0
                    Idx=length(LocalStaticObj)+1;
                    LocalStaticObj(Idx).Handle=codertarget.TargetBoardRegistry;
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
        function out=getSlTargetsLoadedState()
            out=codertarget.TargetBoardRegistry.manageSlTargetsLoadedState();
        end
        function out=addToTargetBoardRegistry(func,varargin)
            out=codertarget.TargetBoardRegistry.manageInstance('getFast','CoderTargetBoard');
            out.registerTargetBoards(func);
        end
    end

    methods(Access='private',Static)
        function out=manageSlTargetsLoadedState(action)
            mlock;
            persistent slTgtsLoaded;
            if isempty(slTgtsLoaded)
                slTgtsLoaded=false;
            end
            if nargin==1
                switch action
                case true
                    slTgtsLoaded=true;
                case false
                    slTgtsLoaded=false;
                otherwise
                end
            end
            out=slTgtsLoaded;
        end
    end

    methods(Access='private')
        function idx=getTargetBoardIdx(reg,TargetBoardName)

            idx=[];
            for i=1:numel(reg.TargetBoards)
                if isequal(TargetBoardName,reg.TargetBoards(i).Name)
                    idx=i;
                    return;
                end
            end
        end
        function addTargetBoards(reg,targetBoards)
            if isa(targetBoards,'function_handle')
                addTargetBoardFcns(reg,targetBoards);
            else
                newTargetBoards=targetBoards;
                for i=1:numel(newTargetBoards)
                    if isempty(reg.TargetBoards)
                        reg.TargetBoards=newTargetBoards(i);
                    else
                        reg.TargetBoards=[reg.TargetBoards,newTargetBoards(i)];
                    end
                end
            end
        end
        function addTargetBoardFcns(reg,targetBoardName)
            if(~isa(targetBoardName,'function_handle'))
                if~ischar(targetBoardName)||isempty(which(targetBoardName))
                    return;
                end
                targetBoardName=str2func(targetBoardName);
            end
            if isTargetBoardRegistered(reg,targetBoardName)
                return;
            end
            reg.FcnHandles{end+1}=targetBoardName;
        end
        function runAllTargetFcns(reg)
            for ii=1:numel(reg.FcnHandles)
                newEntry=feval(reg.FcnHandles{ii});
                addTargetBoards(reg,newEntry);
            end

            reg.FcnHandles={};
        end
    end

    methods
        function set.TargetBoards(h,val)
            if isa(val,'codertarget.targethardware.TargetHardwareRegEntry')
                h.TargetBoards=val;
            elseif isempty(val)
                h.TargetBoards=[];
            end
        end
    end
end
