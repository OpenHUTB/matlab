function open(system,selection,suppressUI,suppressProjectDialog,parentModel)




















    if nargin>1&&~isempty(selection)
        if~ismember(selection,{'all','compile','noncompile','topmodel'})
            DAStudio.error('SimulinkUpgradeAdvisor:advisor:InvalidSelection');
        end
    else



        selection='';
    end

    if nargin<3||isempty(suppressUI)
        suppressUI=false;
    end

    if nargin<4||isempty(suppressProjectDialog)
        suppressProjectDialog=false;
    end

    isTestHarness=(nargin>4);


    if isTestHarness
        UpgradeAdvisor.load(parentModel);
        [~,parentModelName,~]=fileparts(parentModel);
        if strcmp(parentModelName,system)

            sysRoot=UpgradeAdvisor.load(system);
        else
            testHarnesses=Simulink.harness.internal.getHarnessList(parentModelName);

            allTestHarnessNames={testHarnesses.name};
            ind=ismember(allTestHarnessNames,system);
            if~any(ind)

                MSLDiagnostic('SimulinkUpgradeAdvisor:tasks:LooperMissingTestHarness',...
                system).reportAsWarning;
                return
            else
                thisHarness=testHarnesses(ind);
            end

            Simulink.harness.load(thisHarness.ownerFullPath,thisHarness.name);
            sysRoot=thisHarness.name;
        end
    else
        sysRoot=UpgradeAdvisor.load(system);
    end

    advisorsManager=Advisor.Manager.getInstance;
    currentAdvisors=advisorsManager.ApplicationObjMap.values;

    sysPath=get_param(sysRoot,'Filename');

    import matlab.internal.project.util.isFileInProject;
    projectMapper=matlab.internal.project.util.FileToProjectMapper(sysPath);









    if~suppressProjectDialog&&~suppressUI&&projectMapper.InAProject&&...
        ~isUpgradeAdvisorOpenForSystem(currentAdvisors,sysRoot)&&...
        (projectMapper.InALoadedProject||isFileInProject(sysPath,projectMapper.ProjectRoot))
        projectToClose=[];
        if~isempty(slproject.getCurrentProjects)&&~projectMapper.InRootOfALoadedProject
            currentProject=slproject.getCurrentProject;
            projectToClose=currentProject.Name;
        end
        if UpgradeAdvisor.askToOpenProjectUpgrade(sysPath,projectMapper.ProjectRoot,projectToClose)
            return;
        end
    end


    for jj=1:numel(currentAdvisors)
        thisAdvisor=currentAdvisors{jj};
        if thisAdvisor.isvalid&&strncmp(thisAdvisor.AdvisorId,...
            UpgradeAdvisor.UPGRADE_GROUP_ID,...
            numel(UpgradeAdvisor.UPGRADE_GROUP_ID))



            if~strcmp(thisAdvisor.AnalysisRoot,sysRoot)




                thisMAObj=thisAdvisor.getRootMAObj;
                thisMAExplorer=[];
                thisMAExplorerVisble=false;

                if isa(thisMAObj,'Simulink.ModelAdvisor')
                    thisMAExplorer=thisMAObj.MAExplorer;
                    if isa(thisMAExplorer,'DAStudio.Explorer')
                        thisMAExplorerVisble=thisMAObj.MAExplorer.isVisible;
                    end
                end

                if thisMAExplorerVisble
                    thisMAExplorer.hide;
                end
            end
        end
    end

    if isempty(selection)||strcmp(selection,'topmodel')

        if~hasChildren(sysRoot)
            selection='allExceptHierarchy';
        else

            selection='noncompile';
        end
    end

    try

        upgradeNode=UpgradeAdvisor.UPGRADE_GROUP_ID;

        resetShowProgressBarPreference=turnOffProgressBar(suppressUI);
        mdlAdvisor=Simulink.ModelAdvisor.getModelAdvisor(sysRoot,'new',upgradeNode);
        delete(resetShowProgressBarPreference);


        taskRoot=mdlAdvisor.TaskAdvisorRoot;
        if isempty(taskRoot)


            return
        end
        reorderChecks(mdlAdvisor,taskRoot);

        children=taskRoot.getAllChildren;
        checksNonCompile=getNonCompileChecks(mdlAdvisor,children);


        if~isempty(selection)
            selectChecks(children,checksNonCompile,selection);
        end

        if~suppressUI

            mdlAdvisor.TaskAdvisorRoot.updateStates('None');


            mdlAdvisor.displayExplorer;


            customizeTitle(mdlAdvisor);
            customizeToolbar(mdlAdvisor);


            selectRootNode(mdlAdvisor,upgradeNode);
        end

    catch exception
        if strcmp(exception.identifier,'MATLAB:badsubscript')
            disp(DAStudio.message('SimulinkUpgradeAdvisor:advisor:noTasks'));
        else
            rethrow(exception);
        end
    end

