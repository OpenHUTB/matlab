function[success,msg]=dlgCallback(obj,dlg,action)











    switch action
    case{'Ok','Apply'}
        i_ok(obj,dlg)
    otherwise

    end
    obj.DialogData=[];
    success=true;
    msg='';
end

function i_ok(obj,~)

    data=obj.DialogData;
    if isempty(data)

        return;
    else
        h=obj.SimulinkHandle;
        i_set(h,data,'Block');
        i_set(h,data,'Line');
        i_set(h,data,'Annotation');
    end
end

function i_set(h,data,tag)
    data=data.(tag);
    set_param(h,['Default',tag,'FontName'],data.FontName);
    set_param(h,['Default',tag,'FontSize'],data.FontSize);
    set_param(h,['Default',tag,'FontWeight'],data.FontWeight);
    set_param(h,['Default',tag,'FontAngle'],data.FontAngle);
end


