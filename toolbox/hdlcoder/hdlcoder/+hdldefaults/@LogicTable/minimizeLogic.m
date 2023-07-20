function[minimizedInputTable,minimizedOutputTable]=minimizeLogic(this,inputTable,outputTable)%#ok<INUSL>



    minimizedInputTable=inputTable~=0;
    minimizedOutputTable=outputTable~=0;

end