function[wasSuccessful,errMsg]=addRows(signalID,timesToRemove,dataValuesToKeep,varargin)




    errMsg='';
    wasSuccessful=false;

    appInstanceID=varargin{1};

    [wasSuccessful,errMsg]=slwebwidgets.tableeditor.editTableData(signalID,timesToRemove,dataValuesToKeep,appInstanceID);
