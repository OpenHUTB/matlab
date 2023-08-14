classdef(Abstract)TypeView<handle&matlab.mixin.Heterogeneous




    properties(Abstract,Constant,Hidden)
IdPrefix
    end

    properties(Abstract,SetAccess=private)
Showing
Ready
    end

    properties(Abstract,SetAccess=private,SetObservable)
Busy
    end

    properties(SetAccess=?codergui.internal.type.TypeApplet)
ViewId
    end

    properties(SetAccess=?codergui.internal.type.TypeApplet,SetObservable)
        Enabled=true
    end

    properties(SetAccess=?codergui.internal.type.TypeApplet)
Owner
    end

    methods(Abstract)

        start(this)


        show(this)


        hide(this)


        focus(this)

        stopEditing(this,cancel)
    end

    methods
        function editType(this,typeNode)%#ok<*INUSD>
        end

        function editTypeAttribute(this,typeNode,attributeKey)
        end
    end

    methods(Abstract,Access={?codergui.internal.type.TypeView,?codergui.internal.type.TypeApplet})
        applyModel(this,typeMaker)

        applyModelChanges(this,changeEvent)
    end
end
