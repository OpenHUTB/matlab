function[sgrpInfo,cpArray]=explorer()



    sgrpInfo.Name=pm_message('sm:sli:configParameters:explorer:Name');
    sgrpInfo.Description=pm_message('sm:sli:configParameters:explorer:Description');

    cpArray(1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Name=pm_message(...
    'sm:sli:configParameters:explorer:openEditorOnUpdate:ParamName');
    cpArray(end).Label=pm_message(...
    'sm:sli:configParameters:explorer:openEditorOnUpdate:Label');
    cpArray(end).DataType='slbool';
    cpArray(end).DefaultValue='on';
    cpArray(end).Visible=true;


    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Name=pm_message(...
    'mech2:sli:explorer:explorerSettings:ParamName');
    cpArray(end).Label=pm_message(...
    'mech2:sli:explorer:explorerSettings:Label');
    cpArray(end).DataType='string';
    cpArray(end).DefaultValue='';
    cpArray(end).Visible=false;

end
