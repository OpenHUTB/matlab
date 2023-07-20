function paramEnum=getInputParam_Enum(msgCatalogName,rowspan,colspan,entries,varargin)










    if nargin>4
        value=varargin{1};
    else
        if~isempty(entries)
            value=entries{1};
        else
            paramEnum=ModelAdvisor.InputParameter;
            return;
        end
    end

    paramEnum=ModelAdvisor.InputParameter;
    paramEnum.Type='Enum';
    paramEnum.RowSpan=rowspan;
    paramEnum.ColSpan=colspan;
    paramEnum.Visible=false;
    paramEnum.Entries=entries;
    paramEnum.Name=DAStudio.message(msgCatalogName);
    paramEnum.Value=value;

end
