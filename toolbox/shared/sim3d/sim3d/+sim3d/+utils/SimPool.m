classdef SimPool













    methods(Static=true,Access=private)
        function out=pool(action,Mdl,blk,varargin)
            mlock;
            persistent p;
            if isempty(p)
                p=containers.Map;
            end

            if~isempty(Mdl)
                if~isKey(p,Mdl)
                    p(Mdl)=containers.Map;
                end
                pMdl=p(Mdl);
            end
            switch action
            case 'reset'
                if isKey(p,Mdl)
                    remove(p,Mdl);
                end
                out=[];
            case 'next'
                ActorType=varargin{1};
                if~isKey(pMdl,ActorType)
                    pMdl(ActorType)=sim3d.utils.ActorGroupObj(ActorType);
                end
                ActorGroup=pMdl(ActorType);
                if isKey(pMdl,'Custom')
                    ActorGroup.addNewActor(blk,pMdl('Custom'));
                else
                    ActorGroup.addNewActor(blk,[]);
                end
                out.Tag=[ActorType,num2str(pMdl(ActorType).LastActor.ID)];
                out.ID=num2str(pMdl(ActorType).LastActor.ID);
            case 'add'
                ActorType=varargin{1};
                ID=varargin{2};
                if~isKey(pMdl,ActorType)
                    pMdl(ActorType)=sim3d.utils.ActorGroupObj(ActorType);
                end
                ActorGroup=pMdl(ActorType);
                ActorGroup.addActor(blk,ID);
                out=[];
            case 'addCustom'
                ActorTag=varargin{1};
                if~isKey(pMdl,'Custom')
                    pMdl('Custom')=sim3d.utils.ActorGroupObj('Custom');
                end
                ActorGroup=pMdl('Custom');
                ActorGroup.addCustomActor(blk,ActorTag);
                out=[];
            case 'remove'
                ActorType=varargin{1};
                ID=varargin{2};
                if~isKey(pMdl,ActorType)

                else
                    ActorGroup=pMdl(ActorType);
                    ActorGroup.removeActor([ActorType,num2str(ID)]);
                    if isempty(ActorGroup.LastActor)
                        remove(pMdl,ActorType);
                    end
                    if isempty(pMdl)
                        remove(p,Mdl);
                    end
                end
                out=[];
            case 'removeCustom'
                ActorTag=varargin{1};
                if isKey(pMdl,'Custom')
                    ActorGroup=pMdl('Custom');
                    ActorGroup.removeCustomActor(ActorTag);
                end
                out=[];
            case 'exist'
                ActorType=varargin{1};
                ID=varargin{2};
                if~isKey(pMdl,ActorType)
                    out=false;
                else
                    ActorGroup=pMdl(ActorType);
                    if~isKey(ActorGroup.Actors,[ActorType,ID])
                        out=false;
                    else
                        out=true;
                    end
                end
            case 'existCustom'
                ActorTag=varargin{1};
                out=false;
                if isKey(pMdl,'Custom')
                    ActorGroup=pMdl('Custom');
                    out=ActorGroup.exist(ActorTag,blk);
                end
            case 'existCustomBlk'
                ActorTag=varargin{1};
                out=false;
                if isKey(pMdl,'Custom')
                    ActorGroup=pMdl('Custom');
                    out=ActorGroup.existBlk(ActorTag,blk);
                end
            case 'getList'
                ActorType=varargin{1};
                if isKey(pMdl,ActorType)
                    ActorGroup=pMdl(ActorType);
                    nActors=length(ActorGroup.Actors);
                    out=cell(1,nActors);
                    currActor=ActorGroup.LastActor;
                    for i=1:nActors
                        out{nActors+1-i}=currActor.ActorTag;
                        currActor=currActor.Prev;
                    end
                else
                    out={};
                end
                if isempty(out)
                    out={};
                end

            case 'disp'
                MdlKeys=p.keys;
                for i=1:length(MdlKeys)

                    MdlGroup=p(MdlKeys{i});
                    if isempty(MdlGroup)||~bdIsLoaded(MdlKeys{i})
                        remove(p,MdlKeys{i});
                    else
                        fprintf('\n%s:',MdlKeys{i});
                        GroupKeys=MdlGroup.keys;
                        for j=1:length(GroupKeys)
                            ActorGroup=MdlGroup(GroupKeys{j});
                            fprintf('\n    %s:',ActorGroup.ActorType);
                            for k=1:length(ActorGroup.Actors)
                                ActorKeys=ActorGroup.Actors.keys;
                                Actor=ActorGroup.Actors(ActorKeys{k});
                                fprintf('\n       %d:%s(%s)',Actor.ID,Actor.ActorTag,Actor.Blk);
                            end
                            fprintf('\n');
                        end
                    end
                end
                out=[];
            case 'cleanCustom'
                ActorTag=varargin{1};
                ActorGroup=pMdl('Custom');
                nActors=length(ActorGroup.Actors);
                currActor=ActorGroup.LastActor;
                for i=1:nActors
                    Prev=currActor.Prev;
                    if strcmp(blk,currActor.Blk)&&~strcmp(ActorTag,currActor.ActorTag)
                        ActorGroup.removeCustomActor(currActor.ActorTag);
                    end
                    currActor=Prev;
                end
                out=[];
            case 'getBlock'
                ActorType=varargin{1};
                ActorTag=varargin{2};
                out='';
                if isKey(pMdl,ActorType)
                    ActorGroup=pMdl(ActorType);
                    if isKey(ActorGroup.Actors,ActorTag)
                        Actor=ActorGroup.Actors(ActorTag);
                        out=Actor.Blk;
                    end
                end
            end
        end
    end
    methods(Static=true,Hidden=true)
        function reset(blk)
            if~bdIsLibrary(bdroot(blk))
                Mdl=bdroot(blk);
                [~]=sim3d.utils.SimPool.pool('reset',Mdl,blk);
            end
        end
        function ActorTag=next(Mdl,blk,ActorType)
            ActorTag=sim3d.utils.SimPool.pool('next',Mdl,blk,ActorType);
        end
        function ActorTag=add(Mdl,blk,ActorType,ID)
            if~sim3d.utils.SimPool.exist(Mdl,blk,ActorType,ID)
                ActorTag=sim3d.utils.SimPool.pool('add',Mdl,blk,ActorType,ID);
            end
        end
        function disp()
            [~]=sim3d.utils.SimPool.pool('disp',[],[]);
        end
        function ActorName(Mdl,blk,ActorType,ID)
            [~]=sim3d.utils.SimPool.pool('ActorName',Mdl,blk,ActorType,ID);
        end
        function out=exist(Mdl,blk,ActorType,ID)
            out=sim3d.utils.SimPool.pool('exist',Mdl,blk,ActorType,ID);
        end
        function list=getActorList(Mdl,ActorType)
            list=sim3d.utils.SimPool.pool('getList',Mdl,[],ActorType);
        end
        function remove(Mdl,blk,ActorType,ID)
            [~]=sim3d.utils.SimPool.pool('remove',Mdl,blk,ActorType,ID);
        end
        function copyCallback(blk)
            type=get_param(blk,'ActorType');
            if strcmp(type,'Sim3dActor')
                world=sim3d.World.getWorld(string(bdroot(blk)));
                if~isempty(world)
                    world.delete();
                end
                operation=get_param(blk,'Operation');
                if~(strcmp('Create at setup',operation))
                    return;
                end
            end
            if~bdIsLibrary(bdroot(blk))
                set_param(blk,'ActorTag','','ActorName','','ID','');
            end
        end
        function preDeleteCallback(blk)
            if~bdIsLibrary(bdroot(blk))
                Mdl=bdroot(blk);
                ActorType=get_param(blk,'ActorType');
                ActorTag=get_param(blk,'ActorTag');
                ID=get_param(blk,'ID');

                if sim3d.utils.SimPool.isCustomTag(ActorTag,ActorType)
                    [~]=sim3d.utils.SimPool.pool('removeCustom',Mdl,blk,ActorTag);
                elseif sim3d.utils.SimPool.exist(Mdl,blk,ActorType,ID)
                    [~]=sim3d.utils.SimPool.pool('remove',Mdl,blk,ActorType,ID);
                end

            end
        end
        function DestroyCallback(blk)
            lib=strsplit(blk,'/');
            if~strcmp(lib{1},'built-in')
                sim3d.utils.SimPool.preDeleteCallback(blk)
            end
        end
        function UndoDeleteCallback(blk)
            type=get_param(blk,'ActorType');
            if strcmp(type,'Sim3dActor')
                operation=get_param(blk,'Operation');
                if~(strcmp('Create at setup',operation))
                    return;
                end
            end
            sim3d.utils.SimPool.addActorTag(blk);
        end
        function loadCallback(blk)
            type=get_param(blk,'ActorType');
            if strcmp(type,'Sim3dActor')
                operation=get_param(blk,'Operation');
                if~(strcmp('Create at setup',operation))
                    return;
                end
            end
            sim3d.utils.SimPool.addActorTag(blk);
        end
        function nameChangeCallback(blk)
            type=get_param(blk,'ActorType');
            if strcmp(type,'Sim3dActor')
                operation=get_param(blk,'Operation');
                if~(strcmp('Create at setup',operation))
                    return;
                end
            end
            sim3d.utils.SimPool.loadCallback(blk);
        end
        function postSaveCallback(blk)
            type=get_param(blk,'ActorType');
            if strcmp(type,'Sim3dActor')
                operation=get_param(blk,'Operation');
                if~(strcmp('Create at setup',operation))
                    return;
                end
            end
            sim3d.utils.SimPool.addActorTag(blk);
        end
        function addActorTag(blk)



            if~bdIsLibrary(bdroot(blk))
                Mdl=bdroot(blk);
                ActorName=get_param(blk,'ActorName');
                ActorTag=get_param(blk,'ActorTag');
                ActorType=get_param(blk,'ActorType');
                ID=get_param(blk,'ID');
                switch sim3d.utils.SimPool.getStatus(blk)
                case 'AddDefault'
                    ActorTag=sim3d.utils.SimPool.next(Mdl,blk,ActorType);
                    set_param(blk,'ActorName',ActorTag.Tag,'ActorTag',ActorTag.Tag,'ID',ActorTag.ID);
                case 'AddNew'
                    if sim3d.utils.SimPool.isCustomTag(ActorName,ActorType)
                        sim3d.utils.SimPool.pool('addCustom',Mdl,blk,ActorName);
                    else
                        sim3d.utils.SimPool.pool('add',Mdl,blk,ActorType,str2double(ID));
                    end
                case 'Refresh'
                    if sim3d.utils.SimPool.isCustomTag(ActorName,ActorType)
                        if sim3d.utils.SimPool.isCustomTag(ActorTag,ActorType)
                            sim3d.utils.SimPool.pool('removeCustom',Mdl,blk,ActorTag);
                        else
                            sim3d.utils.SimPool.pool('remove',Mdl,blk,ActorType,ID);
                        end
                        sim3d.utils.SimPool.pool('addCustom',Mdl,blk,ActorName);
                        set_param(blk,'ActorTag',ActorName,'ID','C');
                    else
                        if sim3d.utils.SimPool.isCustomTag(ActorTag,ActorType)
                            sim3d.utils.SimPool.pool('removeCustom',Mdl,blk,ActorTag);
                        else
                            sim3d.utils.SimPool.pool('remove',Mdl,blk,ActorType,ID);
                        end
                        ID=ActorName(length(ActorType)+1:end);
                        sim3d.utils.SimPool.pool('add',Mdl,blk,ActorType,ID);
                        set_param(blk,'ActorTag',ActorName,'ID',ID);
                    end
                case 'Skip'
                case 'Error'
                    error('%s is already being used. Use a different name.',ActorName);
                otherwise
                    error('%s is not valid case',sim3d.utils.SimPool.getStatus(blk));
                end

            end
        end
        function out=checkTag(Mdl,blk,ActorTag)

            out=false;
            checkType='SimulinkVehicle';
            nType=length(checkType);
            if nType<length(ActorTag)&&strcmp('SimulinkVehicle',ActorTag(1:nType))
                ID=str2double(ActorTag(nType+1:end));
                if isnan(ID)||ID<=0||floor(ID)~=ID
                    out=true;
                else
                    out=~sim3d.utils.SimPool.pool('exist',Mdl,blk,checkType,num2str(ID));
                end
            end
        end
        function actorBlk=getActorBlock(blk,ActorType,ActorTag)
            Mdl=bdroot(blk);
            actorBlk=sim3d.utils.SimPool.pool('getBlock',Mdl,blk,ActorType,ActorTag);
        end
        function out=getStatus(blk)
            Mdl=bdroot(blk);
            ActorName=get_param(blk,'ActorName');
            ActorTag=get_param(blk,'ActorTag');
            ActorType=get_param(blk,'ActorType');
            ID=get_param(blk,'ID');
            ActorBlk=sim3d.utils.SimPool.getActorBlock(blk,ActorType,ActorTag);
            if isempty(ActorBlk)
                ActorBlk=sim3d.utils.SimPool.getActorBlock(blk,'Custom',ActorTag);
            end
            if isempty(ActorName)&&isempty(ActorTag)&&isempty(ID)

                out='AddDefault';

            elseif strcmp(ActorName,ActorTag)


                if isempty(ActorBlk)

                    out='AddNew';
                elseif strcmp(blk,ActorBlk)

                    out='Skip';
                else

                    out='Refresh';
                end
            else

                poolBlk=[sim3d.utils.SimPool.getActorBlock(blk,ActorType,ActorName),sim3d.utils.SimPool.getActorBlock(blk,'Custom',ActorName)];
                if isempty(poolBlk)
                    out='Refresh';
                elseif strcmp(blk,poolBlk)

                    out='Skip';
                else

                    out='Error';
                end
            end
        end
        function out=isCustomTag(ActorTag,ActorType)

            if length(ActorTag)<=length(ActorType)||~strcmp(ActorTag(1:length(ActorType)),ActorType)
                out=true;
            else
                ActorTagPostfix=str2double(ActorTag(length(ActorType)+1:end));
                if isnan(ActorTagPostfix)||ActorTagPostfix<=0||floor(ActorTagPostfix)~=ActorTagPostfix
                    out=true;
                else
                    out=false;
                end
            end

        end
    end

end
