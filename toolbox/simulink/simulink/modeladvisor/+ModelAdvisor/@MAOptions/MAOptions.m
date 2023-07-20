classdef MAOptions<handle






    properties(Access='private')
        mdlName='';
        DefaultMAType={DAStudio.message('ModelAdvisor:engine:ModelAdvisor'),...
        DAStudio.message('ModelAdvisor:engine:ModelAdvisorDashboard')};

        DefaultMAViewModes={'MAStandardUI','MADashboard'};
    end

    properties(Access='public')
        fDialogHandle;
        eventListener=[];
    end


    methods(Static=true)



        function optionsDlg=findExistingDlg(modelName)
            tr=DAStudio.ToolRoot;
            dlgs=tr.getOpenDialogs;
            optionsDlg=[];
            dialogtag=ModelAdvisor.MAOptions.getDialogTag(modelName);
            for idx=1:numel(dlgs)
                if strcmp(dlgs(idx).dialogTag,dialogtag)
                    dlg=dlgs(idx);
                    optionsDlg=dlg.getSource;
                    break;
                end
            end
        end

        function tag=getDialogTag(~)
            tag='_MA_Preferences_Dlg';
        end

    end

    methods

        function obj=MAOptions(mdlName)
            instance=ModelAdvisor.MAOptions.findExistingDlg(mdlName);
            if isempty(instance)
                obj.mdlName=mdlName;
            else
                obj=instance;
            end
            setEventHandler(obj);
        end


        function show(aObj)
            if isempty(aObj.fDialogHandle)
                dlg=DAStudio.Dialog(aObj);
                aObj.fDialogHandle=dlg;
            else
                aObj.fDialogHandle.show;
            end
            aObj.fDialogHandle.refresh;
        end

        function idx=getStringIdx(this,viewMode)
            if strcmp(viewMode,'MAStandardUI')
                idx=1;
            elseif strcmp(viewMode,'MADashboard')
                idx=2;
            end
        end

        function postApply(this)
            mp=ModelAdvisor.Preferences;

            idx=this.fDialogHandle.getWidgetValue('DefaultMAType');
            modeladvisorprivate('modeladvisorutil2','DefaultMAUI',this.DefaultMAViewModes{idx+1});

            idx=this.fDialogHandle.getWidgetValue('ShowByProduct');
            if~(mp.ShowByProduct==idx)
                mp.ShowByProduct=idx;
                ModelAdvisor.Node.toggleTreeview('ByProduct');
            end

            idx=this.fDialogHandle.getWidgetValue('ShowByTask');
            if~(mp.ShowByTask==idx)
                mp.ShowByTask=idx;
                ModelAdvisor.Node.toggleTreeview('ByTask');
            end

            idx=this.fDialogHandle.getWidgetValue('ShowSourceTab');
            if~(mp.ShowSourceTab==idx)
                mp.ShowSourceTab=idx;
                ModelAdvisor.Node.toggleTreeview('SourceTab');
            end

            idx=this.fDialogHandle.getWidgetValue('ShowExclusionTab');
            if~(mp.ShowExclusionTab==idx)
                mp.ShowExclusionTab=idx;
                ModelAdvisor.Node.toggleTreeview('ExclusionTab');
            end

            idx=this.fDialogHandle.getWidgetValue('ShowAccordion');
            if~(mp.ShowAccordion==idx)
                mp.ShowAccordion=idx;
                ModelAdvisor.Node.toggleTreeview('Accordion');
            end

            idx=this.fDialogHandle.getWidgetValue('ShowExclusionsInRpt');
            if~(mp.ShowExclusionsInRpt==idx)
                mp.ShowExclusionsInRpt=idx;
                ModelAdvisor.Node.toggleTreeview('Exclusions');
            end

            idx=this.fDialogHandle.getWidgetValue('RunInBackground');
            if~(mp.RunInBackground==idx)
                mp.RunInBackground=idx;
                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
                if~isempty(mdladvObj)
                    mdladvObj.runInBackground=mp.RunInBackground;
                    if mdladvObj.runInBackground
                        mdladvObj.Toolbar.RunInBackground.on='on';
                    else
                        mdladvObj.Toolbar.RunInBackground.on='off';
                    end
                end
            end

            idx=this.fDialogHandle.getWidgetValue('EnableCustomizationCache');
            if~(mp.EnableCustomizationCache==idx)
                mp.EnableCustomizationCache=idx;
            end

            mp.save;
        end
    end
end
