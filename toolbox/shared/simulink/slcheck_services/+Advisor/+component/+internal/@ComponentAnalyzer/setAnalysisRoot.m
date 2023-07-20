



function setAnalysisRoot(this,root)


    assert(root.ComponentType~=Advisor.component.Types.MFile,'Not supported at the moment');

    if exist(root.File,'file')~=4&&exist(root.File,'file')~=2

        DAStudio.error('Advisor:base:Components_RootFileNotFound',root.File);
    end


    tempComp=Advisor.component.Component();
    tempComp.ID=root.ComponentID;
    tempComp.Type=root.ComponentType;
    [obj,contextObj]=Advisor.component.getComponentSource(tempComp);



    if isempty(contextObj)
        modelName=bdroot(getfullname(obj.getFullName()));
    else

        modelName=bdroot(getfullname(contextObj.getFullName()));
    end

    if~strcmp(root.File,get_param(modelName,'FileName'))

        DAStudio.error('Advisor:base:Components_RootNotOnPathOrShadowed',root.File);
    end

    rootFullName=Advisor.component.getComponentPath(tempComp);

    if Simulink.harness.isHarnessBD(modelName)&&this.AnalysisOptions.isMultiFile







        DAStudio.error('Advisor:base:Components_HarnessRootNotSupported');
    end


    if root.ComponentType~=Advisor.component.Types.Model
        this.CreateSubHierarchy=true;


        [arootCompID,aType]=...
        Advisor.component.ComponentManager.parseAnalysisRoot(...
        modelName,'Model');

        if aType~=root.ComponentType
            if~this.AnalysisOptions.AnalyzeLibraries&&~strcmpi(get_param(rootFullName,'LinkStatus'),'none')


                DAStudio.error('Advisor:base:Components_LibraryRoot',rootFullName);
            end
        end

        this.AbstractAnalysisRoot.ComponentID=arootCompID;
        this.AbstractAnalysisRoot.ComponentType=aType;
    else
        this.AbstractAnalysisRoot.ComponentID=root.ComponentID;
        this.AbstractAnalysisRoot.ComponentType=root.ComponentType;
    end

    this.AbstractAnalysisRoot.File=root.File;
    this.AbstractAnalysisRoot.Name=this.AbstractAnalysisRoot.ComponentID;

    root.Name=rootFullName;
    this.AnalysisRoot=root;
end