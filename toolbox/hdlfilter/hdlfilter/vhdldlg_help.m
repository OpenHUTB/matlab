function y=vhdldlg_help

    y.tag_mapping=@tag_mapping;


    function tag=tag_mapping(hFig,tag)

        [tag,tbx]=strtok(tag,filesep);

        switch tag
        case 'hdlgui_language_serialpartitionstr',
            hc=findobj(hFig,'Tag','architectures');
            if get(hc,'value')==5
                tag='hdlguioptions_LUT_Partition';
            else
                tag='hdlgui_language_serial_partition';
            end
        case 'hdlgui_language_daradixstr'
            tag='hdloptions_DARadix';
        end


        tag=[tag,tbx];
