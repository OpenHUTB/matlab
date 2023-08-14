function result=toggleCheckHighlight(this,state)
    result=true;
    if isempty(this.maObj)
        return;
    end

    if strcmp(state,'true')


        am=Advisor.Manager.getInstance;
        allApplications=am.ApplicationObjMap.values;
        for i=1:length(allApplications)
            loopmdladvObj=allApplications{i}.getRootMAObj();
            if isa(loopmdladvObj,'Simulink.ModelAdvisor')&&...
                isprop(loopmdladvObj,'ResultGUI')&&...
                isa(loopmdladvObj.ResultGUI,'DAStudio.Informer')&&...
                strcmp(bdroot(loopmdladvObj.SystemName),bdroot(this.maObj.SystemName))&&...
                ~strcmp(loopmdladvObj.SystemName,this.maObj.SystemName)
                return
            end
        end

        this.maObj.ShowInformer=true;
        setpref('modeladvisor','ShowInformer',this.maObj.ShowInformer);
        me=this.maObj.MAExplorer;
        if isa(me,'DAStudio.Explorer')
            imme=DAStudio.imExplorer(me);
            selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
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
                open_system(this.maObj.SystemName);
            end
        end
    else
        this.maObj.ShowInformer=false;
        setpref('modeladvisor','ShowInformer',this.maObj.ShowInformer);
        if isa(this.maObj.ResultGUI,'DAStudio.Informer')
            modeladvisorprivate('modeladvisorutil2','CloseResultGUICallback');
            this.maObj.ResultGUI.delete;
        end

        editor=GLUE2.Util.findAllEditors(this.maObj.SystemName);
        if~isempty(editor)
            editor.closeNotificationByMsgID('modeladvisor.highlight.openconfigset');
        end
    end
end