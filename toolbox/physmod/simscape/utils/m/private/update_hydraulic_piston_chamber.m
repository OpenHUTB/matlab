function out=update_hydraulic_piston_chamber(hBlock)






    set_param(hBlock,'Commented','on')


    h=get_param(hBlock,'LineHandles');
    if h.LConn(2)~=-1
        delete_line(h.LConn(2));
    end


    removed_block_warning.subsystem=getfullname(hBlock);

    translational_converter_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Elements'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Elements/Translational Mechanical Converter (IL)'''' )" >Translational Mechanical Converter (IL) block</a>';
    removed_block_warning.messages={['Consider modeling fluid compressibility with a ',translational_converter_hyperlink,'.']};

    out.removed_block_warning=removed_block_warning;
end



