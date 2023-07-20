classdef CodeView<handle



    events
CodeViewEvent
    end

    properties
cid
studio
registerCallbackId
canvasListener
        codeListener={}
mlfbListener
preModel
buildType
        files={}
ui
        docked=false
    end

    properties(Hidden)
        review=false
    end

    properties(Dependent)
model
top
    end

    methods
        function obj=CodeView(st)
            if nargin>0
                obj.studio=st;
            end
            obj.init();


        end

        function delete(obj)
            l=obj.canvasListener;
            if~isempty(l)
                sn=l.Source{1};
                delete(sn);
            end







        end

        function modelName=get.model(obj)
            modelName='';
            st=obj.studio;
            if isempty(st)
                return;
            end
            if~isvalid(st)
                return;
            end

            editor=st.App.getActiveEditor;
            hids=GLUE2.HierarchyService.split(editor.getHierarchyId());
            topLevel=GLUE2.HierarchyService.getTopLevel(hids(end));
            handle=SLM3I.HierarchyServiceUtils.getHandle(topLevel);
            modelName=get_param(handle,'Name');
        end

        function modelName=get.top(obj)
            st=obj.studio;
            if isempty(st)
                modelName='';
                return;
            end

            modelH=bdroot(st.App.blockDiagramHandle);
            modelName=get_param(modelH,'Name');
        end

        dlgSruct=getDialogSchema(obj)
        dlgSruct=getCodeSchema(obj)
        url=getUrl(obj)

        open(obj,varargin)
        refresh(obj)
        switchModel(obj,current)
    end

    methods(Access=public)
        init(obj)
        sendData(obj,uid)

        onSelect(obj,src,data)
        onClick(obj,src,evt)
        handleEditorChanged(obj,cbinfo)
        callback(obj,src,evt)
        mlfbCallback(obj,src,evt)
        out=getCodeData(obj)
        toggleAnnotation(obj,flag)


        publish(obj,action,data,uid)


        onMouseEnter(obj,src,evt)
        onMouseLeave(obj,src,evt)


        highlightAnnotation(obj,record)
        updateAnnotation(obj,records)
    end

    properties(Hidden)
        ref=0;
    end
end

