classdef sfunctionbuilderMgr<handle















    properties(SetAccess=protected)
sfunctionbuilderModel
sfunctionbuilderModelForJavaGUI
sfunctionbuilderBlockHandleViewMap
    end

    methods

        function obj=sfunctionbuilderMgr()
            obj.sfunctionbuilderModelForJavaGUI=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();
            obj.sfunctionbuilderModel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();
            obj.sfunctionbuilderBlockHandleViewMap=containers.Map('KeyType','double','ValueType','any');
        end

        function setupModel(obj)

        end


        function SfunWizardData=addBlock(obj,block)
            SfunWizardData=obj.sfunctionbuilderModel.addBlock(block);
        end




        function loadJavaScriptUI(obj,bH,SfunWizardData)
            if isKey(obj.sfunctionbuilderBlockHandleViewMap,bH)
                jsview=obj.sfunctionbuilderBlockHandleViewMap(bH);
            else
                jsview=sfunctionbuilder.internal.sfunctionbuilderView(bH,SfunWizardData);
                obj.sfunctionbuilderBlockHandleViewMap(bH)=jsview;
            end
            obj.sfunctionbuilderModel.registerView(bH,jsview);
            jsview.open();
        end


        function destroyUI(obj,bH)
            if isKey(obj.sfunctionbuilderBlockHandleViewMap,bH)
                view=obj.sfunctionbuilderBlockHandleViewMap(bH);
                view.deleteView();

                remove(obj.sfunctionbuilderBlockHandleViewMap,bH);
            end
        end


        function view=getUI(obj,bH)
            if isKey(obj.sfunctionbuilderBlockHandleViewMap,bH)
                view=obj.sfunctionbuilderBlockHandleViewMap(bH);
            else
                view=[];
            end
        end


        function destroyModel(obj,bH)
            obj.sfunctionbuilderModel.destroyModel(bH);
        end


        function refreshJavaScriptUI(obj,block)
            bH=block.BlockHandle;
            view=obj.sfunctionbuilderBlockHandleViewMap(bH);

            view.refresh(block.AppData);
        end



        function url=getURL(obj,varargin)
            url=[];
            if nargin==1
                blockHandle=getSimulinkBlockHandle(gcb);
            elseif nargin==2
                blockHandle=varargin{1};
            else
                return
            end
            view=obj.sfunctionbuilderBlockHandleViewMap(blockHandle);
            if~isempty(view)
                url=view.getURL();
            end
        end

        function embedintoSLCanvas(obj)

            mdl=bdroot(gcb);
            src=simulinkcoder.internal.util.getSource(mdl);
            editor=src.studio.App.getActiveEditor;



            bH=getSimulinkBlockHandle(gcb);

            if isKey(obj.sfunctionbuilderBlockHandleViewMap,bH)
                view=obj.sfunctionbuilderBlockHandleViewMap(bH);
            else
                SfunWizardData=get_param(gcb,'WizardData');
                view=sfunctionbuilder.internal.sfunctionbuilderView(obj,bH,SfunWizardData);
                obj.sfunctionbuilderBlockHandleViewMap(bH)=view;
            end
            view.cefObj.hide()
            url=view.getURL();


            replace=['$1','dev'];
            url=regexprep(url,'(snc=)([^&]+)',replace);


            SLM3I.SLCommonDomain.loadWebContentForEditorCEF(editor,url);
        end

        function removefromSLCanvas(obj)
            mdl=bdroot(gcb);
            src=simulinkcoder.internal.util.getSource(mdl);
            editor=src.studio.App.getActiveEditor;
            SLM3I.SLCommonDomain.removeWebContentFromEditor(editor);


            bH=getSimulinkBlockHandle(gcb);
            view=obj.sfunctionbuilderBlockHandleViewMap(bH);
            view.open();

        end

    end


    methods(Static)
        function sfunctionbuilderMgr=getInstance()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=sfunctionbuilder.internal.sfunctionbuilderMgr();
            end
            sfunctionbuilderMgr=localObj;
        end
    end

end

