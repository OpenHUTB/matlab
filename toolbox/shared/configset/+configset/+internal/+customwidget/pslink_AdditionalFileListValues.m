function out=pslink_AdditionalFileListValues(cs,name,direction,widgetVals)


    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('Polyspace');
    else
        hObj=cs;
    end

    if direction==0
        val=hObj.get_param(name);
        out={val,configset.internal.getMessage('polyspace:gui:pslink:GUIprjConfLbl'),''};
    elseif direction==1
        out=widgetVals{1};
    end

