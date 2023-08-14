function allTypes=summ_getTypeList








    types=findtype(RptgenRMI.enumRMIType());
    allTypes={types.Strings{:};types.displayNames{:}}';
