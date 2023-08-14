classdef ElementType


    properties
        StringRepresentation;
    end

    methods
        function obj=ElementType(stringRepresentation)
            obj.StringRepresentation=stringRepresentation;
        end

        function result=getString(this)
            result=this.StringRepresentation;
        end
    end

    enumeration
        NONE("")
        TABLE("table")
        MENU("menu")
        MENU_ITEM("menu item")
        DOCUMENT("document")
        DOCUMENT_GROUP("document group")
        PANEL("panel")
        TOOLSTRIP("toolstrip")
        TOOLSTRIP_TAB("toolstrip tab")
        BUTTON("button")
        LIST("list")
        LIST_ITEM("list item")
        DROP_DOWN("drop down")
        COMBO_BOX("combo box")
        SLIDER("slstringRepresentationer")
        SPINNER("spinner")
        TEXT_FIELD("text field")
        TEXT_AREA("text area")
        APP("app")
    end
end