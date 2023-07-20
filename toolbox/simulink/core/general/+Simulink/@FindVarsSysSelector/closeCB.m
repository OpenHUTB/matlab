function closeCB(this,closeAction)




    switch lower(closeAction)
    case 'ok'

        rootStr='^Simulink Root/';




        userData=this.userData;
        mdl=regexprep(this.SelectedSystem,rootStr,'');
        searchRefMdls=this.SearchRefMdls;
        forceRecompile=this.RefreshVarUsage;
        if searchRefMdls
            searchRefMdls='yes';
        else
            searchRefMdls='no';
        end


        if strcmp(userData.SearchFcn,'renameAll')
            [~,~,isGlobalWS]=getSourceAndDDScope(userData);
            if isGlobalWS
                searchRefMdls='yes';
            else
                searchRefMdls='no';
            end
        end


        if~isempty(mdl)
            if strcmp(mdl,'Simulink Root')
                mdl=slroot;
            else
                mdlStr=regexp(mdl,'Simulink Root/(.*)','tokens');
                if isempty(mdlStr)
                    mdlName=mdl;
                else
                    mdlName=mdlStr{1}{1};
                end
                mdl=get_param(mdlName,'Object');

                if strcmp(get_param(mdlName,'Type'),'block')&&...
                    slprivate('is_stateflow_based_block',mdlName)
                    c=mdl.getHierarchicalChildren;
                    mdl=find(c,'-class','Stateflow.Chart');
                end
            end

            needCompileModels={};

            if(mdl==slroot)
                models=getAllModelsInRoot();
                for u=1:length(models)
                    if(forceRecompile||~hasModelCompiled(models{u},searchRefMdls))
                        needCompileModels{end+1}=getFullName(models{u});%#ok
                    end
                end
            else
                top_mdl=mdl;
                while~isa(top_mdl,'Simulink.BlockDiagram')
                    top_mdl=top_mdl.getParent;
                end

                if(forceRecompile||~hasModelCompiled(top_mdl,searchRefMdls))
                    needCompileModels{end+1}=getFullName(top_mdl);
                end

            end








            update='no';
            if forceRecompile
                update='yes';
            else
                if~isempty(needCompileModels)
                    if findVarsCompileQuestDialog(needCompileModels)
                        update='yes';
                    else

                        return;
                    end
                end
            end

            feval(userData.SearchFcn,userData,mdl,searchRefMdls,update);
        end

    case{'cancel','close'}
        this.SelectedSystem='';
    end
end



function meSearch(userData,mdl,searchRefMdls,update)%#ok

    if isempty(userData.ModelExplorer)
        userData.ModelExplorer=daexplr;
    end
    me=userData.ModelExplorer;


    me.view(mdl);



    am=DAStudio.ActionManager;
    regexp_action=am.createDefaultAction(me,'SEARCH_REGEXP');
    whole_action=am.createDefaultAction(me,'SEARCH_MATCHWHOLE');
    case_action=am.createDefaultAction(me,'SEARCH_MATCHCASE');

    orig_regexp=regexp_action.on;
    orig_whole=whole_action.on;
    orig_case=case_action.on;

    regexp_action.on='off';
    whole_action.on='on';
    case_action.on='on';


    me.search(getString(message('modelexplorer:DAS:ME_FOR_VARIABLE_USAGE')),...
    true,...
    userData.Workspace,...
    userData.Variable,...
    searchRefMdls,...
    update);

    regexp_action.on=orig_regexp;delete(regexp_action);
    whole_action.on=orig_whole;delete(whole_action);
    case_action.on=orig_case;delete(case_action);

end

function renameAll(userData,mdl,searchRefMdls,update)%#ok

    if mdl==slroot




        children=mdl.getChildren;
        models={};
        for u=1:length(children)
            if isa(children(u),'Simulink.BlockDiagram')
                bdType=...
                get_param(children(u).name,'BlockDiagramType');
                isModel=strcmpi(bdType,'model');
                isLibrary=strcmpi(bdType,'library');
                assert(isModel||isLibrary);
                if isModel
                    models{end+1}=children(u).getFullName;%#ok
                end
            end
        end
    else
        models=getFullName(mdl);
    end

    [source,ddScope,isVarInGlobalWS]=getSourceAndDDScope(userData);
    assert(isequal(searchRefMdls,'yes')||isequal(searchRefMdls,'no'));
    searchRefMdlsLogical=isequal(searchRefMdls,'yes');

    assert(isequal(update,'yes')||isequal(update,'no'));
    updateLogical=isequal(update,'yes');

    SLStudio.RenameVariableDialog.launch(models,...
    source,ddScope,userData.Variable,...
    searchRefMdlsLogical,updateLogical,isVarInGlobalWS);
end

function owner=getBlockDiagramOfModelDict(scope)
    scopeParent=scope.getParent;
    if~isa(scope,'Simulink.DataDictionaryScopeNode')||isempty(scopeParent)
        owner=slroot;
        return;
    end

    while~isa(scopeParent,'Simulink.BlockDiagram')&&scopeParent~=slroot
        scopeParent=scopeParent.getParent;
        if isempty(scopeParent)
            scopeParent=slroot;
            break;
        end
    end

    owner=scopeParent;
end

function models=getAllModelsInRoot
    root=slroot;
    children=root.getChildren;
    models={};

    for u=1:length(children)
        if isa(children(u),'Simulink.BlockDiagram')&&~children(u).isLibrary
            models{end+1}=children(u);%#ok
        end
    end
end



function hasCompiled=hasModelCompiled(model,searchRefMdls)
    if searchRefMdls


        [refMdls,~]=find_mdlrefs(getFullName(model),'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
        for i=1:numel(refMdls)
            try
                wks=get_param(refMdls{i},'ModelWorkspace');
            catch

                hasCompiled=false;
                return;
            end

            hasCompiled=wks.hasCachedVarUsageInfo;

            if~hasCompiled
                return;
            end
        end
    else

        wks=model.ModelWorkspace;
        hasCompiled=wks.hasCachedVarUsageInfo;
    end
end


function sortedAoS=structArraySort(aos)
    fields=fieldnames(aos);
    temp=struct2cell(aos);
    temp=permute(temp,[2,1]);
    temp=sortrows(temp,[5,1]);
    sortedAoS=cell2struct(temp,fields,2);
end

function[source,ddScope,isGlobalWS]=getSourceAndDDScope(userData)
    scope=userData.Scope;
    isGlobalWS=false;
    baseWSName='base workspace';
    if ischar(scope)
        if isempty(userData.Source)
            source=['^',scope,'$'];
            ddScope='';
            isGlobalWS=strcmp(scope,baseWSName);
        else
            source=userData.Source;
            ddScope=strtok(userData.Workspace);
            isGlobalWS=true;
        end
    elseif isa(scope,'DAStudio.WorkspaceNode')
        scopeParent=scope.getParent;
        if isa(scopeParent,"DAStudio.DAObjectProxy")
            scopeParent=scopeParent.getMCOSObjectReference;
        end
        if isa(scopeParent,'Simulink.BlockDiagram')
            source=scopeParent.Name;
        else
            source=baseWSName;
            isGlobalWS=true;
        end
        source=['^',source,'$'];
        ddScope='';
    else
        assert(isa(scope,'Simulink.DataDictionaryScopeNode'));
        isGlobalWS=true;
        scopeParent=getBlockDiagramOfModelDict(scope);
        if scopeParent~=slroot
            source=['^',scopeParent.name,'$'];
        else
            source=scope.getPossibleSources;
        end
        ddScope=strtok(userData.Workspace);
    end
end

