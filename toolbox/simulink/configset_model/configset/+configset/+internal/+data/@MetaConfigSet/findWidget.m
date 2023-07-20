function out=findWidget(obj,wName,varargin)







    out=[];

    if obj.WidgetNameMap.isKey(wName)
        param=obj.WidgetNameMap(wName);
    else

        parts=strsplit(wName,':');
        if length(parts)>1&&obj.ComponentMap.isKey(parts{1})&&...
            strcmp(obj.ComponentMap(parts{1}).Type,'Target')
            wName=['Target:',parts{2}];
            if obj.WidgetNameMap.isKey(wName)
                param=obj.WidgetNameMap(wName);
            else
                error('MetaConfigSet:WidgetNotInDataModel',['Widget ''',parts{2},''' not found in data model.']);
            end
        else
            error('MetaConfigSet:WidgetNotInDataModel',['Widget ''',wName,''' not found in data model.']);
        end
    end
    if nargin>2
        adp=varargin{1};
        cs=varargin{2};
        param=adp.getParamData(param,obj,cs,false);

        if isempty(param)
            return;
        end
    else
        param=obj.getParamAllFeatures(param);
    end
    if iscell(param)
        pList=param;
    else
        pList={param};
    end

    for p=1:length(pList)
        match=[];
        param=pList{p};
        if param.Hidden
            continue;
        end

        for i=1:length(param.WidgetList)
            if strcmp(wName,param.WidgetList{i}.Name)||strcmp(wName,param.WidgetList{i}.FullName)
                match=param.WidgetList{i};
                break;
            end
        end


        if isempty(match)&&(strcmp(wName,param.Name)||strcmp(wName,param.FullName))
            match=param;
        end

        if~isempty(match)
            if isempty(out)
                out=match;
            else
                if iscell(out)
                    out{end+1}=match;%#ok<AGROW>
                else
                    out={out,match};%#ok<AGROW>
                end
            end
        end

    end


