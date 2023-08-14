function s=getInfo(obj,varargin)




    if nargin==2&&~isempty(varargin{1})
        s=getInfo@configset.internal.data.ParamStaticData(obj,varargin{1});
    else
        s=getInfo@configset.internal.data.ParamStaticData(obj);
    end
    s=rmfield(s,'value');
    s=rmfield(s,'converted');


    if~isempty(obj.WidgetType)
        s.type=obj.WidgetType;
    elseif~isempty(obj.Type)
        s.type=obj.Type;
    end
    s.param=obj.getParamName;


    if obj.ShowCommandLineName
        s.cmd=s.param;
    else
        s.cmd='';
    end


    if strcmp(obj.WidgetType,'table')
        if~isempty(obj.f_AvailableValues)
            s.fn.tableData=obj.f_AvailableValues;
        end
    end


    if strcmp(obj.WidgetType,'image')
        s.imgsrc=obj.UI.f_image;
    end

