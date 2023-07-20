function info=getAccumPrecInfo(this,action)














    info=cell(1,2);
    switch(action)
    case 'MASK_NAMES'
        info{1}='accumFracLength';
        info{2}='tapSumFracLength';

    case{'FL_SCHEMA','SL_SCHEMA'}
        info{1}.Visible=1;
        info{2}.Name='Tap sum:';
        if this.FilterSource==0

            TransferFunction=this.DialogModeTransferFunction;
            FIRStructure=this.DialogModeFIRStructure;
        elseif this.FilterSource==1

            TransferFunction=this.PortsModeTransferFunction;
            FIRStructure=this.PortsModeFIRStructure;
        end
        if(strcmp(TransferFunction,'FIR (all zeros)')&&...
            (strcmp(FIRStructure,'Direct form symmetric')||...
            strcmp(FIRStructure,'Direct form antisymmetric')))
            info{1}.Name='Accum:';
            info{2}.Visible=1;
        else
            info{1}.Name='';
            info{2}.Visible=0;
        end
    end
