classdef ToolbarButton<handle




    properties
        name;
        toolbar;
        selected;
handle
    end

    methods
        function this=ToolbarButton(toolbar,handle)
            this.toolbar=toolbar;
            this.handle=handle;
        end

        function setEnabled(this,val)
            if val
                set(this.handle,'Enable','on');
            else
                set(this.handle,'Enable','off');
            end
        end

        function tf=isEnabled(this)
            tf=strcmp(get(this.handle,'Enable'),'on');
        end

        function setName(this,val)
            this.name=val;
        end

        function setSelected(this,val)
            if val
                set(this.handle,'Selected','on');
                set(this.handle,'Value',1);
            else
                set(this.handle,'Selected','off');
                set(this.handle,'Value',0);
            end
        end

        function tf=isSelected(this)
            tf=strcmp(get(this.handle,'Selected'),'on');
        end

        function tf=isVisible(this)
            tf=strcmp(get(this.handle,'Visible'),'on');
        end
    end
end
