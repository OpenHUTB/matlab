function hdlcoderAttachConfigSet(bd)




    cs=get_param(bd,'ConfigurationSets');
    if~isempty(cs)


        attachhdlcconfig(bd);
    else


        Simulink.addBlockDiagramCallback(...
        bd,...
        'PostLoad',...
        'AttachHDLCoderConfigurationSetCallback',...
        @i_attachHDLCoderConfigSet);
    end
end

function i_attachHDLCoderConfigSet()
    opts=Simulink.internal.BDLoadOptions(bdroot);
    if opts.isLoading&&opts.isFromTemplate
        if(~isequal(class(getActiveConfigSet(bdroot)),'Simulink.ConfigSetRef'))


            attachhdlcconfig(bdroot);
        end
    end

end

