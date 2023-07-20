function blockInfo=getBlockInfo(this,hC)






















    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo.inMode=[strcmpi(sysObjHandle.PhaseIncrementSource,'Input port');
        strcmpi(sysObjHandle.PhaseOffsetSource,'Input port');
        strcmpi(sysObjHandle.DitherSource,'Input port');
        sysObjHandle.ResetAction;
1

        ];

        wform=lower(sysObjHandle.Waveform);

        blockInfo.outMode=[strcmp(wform,'sine')||strcmp(wform,'sine and cosine');
        strcmp(wform,'cosine')||strcmp(wform,'sine and cosine');
        strcmp(wform,'complex exponential');
        sysObjHandle.PhasePort];

        blockInfo.InternalDither=strcmpi(sysObjHandle.DitherSource,'Property');
        blockInfo.LUTCompress=sysObjHandle.LUTCompress;

        if strcmpi(sysObjHandle.PhaseIncrementSource,'Input port')
            blockInfo.PhaseInc=100;
        else
            blockInfo.PhaseInc=sysObjHandle.PhaseIncrement;
        end
        if strcmpi(sysObjHandle.PhaseOffsetSource,'Input port')
            blockInfo.PhaseOffset=0;
        else
            blockInfo.PhaseOffset=sysObjHandle.PhaseOffset;
        end
        if strcmpi(sysObjHandle.DitherSource,'Property')
            blockInfo.DitherBits=double(sysObjHandle.NumDitherBits);
        else
            blockInfo.DitherBits=4;
        end

        blockInfo.AccuWL=sysObjHandle.AccumulatorWL;
        blockInfo.PhaseQuantization=sysObjHandle.PhaseQuantization;
        blockInfo.outWL=sysObjHandle.OutputWL;
        blockInfo.outFL=sysObjHandle.OutputFL;
        blockInfo.SamplesPerFrame=double(sysObjHandle.SamplesPerFrame);
        if blockInfo.PhaseQuantization
            blockInfo.PhaseBits=sysObjHandle.NumQuantizerAccumulatorBits;
        else
            blockInfo.PhaseBits=blockInfo.AccuWL;
        end
    else

        bfp=hC.Simulinkhandle;

        blockInfo.inMode=[strcmpi(get_param(bfp,'PhaseIncrementSource'),'Input port');
        strcmpi(get_param(bfp,'PhaseOffsetSource'),'Input port');
        strcmpi(get_param(bfp,'DitherSource'),'Input port');
        strcmpi(get_param(bfp,'ResetAction'),'on');
1

        ];

        wform=lower(get_param(bfp,'Waveform'));

        blockInfo.outMode=[strcmp(wform,'sine')||strcmp(wform,'sine and cosine');
        strcmp(wform,'cosine')||strcmp(wform,'sine and cosine');
        strcmp(wform,'complex exponential');
        strcmpi(get_param(bfp,'PhasePort'),'on')];

        blockInfo.InternalDither=strcmpi(get_param(bfp,'DitherSource'),'Property');
        blockInfo.LUTCompress=strcmpi(get_param(bfp,'LUTCompress'),'on');

        if strcmpi(get_param(bfp,'PhaseIncrementSource'),'Input port')
            blockInfo.PhaseInc=100;
        else
            blockInfo.PhaseInc=this.hdlslResolve('PhaseIncrement',bfp);
        end
        if strcmpi(get_param(bfp,'PhaseOffsetSource'),'Input port')
            blockInfo.PhaseOffset=0;
        else
            blockInfo.PhaseOffset=this.hdlslResolve('PhaseOffset',bfp);
        end
        if strcmpi(get_param(bfp,'DitherSource'),'Property')
            blockInfo.DitherBits=double(this.hdlslResolve('NumDitherBits',bfp));
        else
            blockInfo.DitherBits=4;
        end

        blockInfo.AccuWL=this.hdlslResolve('AccumulatorWL',bfp);
        blockInfo.PhaseQuantization=strcmpi(get_param(bfp,'PhaseQuantization'),'on');
        blockInfo.outWL=this.hdlslResolve('OutputWL',bfp);
        blockInfo.outFL=this.hdlslResolve('OutputFL',bfp);
        blockInfo.SamplesPerFrame=double(this.hdlslResolve('SamplesPerFrame',bfp));
        if blockInfo.PhaseQuantization
            blockInfo.PhaseBits=this.hdlslResolve('NumQuantizerAccumulatorBits',bfp);
        else
            blockInfo.PhaseBits=blockInfo.AccuWL;
        end

    end







    blockInfo.resetnone=1;

    hdlnco=dsphdl.NCO('SamplesPerFrame',blockInfo.SamplesPerFrame);
    blockInfo.delay=getLatency(hdlnco);

    blockInfo.SimulinkRate=hC.PirOutputSignals(1).SimulinkRate;
end
