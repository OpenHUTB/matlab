

classdef ListItem<handle

    properties(Abstract,Constant)

MinWidth
    end

    properties(Abstract)

Panel



Visible
    end

    properties(Dependent)

Units
Position
    end

    events


ListItemSelected

        ListItemExpanded;
        ListItemShrinked;

        ListItemModified;
        ListItemDeleted;

        ListItemBeingEdited;
        ListItemROIVisibility;
    end

    methods(Abstract)



        select(~)




        unselect(~)

    end






    methods
        function val=get.Units(this)
            val=this.Panel.Units;
        end

        function val=get.Position(this)
            val=this.Panel.Position;
        end

        function set.Position(this,val)
            this.Panel.Position=val;
        end

        function set.Units(this,val)
            this.Panel.Units=val;
        end







        function adjustWidth(this,parentWidth)
            this.Position(3)=max(this.MinWidth,parentWidth);
        end










        function adjustHeight(this,parentHeight)%#ok<INUSD>

        end
    end

    methods(Sealed)



        function pos=getpixelposition(this,varargin)
            pos=getpixelposition(this.Panel,varargin{:});
        end
    end
end