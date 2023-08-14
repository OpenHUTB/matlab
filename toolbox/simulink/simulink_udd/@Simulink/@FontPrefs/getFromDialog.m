function getFromDialog(obj,dlg)









    obj.DialogData=[];
    i_get(obj,dlg,'Block');
    i_get(obj,dlg,'Line');
    i_get(obj,dlg,'Annotation');

end

function i_get(obj,dlg,tag)

    [faces,ignore,sizes]=obj.allowedValues;

    x.FontName=faces{dlg.getWidgetValue([tag,'FontName'])+1};
    x.FontSize=sizes(dlg.getWidgetValue([tag,'FontSize'])+1);
    [x.FontWeight,x.FontAngle]=...
    i_style(dlg.getWidgetValue([tag,'FontStyle']));

    obj.DialogData.(tag)=x;
end


function[weight,angle]=i_style(style)

    is_bold=style==1||style==3;
    is_italic=style==2||style==3;
    if is_bold
        weight='bold';
    else
        weight='normal';
    end
    if is_italic
        angle='italic';
    else
        angle='normal';
    end

end
