function allTypes=summ_getTypeList









    types=findtype(rptgen_sl.enumSimulinkType());
    allTypes={types.Strings{:};types.displayNames{:}}';
