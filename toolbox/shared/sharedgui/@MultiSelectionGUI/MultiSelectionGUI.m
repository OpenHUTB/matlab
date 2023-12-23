classdef MultiSelectionGUI<handle

    properties

availableObjs
selectedObjs
okCallBackFcn
helpDocLocation
configsetTag
itemNamesAndDescription
highlightObjDescription
        numOfObjs int32=0;
rhsChosenItem
currentConfig
    end

    methods
        function obj=MultiSelectionGUI(lhsObjs,rhsObjs,callbackFcnHandle,docInfo,itemInfo,currentConfig)

            obj.init(lhsObjs,rhsObjs,callbackFcnHandle,docInfo,itemInfo,currentConfig);
        end
    end


    methods
        dialogCallback(obj,hDlg,tag)
        out=getDialogSchema(obj)
        out=getContentDialogSchema(obj)
        generateHighlightObjDescription(obj,hDlg)
        [success,errMsg]=postApplyCallBack(obj)
    end


    methods(Access=private)
        init(obj,varargin)
    end

end


