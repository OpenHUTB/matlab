function closeButton(dlgSrc,dialogH)



    modelName=dlgSrc.modelName;
    sldvprivate('closeModelView',modelName);
    delete(dialogH);
