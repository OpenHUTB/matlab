function out=createCustomFunction(type,str)


    if~isempty(str)
        if isempty(strfind(str,'.'))


            if strcmp(type,'configset.internal.data.WidgetStaticData')
                str=['configset.internal.customwidget.',str];
            else
                str=['configset.internal.custom.',str];
            end
        end
        out=str;
    else
        out='';
    end

end

