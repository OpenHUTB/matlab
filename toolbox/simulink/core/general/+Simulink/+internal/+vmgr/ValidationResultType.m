classdef(Sealed,Hidden)ValidationResultType







    enumeration
        Active,
        Analyzed,
        Inactive,
        Error,
        Ignored,
None
    end

    methods(Static,Access=public,Hidden=true)
        function isValid=isValidValidationResultType(choiceType)
            isValid=~isempty(choiceType)&&((choiceType==Simulink.internal.vmgr.ValidationResultType.Active)||...
            (choiceType==Simulink.internal.vmgr.ValidationResultType.Analyzed)||...
            (choiceType==Simulink.internal.vmgr.ValidationResultType.Inactive)||...
            (choiceType==Simulink.internal.vmgr.ValidationResultType.Error)||...
            (choiceType==Simulink.internal.vmgr.ValidationResultType.Ignored)||...
            (choiceType==Simulink.internal.vmgr.ValidationResultType.None));
        end
    end
end
