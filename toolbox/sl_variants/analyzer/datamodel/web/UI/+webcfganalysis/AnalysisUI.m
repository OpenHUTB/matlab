classdef AnalysisUI<handle




    properties(Hidden)
        webWindow;
        model;
        connectorChannel;
        sync;
        modelName;
        commandChannel;
        updateChannel;
    end

    methods

        function obj=AnalysisUI(ctrlMgr)
            obj.model=ctrlMgr.mMF0Model;
            obj.modelName=ctrlMgr.mSysName;
            obj.commandChannel=['/sl_variants_analyzer_datamodel/channel','/',obj.model.UUID];
            obj.updateChannel=['/sl_variants_analyzer_datamodel/channel','/',obj.model.UUID];
            obj.connectorChannel=mf.zero.io.ConnectorChannelMS(obj.commandChannel,obj.updateChannel);
            obj.sync=mf.zero.io.ModelSynchronizer(obj.model,obj.connectorChannel);
            obj.sync.start();
        end

        function url=getUrl(obj)
            url=[connector.getUrl('toolbox/sl_variants/analyzer/datamodel/web/index.html'),'&uuid=',obj.model.UUID];
        end

        function showUI(obj)
            connector.ensureServiceOn;

            if slsvTestingHook('VariantConfigDebugMode')<1
                url=obj.getUrl();

                obj.handleClose();

                obj.createWebWindow(url);
            else

                url=[connector.getUrl('toolbox/sl_variants/analyzer/datamodel/web/index-debug.html'),'&uuid=',obj.model.UUID];
                web(url,'-browser');
            end
        end

        function createWebWindow(obj,url)
            win=matlab.internal.webwindow(url);
            obj.webWindow=win;
            win.Position=getGeometry();
            win.Title=['Variant Analyzer: ',obj.modelName];
            win.show();
            win.bringToFront();



            mgrInstance=webcfganalysis.AnalysisUIMgr.getInstance();
            mgrInstance.addModelInstance(obj.modelName,obj);
        end


        function delete(obj)
            obj.handleClose();
        end


        function hide(obj)
            if isempty(obj.webWindow)
                return;
            end
            obj.webWindow.hide();
        end
    end

    methods(Hidden,Static)


        function isOpen=isWindowOpen(modelName)
            isOpen=false;
            mgrInstance=webcfganalysis.AnalysisUIMgr.getInstance();
            webwin=mgrInstance.getWebWindowForModel(modelName);
            if~isempty(webwin)&&webwin.isWindowValid
                isOpen=webwin.isWindowActive;
            end
        end

        function isVisible=isWindowVisible(modelName)
            isVisible=false;
            mgrInstance=webcfganalysis.AnalysisUIMgr.getInstance();
            webwin=mgrInstance.getWebWindowForModel(modelName);
            if~isempty(webwin)
                isVisible=webwin.isVisible;
            end
        end


        function closeWindow(modelName)
            mgrInstance=webcfganalysis.AnalysisUIMgr.getInstance();
            webwin=mgrInstance.getWebWindowForModel(modelName);
            if isempty(webwin)&&~webwin.isWindowValid&&...
                ~webwin.isWindowActive
                return;
            end
            webwin.close;
        end
    end

    methods(Access=private)
        function handleClose(obj)
            if isempty(obj.webWindow)
                return;
            end

            mgrInstance=webcfganalysis.AnalysisUIMgr.getInstance();
            mgrInstance.removeModelInstance(obj.modelName);

            obj.webWindow.close();
            obj.webWindow=[];
        end
    end
end

function ret=getGeometry()
    width=800;
    height=800;

    r=groot;
    screenWidth=r.ScreenSize(3);
    screenHeight=r.ScreenSize(4);
    maxWidth=0.8*screenWidth;
    maxHeight=0.8*screenHeight;
    if maxWidth>0&&width>maxWidth
        width=maxWidth;
    end
    if maxHeight>0&&height>maxHeight
        height=maxHeight;
    end

    xOffset=10;
    yOffset=(screenHeight-height)/2;

    ret=[xOffset,yOffset,width,height];
end


