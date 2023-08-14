function getFromSimulink(obj)









    obj.DialogData=[];
    i_get(obj,'Block');
    i_get(obj,'Line');
    i_get(obj,'Annotation');

end

function i_get(obj,tag)

    h=obj.SimulinkHandle;
    x.FontName=get_param(h,['Default',tag,'FontName']);
    x.FontSize=get_param(h,['Default',tag,'FontSize']);
    x.FontWeight=get_param(h,['Default',tag,'FontWeight']);
    x.FontAngle=get_param(h,['Default',tag,'FontAngle']);
    obj.DialogData.(tag)=x;

end



