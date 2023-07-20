classdef(Abstract)ControlBase<handle




    properties
Type
ObjectTargetsChangedListener
ObjectPositionChangeListener
ObjectOuterPositionChangeListener
ObjectTextEditingChangeListener
ObjectBeingDestroyedListener
    end

    methods(Abstract)
        response=process(this,message)
    end
    methods
        function this=ControlBase()
            this.Type='base';
            this.ObjectTargetsChangedListener=[];
            this.ObjectPositionChangeListener=[];
            this.ObjectOuterPositionChangeListener=[];
            this.ObjectTextEditingChangeListener=[];
            this.ObjectBeingDestroyedListener=[];
        end

        function updatePVPairs(~)
        end
    end
end
