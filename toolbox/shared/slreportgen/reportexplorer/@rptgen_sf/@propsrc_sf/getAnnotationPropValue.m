function[pValue,propName]=getAnnotationPropValue(psSF,objList,propName)






    ps=rptgen_sl.propsrc_sl_annotation;

    opt=getAnnotationOptions(ps,propName);

    [opt.dValue]=getCommonPropValue(psSF,objList,propName);

    [opt.interpreter]=getCommonPropValue(psSF,objList,'Interpretation');

    pValue=getAnnotationMarkup(ps,opt);


    pValue={pValue};

end

