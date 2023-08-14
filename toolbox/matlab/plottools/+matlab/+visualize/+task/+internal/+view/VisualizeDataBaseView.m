classdef(Abstract)VisualizeDataBaseView<handle&matlab.mixin.Heterogeneous






    properties(Hidden,GetAccess=public,SetAccess=private)

ParentContainer
    end

    properties(Constant,Hidden,Access=public)

        RowHeight(1,1)double=22;
        Padding(1,1)double=5;
        IconSize(1,1)double=16;
    end

    properties(Access=protected)

Model
    end

    events

ValueChangedEvent
    end

    methods(Access=public)

        function obj=VisualizeDataBaseView(parentContainer,model)


            obj.ParentContainer=parentContainer;


            obj.createComponents();


            obj.updateView(model);
        end
    end

    methods(Abstract,Access=protected)


        createComponents(obj,ParentContainer)


        valueChanged(obj,src,event)
    end

    methods(Abstract,Access=public)


        updateView(Model);
    end
end