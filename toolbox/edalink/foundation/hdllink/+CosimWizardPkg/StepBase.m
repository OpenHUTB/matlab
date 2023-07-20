

classdef StepBase<handle
    properties
        Wizard;
    end
    methods
        function obj=StepBase(Wizard)
            obj.Wizard=Wizard;
        end
        function WidgetGroup=getWidgetGroup(this)
            WidgetGroup=this.getDialogSchema;
            WidgetGroup.Type='panel';
            WidgetGroup.Name='';
            WidgetGroup.RowSpan=[2,5];
            WidgetGroup.ColSpan=[2,10];
            WidgetGroup.Flat=true;
            WidgetGroup.Tag=['edaWidgetGroup.',class(this)];
        end
    end
    methods(Abstract)
        onBack(this,dlg);
        onNext(this,dlg);
        schema=getDialogSchema(this);




        EnterStep(this,dlg);
    end
end



