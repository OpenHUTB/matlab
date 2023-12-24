function obsPrtBlks=addObserverPortsForSignalsInObserver(prtHdls,obs,showAndSelect,varargin)

    if iscell(prtHdls)
        blockPath=prtHdls{1};
        prtHdls=prtHdls{2};
    else
        blockPath=[];
    end
    obsPrtBlks=zeros(1,numel(prtHdls));
    obsPrtLines=zeros(1,numel(prtHdls));
    existingObsPrtBlks=Simulink.observer.internal.getObserverPortsInsideObserverModel(get_param(bdroot(obs),'Handle'));
    for j=1:numel(existingObsPrtBlks)
        obj=get_param(existingObsPrtBlks(j),'Object');
        obj.hilite('none');
    end
    pos=getNewObserverPortStartingPosition(obs);

    for j=1:numel(prtHdls)
        pos=pos+[0,50,0,50];
        prtH=prtHdls(j);
        blockArgs=["MakeNameUnique","on"];
        if isstruct(prtH)
            sfObjId=prtH.SFObj;
            sfObj=idToHandle(sfroot,sfObjId);
            if isa(sfObj,'Stateflow.Chart')||isa(sfObj,'Stateflow.ReactiveTestingTableChart')...
                ||isa(sfObj,'Stateflow.StateTransitionTableChart')||isa(sfObj,'Stateflow.TruthTableChart')
                actType=prtH.Spec;
                blkH=get_param(sfObj.getFullName,'Handle');
                obsPrtBlks(j)=add_block('sltestlib/ObserverPort',[obs,'/ObserverPort'],'Position',pos,blockArgs{:});
                Simulink.observer.internal.configureObserverPort(obsPrtBlks(j),'SFState',[blockPath',blkH']',{actType,''});
            else
                blkH=get_param(sfObj.Chart.getFullName,'Handle');
                ssid=num2str(sfObj.SSIdNumber);
                if isa(sfObj,'Stateflow.State')||isa(sfObj,'Stateflow.AtomicSubchart')||isa(sfObj,'Stateflow.SimulinkBasedState')
                    actType=prtH.Spec;
                    obsPrtBlks(j)=add_block('sltestlib/ObserverPort',[obs,'/ObserverPort'],'Position',pos,blockArgs{:});
                    Simulink.observer.internal.configureObserverPort(obsPrtBlks(j),'SFState',[blockPath',blkH']',{actType,ssid});
                elseif isa(sfObj,'Stateflow.Data')
                    obsPrtBlks(j)=add_block('sltestlib/ObserverPort',[obs,'/ObserverPort'],'Position',pos,blockArgs{:});
                    Simulink.observer.internal.configureObserverPort(obsPrtBlks(j),'SFData',[blockPath',blkH']',ssid);
                else
                    DAStudio.error('Simulink:Observer:InvalidObserverPortConfig');
                end
            end
        else
            if prtH~=-1
                if~strcmp(get_param(prtH,'PortType'),'outport')
                    DAStudio.error('Simulink:Observer:InvalidObserverPortConfig');
                end
                block=get_param(prtH,'Parent');
                prtIdx=get_param(prtH,'PortNumber');
                blkH=get_param(block,'Handle');
                if Simulink.observer.internal.isBlockInConditionalSubsystem(blkH)

                    pos=pos+[0,30,0,30];
                end
                obsPrtBlks(j)=add_block('sltestlib/ObserverPort',[obs,'/ObserverPort'],'Position',pos,blockArgs{:});
                Simulink.observer.internal.configureObserverPort(obsPrtBlks(j),'Outport',[blockPath',blkH']',prtIdx);
            else
                obsPrtBlks(j)=add_block('sltestlib/ObserverPort',[obs,'/ObserverPort'],'Position',pos,blockArgs{:});
            end
        end
        if~isempty(varargin)
            set_param(obsPrtBlks(j),varargin{:});
        end
        lineHandles=get_param(obsPrtBlks(j),"LineHandles");

        if lineHandles.Outport==-1

            portHandles=get_param(obsPrtBlks(j),'PortHandles');
            portPos=get_param(portHandles.Outport,'Position');
            obsPrtLines(j)=add_line(obs,[portPos;portPos+[120,0]]);
        else
            obsPrtLines(j)=lineHandles.Outport;
        end
    end

    objs=find_system(obs,'SearchDepth',1,'FindAll','on','Selected','on');
    arrayfun(@(x)set_param(x,'Selected','off'),objs);
    if showAndSelect
        for j=1:numel(prtHdls)
            set_param(obsPrtBlks(j),'Selected','on');
            set_param(obsPrtLines(j),'Selected','on');
        end
        if get_param(obs,'open')~="on"
            open_system(obs,'window');
        end
    end
end

function pos=getNewObserverPortStartingPosition(obs)
    existingObsPrtBlks=find_system(obs,'SearchDepth',1,'BlockType','ObserverPort');
    obsH=get_param(bdroot(obs),"Handle");


    conditionalObsPrtBlks=Simulink.observer.internal.getConditionalSubsystemObserverPortBlocks(obsH);
    partitions=arrayfun(@Simulink.observer.internal.partition.getPartitionFromObsPort,...
    conditionalObsPrtBlks,"UniformOutput",false);


    existingObsPrtBlks=[existingObsPrtBlks;partitions];
    if isempty(existingObsPrtBlks)

        pos=[0,0,45,26];
    else
        posArray=cell2mat(get_param(existingObsPrtBlks,'Position'));
        posArray=sortrows(posArray,4);
        xpos=posArray(end,1);
        ypos=posArray(end,4);
        obsPortHeight=26;

        pos=[xpos,ypos,xpos+45,ypos+obsPortHeight];
    end
end
