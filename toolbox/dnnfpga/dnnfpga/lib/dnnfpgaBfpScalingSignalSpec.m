function dnnfpgaBfpScalingSignalSpec(gcb,KdataType)




    if(isempty(KdataType))
        return;
    end


    ssName='DTC';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');
    try
        lh=get_param(ssPath,'LineHandles');
        delete_block(ssPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        InPortName='InData';
        OutPortName='OutData';
        add_block('hdlsllib/Signal Attributes/Signal Specification',[gcb,'/DTC'],'position',pos);
        if(strcmp(KdataType,'single'))
            set_param([gcb,'/DTC'],'OutDataTypeStr','Inherit: auto');
            set_param([gcb,'/DTC'],'Dimensions','-1');
        else
            set_param([gcb,'/DTC'],'OutDataTypeStr','uint32');
            set_param([gcb,'/DTC'],'Dimensions','[cc.fcp.opDDRRatio]');
        end
        add_line(gcb,[InPortName,'/1'],'DTC/1','autorouting','on');
        add_line(gcb,'DTC/1',[OutPortName,'/1'],'autorouting','on');
    catch
    end
end


