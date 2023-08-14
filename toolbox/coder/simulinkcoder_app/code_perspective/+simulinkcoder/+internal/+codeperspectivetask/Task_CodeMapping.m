classdef Task_CodeMapping<simulinkcoder.internal.codeperspectivetask.BaseTask




    properties(Constant)
        ID='CodeMapping'
    end

    methods
        function result=turnOn(obj,input,minimize)
            if nargin<3
                minimize=false;
            end

            src=simulinkcoder.internal.util.getSource(input);
            studio=src.studio;
            h=studio.App.getActiveEditor.blockDiagramHandle;


            isERT=strcmp(get_param(h,'IsERTTarget'),'on');
            if isERT
                try
                    coder.internal.CoderDataStaticAPI.updateDictionariesInClosureIfPackageChanged(h);
                catch ME
                    warning(ME.identifier,'%s',ME.message);
                end
            end


            ss=studio.getComponent('GLUE2:SpreadSheet','CodeProperties');
            if~isempty(ss)
                needsCleanUp=~Simulink.CodeMapping.tabSuffixMatchesApp(studio);
                if needsCleanUp
                    ss.resetTitleView();
                    titleView=ss.getTitleView();
                    if isa(titleView,'DAStudio.Dialog')
                        dataViewObj=titleView.getDialogSource;
                        dataViewObj.clearAllListeners();
                        dataViewObj.removeAllTabs();
                    end
                    studio.hideComponent(ss);
                end
            end
            simulinkcoder.internal.util.openCodeMappingSS(studio,h,minimize);
            obj.refresh(studio);

            result=true;
        end

        function show(obj,input)
            src=simulinkcoder.internal.util.getSource(input);
            studio=src.studio;
            cmp=studio.getComponent('GLUE2:SpreadSheet','CodeProperties');
            if isempty(cmp)
                obj.turnOn(studio);
            else
                studio.showComponent(cmp);
            end

            cmp=studio.getComponent('GLUE2:SpreadSheet','CodeProperties');
            cmp.restore;
        end

        function turnOff(obj,input)%#ok<INUSL>
            src=simulinkcoder.internal.util.getSource(input);
            studio=src.studio;
            ss=studio.getComponent('GLUE2:SpreadSheet','CodeProperties');
            ssDD=studio.getComponent('GLUE2:SpreadSheet','DefaultsProperties');
            if~isempty(ssDD)
                studio.hideComponent(ssDD);
            end
            if~isempty(ss)
                titleView=ss.getTitleView();
                if isa(titleView,'DAStudio.Dialog')
                    dataViewObj=titleView.getDialogSource;
                    dataViewObj.clearAllListeners();
                end
                studio.hideComponent(ss);
            end

            editor=studio.App.getActiveEditor;
            editor.closeNotificationByMsgID('CodeMappingEditor_CannotLoad');
        end

        function bool=isAvailable(~,type)


            switch type
            case{'grt','ert','autosar','autosar_adaptive','cpp'}
                bool=true;
            otherwise
                bool=false;
            end

        end

        function reset(obj,cps)



            studio=cps.studio;
            top=studio.App.blockDiagramHandle;
            cp=simulinkcoder.internal.CodePerspective.getInstance;


            mdl=studio.App.getActiveEditor.blockDiagramHandle;
            cgb=get_param(mdl,'CodeGenBehavior');
            if strcmp(cgb,'None')
                obj.turnOff(studio);
                return;
            end

            [app,~,lang]=cp.getInfo(top);
            if obj.isAutoOn(studio)


                if strcmp(app,"EmbeddedCoder")&&~strcmp(lang,cps.appLang)
                    appInfo=coder.internal.toolstrip.util.getAppInfo(app);
                    pkg=get_param(top,'CodeInterfacePackaging');
                    msg=message('SimulinkCoderApp:codeperspective:UpdatedByInterfaceChange',...
                    appInfo.disp,pkg).getString;
                    notifyKey='CoderAppUpdatedByInterfaceChange';
                    editor=studio.App.getActiveEditor;
                    editor.deliverInfoNotification(notifyKey,msg);
                end
                obj.turnOn(studio,true);
            else
                obj.turnOff(studio);
            end
        end

        function refresh(obj,studio)









            [status,reason]=simulinkcoder.internal.util.getCodeMappingPanelStatus(studio);

            if status<2









                obj.turnOff(studio);


                if~isempty(reason)
                    editor=studio.App.getActiveEditor;
                    editor.deliverInfoNotification('CodeMappingEditor_CannotLoad',reason);
                end
            end
        end
    end
end


