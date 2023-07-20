function paramEnum=getInputParam_Bool(msgCatalogName,rowspan,colspan)








    paramEnum=ModelAdvisor.InputParameter;
    paramEnum.Type='bool';
    paramEnum.RowSpan=rowspan;
    paramEnum.ColSpan=colspan;
    paramEnum.Visible=false;
    paramEnum.Enable=true;
    paramEnum.Name=DAStudio.message(msgCatalogName);
    paramEnum.Value=true;

end
