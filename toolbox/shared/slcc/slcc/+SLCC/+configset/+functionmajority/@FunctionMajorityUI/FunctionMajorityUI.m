classdef FunctionMajorityUI<handle



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
    end

    properties(Constant,Hidden)
        tagPrefix='Tag_Function_Majority_';
    end

    methods
        function obj=FunctionMajorityUI(hParentDlg,hCompSrc)
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
