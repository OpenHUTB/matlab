function v=hdlimplparamstruct(paramName,paramType,defValue,allValues,tabName,tabPosition,groupName,groupPosition)









    v=struct;
    v.ImplParamName=paramName;
    v.ImplParamType=paramType;
    v.DefaultValue=defValue;

    v.Value=defValue;
    v.AllValues=allValues;
    v.tabName=tabName;
    v.tabPosition=tabPosition;
    v.groupName=groupName;
    v.groupPosition=groupPosition;