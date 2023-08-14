function dnnfpgaDatamemlibRenderBFPDataMem(gcb,KernelDataType)

    if(isempty(KernelDataType))
        return;
    end

    outPortPosOrig=[840,558,870,572];
    ssName='DataMem';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');

    try
        lh=get_param(ssPath,'LineHandles');
        delete_block(ssPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);


        redrawDataMem(pos,[gcb,'/',ssName],KernelDataType);


        InPortName1='WrBus1';
        InPortName2='WrBus2';
        InPortName3='WrBus3';
        InPortName4='RdBus1';
        InPortName5='RdBus2';
        InPortName6='zMode';
        OutPortName1='RdDataA';
        OutPortName2='RdDataB';

        add_line(gcb,[InPortName1,'/1'],[ssName,'/1'],'autorouting','on');
        add_line(gcb,[InPortName2,'/1'],[ssName,'/2'],'autorouting','on');
        add_line(gcb,[InPortName3,'/1'],[ssName,'/3'],'autorouting','on');
        add_line(gcb,[InPortName4,'/1'],[ssName,'/4'],'autorouting','on');
        add_line(gcb,[InPortName5,'/1'],[ssName,'/5'],'autorouting','on');
        add_line(gcb,[InPortName6,'/1'],[ssName,'/6'],'autorouting','on');
        add_line(gcb,[ssName,'/1'],[OutPortName1,'/1'],'autorouting','on');
        add_line(gcb,[ssName,'/2'],[OutPortName2,'/1'],'autorouting','on');

    catch me
    end

end

function redrawDataMem(pos,curgcb,KernelDataType)

    root=fileparts(curgcb);



    if(strcmp(KernelDataType,'single'))
        add_block('dnnfpgaNewdatamemlib/DataMem1',curgcb,'Position',pos);


    else
        add_block('dnnfpgaNewdatamemlib/DataMemBFP',curgcb,'Position',pos);


    end

end
