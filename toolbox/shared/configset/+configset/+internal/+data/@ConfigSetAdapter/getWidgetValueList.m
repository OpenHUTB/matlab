function valueList=getWidgetValueList(obj,name,varargin)



    if nargin>=3
        pd=varargin{1};
    else
        pd=obj.getParamData(name);
    end
    if nargin>=5
        cs=varargin{2};
        component=varargin{3};
    else
        cs=obj.Source;
        component=[];
    end

    if isempty(pd)
        valueList={};
        return;
    end

    if~isempty(pd.WidgetValuesFcn)
        fh=str2func(pd.WidgetValuesFcn);
        valueList=fh(cs,name,0);
    else
        valueList=cell(1,length(pd.WidgetList));
        value=obj.getParamValue(name,pd.Name,cs,component);
        valueList{1}=value;
    end

