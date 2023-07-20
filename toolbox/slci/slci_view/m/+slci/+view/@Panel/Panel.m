



classdef Panel<handle

    properties(Access=private)
fId
fStudio
fTitle
        fComp='GLUE2:DDG Component'
fTag
fChannel

fUrl
fDebugUrl

fDialog
    end

    methods

        function obj=Panel(st)
            obj.fStudio=st;
            obj.init();
        end


        function delete(obj)
            delete(obj.fDialog);
        end
    end

    methods(Access=protected)

        init(obj);

    end

    methods(Access=protected)

        showPanel(obj,dialogObj,dockposition,dockoption)
    end

    methods

        status=getStatus(obj)


        result=turnOn(obj)
        turnOff(obj)
        hide(obj)
        show(obj)
    end

    methods



        function setId(obj,id)
            obj.fId=id;
        end


        function out=getId(obj)
            out=obj.fId;
        end


        function setTitle(obj,title)
            obj.fTitle=title;
        end


        function out=getTitle(obj)
            out=obj.fTitle;
        end


        function setTag(obj,tag)
            obj.fTag=tag;
        end


        function out=getTag(obj)
            out=obj.fTag;
        end


        function setChannel(obj,channel)
            obj.fChannel=channel;
        end


        function out=getChannel(obj)
            out=obj.fChannel;
        end


        function setComp(obj,comp)
            obj.fComp=comp;
        end


        function out=getComp(obj)
            out=obj.fComp;
        end


        function out=getStudio(obj)
            out=obj.fStudio;
        end


        function out=hasDialog(obj)
            out=~isempty(obj.fDialog);
        end


        function out=getDialog(obj)
            assert(obj.hasDialog,'Dialog is not created yet');
            out=obj.fDialog;
        end


        function setDialog(obj,dialogObj)
            assert(~obj.hasDialog,'Dialog exists already');
            obj.fDialog=dialogObj;
        end

    end
end