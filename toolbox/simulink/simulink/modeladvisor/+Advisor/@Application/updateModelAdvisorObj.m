


















function[maObj,status]=updateModelAdvisorObj(this,compId,isRoot)%#ok<INUSD> may need this later to tell the MA object that it is analysing a root model!
    status=0;

    if~this.CompId2MAObjIdxMap.isKey(compId)


        isRootOfAnalysis=strcmp(compId,this.AnalysisRootComponentId);




        maObj=Simulink.ModelAdvisor();
        maObj.initSchemaData();




        maObj.ApplicationID=this.ID;

        Simulink.ModelAdvisor.getActiveModelAdvisorObj(maObj);

...
...
...
...
...
...
...
...




        if this.MultiMode&&~isempty(this.ComponentManager)
            comp=this.ComponentManager.getComponent(compId);
            compInfo.compID=comp.ID;
            compInfo.compType=comp.Type;
            compInfo.SID=comp.ID;
            compInfo.systemSID=bdroot(Simulink.ID.getHandle(comp.ID));
            compInfo.isLibrary=any(strcmpi(...
            get_param(compInfo.systemSID,'BlockDiagramType'),{'library','subsystem'}));

        else

            compInfo.compID=compId;
            compInfo.compType=this.AnalysisRootType;
            compInfo.SID=Simulink.ID.getSID(this.AnalysisRoot);
            compInfo.systemSID=Simulink.ID.getSID(this.RootModel);
            compInfo.isLibrary=any(strcmpi(...
            get_param(compInfo.systemSID,'BlockDiagramType'),{'library','subsystem'}));
        end


        maObj.ComponentID=compInfo.compID;






        p=ModelAdvisor.Preferences();

        if p.CommandLineRun
            maObj.CmdLine=true;
        end


        if~this.LegacyMode
            maObj.CmdLine=true;
        end


        startConfigFilePath=this.TaskManager.ConfigFilePath;

        if ischar(startConfigFilePath)
            maObj.StartConfigFilePath=startConfigFilePath;
        end

        maObj.CustomTARootID=this.AdvisorId;



        if isRootOfAnalysis&&this.LegacyMode
            am=Advisor.Manager.getInstance;

            if~isempty(am.parallelDatabase)
                maObj.parallel=true;
                maObj.Database=am.parallelDatabase;
            end
        end


        system=Simulink.ID.getFullName(compInfo.SID);


        if this.UseTempDir
            addpath(pwd);
            cdp=cd(this.TempDir);

            maObj.init(system);
            cd(cdp);
            rmpath(cdp);
        else
            maObj.init(system);
        end


        maObj.addlistener('CheckExecutionStart',@this.CheckExecutionListener);




        if~maObj.ContinueViewExistRpt


            if isRootOfAnalysis
                this.RootMAObj=maObj;
            end

            if this.LegacyMode&&isRootOfAnalysis



                mdlObj=get_param(bdroot(system),'Object');
                mdlObj.setModelAdvisorObj(maObj);


                attic('add',this.ID,maObj.TaskAdvisorCellArray);
            end



            bd=get_param(bdroot(system),'Object');
            if~bd.hasCallback('PostNameChange',this.ID)
                Simulink.addBlockDiagramCallback(bdroot(system),'PostNameChange',...
                this.ID,...
                @()modelNameChangeCallbackFct(this,compId));


                maObj.TaskManager=this.TaskManager;
            end



            this.MAObjs{end+1}=maObj;
            this.CompId2MAObjIdxMap(compId)=length(this.MAObjs);




            this.TaskManager.initDataForComponent(compId,maObj,...
            'legacy',true,'isRoot',isRootOfAnalysis);

        else


            if~this.LegacyMode
                maObj.delete();
                status=1;


                Simulink.ModelAdvisor.getActiveModelAdvisorObj([]);
            else





                this.RootMAObj=maObj;
            end
        end
    else

        idx=this.CompId2MAObjIdxMap(compId);
        maObj=this.MAObjs{idx};






        p=ModelAdvisor.Preferences();

        if p.CommandLineRun
            maObj.CmdLine=true;
        else
            maObj.CmdLine=false;
        end





        if~ishandle(maObj.SystemHandle)

            newHandle=get_param(maObj.SystemName,'Handle');
            maObj.SystemHandle=newHandle;

            if~ischar(maObj.System)
                maObj.System=newHandle;
            end



            system=bdroot(maObj.SystemName);
            bdObj=get_param(system,'object');

            if~bdObj.hasCallback('PostNameChange',this.ID)

                Simulink.addBlockDiagramCallback(system,'PostNameChange',...
                this.ID,...
                @()modelNameChangeCallbackFct(this,compId));
            end
        end

    end
end
