function paramString=getInputParam_String(msgCatalogName,rowspan,colspan,varargin)










    if nargin>3
        value=varargin{1};
    else
        value='';
    end

    paramString=ModelAdvisor.InputParameter;
    paramString.RowSpan=rowspan;
    paramString.ColSpan=colspan;
    paramString.Name=DAStudio.message(msgCatalogName);
    paramString.Type='String';
    paramString.Value=value;
    paramString.Visible=false;
    paramString.Enable=false;
end
