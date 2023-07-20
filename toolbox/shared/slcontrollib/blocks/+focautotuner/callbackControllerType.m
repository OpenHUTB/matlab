function callbackControllerType(blkh,loop)







    if~strcmp(get_param(bdroot(blkh),'SimulationStatus'),'stopped')
        return
    end
    maskObj=Simulink.Mask.get(blkh);
    TypeString=horzcat('PIDType',loop);
    selection=get_param(blkh,TypeString);


    Istring=horzcat('IntegratorMethod',loop);
    objectI=maskObj.Parameters.findobj('Name',Istring);
    if ismember('I',selection)
        objectI.Enabled='on';
    else
        objectI.Enabled='off';
    end


    Dstring=horzcat('FilterMethod',loop);
    objectD=maskObj.Parameters.findobj('Name',Dstring);
    if ismember('F',selection)
        objectD.Enabled='on';
    else
        objectD.Enabled='off';
    end


