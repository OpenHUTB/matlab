function configureInjectorPort(injPrtBlkH,injectedObjectType,blockHdlList,spec,uiMode)

    if nargin<5
        uiMode=false;
    end
    blockNodeStr='';
    injRefBlk=get_param(bdroot(injPrtBlkH),'InjectorContext');
    injPrtName=getfullname(injPrtBlkH);
    injMdl=get_param(bdroot(injPrtBlkH),'Name');

    if strcmp(get_param(injPrtBlkH,'BlockType'),'InjectorInport')
        generalErrorID='Simulink:Injector:InvalidInjectorInportConfig';
        blkTypeMsgStr=DAStudio.message('Simulink:SltBlkMap:InjectorInport');
    else
        generalErrorID='Simulink:Injector:InvalidInjectorOutportConfig';
        blkTypeMsgStr=DAStudio.message('Simulink:SltBlkMap:InjectorOutport');
    end

    try
        if isempty(injRefBlk)
            DAStudio.error('Simulink:Injector:CannotConfigureStandaloneInjectorPort',injPrtName,injMdl);
        end

        topMdl=get_param(bdroot(injRefBlk),'Name');
        currModel=topMdl;
        visitedModels={currModel};
        for i=1:numel(blockHdlList)
            if~strcmp(currModel,get_param(bdroot(blockHdlList(i)),'Name'))
                DAStudio.error('Simulink:Injector:CannotWalkThruInvalidRefMdl',injPrtName,getfullname(blockHdlList(i-1)));
            end
            currInjCtx=get_param(currModel,'CoSimContext');
            if~isempty(currInjCtx)&&strcmp(bdroot(currInjCtx),topMdl)
                if strcmp(currModel,injMdl)
                    DAStudio.error('Simulink:SltBlkMap:CannotMapToEntityInsideContextMdlItself',blkTypeMsgStr,injPrtName,currModel);
                else
                    DAStudio.error('Simulink:SltBlkMap:CannotMapToEntityInsideAnotherContextMdl',blkTypeMsgStr,injPrtName,currModel);
                end
            end
            if i~=numel(blockHdlList)
                if~strcmp(get_param(blockHdlList(i),'BlockType'),'ModelReference')
                    DAStudio.error(generalErrorID);
                end
                currModel=get_param(blockHdlList(i),'ModelName');
                if ismember(currModel,visitedModels)
                    DAStudio.error('Simulink:SltBlkMap:CannotMapToEntityWithCircularPath',blkTypeMsgStr,injPrtName,currModel);
                end
                visitedModels{end+1}=currModel;%#ok<AGROW>
            end
            blockNodeStr=[blockNodeStr,'|',get_param(blockHdlList(i),'SIDFullString')];%#ok<AGROW>
        end

        switch injectedObjectType
        case 'Outport'
            blkPrts=get_param(blockHdlList(end),'PortHandles');
            if spec<1||spec>numel(blkPrts.Outport)
                msg=message('Simulink:SltBlkMap:InvalidMappedOutportIndex',...
                blkTypeMsgStr,injPrtName,num2str(spec),getfullname(blockHdlList(end)),num2str(numel(blkPrts.Outport)));
                ME=MSLException(msg);
                ME.throw();
            end
            objSpec=['|',num2str(spec)];
        otherwise
            DAStudio.error(generalErrorID);
        end

        warnStat=warning('off','Simulink:Commands:LoadMdlParameterizedLink');
        warnCleanUp=onCleanup(@()warning(warnStat.state,'Simulink:Commands:LoadMdlParameterizedLink'));

        mapObj=struct('HierElement',struct('Type',injectedObjectType,'BlockNodeStr',blockNodeStr(2:end),'Spec',objSpec));
        Simulink.injector.internal.configureInjectorPortInternal(injPrtBlkH,mapObj);
    catch ME
        Simulink.injector.internal.error(ME,uiMode,'Simulink:Injector:InjectorStage',injMdl);
        return;
    end

end

