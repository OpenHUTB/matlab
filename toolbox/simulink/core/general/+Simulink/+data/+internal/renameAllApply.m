function renameAllApply(context,type,oldname,newname,varargin)














    if isequal(oldname,newname)
        return;
    end

    [context,findVarsArguments]=checkAndSetRenameAllEnvironment(context,type,newname,varargin);


    ed=DAStudio.EventDispatcher;
    broadcastEvent(ed,'MESleepEvent');
    cleanupWake=onCleanup(@()broadcastEvent(ed,'MEWakeEvent'));




    varUsages=getVariableUsages(context,oldname,findVarsArguments);




    for i=1:length(varUsages)
        varUsage=varUsages(i);
        validateVariableUsageForRename(varUsage,oldname,newname);
        if strcmp(varUsage.SourceType,'model workspace')
            validateModelWSVarDefinition(varUsage,newname);
        else
            validateGlobalWSVarDefinition(context,varUsage,oldname,newname);
        end
    end




    for i=1:length(varUsages)
        varUsage=varUsages(i);
        wks=getWorkspace(varUsage);





        if isa(wks,'Simulink.data.dictionary.Section')
            entry='';
            entries=wks.getEntry(oldname);
            for j=1:numel(entries)
                if strcmp(entries(j).DataSource,varUsage.Source)
                    entry=entries(j);
                end
            end

            assert(~isempty(entry));
            value=entry.getValue;
            validateValueForRename(value);


            entry.Name=newname;
        else
            value=evalin(wks,oldname);
            validateValueForRename(value);
            if isa(wks,'Simulink.ModelWorkspace')
                model=varUsage.Source;
                prevOrderedFlag=get_param(model,'OrderedModelArguments');
                oldModelArgs=get_param(model,'ParameterArgumentNames');


                wks.renameVariable(oldname,newname);
            else

                assignin(wks,newname,value);


                clearCmd=['clear ',oldname,';'];
                evalin(wks,clearCmd);
            end
        end





        Simulink.renameVarImpl(varUsage,newname);




        if isequal(varUsage.SourceType,'model workspace')&&isequal(prevOrderedFlag,'on')
            newModelArgs=Simulink.internal.replaceID(oldModelArgs,oldname,newname);
            set_param(model,'OrderedModelArguments',prevOrderedFlag);
            set_param(model,'ParameterArgumentNames',newModelArgs);
        end


        usageDetails=varUsage.DirectUsageDetails;
        for j=1:length(usageDetails)
            detail=usageDetails(j);
            props=detail.Properties;
            exprs=detail.Expressions;
            assert(isequal(size(props),size(exprs)));
            for k=1:length(props)
                prop=props{k};
                expr=exprs{k};

                switch(detail.UsageType)

                case 'Block'
                    blockH=get_param(detail.Identifier,'Handle');
                    searchAllLevels=true;
                    if Stateflow.SLUtils.isStateflowBlock(blockH)
                        assert(isequal(expr,oldname));
                        if isa(value,'Simulink.DataType')
                            Stateflow.Refactor.renameDataTypeForBlock(...
                            blockH,oldname,newname);
                        else
                            Stateflow.Refactor.renameDataAndRefactorUsagesForBlock(...
                            blockH,oldname,newname,searchAllLevels);
                        end
                    elseif~isempty(prop)





                        if strcmp(get_param(blockH,'BlockType'),'ModelReference')
                            paramExpr=expr;
                        else
                            paramExpr=get_param(blockH,prop);
                        end
                        Simulink.updateReferenceInBlockParam(blockH,prop,paramExpr,oldname,newname,detail.Identifier);
                    end


                case 'Port'
                    assert(isequal(expr,oldname));



                    hPort=find_system(varUsage.Users,'FindAll','on',...
                    'SearchDepth','0','Type','port','Name',oldname);

















                    for m=1:length(hPort)
                        set_param(hPort(m),prop,newname);
                    end




                case 'Variable'
                    varWks=getWorkspace(detail.Identifier);
                    varName=detail.Identifier.Name;
                    if(evalin(varWks,['isa(',varName,', ''Simulink.ConfigSet'')']))
                        prevExpr=evalin(varWks,['get_param(',varName,', ''',prop,''' )']);
                        newExpr=Simulink.internal.replaceID(prevExpr,oldname,newname);
                        varCmd=['set_param(',varName,', ''',prop,''', ''',newExpr,''');'];
                    else
                        prevExpr=evalin(varWks,[varName,'.',prop]);
                        if isa(prevExpr,'Simulink.data.Expression')
                            newExpr=Simulink.internal.replaceID(prevExpr.ExpressionString,oldname,newname);
                            varCmd=[varName,'.',prop,'=slexpr(''',newExpr,''');'];
                        else
                            newExpr=Simulink.internal.replaceID(prevExpr,oldname,newname);
                            varCmd=[varName,'.',prop,'=''',newExpr,''';'];
                        end
                    end
                    evalin(varWks,varCmd);



                case{'Configuration','VariantConfiguration'}
                    prevExpr=get_param(detail.Identifier,prop);
                    newExpr=Simulink.internal.replaceID(prevExpr,oldname,newname);
                    set_param(detail.Identifier,prop,newExpr);

                otherwise
                    assert(false,['Unsupported usage type: ',detail.UsageType]);
                end
            end
        end
    end

end





function[context,findVarsArguments]=checkAndSetRenameAllEnvironment(context,type,newname,findVarsArguments)

    if~iscell(context)
        context={context};
    end


    assert(isequal(type,'Variable'));


    if~isvarname(newname)
        DAStudio.error('Simulink:Data:RenameAllInvalidName',newname);
    end


    simStatus=get_param(bdroot(context),'SimulationStatus');
    if~all(strcmp(simStatus,'stopped'))
        DAStudio.error('Simulink:Data:RenameAllSimActive');
    end


    findVarsArguments=checkFindVarsArguments(findVarsArguments);
end

function findVarsArguments=checkFindVarsArguments(findVarsArguments)


    inputSources=extractSourceList(findVarsArguments);
    assert(~isempty(inputSources),'Property ''Source'' is empty.');



    globalSources=extractGlobalSources(inputSources);
    assertMsg=['Do not support renaming varialbe in both global workspace and model workspace'];
    assert(isempty(globalSources)||(numel(globalSources)==numel(inputSources)),assertMsg);




    index=find(strcmpi(findVarsArguments,'SearchReferencedModels'));
    assert(numel(index)<2);
    searchReferencedModels=~isempty(globalSources);
    if~isempty(index)
        findVarsArguments{index+1}=searchReferencedModels;
    else
        findVarsArguments{end+1}='SearchReferencedModels';
        findVarsArguments{end+1}=searchReferencedModels;
    end


    index=find(strcmpi(findVarsArguments,'FindUsedVars'));
    assert(numel(index)<2);
    if~isempty(index)
        assert(findVarsArguments{index+1}==true);
    end
end




function varUsages=getVariableUsages(context,oldname,findVarsArguments)

    renameGlbVar=isRenamingGlobalVars(findVarsArguments);
    if renameGlbVar
        varUsages=getGlobalVarUsages(context,oldname,findVarsArguments);
    else
        varUsages=getMWVarUsages(context,oldname,findVarsArguments);
    end


    if numel(varUsages)<1
        DAStudio.error('Simulink:Data:RenameAllNotFound',oldname);
    end

    if~renameGlbVar&&numel(varUsages)>1
        DAStudio.error('Simulink:Data:RenameAllMultipleMatches',oldname);
    end


    for i=1:numel(varUsages)
        varUsage=varUsages(i);
        if strcmpi(varUsage.SourceType,'mask workspace')
            DAStudio.error('Simulink:Data:RenameAllMaskVariable',...
            varUsage.Name,varUsage.Source);
        end
    end
end

function varUsages=getMWVarUsages(context,oldname,findVarsArguments)




    modelWSList=extractSourceList(findVarsArguments);

    index=find(strcmpi(findVarsArguments,'Source'));
    findVarsArguments{index}='SourceType';
    findVarsArguments{index+1}='model workspace';

    varUsagesUsed=Simulink.findVars(context,...
    'Name',@(name)strcmp(name,oldname),...
    findVarsArguments{:});


    findVarsArguments=setSearchMethodAsCached(findVarsArguments);
    varUsagesNotUsed=Simulink.findVars(context,...
    'Name',@(name)strcmp(name,oldname),...
    'FindUsedVars',false,...
    findVarsArguments{:});

    tmpVarUsages=[varUsagesUsed,varUsagesNotUsed];
    varUsages=[];
    for i=1:numel(tmpVarUsages)
        if ismember(tmpVarUsages(i).Source,modelWSList)
            varUsages=[varUsages,tmpVarUsages(i)];
        end
    end
end

function varUsages=getGlobalVarUsages(context,oldname,findVarsArguments)

    index=find(strcmpi(findVarsArguments,'Scope'),1);
    scope='';
    if~isempty(index)
        scope=findVarsArguments{index+1};
        findVarsArguments(index:(index+1))=[];
    end


    varUsed=Simulink.findVars(context,...
    'Name',@(name)strcmp(name,oldname),...
    findVarsArguments{:});

    findVarsArguments=setSearchMethodAsCached(findVarsArguments);
    try

        varNotUsed=Simulink.findVars(context,...
        'Name',@(name)strcmp(name,oldname),...
        'FindUsedVars',false,...
        findVarsArguments{:});
    catch
        varNotUsed=[];
    end

    varUsagesTmp=[varUsed,varNotUsed];


    if isempty(scope)&&~isempty(varUsagesTmp)
        for i=1:numel(varUsagesTmp)
            varUsage=varUsagesTmp(i);
            if strcmpi(varUsage.SourceType,'base workspace')
                isCfgset=evalin('base',['isa(',varUsage.Name,', ''Simulink.ConfigSet'')']);
                if isCfgset
                    scope='Configurations';
                else
                    scope='Design';
                end
                break;
            end
        end
        assert(~isempty(scope));
    end


    varUsages=[];
    for i=1:numel(varUsagesTmp)
        varUsage=varUsagesTmp(i);
        if strcmpi(varUsage.SourceType,'base workspace')
            varUsages=[varUsages,varUsage];
        else
            assert(strcmpi(varUsage.SourceType,'data dictionary'));
            if strcmp(varUsage.Scope,scope)
                varUsages=[varUsages,varUsage];
            end
        end
    end
end

function renamingGlobalVar=isRenamingGlobalVars(findVarsArguments)
    index=find(strcmpi(findVarsArguments,'SearchReferencedModels'));
    assert(numel(index)==1);
    renamingGlobalVar=(findVarsArguments{index+1}==true);
end

function findVarsArguments=setSearchMethodAsCached(findVarsArguments)
    cached='cached';
    searchMethod='SearchMethod';

    index=find(strcmpi(findVarsArguments,searchMethod));
    assert(numel(index)<2);

    if~isempty(index)
        findVarsArguments{index+1}=cached;
    else
        findVarsArguments{end+1}=searchMethod;
        findVarsArguments{end+1}=cached;
    end
end




function validateModelWSVarDefinition(varUsage,newname)
    wks=getWorkspace(varUsage);







    if doesVarExistInWorkspace(wks,newname)
        DAStudio.error('Simulink:Data:RenameAllAlreadyExists',newname);
    end




    model=varUsage.Source;
    if existsInGlobalScope(model,newname)
        DAStudio.error('Simulink:Data:RenameAllHidesExistingVar',newname);
    end

end


function validateGlobalWSVarDefinition(context,varUsage,oldname,newname)

    assert(strcmp(varUsage.SourceType,'base workspace')||...
    strcmp(varUsage.SourceType,'data dictionary'));
    assert(iscell(context));


    if slfeature('SLDataDictionaryDataScopeSimSystemOfSystems')==1
        validateDataDictForIndependentSys(context,varUsage,oldname,newname);
        return;
    elseif slfeature('SLDataDictionaryDataScopeSimSystemOfSystems')==2
        validateDataDictForEncapsulatedSys(context,varUsage,oldname,newname);
        return;
    end
    assert(slfeature('SLDataDictionaryDataScopeSimSystemOfSystems')==0);










    if isequal(varUsage.SourceType,'data dictionary')
        otherSourceType='base workspace';
    else
        otherSourceType='data dictionary';
    end

    newnameUsage=Simulink.findVars(context,...
    'Name',newname,...
    'SourceType',otherSourceType,...
    'SearchReferencedModels',false,...
    'SearchMethod','cached');
    if~isempty(newnameUsage)
        DAStudio.error('Simulink:Data:RenameAllClash',newname);
    end







    allowDupsInDataDictClosure=...
    slfeature('SLDataDictionaryDuplicateMode')>0||...
    slfeature('DuplicateModeForOneModelCompilation')==2;




    renameVarInBWS=strcmp(varUsage.SourceType,'base workspace');
    renameVarInDD=strcmp(varUsage.SourceType,'data dictionary');

    oldnameInBWS=isVarInBWS(oldname);
    newnameInBWS=isVarInBWS(newname);


    desgDataSec='Design Data';
    configSec='Configurations';
    otherDataSec='Other Data';

    oldnameDD='';
    oldnameSec='';
    if renameVarInDD
        oldnameDD=varUsage.Source;
        oldnameSec=varUsage.Scope;
        if strcmp(oldnameSec,'Design')
            oldnameSec=desgDataSec;
        end




        if strcmp(oldnameSec,otherDataSec)
            return;
        end
    end





    if renameVarInBWS&&newnameInBWS
        DAStudio.error('Simulink:Data:RenameAllAlreadyExists',newname);
    end





















    for i=1:numel(context)

        topMdl=context{i};


        models=find_mdlrefs(topMdl,'AllLevels',true,...
        'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

        oldname_in_mdlref_glb_scope=false;
        newname_in_mdlref_bws=false;
        newname_in_mdlref_dd=false;
        mdlref_dd_has_newname={};
        mdlref_dd_section_has_newname={};


        for j=1:numel(models)
            mdl=models{j};

            allDD={get_param(mdl,'DataDictionary')};
            if slfeature('SLLibrarySLDD')>0
                allDD=unique([allDD,slprivate('getAllDictionariesOfLibrary',mdl)]);
            end


            configSetAccessor=Simulink.data.ConfigSetAccessor.create(mdl);


            for k=1:numel(allDD)
                mdlAccessToDD=~isempty(allDD{k});
                mdlAccessToBWS=modelAccessToBWS(mdl);


                oldnameInDDVisibleToMdl=isDataDictionaryInClosure(oldnameDD,allDD{k},oldname,oldnameSec);

                newnameInDDVisibleToMdl=false;
                newnameSecs={};
                ddHasNewname='';
                if mdlAccessToDD

                    dataAccessor=Simulink.data.DataAccessor.createForOutputData(allDD{k});
                    varIds=dataAccessor.identifyByName(newname);
                    if numel(varIds)>=1
                        newnameSecs{end+1}=desgDataSec;%#ok
                    end


                    ddIndexFromConfig=0;
                    csIds=configSetAccessor.identifyByName(newname,false);
                    for ii=1:numel(csIds)
                        if strcmp(csIds(ii).getDataSourceFriendlyName,allDD{k})
                            newnameSecs{end+1}=configSec;%#ok
                            ddIndexFromConfig=ii;
                        end
                    end

                    newnameInDDVisibleToMdl=~isempty(newnameSecs);
                    if newnameInDDVisibleToMdl
                        if numel(varIds)
                            ddHasNewname=varIds.getDataSourceFriendlyName;
                        else
                            if ddIndexFromConfig
                                ddHasNewname=csIdsFromConfig(ddIndexFromConfig).getDataSourceFriendlyName;
                            end
                        end
                    end
                end

                oldnameInBWSVisibleToMdl=(mdlAccessToBWS&&oldnameInBWS);
                newnameInBWSVisibleToMdl=(mdlAccessToBWS&&newnameInBWS);
                assert(~(oldnameInBWSVisibleToMdl&&newnameInBWSVisibleToMdl));




                newname_in_same_dd_sec=oldnameInDDVisibleToMdl&&...
                newnameInDDVisibleToMdl&&...
                ismember(oldnameSec,newnameSecs);
                if newname_in_same_dd_sec&&~allowDupsInDataDictClosure
                    assert(~isempty(ddHasNewname));
                    DAStudio.error('Simulink:Data:RenameAllAlreadyExists',newname);
                end




                name_clash=(oldnameInBWSVisibleToMdl&&newnameInDDVisibleToMdl)||...
                (oldnameInDDVisibleToMdl&&newnameInBWSVisibleToMdl);
                if name_clash
                    DAStudio.error('Simulink:Data:RenameAllClash',newname);
                end





                oldname_in_mdlref_glb_scope=oldname_in_mdlref_glb_scope||...
                oldnameInDDVisibleToMdl||...
                oldnameInBWSVisibleToMdl;
                newname_in_mdlref_bws=newname_in_mdlref_bws||...
                newnameInBWSVisibleToMdl;
                newname_in_mdlref_dd=newname_in_mdlref_dd||...
                newnameInDDVisibleToMdl;

                if newname_in_mdlref_dd
                    if~isempty(ddHasNewname)
                        mdlref_dd_has_newname=union(mdlref_dd_has_newname,ddHasNewname);
                        mdlref_dd_section_has_newname=union(mdlref_dd_section_has_newname,newnameSecs);
                    end
                end

                if oldname_in_mdlref_glb_scope&&newname_in_mdlref_bws
                    DAStudio.error('Simulink:Data:RenameAllExistsInBaseWS',newname);
                end

                if oldname_in_mdlref_glb_scope&&newname_in_mdlref_dd
                    if renameVarInBWS||(renameVarInDD&&ismember(oldnameSec,mdlref_dd_section_has_newname))
                        assert(~isempty(mdlref_dd_has_newname));
                        DAStudio.error('Simulink:Data:RenameAllExistsInDict',newname,mdlref_dd_has_newname{1});
                    end
                end
            end
        end
    end
end


function validateDataDictForIndependentSys(context,varUsage,oldname,newname)
    assert(slfeature('SLDataDictionaryDataScopeSimSystemOfSystems')==1);
    assert(iscell(context));


    newnameInBWS=isVarInBWS(newname);
    if strcmp(varUsage.SourceType,'base workspace')
        if newnameInBWS
            DAStudio.error('Simulink:Data:RenameAllExistsInBaseWS',newname);
        else

            return;
        end
    end



    assert(strcmp(varUsage.SourceType,'data dictionary'));

    desgDataSec='Design Data';
    configSec='Configurations';
    section=varUsage.Scope;
    if strcmp(section,'Design')
        section=desgDataSec;
    end
    assert(strcmp(section,desgDataSec)||strcmp(section,configSec));

    for i=1:numel(context)
        sources=getAllGlobalDataSources(context{i});

        for j=1:numel(sources)

            if strcmp(sources{j},'base')
                continue;
            end



            dd=Simulink.data.dictionary.open(sources{j});
            wks=dd.getSection(section);

            oldnameFound=wks.exist(oldname);
            newnameFound=wks.exist(newname);

            if~oldnameFound&&~newnameFound
                continue;
            end

            oldnameInGivenDD=false;
            if oldnameFound
                entryForOldname=wks.getEntry(oldname);
                assert(numel(entryForOldname)==1);

                oldnameInGivenDD=strcmp(varUsage.Source,entryForOldname.DataSource);
            end

            if oldnameInGivenDD&&newnameFound
                entryForNewname=wks.getEntry(newname);
                assert(numel(entryForNewname)==1);
                DAStudio.error('Simulink:Data:RenameAllExistsInDict',...
                newname,entryForNewname.DataSource);
            end
        end
    end
end


function validateDataDictForEncapsulatedSys(context,varUsage,oldname,newname)
    assert(slfeature('SLDataDictionaryDataScopeSimSystemOfSystems')==2);
    assert(iscell(context));

    renameVarFromBWS=strcmp(varUsage.SourceType,'base workspace');
    renameVarFromDD=strcmp(varUsage.SourceType,'data dictionary');


    oldnameInBWS=isVarInBWS(oldname);
    newnameInBWS=isVarInBWS(newname);
    if renameVarFromBWS&&newnameInBWS
        DAStudio.error('Simulink:Data:RenameAllExistsInBaseWS',newname);
    end

    desgDataSec='Design Data';
    configSec='Configurations';
    if renameVarFromBWS


        sections={desgDataSec,configSec};
    else
        assert(renameVarFromDD);


        sections={varUsage.Scope};
        if isequal(sections{1},'Design')
            sections{1}=desgDataSec;
        end
        assert(strcmp(sections{1},desgDataSec)||strcmp(sections{1},configSec));
    end


    for i=1:numel(context)
        sources=getAllGlobalDataSources(context{i});

        oldname_in_mdlref_glb_scope=ismember('base',sources)&&oldnameInBWS;
        newname_in_mdlref_bws=ismember('base',sources)&&newnameInBWS;
        newname_in_mdlref_dd=false;

        for j=1:numel(sources)
            src=sources{j};
            if strcmp(src,'base')
                continue;
            end

            dd=Simulink.data.dictionary.open(src);
            for k=1:numel(sections)
                wks=dd.getSection(sections{k});

                oldnameFound=wks.exist(oldname);
                newnameFound=wks.exist(newname);

                if~oldnameFound&&~newnameFound
                    continue;
                end

                oldnameInGivenDD=false;
                if oldnameFound
                    entryForOldname=wks.getEntry(oldname);
                    assert(numel(entryForOldname)==1);

                    oldnameInGivenDD=strcmp(varUsage.Source,entryForOldname.DataSource);
                end

                if oldnameInGivenDD&&newnameFound
                    entryForNewname=wks.getEntry(newname);
                    assert(numel(entryForNewname)==1);
                    DAStudio.error('Simulink:Data:RenameAllExistsInDict',...
                    newname,entryForNewname.DataSource);
                end

                if~oldname_in_mdlref_glb_scope
                    oldname_in_mdlref_glb_scope=oldnameInGivenDD;
                end

                if~newname_in_mdlref_dd
                    newname_in_mdlref_dd=newnameFound;
                end

                if oldname_in_mdlref_glb_scope&&newname_in_mdlref_bws
                    DAStudio.error('Simulink:Data:RenameAllExistsInBaseWS',newname);
                end

                if oldname_in_mdlref_glb_scope&&newname_in_mdlref_dd
                    assert(~isemtpy(entryForNewname));
                    DAStudio.error('Simulink:Data:RenameAllExistsInDict',...
                    newname,entryForNewname.DataSource);
                end
            end

        end
    end

end









function validateVariableUsageForRename(varUsage,oldname,newname)

    unsupportedBlocks={};
    blocksAlreadyUsingNewName={};
    varsAlreadyUsingNewName={};
    protectedModels={};
    modelsWhoseConfigSetUsesNewName={};






    usageDetails=varUsage.DirectUsageDetails;
    for j=1:length(usageDetails)
        detail=usageDetails(j);
        props=detail.Properties;
        exprs=detail.Expressions;
        assert(isequal(size(props),size(exprs)));

        if any(strcmp(props,'Protected property'))



            model=detail.Identifier;
            protectedModels{end+1}=model;%#ok
        else
            for k=1:length(props)
                prop=props{k};
                expr=exprs{k};

                switch(detail.UsageType)

                case 'Block'
                    block=detail.Identifier;
                    blockH=get_param(block,'Handle');
                    if Stateflow.SLUtils.isStateflowBlock(blockH)


                        sfBlockType=get_param(block,'SFBlockType');
                        isValid=~isequal(sfBlockType,'Truth Table');
                    else
                        blockType=get_param(block,'BlockType');
                        blockObj=get_param(block,'Object');

                        isValid=false;
                        if isequal(blockType,'ModelReference')
                            dictBlock=get_param(block,'DictionaryBlock');
                            if~isempty(dictBlock)
                                if~isempty(dictBlock.Parameter{prop})
                                    isValid=true;
                                end
                            end
                        end

                        if~isValid




                            if slfeature('RenameVariable')>=2
                                isValid=...
                                (isempty(prop)&&isequal(blockType,'ModelReference'))||...
                                isprop(blockObj,prop);
                            else
                                isValid=...
                                (isempty(prop)&&isequal(blockType,'ModelReference'))||...
                                (isprop(blockObj,prop)&&...
                                isequal(get_param(blockH,prop),expr));
                            end
                        end
                    end

                    if~isValid
                        unsupportedBlocks{end+1}=block;%#ok
                    elseif willExistingVarHideRenamedVarFromBlock(varUsage,newname,block)
                        blocksAlreadyUsingNewName{end+1}=block;%#ok
                    end


                case 'Port'
                    assert(isequal(expr,oldname));
                    hPort=find_system(varUsage.Users,'FindAll','on',...
                    'SearchDepth','0','Type','port','Name',oldname);

                    for m=1:length(hPort)
                        assert(isequal(get_param(hPort(m),prop),oldname));

                        block=get_param(hPort(m),'Parent');
                        if willExistingVarHideRenamedVarFromBlock(varUsage,newname,block)
                            blocksAlreadyUsingNewName{end+1}=block;%#ok
                        end
                    end




                case 'Variable'




                    user=detail.Identifier;
                    assert(isa(user,'Simulink.VariableUsage'));


                    existingVarContextLevel=getResolvedVarContextLevel(newname,user);


                    newVarContextLevel=getVarUsageContextLevel(varUsage);
                    if existingVarContextLevel>newVarContextLevel
                        varsAlreadyUsingNewName{end+1}=user.Name;%#ok
                    end


                case{'Configuration','VariantConfiguration'}
                    model=detail.Identifier;



                    if willExistingVarHideRenamedVarFromBlock(varUsage,newname,model)
                        modelsWhoseConfigSetUsesNewName{end+1}=model;%#ok
                    end

                otherwise
                    assert(false,['Unsupported usage type: ',detail.UsageType]);
                end
            end
        end
    end


    errors=MException.empty;

    if~isempty(unsupportedBlocks)
        e=MException(message('Simulink:Data:RenameAllUnsupportedBlocks'));
        e=addNamesAsCauses(e,unsupportedBlocks);
        errors(end+1)=e;
    end

    if~isempty(blocksAlreadyUsingNewName)
        e=MException(message('Simulink:Data:RenameAllAlreadyUsedByBlock',...
        oldname,newname,newname));
        e=addNamesAsCauses(e,blocksAlreadyUsingNewName);
        errors(end+1)=e;
    end

    if~isempty(varsAlreadyUsingNewName)
        e=MException(message('Simulink:Data:RenameAllAlreadyUsedByVar',...
        oldname,newname,newname));
        e=addNamesAsCauses(e,varsAlreadyUsingNewName);
        errors(end+1)=e;
    end

    if~isempty(protectedModels)
        e=MException(message('Simulink:Data:RenameAllProtectedModel'));
        e=addNamesAsCauses(e,protectedModels);
        errors(end+1)=e;
    end

    if~isempty(modelsWhoseConfigSetUsesNewName)
        e=MException(message('Simulink:Data:RenameAllAlreadyUsedByConfigSet',...
        oldname,newname,newname));
        e=addNamesAsCauses(e,modelsWhoseConfigSetUsesNewName);
        errors(end+1)=e;
    end

    if~isempty(errors)
        if isscalar(errors)
            throw(errors);
        else
            combinedError=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
            for i=1:length(errors)
                combinedError=combinedError.addCause(errors(i));
            end
            throw(combinedError);
        end
    end

end




function result=willExistingVarHideRenamedVarFromBlock(...
    varUsage,...
    newname,...
    block)


    existingVarContextLevel=getSlResolveContextLevel(newname,block);


    newVarContextLevel=getVarUsageContextLevel(varUsage);

    result=(existingVarContextLevel>newVarContextLevel);

end












function contextLevel=getSlResolveContextLevel(name,block)

    [context,isResolved]=...
    slResolve(name,block,'context','startUnderMask');
    if isResolved
        switch context
        case 'Global'

            contextLevel=1;
        case 'Model'

            contextLevel=2;
        otherwise

            maskObj=get_param(context,'Object');
            assert(maskObj.isMasked);
            contextLevel=3;
        end
    else

        contextLevel=0;
    end

end





function contextLevel=getResolvedVarContextLevel(name,usageContext)
    sourceType=usageContext.SourceType;
    if isequal(sourceType,'base workspace')||...
        isequal(sourceType,'data dictionary')

        wks=getWorkspace(usageContext);
        if doesVarExistInWorkspace(wks,name)

            contextLevel=1;
        else

            contextLevel=0;
        end
    else

        model=usageContext.Source;
        contextLevel=getSlResolveContextLevel(name,model);
    end
end



function contextLevel=getVarUsageContextLevel(varUsage)
    switch varUsage.SourceType
    case{'base workspace','data dictionary'}
        contextLevel=1;
    case 'model workspace'
        contextLevel=2;
    case 'mask workspace'
        contextLevel=3;
    otherwise
        assert(false,['Unrecognized VariableUsage.SourceType ''',...
        varUsage.SourceType,'''']);
    end
end



function exception=addNamesAsCauses(...
    ex,...
    names)

    names=unique(names);
    for i=1:length(names)
        blk=names{i};
        cause=MException(message('Simulink:SLMsgViewer:EXCEPTION_MSG',blk));
        ex=ex.addCause(cause);
    end
    exception=ex;
end







function validateValueForRename(value)
    if isa(value,'Simulink.data.dictionary.EnumTypeDefinition')












        DAStudio.error('Simulink:Data:RenameAllEnumNotSupported');
    end
end

function wks=getWorkspace(varUsage)

    switch varUsage.SourceType
    case 'base workspace'
        wks='base';
    case 'model workspace'
        wks=get_param(varUsage.Source,'ModelWorkspace');
    case 'data dictionary'
        dd=Simulink.data.dictionary.open(varUsage.Source);
        section=varUsage.Scope;
        if isequal(section,'Design')
            section='Design Data';
        end
        wks=dd.getSection(section);
    case 'mask workspace'
        DAStudio.error('Simulink:Data:RenameAllMaskVariable',...
        varUsage.Name,varUsage.Source);
    otherwise
        assert(false,['Unknown VariableUsage.SourceType ''',varUsage.SourceType,'''']);
    end

end

function result=doesVarExistInWorkspace(...
    wks,...
    varName)
    if ischar(wks)
        cmd=['exist(''',varName,''', ''var'')'];
        result=evalin(wks,cmd);
    elseif isa(wks,'Simulink.ModelWorkspace')
        result=wks.hasVariable(varName);
    elseif isa(wks,'Simulink.data.dictionary.Section')
        result=wks.exist(varName);
    else
        assert(false);
    end

end


function result=extractSourceList(args)
    result={};
    sources='';

    for i=1:length(args)
        if strcmp(args{i},'Source')
            sources=args{i+1};
            break;
        end
    end

    if isempty(sources)
        return;
    end

    c=strsplit(sources,'|');
    for i=1:length(c)
        tok=c{i};
        if tok(1)=='^'&&tok(end)=='$'
            tok=tok(2:end-1);
        end
        result{end+1}=tok;
    end
end

function result=extractGlobalSources(sources)
    assert(iscell(sources));

    result={};
    for i=1:numel(sources)
        src=sources{i};
        if strcmpi(src,'base workspace')
            result{end+1}=src;
        else
            [~,~,ext]=fileparts(src);

            if strcmp(ext,'.sldd')
                result{end+1}=src;
            end
        end
    end
end


function result=extractScope(args)
    result='';
    for i=1:length(args)
        if strcmp(args{i},'Scope')
            result=args{i+1};
            return;
        end
    end
end

function sources=getAllGlobalDataSources(topModel)
    sourceSet=containers.Map;
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        systems=find_mdlrefs(bdroot(topModel),...
        'IncludeProtectedModels',true,'MatchFilter',@Simulink.match.codeCompileVariants);
    else
        systems=find_mdlrefs(bdroot(topModel),...
        'IncludeProtectedModels',true,'Variants','ActivePlusCodeVariants');
    end

    for j=1:length(systems)
        try
            model=bdroot(systems{j});



            dict=get_param(model,'DataDictionary');
            if~isempty(dict)
                sourceSet(dict)=[];
            end

            if modelAccessToBWS(model)
                sourceSet('base')=[];
            end
        catch ex




            if~strcmp(ex.identifier,'Simulink:LoadSave:InvalidBlockDiagramName')
                rethrow(ex);
            end
        end
    end
    sources=sourceSet.keys;
end

function result=modelAccessToBWS(mdl)
    result=strcmpi(get_param(mdl,'HasAccessToBaseWorkspace'),'on');
end

function result=isVarInBWS(varname)
    result=evalin('base',['exist(''',varname,''', ''var'')']);
end

function isInClosure=isDataDictionaryInClosure(dictName,topDictName,oldname,section)
    isInClosure=false;

    if isempty(dictName)||isempty(topDictName)
        return;
    end

    ddObj=Simulink.data.dictionary.open(topDictName);
    secObj=ddObj.getSection(section);
    if secObj.exist(oldname)
        entriesForOldname=secObj.getEntry(oldname);
        for i=1:numel(entriesForOldname)

            if strcmp(dictName,entriesForOldname(i).DataSource)
                isInClosure=true;
                break;
            end
        end
    end
    ddObj.close();

end



