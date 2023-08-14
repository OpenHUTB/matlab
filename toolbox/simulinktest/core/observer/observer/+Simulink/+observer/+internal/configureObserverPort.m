function configureObserverPort(obsPrtBlkH,observedObjectType,blockHdlList,objSpec,uiMode,varargin)



















    if nargin==6
        topMdl=varargin{1};
    elseif nargin==5
        topMdl=[];
    elseif nargin<5
        uiMode=false;
        topMdl=[];
    end
    blockNodeStr='';
    obsRefBlk=get_param(bdroot(obsPrtBlkH),'ObserverContext');
    obsPrtName=getfullname(obsPrtBlkH);
    obsMdl=get_param(bdroot(obsPrtBlkH),'Name');
    blkTypeMsgStr=DAStudio.message('Simulink:SltBlkMap:ObserverPort');

    try
        if isempty(obsRefBlk)
            DAStudio.error('Simulink:Observer:CannotConfigureStandaloneObserverPort',obsPrtName,obsMdl);
        end

        if isempty(topMdl)
            topMdl=get_param(bdroot(obsRefBlk),'Name');
        end

        currModel=topMdl;
        visitedModels={currModel};
        for i=1:numel(blockHdlList)
            if~strcmp(currModel,get_param(bdroot(blockHdlList(i)),'Name'))
                DAStudio.error('Simulink:Observer:CannotObserveThruInvalidRefMdl',obsPrtName,getfullname(blockHdlList(i-1)));
            end
            currObsCtx=get_param(currModel,'CoSimContext');
            if~isempty(currObsCtx)&&strcmp(bdroot(currObsCtx),topMdl)
                if strcmp(currModel,obsMdl)
                    DAStudio.error('Simulink:SltBlkMap:CannotMapToEntityInsideContextMdlItself',blkTypeMsgStr,obsPrtName,currModel);
                else
                    DAStudio.error('Simulink:SltBlkMap:CannotMapToEntityInsideAnotherContextMdl',blkTypeMsgStr,obsPrtName,currModel);
                end
            end
            if i~=numel(blockHdlList)
                if~strcmp(get_param(blockHdlList(i),'BlockType'),'ModelReference')
                    DAStudio.error('Simulink:Observer:InvalidObserverPortConfig');
                end
                currModel=get_param(blockHdlList(i),'ModelName');
                if ismember(currModel,visitedModels)
                    DAStudio.error('Simulink:SltBlkMap:CannotMapToEntityWithCircularPath',blkTypeMsgStr,obsPrtName,currModel);
                end
                visitedModels{end+1}=currModel;%#ok<AGROW>
            end
            sidFullStr=Simulink.observer.internal.getSIDFullStringAllocateIfNeeded(get_param(currModel,'Handle'),blockHdlList(i));
            blockNodeStr=[blockNodeStr,'|',sidFullStr];%#ok<AGROW>
        end

        switch observedObjectType
        case 'Outport'
            blkPrts=get_param(blockHdlList(end),'PortHandles');
            if objSpec<1||objSpec>numel(blkPrts.Outport)
                msg=message('Simulink:SltBlkMap:InvalidMappedOutportIndex',...
                blkTypeMsgStr,obsPrtName,num2str(objSpec),getfullname(blockHdlList(end)),num2str(numel(blkPrts.Outport)));
                ME=MSLException(msg);
                ME.throw();
            end
            objSpec=['|',num2str(objSpec)];
        case 'SFState'
            if slfeature('ObserverSFSupport')==0
                DAStudio.error('Simulink:Observer:ObserverSFSupportFeatureNotOn');
            end
            actType=objSpec{1};
            ssid=objSpec{2};
            if~ismember(actType,{'Self','Child','Leaf'})
                DAStudio.error('Simulink:Observer:InvalidObserverPortConfig');
            end
            switch actType
            case 'Self'
                actTypeStr='Self activity';
            case 'Child'
                actTypeStr='Child activity';
            case 'Leaf'
                actTypeStr='Leaf state activity';
            end
            if isempty(ssid)
                stateId=sfprivate('block2chart',blockHdlList(end));
                if stateId==0
                    DAStudio.error('Simulink:SltBlkMap:InvalidMappedStateSSID',...
                    blkTypeMsgStr,obsPrtName,getfullname(blockHdlList(end)));
                end
                stateObj=idToHandle(sfroot,stateId);
                objName=stateObj.Name;
                if strcmp(actType,'Self')
                    DAStudio.error('Simulink:SltBlkMap:CannotMapToStateflowChartSelf',...
                    blkTypeMsgStr,obsPrtName,getfullname(blockHdlList(end)));
                elseif strcmp(stateObj.Decomposition,'PARALLEL_AND')
                    DAStudio.error('Simulink:SltBlkMap:CannotMapToStateflowChartParallelChildren',...
                    blkTypeMsgStr,obsPrtName,actTypeStr,getfullname(blockHdlList(end)));
                end
            else
                stateObj=sfprivate('ssIdToHandle',[':',ssid],blockHdlList(end));
                if isempty(stateObj)
                    DAStudio.error('Simulink:SltBlkMap:InvalidMappedStateSSID',...
                    blkTypeMsgStr,obsPrtName,getfullname(blockHdlList(end)));
                end
                objName=stateObj.Name;
                if isa(stateObj,'Stateflow.State')
                    if~strcmp(actType,'Self')&&strcmp(stateObj.Decomposition,'PARALLEL_AND')
                        DAStudio.error('Simulink:SltBlkMap:CannotMapToStateflowStateParallelChildren',...
                        blkTypeMsgStr,obsPrtName,actTypeStr,objName,getfullname(blockHdlList(end)));
                    end
                elseif isa(stateObj,'Stateflow.AtomicSubchart')
                    if~strcmp(actType,'Self')
                        chartBlkH=sfprivate('chart2block',stateObj.Subchart.Id);
                        pos=strfind(blockNodeStr,'|');
                        blockNodeStr=[blockNodeStr(1:pos(end)),get_param(chartBlkH,'SIDFullString')];
                        ssid='';
                    end
                elseif isa(stateObj,'Stateflow.SimulinkBasedState')
                    if~strcmp(actType,'Self')
                        DAStudio.error('Simulink:SltBlkMap:CannotMapToSimulinkStateChildren',...
                        blkTypeMsgStr,obsPrtName,actTypeStr,objName,getfullname(blockHdlList(end)));
                    end
                else
                    DAStudio.error('Simulink:SltBlkMap:InvalidMappedStateSSID',...
                    blkTypeMsgStr,obsPrtName,getfullname(blockHdlList(end)));
                end
            end
            objSpec=['|',actType,'|',ssid];
        case 'SFData'
            if slfeature('ObserverSFSupport')==0
                DAStudio.error('Simulink:Observer:ObserverSFSupportFeatureNotOn');
            end
            dataObj=sfprivate('ssIdToHandle',[':',objSpec],blockHdlList(end));
            if isempty(dataObj)||~isa(dataObj,'Stateflow.Data')||(~strcmp(dataObj.Scope,'Local')&&~strcmp(dataObj.Scope,'Parameter'))
                DAStudio.error('Simulink:SltBlkMap:InvalidMappedLocalDataSSID',...
                blkTypeMsgStr,obsPrtName,getfullname(blockHdlList(end)));
            end
            objSpec=['|',objSpec];
        case 'BlockInternal'
            objSpec=['|',objSpec];
        otherwise
            DAStudio.error('Simulink:Observer:InvalidObserverPortConfig');
        end

        warnStat=warning('off','Simulink:Commands:LoadMdlParameterizedLink');
        warnCleanUp=onCleanup(@()warning(warnStat.state,'Simulink:Commands:LoadMdlParameterizedLink'));

        mapObj=struct('HierElement',struct('Type',observedObjectType,'BlockNodeStr',blockNodeStr(2:end),'Spec',objSpec));
        Simulink.observer.internal.configureObserverPortInternal(obsPrtBlkH,mapObj);
    catch ME
        Simulink.observer.internal.error(ME,uiMode,'Simulink:Observer:ObserverStage',obsMdl);
        return;
    end

end
