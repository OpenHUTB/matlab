function cbe_postshow(me,e)%#ok



    if~isempty(me)
        dlghandle=TflDesigner.getdialoghandle;

        if~isempty(dlghandle)
            this=TflDesigner.getselectedlistnodes;











            if~isempty(this)&&this.copyconcepargsettings==2
                dlghandle.setWidgetValue('Tfldesigner_CopyConcepArgSettings',true);
                this.copyconcepargsettings=1;
                dlghandle.refresh;
            end
        end
    end
