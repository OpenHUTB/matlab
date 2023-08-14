classdef slmlemgr<handle




    events
MLFB
EVENT
    end

    properties(Hidden)
        msgId=[]
        debug=false
        channel='/slmle'
MLFBEditorMap
    end

    methods(Access=private)
        function obj=slmlemgr()
            obj.init();
        end
    end

    methods(Static)
        obj=getInstance()
    end

    methods
        function delete(obj)
            obj.destroy();
        end
    end

    methods
        init(obj)
        destroy(obj)

        url=getUrl(obj,block)
        cid=getChartId(obj,block)
        objectId=getObjectId(obj,block);

        publish(obj,objectId,action,data)
        action(obj,msg)

        ed=open(obj,objectId,studio)
        close(obj,editor)

        refresh(obj,objectId,uid)
        update(obj,text,objectId,uid)

        debugStop(obj)

        editor=getMLFBEditor(obj,objectId,blkH,studio)
        editors=getMLFBEditorsFromAllStudios(obj,objectId)
        isAdded=addMLFBEditor(obj,objectId,blkH,studio)
        cleanupMLFBEditorMap(obj)
        editor=getMLFBEditorByStudioAdapter(obj,saEd)
        editors=getAllEditorsForChart(obj,chartId)

        bool=highlight(obj,objectId,sPos,ePos)
        highlightBySid(obj,sid,studio)

        updatedText=saveAndUpdate(obj,data,objectId);
    end
end

