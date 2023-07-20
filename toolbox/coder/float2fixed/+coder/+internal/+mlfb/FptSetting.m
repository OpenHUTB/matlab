classdef(Sealed)FptSetting



    enumeration
        WordLength('DefaultWordLength','edit_def_wl')
        FractionLength('DefaultFractionLength','edit_def_fl')
        SafetyMargin('SafetyMarginForSimMinMax','edit_safetymargin_sim')
        ProposeSignedness('isAutoSignedness','propose_signedness')
        ProposeWordLength('isWLSelectionPolicy','scale_selection')
    end

    properties
ModelProperty
DdgWidgetTag
    end

    methods
        function this=FptSetting(propName,widgetTag)
            this.ModelProperty=propName;
            this.DdgWidgetTag=widgetTag;
        end

        function validate(this,value)

        end
    end
end