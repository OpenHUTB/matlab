function stateflowDataList=getStateflowDataListForVariant(bd,variant,commented)





    stateflowDataList=[];
    findSysOpts={};
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        if strcmpi(variant,'ActiveVariants')

            findSysOpts=[findSysOpts,'MatchFilter',{@Simulink.match.activeVariants}];
        elseif strcmpi(variant,'AllVariants')

            findSysOpts=[findSysOpts,'MatchFilter',{@Simulink.match.allVariants}];
        else

            [msg,id]=fxptui.message('incorrectInputVariantArgs');
            throw(MException(id,msg));
        end
    else
        findSysOpts=[findSysOpts,'Variants',variant];
    end
    findSysOpts=[findSysOpts,'IncludeCommented',commented,'MaskType','Stateflow'];
    stateflowSysList=find_system(bd.getFullName,findSysOpts{:});
    if isempty(stateflowSysList)
        return;
    end

    stateflowSysObjList=get_param(stateflowSysList,'Object');
    for i=1:length(stateflowSysObjList)
        stateflowSysObj=stateflowSysObjList{i};





        if strcmp(stateflowSysObj.Commented,'on')||...
            (strcmp(variant,'ActiveVariants')&&...
            strcmp(stateflowSysObj.CompiledIsActive,'off'))
            continue;
        end
        chartId=sfprivate('block2chart',stateflowSysObj.Handle);
        if(chartId>0)
            dataIds=sf('DataIn',chartId,false);
            newSFdata=idToHandle(sfroot,dataIds);

            newSFdata=newSFdata(~(arrayfun(@(x)(max(x.Machine.isLibrary)),newSFdata)));
            stateflowDataList=[stateflowDataList,(newSFdata(:))'];%#ok<AGROW>
        end
    end
end
