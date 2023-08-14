classdef DragInteractionBase<handle




    properties(Access=private)
        dragstartcompleted=false;
        startdata;
    end

    methods
        function response(this,eventdata)
            switch eventdata.name
            case 'dragstart'
                this.dragstartcompleted=false;
                this.startdata=this.dragstart(eventdata);
                this.dragstartcompleted=true;
            case 'dragprogress'
                if this.dragstartcompleted
                    this.dragprogress(eventdata,this.startdata);
                end
            case 'dragend'
                this.dragstartcompleted=false;
                this.dragend(eventdata,this.startdata);
            end
        end
    end

    methods(Abstract)
        startdata=dragstart(this,evd)
        dragprogress(this,evd,startdata)
        dragend(this,evd,startdata)
    end
end
