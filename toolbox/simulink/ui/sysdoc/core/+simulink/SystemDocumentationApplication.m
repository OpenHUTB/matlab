
classdef SystemDocumentationApplication<handle




    methods(Static,Access=public)

        function show(studio)
            import simulink.SystemDocumentationApplication;
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end

            sysdocApp=SystemDocumentationApplication.getInstance();


            modelName=SysDocUtil.getModelName(studio);
            sysdocObj=sysdocApp.getSystemDocumentation(modelName);
            if isempty(sysdocObj)
                sysdocObj=sysdocApp.createSystemDocumentation(modelName);
                if isempty(sysdocObj)
                    return;
                end
            end


            studioWidgetMgr=sysdocObj.getStudioWidgetManager(studio);
            if isempty(studioWidgetMgr)
                studioWidgetMgr=sysdocObj.createStudioWidgetManager(studio);
                if isempty(studioWidgetMgr)
                    return;
                end
            end

            studioWidgetMgr.show();
        end

        function hide(studio)
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end


            studioWidgetMgr=SysDocUtil.getStudioWidgetManager(studio);
            if isempty(studioWidgetMgr)
                return;
            end

            studioWidgetMgr.hide();
        end

        function visible=isVisible(studio)
            import simulink.sysdoc.internal.SysDocUtil;
            visible=false;
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end


            studioWidgetMgr=SysDocUtil.getStudioWidgetManager(studio);
            if isempty(studioWidgetMgr)
                return;
            end

            visible=studioWidgetMgr.isVisible();
        end

        function close(modelName)
            simulink.SystemDocumentationApplication.getInstance().removeSystemDocumentationForModel(modelName);
        end


        function sysdocApp=getInstance()
            import simulink.sysdoc.internal.SysDocUtil;
            persistent s_sysdocAppSingle;
            if~SysDocUtil.isNotEmptyAndValid(s_sysdocAppSingle)
                import simulink.SystemDocumentationApplication;
                s_sysdocAppSingle=SystemDocumentationApplication();
            end
            sysdocApp=s_sysdocAppSingle;
        end



        function showOnCurrentStudio(studio,isEventuallyVisible,userData)
            if~isEventuallyVisible
                return;
            end
            import simulink.SystemDocumentationApplication;
            SystemDocumentationApplication.show(studio);
        end

        function print()
            import simulink.sysdoc.internal.SysDocUtil;
            studio=SysDocUtil.getActiveStudio();
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end
            studioWidgetMgr=SysDocUtil.getStudioWidgetManager(studio);
            if isempty(studioWidgetMgr)
                return;
            end
            contentWidget=studioWidgetMgr.getContentWidget();
            if isempty(contentWidget)

                return;
            end
            simulink.sysdoc.internal.StudioWidgetManager.onPrintPage(contentWidget);
        end

        function printBySID(sid)
            import simulink.sysdoc.internal.SysDocUtil;
            studio=SysDocUtil.getActiveStudio();
            if~SysDocUtil.isNotEmptyAndValid(studio)


                return;
            end
            studioWidgetMgr=SysDocUtil.getStudioWidgetManager(studio);
            if isempty(studioWidgetMgr)
                return;
            end
            studioWidgetMgr.printBySID(sid);
        end
    end





    properties(Access=protected)
        m_sysdocMap=[];


        m_debugMode=false;


        m_testMode=false;
        m_testSaveTimeOut=[];

        m_printer=[];
        m_rtcRequestFrontController=[];
    end

    methods(Access=public)



        function setDebugMode(this,debugMode)
            this.m_debugMode=debugMode;
        end

        function debugMode=isDebugMode(this)
            debugMode=this.m_debugMode;
        end

        function testMode=isTestMode(this)
            testMode=this.m_testMode;
        end

        function testSaveTimeOut=getTestSaveTimeOut(this)
            testSaveTimeOut=this.m_testSaveTimeOut;
        end





        function sysdocObj=getSystemDocumentation(this,modelName)
            sysdocObj=[];

            if~this.m_sysdocMap.isKey(modelName)
                return;
            end

            sysdocObj=this.m_sysdocMap(modelName);
        end



        function sysdocObj=createSystemDocumentation(this,modelName)
            sysdocObj=[];
            if isempty(modelName)
                return;
            end

            assert(~this.m_sysdocMap.isKey(modelName),'SystemDocumentationApplication::createSystemDocumentation - SystemDocumentation should not be created repeatedly.');



            import simulink.sysdoc.internal.SystemDocumentation;
            sysdocObj=SystemDocumentation(modelName);
            this.m_sysdocMap(modelName)=sysdocObj;
            assert(~isempty(sysdocObj),'simulink.SystemDocumentationApplication:createSystemDocumentation - Unable to create SystemDocumentation object.');

            import simulink.sysdoc.internal.SysDocUtil;
            SysDocUtil.subscribeModelBlockDiagramCB(modelName,'PreClose','SystemDocumentation',@()(simulink.SystemDocumentationApplication.close(modelName)));
        end





        function clearAll(this)
            this.m_sysdocMap=containers.Map;
        end


        function removeSystemDocumentationForModel(this,modelName)
            if isempty(modelName)
                return;
            end

            if this.m_sysdocMap.isKey(modelName)
                sysdocObj=this.m_sysdocMap(modelName);
                sysdocObj.handlePreCloseModelLevel();
                this.m_sysdocMap.remove(modelName);
            end

            import simulink.sysdoc.internal.SysDocUtil;
            SysDocUtil.unSubscribeModelBlockDiagramCB(modelName,'PreClose','SystemDocumentation');
        end


        function removeSystemDocumentationForStudio(this,studio)
            import simulink.sysdoc.internal.SysDocUtil;
            if~SysDocUtil.isNotEmptyAndValid(studio)
                return;
            end

            modelName=SysDocUtil.getModelName(studio);
            this.removeSystemDocumentationForModel(modelName);
        end




        function addToPrinterMap(this,fullName)
            if isempty(this.m_printer)
                this.m_printer=fullName;
            else
                error(message('simulink_ui:sysdoc:resources:printerMapFull'));
            end
        end

        function removeFromPrinterMap(this,fullName)
            if isempty(this.m_printer)||~isequal(this.m_printer,fullName)
                error(message('simulink_ui:sysdoc:resources:differentPrinterModel',this.m_printer));
            else
                this.m_printer=[];
            end
        end

        function modelName=getModelNameFromStudioTag(this,currentStudioTag)
            import simulink.notes.internal.NotesPrinter
            if isequal(currentStudioTag,NotesPrinter.NOTES_PRINTER_STUDIO_TAG)
                modelName=this.m_printer;
            else
                error(message('simulink_ui:sysdoc:resources:NotesPrinterStudio'));
            end
        end



        function frontController=getRTCRequestFrontController(this)
            frontController=this.m_rtcRequestFrontController;
        end
    end


    methods(Access={?sysdoc.NotesTester,?SysDocTestInterface})
        function setTestMode(this,testMode,varargin)
            this.m_testMode=testMode;
            if~isempty(varargin)
                this.m_testSaveTimeOut=varargin{1};
            else
                this.m_testSaveTimeOut=40;
            end
        end
    end

    methods(Access=protected)
        function obj=SystemDocumentationApplication()
            import simulink.notes.internal.RTCRequestFrontController;
            obj.m_sysdocMap=containers.Map;
            obj.m_testSaveTimeOut=40;
            obj.m_rtcRequestFrontController=RTCRequestFrontController();
        end
    end
end
