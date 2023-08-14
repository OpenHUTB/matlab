function dnnfpgaBfpScalingRenderWire(gcb,KdataType,debugPathSet)

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
            add_block('hdlsllib/Commonly Used Blocks/Data Type Conversion',[gcb,'/DTC'],'position',pos);
            set_param([gcb,'/DTC'],'OutDataTypeStr',KdataType);
            set_param([gcb,'/DTC'],'RndMeth','Nearest');
        else
            if(debugPathSet==1)
                add_block('dnnfpgaBfpScalinglib/DebuggerCode',[gcb,'/DTC'],'position',pos);
            else
                add_block('dnnfpgaBfpScalinglib/DataTypeInt8Convert',[gcb,'/DTC'],'position',pos);
            end
        end

        add_line(gcb,[InPortName,'/1'],'DTC/1','autorouting','on');
        add_line(gcb,'DTC/1',[OutPortName,'/1'],'autorouting','on');

    catch
    end
end