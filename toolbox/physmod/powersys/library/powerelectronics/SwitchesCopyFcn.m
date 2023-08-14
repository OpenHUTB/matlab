function SwitchesCopyFcn(Device,block)








    if strcmp(get_param([block,'/Goto'],'blocktype'),'Goto')

        set_param([block,'/Goto'],'GotoTag','LibraryTag','TagVisibility','Global');
    end


    if strcmp(get_param([block,'/Status'],'blocktype'),'From')

        set_param([block,'/Status'],'GotoTag','LibraryTag','TagVisibility','Global');
    end


    if strcmp(get_param([block,'/Uswitch'],'blocktype'),'From')

        set_param([block,'/Uswitch'],'GotoTag','LibraryTag','TagVisibility','Global');
    end


    switch Device
    case{'Diode','Thyristor','GTO','IGBT','Detailed Thyristor','Universal Bridge','Three Level Bridge'}
        if strcmp(get_param([block,'/VF'],'blocktype'),'Goto')

            set_param([block,'/VF'],'GotoTag','LibraryTag','TagVisibility','Global');
        end
    end


    switch Device
    case{'Diode','Thyristor','GTO','IGBT','Detailed Thyristor','Universal Bridge'}
        if strcmp(get_param([block,'/ISWITCH'],'blocktype'),'Goto')

            set_param([block,'/ISWITCH'],'GotoTag','LibraryTag','TagVisibility','Global');
        end
    end


    switch Device
    case{'Universal Bridge'}
        if strcmp(get_param([block,'/ISWITCH1'],'blocktype'),'Goto')

            set_param([block,'/ISWITCH1'],'GotoTag','LibraryTag','TagVisibility','Global');
        end
    end


    switch Device
    case{'GTO','IGBT','Universal Bridge','Three Level Bridge'}
        if strcmp(get_param([block,'/ITAIL'],'blocktype'),'Goto')

            set_param([block,'/ITAIL'],'GotoTag','LibraryTag','TagVisibility','Global');
        end
    end