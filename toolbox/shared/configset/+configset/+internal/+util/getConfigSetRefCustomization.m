function out=getConfigSetRefCustomization()







    if slfeature('ConfigSetRefOverride')==2
        enabled='enabled="on" ';
    else
        enabled='enabled="off" ';
    end
    out=[...
'<configset_customization><custom id="Simulink.ConfigSet" '...
    ,enabled...
    ,'info="',getString(message('Simulink:ConfigSet:ConfigSetRef_ReadOnly')),'" '...
    ,'/></configset_customization>'];
