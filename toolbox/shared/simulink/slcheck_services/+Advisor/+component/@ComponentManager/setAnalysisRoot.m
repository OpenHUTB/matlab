












function setAnalysisRoot(this,root,type)
    p=inputParser();
    validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
    p.addRequired('root',validationFcn);
    p.addRequired('type',@(x)(isa(x,'Advisor.component.Types')));
    p.parse(root,type);







    [rootCompID,actualType]=...
    Advisor.component.ComponentManager.parseAnalysisRoot(...
    root,type);



    type=actualType;


    modelName=bdroot(root);

    if isstring(modelName)
        modelName=char(modelName);
    end

    if isstring(rootCompID)
        rootCompID=char(rootCompID);
    end



    if Simulink.harness.isHarnessBD(modelName)&&~this.SingleComponentMode







        DAStudio.error('Advisor:base:Components_HarnessRootNotSupported');

    else




        if type~=Advisor.component.Types.Model



            file=Advisor.component.getComponentFile(modelName,...
            Advisor.component.Types.Model);
        else
            file=Advisor.component.getComponentFile(rootCompID,type);
        end

    end


    if~isempty(file)

        if type~=Advisor.component.Types.Model
            this.CreateSubHierarchy=true;
        end


        [arootCompID,aType]=...
        Advisor.component.ComponentManager.parseAnalysisRoot(...
        bdroot(root),'Model');

        if aType~=type
            if~this.AnalyzeLibraries&&~strcmpi(get_param(root,'LinkStatus'),'none')


                DAStudio.error('Advisor:base:Components_LibraryRoot',root);
            end
        end


        this.AnalysisRoot=root;
        this.AnalysisRootComponentID=rootCompID;
        this.AnalysisRootFile=file;
        this.AnalysisRootType=type;
        this.AbstractRootID=arootCompID;
        this.AbstractRootIDType=aType;
    else
        DAStudio.error('Advisor:base:Components_RootNotOnPath');
    end
end