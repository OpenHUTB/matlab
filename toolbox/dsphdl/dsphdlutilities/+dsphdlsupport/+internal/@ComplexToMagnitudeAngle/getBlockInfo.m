function blockInfo=getBlockInfo(this,hC)












    blockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo.AngleFormat=sysObjHandle.AngleFormat;
        blockInfo.ScaleOutput=sysObjHandle.ScaleOutput;
        blockInfo.UseMultipliers=strcmpi(sysObjHandle.ScalingMethod,'Multiplier');
        outputFormat=(sysObjHandle.OutputFormat);
        blockInfo.outMode=[strcmpi(outputFormat,'Magnitude');strcmpi(outputFormat,'Angle');...
        strcmpi(outputFormat,'Magnitude and Angle')];
        blockInfo.NumIterationsSource=sysObjHandle.NumIterationsSource;
        if strcmpi(blockInfo.NumIterationsSource,'Auto')
            blockInfo.NumIterations=10;
        else
            blockInfo.NumIterations=sysObjHandle.NumIterations;
        end


    else
        bfp=hC.Simulinkhandle;
        blockInfo.outMode=[strcmpi((get_param(bfp,'OutputFormat')),'Magnitude');strcmpi(get_param(bfp,'OutputFormat'),'Angle');...
        strcmpi((get_param(bfp,'OutputFormat')),'Magnitude and Angle')];

        blockInfo.AngleFormat=get_param(bfp,'AngleFormat');
        blockInfo.ScaleOutput=strcmpi(get_param(bfp,'ScaleOutput'),'on');
        blockInfo.UseMultipliers=strcmpi(get_param(bfp,'ScalingMethod'),'Multiplier');
        blockInfo.NumIterationsSource=get_param(bfp,'NumIterationsSource');
        if strcmpi(get_param(bfp,'NumIterationsSource'),'Auto')
            blockInfo.NumIterations=10;
        else
            blockInfo.NumIterations=this.hdlslResolve('NumIterations',bfp);
        end
    end
end

