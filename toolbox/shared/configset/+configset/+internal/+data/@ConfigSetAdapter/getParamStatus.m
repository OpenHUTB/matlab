function out=getParamStatus(obj,name,varargin)









    if nargin<3
        pd=obj.getParamData(name);
    else
        pd=varargin{1};
    end

    cs=obj.getCS;

    if isempty(pd)
        if cs.isValidParam(name)
            out=0;
        else
            out=3;
        end
    else

        if isempty(pd.WidgetList)
            out=obj.getParamWidgetStatus(name,pd);
        else
            status=obj.getWidgetStatusList(name,pd);
            data=obj.getWidgetDataList(name,pd);
            if length(pd.WidgetList)==1

                out=obj.getParamWidgetStatus(name,pd.WidgetList{1});
            else
                out=min(cellfun(@(s,d)(loc_editableStatus(d,s)),...
                status,data));
            end
        end

    end
end


function out=loc_editableStatus(data,status)



    if ismember(data.WidgetType,{'pushbutton','image','hyperlink'})
        out=int8(3);
    else
        out=status;
    end
end

