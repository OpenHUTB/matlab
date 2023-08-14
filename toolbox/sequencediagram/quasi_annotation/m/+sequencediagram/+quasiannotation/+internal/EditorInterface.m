classdef(Sealed)EditorInterface<handle






    properties(Access=private)


        ExecutingJS=false;
    end

    methods(Static)
        function obj=getInstance()
            mlock;
            persistent instance;
            if isempty(instance)||~isvalid(instance)
                instance=sequencediagram.quasiannotation.internal.EditorInterface();
            end
            obj=instance;
        end

        function evalMLString=getRunMatlabFunctionFromJavascriptString(fcnName,inputs)













            assert(iscell(inputs));

            jsonEncodedInputs=jsonencode(inputs);

            evalMLString=...
            "(function () {"+...
            "require(['wigl/matlab/MatlabUtil'], function(MatlabUtil) {"+...
            "MatlabUtil['default'].matlabFEval('"+fcnName+"', "+jsonEncodedInputs+", 0 ).then() })}());";
        end
    end

    events
























































EditorOpened
    end

    methods
        function fireEventWhenEditorIsLoaded(obj,modelName,sequenceDiagramName)


            t=timer;
            t.StartDelay=2;
            t.Period=1;
            t.TasksToExecute=30;
            t.ExecutionMode='fixedSpacing';
            t.ObjectVisibility='off';
            t.Name="SequenceDiagramQuasiAnnotationEditorOpenTimer_"+...
            modelName+"_"+...
            sequenceDiagramName;
            t.TimerFcn=@(t,~)obj.fireEventWhenEditorIsLoadedImpl(modelName,sequenceDiagramName,t);
            t.StopFcn=@(t,~)delete(t);

            t.start();
        end

        function isOpen=isEditorOpen(obj,modelName,sequenceDiagramName)







            isOpen=false;

            window=obj.getSystemComposerViewsCEFWindow(modelName);

            if~isempty(window)
                editorName=obj.getCurrentEditorName(window);
                hasGutter=obj.isSequenceDiagramGutterPresent(window);
                isOpen=hasGutter&&strcmp(editorName,sequenceDiagramName);
            end
        end

        function insertAnnotation(obj,modelName,sequenceDiagramName,panel,html,annotationId)











            panelSelector=obj.getPanelSelector(panel);


























            jsCmd_PreventRaceConditionStart=...
            "existingAnnotation = document.getElementById('"+annotationId+"');"+newline+...
            "if (!existingAnnotation) {";
            jsCmd_PreventRaceConditionEnd="}";











            encodedHtml=strrep(html,'\','\\');
            encodedHtml=strrep(encodedHtml,'"','\"');

            jsCmd_InsertAnnotation=...
            "parentPanel = document.querySelector('"+panelSelector+"');"+newline+...
            'htmlToInsert = "'+encodedHtml+'";'+newline+...
            "parentPanel.insertAdjacentHTML('beforeend', htmlToInsert);";

            jsCmd=...
            jsCmd_PreventRaceConditionStart+newline+...
            jsCmd_InsertAnnotation+newline+...
            jsCmd_PreventRaceConditionEnd;





            if obj.isEditorOpen(modelName,sequenceDiagramName)
                window=obj.getSystemComposerViewsCEFWindow(modelName);
                obj.executeJS(window,jsCmd);
            end

        end

        function removeAnnotation(obj,modelName,sequenceDiagramName,annotationId)



            jsCmd=...
            "annotationToRemove = document.getElementById('"+annotationId+"');"+newline+...
            "if (annotationToRemove) {"+newline+...
            "annotationToRemove.remove();"+newline+...
            "}";





            if obj.isEditorOpen(modelName,sequenceDiagramName)
                window=obj.getSystemComposerViewsCEFWindow(modelName);
                obj.executeJS(window,jsCmd);
            end
        end

        function panelSelector=getPanelSelector(~,panel)
            switch panel
            case 'header'
                panelSelector=".sequencediagram-headerpanel .diagram-diagram";
            case 'body'
                panelSelector=".sequencediagram-bodypanel .diagram-diagram";
            otherwise
                error('invalid panel');
            end
        end

        function openSequenceDiagram(obj,modelName,sequenceDiagramName)














            obj.openViews(modelName);

            t=timer;
            t.StartDelay=2;
            t.Period=2;
            t.TasksToExecute=30;
            t.ExecutionMode='fixedSpacing';
            t.ObjectVisibility='off';
            t.Name="SequenceDiagramQuasiAnnotationOpenSequenceDiagramTimer_"+...
            modelName+"_"+...
            sequenceDiagramName;
            t.TimerFcn=@(t,~)obj.openSequenceDiagramWhenEditorHasLoaded(modelName,sequenceDiagramName,t);
            t.StopFcn=@(t,~)delete(t);

            t.start();
        end
    end

    methods(Access=private)
        function obj=EditorInterface()
        end

        function window=getSystemComposerViewsCEFWindow(~,modelName)
            window=matlab.internal.webwindow.empty();

            if~bdIsLoaded(modelName)





                return;
            end










            mdlHandle=get_param(modelName,'handle');
            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(mdlHandle);

            appMgr=app.getArchViewsAppMgr;
            if appMgr.isStudioOpen
                studioMgr=appMgr.getStudioMgr();
                url=studioMgr.getUrl();

                windowId=regexp(url,'msg=[^&]*','match');
                windowId=string(windowId);

                webWindowMgr=matlab.internal.webwindowmanager.instance();
                windowList=webWindowMgr.windowList;
                windowIdx=string({windowList.CurrentURL}).contains(windowId);
                window=windowList(windowIdx);
            end

        end

        function rawJson=executeJS_impl(obj,window,jsCmd)
































            assert(~obj.ExecutingJS,...
            'SequenceDiagram:QuasiAnnotation:ReentrantExecuteJs',...
            "A reentrant call to execute JavaScript code in the sequence "+...
            "diagram editor by the QuasiAnnotation feature has been detected.")

            obj.ExecutingJS=true;



            executingFlagCleanup=onCleanup(@()cleanupExecutingFlagFcn(obj));
            function cleanupExecutingFlagFcn(ei)
                ei.ExecutingJS=false;
            end










            timeout=60;

            rawJson=window.executeJS(char(jsCmd),timeout);
        end

        function executeJS(obj,window,jsCmd)




            obj.executeJS_impl(window,jsCmd);
        end

        function out=executeJSAndDecode(obj,window,jsCmd)











            rawJson=obj.executeJS_impl(window,jsCmd);















            for ii=1:5
                if isempty(rawJson)
                    pause(.5);
                    rawJson=obj.executeJS_impl(window,jsCmd);
                end
            end
            if isempty(rawJson)
                ME=MException.last;
                id='SequenceDiagram:QuasiAnnotation:ExecuteJsReturnedEmpty';
                msg="Failed to interface with the sequence diagram editor."+newline+...
                "This may have been caused by a MATLAB exception being thrown when interfacing with the editor."+newline+...
                "The last thrown MATLAB exception had the ID: "+ME.identifier+newline+...
                "The full report of the last thrown MATLAB exception was: "+newline+...
                "<REPORT>"+newline+...
                ME.getReport()+newline+...
                "</REPORT>";
                error(id,msg);
            end

            out=jsondecode(rawJson);
        end

        function editorName=getCurrentEditorName(obj,window)
            jsCmd=...
            "currentTab = document.querySelector('#sysarch_editorDocumentContainer .tab.checkedTab .mwTabLabel');"+newline+...
            "currentTabName = currentTab ? currentTab.innerText : '';"+newline+...
            "currentTabName";

            editorName=obj.executeJSAndDecode(window,jsCmd);
        end

        function hasGutter=isSequenceDiagramGutterPresent(obj,window)
            jsCmd=...
            "gutterNode = document.querySelector('#sysarch_editorDocumentContainer .sequencediagram-gutter');"+newline+...
            "hasGutter = Boolean(gutterNode);"+newline+...
            "hasGutter";

            hasGutter=obj.executeJSAndDecode(window,jsCmd);
        end

        function fireEventWhenEditorIsLoadedImpl(obj,modelName,sequenceDiagramName,pollingTimer)


            if obj.ExecutingJS
                return;
            end

            if obj.isEditorOpen(modelName,sequenceDiagramName)
                obj.fireOpenedEvent(modelName,sequenceDiagramName);
                pollingTimer.stop();
            end
        end

        function fireOpenedEvent(obj,modelName,sequenceDiagramName)
            eventData=sequencediagram.quasiannotation.internal.EditorOpenedEventData(modelName,sequenceDiagramName);
            notify(obj,'EditorOpened',eventData);
        end

        function openViews(obj,modelName)








            window=obj.getSystemComposerViewsCEFWindow(modelName);
            if isempty(window)
                app=systemcomposer.internal.arch.load(modelName);
                appMgr=app.getArchViewsAppMgr;
                debug=false;
                appMgr.open(debug);
            else
                window.bringToFront();
            end
        end

        function openSequenceDiagramWhenEditorHasLoaded(obj,modelName,sequenceDiagramName,pollingTimer)




























            if obj.ExecutingJS
                return;
            end

            if obj.isEditorOpen(modelName,sequenceDiagramName)
                pollingTimer.stop();
                return;
            end

            window=obj.getSystemComposerViewsCEFWindow(modelName);

            if~isempty(window)
                openSdJsFunction=...
                "function(){"+newline+...
                "ArchViewsApp['default'].interfaceManager.closeViewsEditorDocument();"+newline+...
                "SequenceDiagramApp.openSequenceDiagram('"+sequenceDiagramName+"');"+newline+...
                "}"+newline;

                jsCmd=...
                "require(['sysarch/adapters/sequencediagram/app/SequenceDiagramApp', 'sysarch/app/ArchViewsApp'], function(SequenceDiagramApp, ArchViewsApp) {"+newline+...
                "window.setTimeout("+newline+...
                openSdJsFunction+...
                ", 1000);"+...
                "});";

                obj.executeJS(window,jsCmd);
            end
        end

    end
end


