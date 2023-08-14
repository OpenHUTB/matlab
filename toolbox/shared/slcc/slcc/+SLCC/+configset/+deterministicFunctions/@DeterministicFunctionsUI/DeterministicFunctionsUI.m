classdef DeterministicFunctionsUI<handle



    properties
parentDlg
csCompSrc
thisDlg
fcnSettingsSS
configSet
    end

    properties(Hidden)
        enableApplyOnParentUponApply(1,1)logical=false;
        functionSuggestions={};
        variableSuggestions={};
    end

    properties(Constant,Hidden)
        tagPrefix='Tag_Deterministic_ByFunction_';
    end

    methods
        function obj=DeterministicFunctionsUI(hParentDlg,hCompSrc)
            obj.init(hParentDlg,hCompSrc);
        end
    end

    methods
        [out]=getDialogSchema(this,schemaName)
        customizeAddCallBack(this)
        customizeDeleteCallBack(this)
        [status,errStr]=preApplyCallBack(this)
        helpCallBack(this)
        [fcnList]=getSuggestedFunctionList(this)
        refreshFunctionSuggestions(this)
    end

    methods(Access=private)
        obj=init(this,hParentDlg,hCompSrc)
    end
end
