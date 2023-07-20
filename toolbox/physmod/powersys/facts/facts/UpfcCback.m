function UpfcCback(block,PO)






    if~exist('PO','var')
        PO=0;
    end


    BlockName=getfullname(block);




    VOLTAGEREGULATION=strcmp('Voltage regulation',get_param(BlockName,'OpMode_SH'));
    WANT_EXTERNAL_VREF=strcmp('on',get_param(BlockName,'ExternalVref'));
    WANT_INTERNAL_VREF=strcmp('off',get_param(BlockName,'ExternalVref'));
    HAVE_EXTERNAL_VREF=strcmp('Inport',get_param([BlockName,'/Vref '],'BlockType'));


    POWERFLOWCONTROL=strcmp('Power flow control',get_param(BlockName,'OpMode_SE'));
    WANT_EXTERNAL_BYPASS=strcmp('External control',get_param(BlockName,'ExternalByPass'));
    HAVE_EXTERNAL_BYPASS=strcmp('Inport',get_param([BlockName,'/Bypass '],'BlockType'));

    WANT_EXTERNAL_VDQREF=strcmp('on',get_param(BlockName,'ExternalVdqref'));
    WANT_INTERNAL_VDQREF=strcmp('off',get_param(BlockName,'ExternalVdqref'));
    HAVE_EXTERNAL_VDQREF=strcmp('Inport',get_param([BlockName,'/Vdqref '],'BlockType'));

    WANT_EXTERNAL_PQREF=strcmp('on',get_param(BlockName,'ExternalPQref'));
    WANT_INTERNAL_PQREF=strcmp('off',get_param(BlockName,'ExternalPQref'));
    HAVE_EXTERNAL_PQREF=strcmp('Inport',get_param([BlockName,'/PQref '],'BlockType'));



    MV=get_param(block,'MaskVisibilities');


    if VOLTAGEREGULATION

        MV{11}='on';
        MV{12}='on';
        MV{13}='on';
        MV{14}='on';
        MV{15}='on';
        MV{16}='off';
        MV{17}='off';

    else

        MV{11}='off';
        MV{12}='off';
        MV{13}='off';
        MV{14}='off';
        MV{15}='off';
        MV{16}='on';
        MV{17}='on';

    end


    if POWERFLOWCONTROL

        MV{22}='on';
        MV{23}='on';
        MV{24}='on';
        MV{25}='on';
        MV{26}='off';
        MV{27}='off';
        MV{28}='off';

    else

        MV{22}='off';
        MV{23}='off';
        MV{24}='off';
        MV{25}='off';
        MV{26}='on';
        MV{27}='on';
        MV{28}='on';

    end

    set_param(BlockName,'MaskVisibilities',MV);



    ME=get_param(block,'MaskEnables');

    if WANT_EXTERNAL_VREF
        ME{11}='off';
    else
        ME{11}='on';
    end
    if WANT_EXTERNAL_PQREF
        ME{22}='off';
    else
        ME{22}='on';
    end
    if WANT_EXTERNAL_VDQREF
        ME{26}='off';
    else
        ME{26}='on';
    end

    set_param(block,'Maskenables',ME);




    if PO==0
        return
    end


    if WANT_EXTERNAL_BYPASS&&~HAVE_EXTERNAL_BYPASS
        replace_block(BlockName,'Followlinks','on','Name','Bypass ','Inport','noprompt');
        set_param([BlockName,'/Bypass '],'Port','2');
    end

    if~WANT_EXTERNAL_BYPASS
        if HAVE_EXTERNAL_BYPASS
            replace_block(BlockName,'Followlinks','on','Name','Bypass ','Constant','noprompt');
        end
        if strcmp('Closed',get_param(BlockName,'ExternalByPass'));
            Value_ByPass='1';
        else
            Value_ByPass='0';
        end
        set_param([BlockName,'/Bypass '],'Value',Value_ByPass);
    end


    if(VOLTAGEREGULATION&&WANT_EXTERNAL_VREF)&&~HAVE_EXTERNAL_VREF

        replace_block(BlockName,'Followlinks','on','Name','Vref ','Inport','noprompt');

        if~WANT_EXTERNAL_BYPASS
            set_param([BlockName,'/Vref '],'Port','2');
        else
            set_param([BlockName,'/Vref '],'Port','3');
        end

    elseif(VOLTAGEREGULATION&&WANT_INTERNAL_VREF)&&HAVE_EXTERNAL_VREF

        replace_block(BlockName,'Followlinks','on','Name','Vref ','Constant','noprompt');
        set_param([BlockName,'/Vref '],'Value','Vref_SH');

    elseif~VOLTAGEREGULATION&&HAVE_EXTERNAL_VREF

        replace_block(BlockName,'Followlinks','on','Name','Vref ','Constant','noprompt');
        set_param([BlockName,'/Vref '],'Value','Vref_SH');

    end


    if(POWERFLOWCONTROL&&WANT_EXTERNAL_PQREF)&&~HAVE_EXTERNAL_PQREF

        replace_block(BlockName,'Followlinks','on','Name','PQref ','Inport','noprompt');

        PORT=2;
        if WANT_EXTERNAL_BYPASS
            PORT=3;
        end

        if(VOLTAGEREGULATION&&WANT_EXTERNAL_VREF)
            PORT=PORT+1;
        end

        set_param([BlockName,'/PQref '],'Port',num2str(PORT));

    elseif(POWERFLOWCONTROL&&WANT_INTERNAL_PQREF)&&HAVE_EXTERNAL_PQREF

        replace_block(BlockName,'Followlinks','on','Name','PQref ','Constant','noprompt');
        set_param([BlockName,'/PQref '],'Value','PQref_SE');

    elseif~POWERFLOWCONTROL&&HAVE_EXTERNAL_PQREF

        replace_block(BlockName,'Followlinks','on','Name','PQref ','Constant','noprompt');
        set_param([BlockName,'/PQref '],'Value','PQref_SE');

    end


    if(~POWERFLOWCONTROL&&WANT_EXTERNAL_VDQREF)&&~HAVE_EXTERNAL_VDQREF

        replace_block(BlockName,'Followlinks','on','Name','Vdqref ','Inport','noprompt');

        PORT=2;
        if WANT_EXTERNAL_BYPASS
            PORT=3;
        end

        if(VOLTAGEREGULATION&&WANT_EXTERNAL_VREF)
            PORT=PORT+1;
        end

        set_param([BlockName,'/Vdqref '],'Port',num2str(PORT));

    elseif(~POWERFLOWCONTROL&&WANT_INTERNAL_VDQREF)&&HAVE_EXTERNAL_VDQREF

        replace_block(BlockName,'Followlinks','on','Name','Vdqref ','Constant','noprompt');
        set_param([BlockName,'/Vdqref '],'Value','Vdqref_SE');

    elseif POWERFLOWCONTROL&&HAVE_EXTERNAL_VDQREF

        replace_block(BlockName,'Followlinks','on','Name','Vdqref ','Constant','noprompt');
        set_param([BlockName,'/Vdqref '],'Value','Vdqref_SE');

    end