


classdef ManualReview<handle
    properties(Access=private)
fDialog
fStudio
fModelHandle
        fListeners={}
    end

    methods

        function obj=ManualReview(st)
            obj.fStudio=st;
            obj.init();
        end


        function delete(obj)

            for i=1:numel(obj.fListeners)
                delete(obj.fListeners{i});
            end
            obj.fListeners={};

        end
    end

    methods(Access=private)

        show(obj)

        hide(obj)
    end

    methods

        init(obj);

        refresh(obj)

        turnOn(obj);

        turnOff(obj);

        out=getStatus(obj)

        addData(obj,file,start_line_no,end_line_no);
    end

    methods


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


        function out=getModelHandle(obj)
            out=obj.fModelHandle;
        end
    end
end