function info=getCoeffPrecInfo(this,action)














    info=cell(1,3);
    switch(action)
    case 'MASK_NAMES'
        info{1}='firstCoeffFracLength';
        info{2}='secondCoeffFracLength';
        info{3}='scaleValueFracLength';

    case{'FL_SCHEMA','SL_SCHEMA'}
        info{1}.Visible=1;
        info{2}.Name='Den:';
        info{3}.Name='Scale values:';
        if strcmp(this.DialogModeTransferFunction,'IIR (poles & zeros)')
            info{1}.Name='Num:';
            info{2}.Visible=1;
            if strncmp(this.DialogModeIIRStructure,'Biquad direct',13)
                info{3}.Visible=1;
            else
                info{3}.Visible=0;
            end
        else
            info{1}.Name='';
            info{2}.Visible=0;
            info{3}.Visible=0;
        end
    end
