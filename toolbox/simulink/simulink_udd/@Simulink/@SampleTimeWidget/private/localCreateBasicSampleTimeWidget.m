function value=localCreateBasicSampleTimeWidget(tag,prmIndex,prmValue,source,methods)



    if prmIndex>=0
        stParamName=source.getDialogParams{prmIndex+1};
        intrinsicParameters=get_param(source.getBlock.handle,'IntrinsicDialogParameters');
        stPrompt=intrinsicParameters.(stParamName).Prompt;
    else
        stPrompt=DAStudio.message('Simulink:blkprm_prompts:AllBlksSampleTime');
    end


    value.Type='edit';
    value.Name=stPrompt;
    value.Tag=tag;
    value.Value=prmValue;
    value=localHandleEditEvent(value,prmIndex,prmValue,source,methods);
    value.NameLocation=2;

end
