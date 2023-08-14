function result=openCheckSelectorWithData(this,rowNum,checkIds)
    result=[];
    this.closeChildWindows();


    CSW=Advisor.CheckSelector();


    CSW.setParent(this);

    propValues.checkIDs=strtrim(strsplit(checkIds(2:end-1),','));
    propValues.rowNum=rowNum;
    propValues.updateTable=true;

    CSW.setInitPropValues(propValues);


    this.childWindow=CSW;


    CSW.open();
end