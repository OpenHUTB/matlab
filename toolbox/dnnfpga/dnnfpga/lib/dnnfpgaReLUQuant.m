function dnnfpgaReLUQuant(gcb,kernelDataType,PipelineLatency)
    if(isempty(kernelDataType))
        kernelDataType='single';
    end
    if(isempty(PipelineLatency))
        return;
    end

    ssName='QReLU';
    ssPath=[gcb,'/',ssName];
    pos=get_param(ssPath,'Position');
    try
        lh=get_param(ssPath,'LineHandles');
        delete_block(ssPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);
        InPortName1='InData';
        InPortName2='Exp';
        OutPortName='OutData';

        if(strcmp(kernelDataType,'single'))
            add_block('built-in/Delay',[gcb,'/QReLU'],'position',pos);


            set_param([gcb,'/QReLU'],'DelayLength','3*PipelineLatency');
        else
            add_block('dnnfpgaBfpScalinglib/leakyReLUShift',[gcb,'/QReLU'],'position',pos);
            add_line(gcb,'Exp/1','QReLU/2','autorouting','on');


            set_param([gcb,'/QReLU'],'FractionBits','FractionBits');
            set_param([gcb,'/QReLU'],'OutputBitWidth','OutputBitWidth');
        end

        add_line(gcb,'InData/1','QReLU/1','autorouting','on');
        add_line(gcb,'QReLU/1','OutData/1','autorouting','on');

    catch
        disp('Cant Render ReLU block');
    end
end

