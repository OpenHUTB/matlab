function addStylesheetToLibrary(this,ssNew)





    tType=ssNew.TransformType;
    if isempty(tType)
        tType='empty';
    end


    try
        typeCat=get(this,['Category',tType]);
    catch
        warning(message('rptgen:RptgenML_StylesheetRoot:unknownTransformType',tType));
        typeCat=this.CategoryEmpty;
    end

    connect(ssNew,typeCat,'up');



