classdef DockedReport<handle



    properties
rootModel
covMode
        hasMultipleTypes=false
        html=''
        url=''
hStudio
hDDGComponent
        tokenActiveEditorChanged=[]
        listeners=[]
        contentFcn=[]
    end


    methods(Access=public)


        function this=DockedReport(studio,covMode,contentFcn,hasMultipleTypes)
            this.hStudio=studio;
            this.covMode=covMode;
            this.contentFcn=contentFcn;
            this.hasMultipleTypes=hasMultipleTypes;

            this.rootModel=get_param(studio.App.blockDiagramHandle,'name');

            c=studio.getService('GLUE2:ActiveEditorChanged');
            this.tokenActiveEditorChanged=c.registerServiceCallback(...
            @(~)this.activeEditorChanged());

            ed=DAStudio.EventDispatcher;
            this.listeners{1}=handle.listener(ed,'CurrentObjectChangedEvent',@this.selectionChangedOnCanvas);
        end

        function delete(this)

            if isempty(this.hStudio)||~isvalid(this.hStudio)||~isVisible(this)
                return;
            end

            this.hStudio.destroyComponent(this.hDDGComponent);

            if~isempty(this.tokenActiveEditorChanged)
                c=this.hStudio.getService('GLUE2:ActiveEditorChanged');
                c.unRegisterServiceCallback(this.tokenActiveEditorChanged);
            end
        end

        function isVisible=isVisible(this)
            isVisible=~isempty(this.hDDGComponent)&&...
            isvalid(this.hDDGComponent)&&this.hDDGComponent.isVisible;
        end

        function show(this)
            this.hStudio.showComponent(this.hDDGComponent);
        end

        function hide(this)
            this.hStudio.hideComponent(this.hDDGComponent);
        end

        function refreshContent(this)
            this.syncContentToSelectedBlock();
            this.refresh;
        end

        function refresh(this)
            d=DAStudio.ToolRoot.getOpenDialogs(this);
            if~isempty(d)
                for i=1:length(d)
                    if d.getSource==this
                        d(i).refresh;
                    end
                end
            end
        end

        function key=getStorageKey(this)
            key=this.hStudio.getStudioTag;
        end

        function registerDAListeners(this)
            bd=get_param(this.rootModel,'Object');
            bd.registerDAListeners;
        end


        dlgstruct=getDialogSchema(this,~)
        init(this)
    end


    methods(Access=private)

        syncContentToSelectedBlock(this,isInit)

        function[urlStr,htmlStr]=getContent(this,modelH,handle,useModelAsFallback)
            [urlStr,htmlStr]=this.contentFcn(modelH,this.covMode,handle,useModelAsFallback);
        end

        function setHtmlStr(this,htmlStr)
            this.html=htmlStr;
            this.url='';
            this.refresh;
        end

        function navigate(this,urlStr)
            this.url=urlStr;
            this.html='';
            this.refresh;
        end


        activeEditorChanged(this);
        selectionChangedOnCanvas(this,~,selectionEvent);
    end


    methods(Static=true)
        [model,idStack]=getSfLibInstanceParentModel(needIds)
    end
end