end

function resetShowProgressBarPreference=turnOffProgressBar(suppressUI)

    currentShowProgressBarPreference=mangeShowProgressBarPreference;
    resetShowProgressBarPreference=...
    onCleanup(@()mangeShowProgressBarPreference(currentShowProgressBarPreference));
    mangeShowProgressBarPreference(~suppressUI);
end

function out=mangeShowProgressBarPreference(in)
    mp=ModelAdvisor.Preferences;
    if nargin
        mp.ShowProgressbar=in;
    end
    if nargout
        out=mp.ShowProgressbar;
    end
end


function b=hasChildren(model)


    currentWarning=warning('off','Simulink:Commands:LoadingOlderModel');
    ResetWarning=onCleanup(@()warning(currentWarning));
    try
        b=false;



        modelRefs=find_mdlrefs(model,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'WarnForInvalidModelRefs',true,...
        'IgnoreVariantErrors',true);
        if numel(modelRefs)>1

            b=notUnderMLRoot(modelRefs(2:end));
            if b

                return
            end
        end




        libs=libinfo(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
        uniqueLibs=setdiff(unique({libs.Library}),'simulink');
        if~isempty(uniqueLibs)

            b=notUnderMLRoot(uniqueLibs);
            if b
                return
            end
        end


        refs=UpgradeAdvisor.internal.findSubsystemReferences(model);
        if~isempty(refs)
            b=notUnderMLRoot(refs);
            if b
                return
            end
        end


        testHarnesses=Simulink.harness.internal.getHarnessList(model);
        if~isempty(testHarnesses)
            b=notUnderMLRoot({testHarnesses(:).name});
        end
    catch E
        warning(E.identifier,'%s',E.message)
        b=true;
    end
    delete(ResetWarning);
end

function b=notUnderMLRoot(blockDiagrams)

    for jj=1:numel(blockDiagrams)
        [~,underMLRoot]=...
        UpgradeAdvisor.UpgradeLooper.notUnderMLRoot(blockDiagrams{jj});
        if~underMLRoot
            b=true;
            return
        end
    end

    b=false;
end


function selectRootNode(mdlAdvisor,upgradeNode)
    try
        explorer=mdlAdvisor.MAExplorer;
        nodeObj=mdlAdvisor.getTaskObj(upgradeNode);
        imme=DAStudio.imExplorer(explorer);
        imme.selectTreeViewNode(nodeObj);
    catch E
        warning(E.identifier,'%s',E.message)
    end
end


function reorderChecks(mdlAdvisor,taskRoot)
    checksNonCompile=getNonCompileChecks(mdlAdvisor,taskRoot.getAllChildren);
    targetIdx=length(taskRoot.getAllChildren);


    hierarchyIdx=getModelHierarchyCheck(taskRoot);
    swapChecks(mdlAdvisor,hierarchyIdx,targetIdx);

    resaveCheckIdx=getResaveCheck(taskRoot);
    swapChecks(mdlAdvisor,resaveCheckIdx,targetIdx-1);




    escapeIndex=1;
    while(sortingFinished(checksNonCompile,escapeIndex))
        checksNonCompile=getNonCompileChecks(mdlAdvisor,taskRoot.getAllChildren);
        compileChecks=~checksNonCompile;
        targetIdx=length(taskRoot.getAllChildren)-2;
        for idx=length(compileChecks)-2:-1:1
            if compileChecks(idx)
                swapChecks(mdlAdvisor,idx,targetIdx);
                targetIdx=targetIdx-1;
            end
        end
        checksNonCompile=getNonCompileChecks(mdlAdvisor,taskRoot.getAllChildren);
        escapeIndex=escapeIndex+1;
    end

    function B=sortingFinished(checksNonCompile,escapeIndex)

        notB=...
        length(checksNonCompile)>2&&...
        checksNonCompile(end)&&...
        checksNonCompile(end-1)&&...
        ~checksNonCompile(end-2)&&...
        checksNonCompile(1)&&...
        sum(abs(diff(checksNonCompile(1:end-2))))==1&&...
        (escapeIndex<numel(checksNonCompile));
        B=~notB;
    end

    if~(escapeIndex<numel(checksNonCompile))

        MSLDiagnostic('SimulinkUpgradeAdvisor:advisor:ReorderCheckAlgProblem').reportAsWarning
    end


    virtualBusUsageCheckIdx=getVirtualBusUsageCheck(taskRoot);




    firstCompileCheckIdx=1+find(diff(checksNonCompile)==-1);
    secondCompileCheckIdx=firstCompileCheckIdx+1;

    swapChecks(mdlAdvisor,virtualBusUsageCheckIdx,firstCompileCheckIdx);


    slupdateCheckIdx=getSlupdateCompileCheck(taskRoot);
    swapChecks(mdlAdvisor,slupdateCheckIdx,secondCompileCheckIdx);
end


function selectChecks(children,checksNonCompile,selection)
    switch selection
    case 'compile'
        checkSelection=~checksNonCompile;
        checkSelection(end)=true;
    case 'noncompile'
        checkSelection=checksNonCompile;
    case 'all'
        checkSelection=true(size(checksNonCompile));
    case 'allExceptHierarchy'
        checkSelection=true(size(checksNonCompile));
        checkSelection(end)=false;
    otherwise
        DAStudio.error('SimulinkUpgradeAdvisor:advisor:InvalidSelection');
    end

    for jj=1:numel(children)
        children{jj}.changeSelectionStatus(checkSelection(jj));
    end
end

function idxFound=getCheck(taskRoot,ID)
    children=taskRoot.getAllChildren;
    idxFound=[];
    for idx=1:numel(children)
        thisID=children{idx}.MAC;
        if strcmp(thisID,ID)
            idxFound=idx;
            return
        end
    end
end

function idx=getVirtualBusUsageCheck(taskRoot)
    idx=getCheck(taskRoot,'mathworks.design.VirtualBusUsage');
end

function idx=getModelHierarchyCheck(taskRoot)
    idx=getCheck(taskRoot,UpgradeAdvisor.UPGRADE_HIERARCHY_ID);
end

function idx=getResaveCheck(taskRoot)
    idx=getCheck(taskRoot,'mathworks.design.CheckSavedInCurrentVersion');
end

function idx=getSlupdateCompileCheck(taskRoot)
    idx=getCheck(taskRoot,'mathworks.design.UpdateRequireCompile');
end

function checks=getNonCompileChecks(mdlAdvisor,children)
    checkObjs=cellfun(@(x)mdlAdvisor.getCheckObj(x.MAC),children,'UniformOutput',false);
    checkCallback=cellfun(@(x)x.CallbackContext,checkObjs,'UniformOutput',false);
    checks=strcmp(checkCallback,'None');
end


function swapChecks(mdlAdvisor,sourceIdx,targetIdx)
    properties={'Children','AllChildrenIndex','ChildrenObj'};
    for n=1:length(properties)
        tmp=mdlAdvisor.TaskAdvisorRoot.(properties{n}){1,sourceIdx};
        mdlAdvisor.TaskAdvisorRoot.(properties{n}){1,sourceIdx}=mdlAdvisor.TaskAdvisorRoot.(properties{n}){1,targetIdx};
        mdlAdvisor.TaskAdvisorRoot.(properties{n}){1,targetIdx}=tmp;
    end
end


function customizeTitle(mdlAdvisor)
    upgradeAdvisorName=DAStudio.message('SimulinkUpgradeAdvisor:advisor:title');
    modelAdvisorName=DAStudio.message('Simulink:tools:MAModelAdvisor');
    mdlAdvisor.MAExplorer.Title=regexprep(mdlAdvisor.MAExplorer.Title,['^',modelAdvisorName],upgradeAdvisorName);
end


function customizeToolbar(mdlAdvisor)
    explorer=mdlAdvisor.MAExplorer;
    if(~isfield(explorer.UserData,'upgradeAction'))
        actionManager=DAStudio.ActionManager;

        action=actionManager.createAction(explorer);
        action.callback='UpgradeAdvisor.toggleNotifications';
        UpgradeAdvisor.updateNotificationButton(mdlAdvisor.System,action);

        explorer.UserData.upgradeAction=action;
        explorer.UserData.toolbar.addAction(action);
    end
end

function value=isUpgradeAdvisorOpenForSystem(openAdvisors,sysRoot)
    for jj=1:numel(openAdvisors)
        thisAdvisor=openAdvisors{jj};
        if thisAdvisor.isvalid&&...
            strcmp(thisAdvisor.AdvisorId,UpgradeAdvisor.UPGRADE_GROUP_ID)&&...
            strcmp(thisAdvisor.AnalysisRoot,sysRoot)
            thisMAObj=thisAdvisor.getRootMAObj;
            if isa(thisMAObj,'Simulink.ModelAdvisor')
                thisMAExplorer=thisMAObj.MAExplorer;
                if isa(thisMAExplorer,'DAStudio.Explorer')&&thisMAObj.MAExplorer.isVisible
                    value=true;
                    return;
                end
            end
        end
    end
    value=false;
end
