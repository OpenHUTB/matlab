function displayInformer(this)


    am=Advisor.Manager.getInstance;
    allApplications=am.ApplicationObjMap.values;
    for i=1:length(allApplications)
        loopmdladvObj=allApplications{i}.getRootMAObj();
        if isa(loopmdladvObj,'Simulink.ModelAdvisor')&&...
            isprop(loopmdladvObj,'ResultGUI')&&...
            isa(loopmdladvObj.ResultGUI,'DAStudio.Informer')&&...
            strcmp(bdroot(loopmdladvObj.SystemName),bdroot(this.SystemName))&&...
            ~strcmp(loopmdladvObj.SystemName,this.SystemName)
            return;
        end
    end

    this.ShowInformer=true;
    setpref('modeladvisor','ShowInformer',this.ShowInformer);

    if~isempty(this.AdvisorWindow)
        selectedNode=this.AdvisorWindow.Controller.getCurrentTreeSelection;
    elseif isa(this.MAExplorer,'DAStudio.Explorer')
        me=this.MAExplorer;
        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
    end

    selectedNode.updateResultGUI;


    skipBringForeground=false;
    [fInfo1,~]=dbstack;
    for i=1:length(fInfo1)
        if~(isempty(strfind(fInfo1(i).file,'openModelAdvisorComplianceResultsInEditor'))&&...
            isempty(strfind(fInfo1(i).file,'openModelAdvisorResultsInEditor'))&&...
            isempty(strfind(fInfo1(i).file,'openModelAdvisorResultsComponent')))
            skipBringForeground=true;
            break;
        end
    end
    if~skipBringForeground
        open_system(this.SystemName);
    end
end