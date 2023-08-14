function dnnfpgaBfpScalingRenderDataType(gcb,KdataType,debugPathSet)

    if(isempty(KdataType))
        return;
    end

    if(isempty(debugPathSet))
        debugPathSet=0;
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

        if(strcmp(KdataType,'single'))
            add_block('hdlsllib/HDL Floating Point Operations/Float Typecast',[gcb,'/DTC'],'position',pos);
            add_line(gcb,[InPortName,'/1'],'DTC/1','autorouting','on');
            add_line(gcb,'DTC/1',[OutPortName,'/1'],'autorouting','on');
        else
            add_block('hdlsllib/Commonly Used Blocks/Data Type Conversion',[gcb,'/DTC'],'position',pos);
            if(debugPathSet==1)
                set_param([gcb,'/DTC'],'OutDataTypeStr','uint32');
            else
                set_param([gcb,'/DTC'],'OutDataTypeStr',KdataType);
            end
            set_param([gcb,'/DTC'],'RndMeth','Nearest');
            add_line(gcb,[InPortName,'/1'],'DTC/1','autorouting','on');
            add_line(gcb,'DTC/1',[OutPortName,'/1'],'autorouting','on');
        end
    catch
    end
end