function wList=getWidgetDataList(obj,name,varargin)



    if nargin<3
        pd=obj.getParamData(name);
    else
        if isa(varargin{1},'configset.internal.data.ParamStaticData')
            pd=varargin{1};
        else
            pd=obj.getParamData(name,varargin{1});
        end
    end
    if isempty(pd)
        wList={};
        return;
    end

    if isempty(pd.WidgetList)
        if pd.Hidden
            wList={};
        else
            wList={pd};
        end
    else
        wList=pd.WidgetList;
    end


