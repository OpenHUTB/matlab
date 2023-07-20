classdef EventType


    properties
        StringRepresentation;
    end

    methods
        function obj=EventType(stringRepresentation)
            obj.StringRepresentation=stringRepresentation;
        end

        function result=getString(this)
            result=this.StringRepresentation;
        end
    end

    enumeration
        CELL_EDIT("cell edit")
        COLUMN_DRAGGED("column dragged")
        COLUMN_SORT("column sorted")
        SCROLL("scrolled")
        MENU_ITEM_SELECTED("menu item selected")
        OPEN_VARIABLE("variable opened")
        SELECTION_CHANGED("selection changed")
        SET_DESCRIPTION("column description changed")
        SET_UNITS("units changed")
        OPENED("opened")
        CLOSED("closed")
        SELECTED("selected")
        DESELECTED("deselected")
        DOCKED("docked")
        UNDOCKED("undocked")
        KEYPRESS("key pressed")
        CLICK("clicked")
        DBL_CLICK("double clicked")
        MINIMIZE("minimized")
        MAXIMIZE("maximized")
        RESTORE("restored")
        LOCATION_CHANGE("location changed")
        DRAG("dragged")
    end
end