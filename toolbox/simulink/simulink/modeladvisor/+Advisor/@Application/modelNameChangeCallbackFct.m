
function modelNameChangeCallbackFct(this,modelName)




    if this.AnalysisRootType==Advisor.component.Types.SubSystem&&...
        strcmp(modelName,this.RootModel)
        compId=this.AnalysisRootComponentId;
    else
        compId=modelName;
    end

    if~isempty(this)&&this.CompId2MAObjIdxMap.isKey(compId)






        if~strcmp(this.AdvisorId,'com.mathworks.HDL.WorkflowAdvisor')
            idx=this.CompId2MAObjIdxMap(compId);

            if~isempty(idx)
                maObj=this.MAObjs{idx};

                handle=maObj.SystemHandle;
                maObj.SystemName=getfullname(handle);


                if ischar(maObj.System)
                    maObj.System=maObj.SystemName;
                end

                loc_updateMAExplorerTitle(maObj);

                loc_updateWorkingDir(this,maObj)

                loc_updateToobarItems(this,modelName,maObj)


                if this.MultiMode
                    this.ComponentManager.setDirtyFlag();
                end


                if strcmp(bdroot(maObj.SystemName),maObj.SystemName)
                    newCompId=maObj.SystemName;
                else
                    newCompId=Advisor.component.subhierarchy.SLContainer.generateID(maObj.SystemName);
                end


                maObj.ComponentID=newCompId;


                this.CompId2MAObjIdxMap.remove(compId);
                this.CompId2MAObjIdxMap(newCompId)=idx;

                system=bdroot(maObj.SystemHandle);


                Simulink.removeBlockDiagramCallback(system,...
                'PostNameChange',this.ID);


                if strcmp(compId,this.AnalysisRootComponentId)
                    this.AnalysisRoot=maObj.SystemName;
                    this.RootModel=bdroot(maObj.SystemName);
                    this.AnalysisRootComponentId=newCompId;
                    this.ID=this.getID(this.AdvisorId,this.AnalysisRoot);
                end





                Simulink.addBlockDiagramCallback(system,'PostNameChange',...
                this.ID,...
                @()modelNameChangeCallbackFct(this,newCompId));
            end
        else



            this.delete();
        end
    end
end


function loc_updateMAExplorerTitle(maObj)

    if~isempty(maObj.MAExplorer)&&isa(maObj.MAExplorer,'DAStudio.Explorer')
        me=maObj.MAExplorer;

        if maObj.IsLibrary
            LibPrefix=[DAStudio.message('ModelAdvisor:engine:Library'),': '];
        else
            LibPrefix='';
        end


        GUITitle=loc_getAdvisorTitle(maObj.CustomTARootID);

        if~isempty(maObj.CustomObject)&&~isempty(maObj.CustomObject.GUITitle)
            GUITitle=maObj.CustomObject.GUITitle;
        end

        me.Title=[GUITitle,' - ',LibPrefix,strrep(getfullname(maObj.System),sprintf('\n'),' ')];

        if~isempty(maObj.ConfigFilePath)
            me.Title=[me.Title,'  ',maObj.ConfigFilePath];
        end
    end
end


function loc_updateWorkingDir(this,maObj)


    if this.UseTempDir
        addpath(pwd);
        cdp=cd(this.TempDir);

        WorkDir=maObj.getWorkDir();

        cd(cdp);
        rmpath(cdp);
    else
        WorkDir=maObj.getWorkDir();
    end


    maObj.AtticData.DiagnoseRightFrame=[WorkDir,filesep,'report.html'];


    maObj.Database.saveMASessionData();

end


function loc_updateToobarItems(this,modelName,maObj)

    if isfield(maObj.Toolbar,'RunInBackground')
        maObj.Toolbar.RunInBackground.callback=strrep(maObj.Toolbar.RunInBackground.callback,modelName,maObj.SystemName);
    end

    if isfield(maObj.Toolbar,'runCheck')
        maObj.Toolbar.runCheck.callback=strrep(maObj.Toolbar.runCheck.callback,modelName,maObj.SystemName);
    end

    if isfield(maObj.Toolbar,'openReport')
        maObj.Toolbar.openReport.callback=strrep(maObj.Toolbar.openReport.callback,modelName,maObj.SystemName);
    end

    if isfield(maObj.Toolbar,'launchLiteUI')
        maObj.Toolbar.launchLiteUI.callback=strrep(maObj.Toolbar.launchLiteUI.callback,modelName,maObj.SystemName);
    end

end

function title=loc_getAdvisorTitle(strAdvisor)
    title=DAStudio.message('Simulink:tools:MAModelAdvisor');
    if strcmp(strAdvisor,'com.mathworks.HDL.WorkflowAdvisor')
        title=DAStudio.message('HDLShared:hdldialog:HDLAdvisor');
    elseif strcmp(strAdvisor,'com.mathworks.cgo.group')
        title=DAStudio.message('Simulink:tools:CodeGenAdvisorTab');
    elseif strcmp(strAdvisor,'com.mathworks.Simulink.UpgradeAdvisor.UpgradeAdvisor')
        title=DAStudio.message('SimulinkUpgradeAdvisor:advisor:title');
    elseif strcmp(strAdvisor,'com.mathworks.FPCA.FixedPointConversionTask')
        title=DAStudio.message('SimulinkFixedPoint:fpca:MSGnameFixedPointConversionAdvisor');
    elseif strcmp(strAdvisor,'com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor')
        title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:PerformanceAdvisor');
    end
end
