function[pValue,propName]=getPropValue(this,objList,propName)




    if~strcmp(propName,'Text')
        [pValue,propName]=getCommonPropValue(this,objList,propName);
    else
        opt=getAnnotationOptions(this,propName);

        [opt.dValue,propName]=getCommonPropValue(this,objList,opt.propName);

        [opt.interpreter,~]=getCommonPropValue(this,objList,'Interpreter');

        pValue=getAnnotationMarkup(this,opt);


        pValue={pValue};
    end
end
