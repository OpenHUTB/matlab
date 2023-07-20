function v=validateFilterImplParams(this,hC)





    fparams=lower(this.filterImplParamNames);

    v=hdlvalidatestruct;



    if any(strncmp('coeffmultipliers',fparams,16))
        v=validateEnumParam(this,hC,'CoeffMultipliers',...
        {'Multiplier','csd','factored-csd'});
    end
    if any([v.Status])
        return;
    end
    if any(strncmp('dalutpartition',fparams,14))&&~isempty(this.getImplParams('DALUTPartition'))...
        ||any(strncmp('daradix',fparams,7))&&~isempty(this.getImplParams('DARadix'))
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');


        switch block.FilterSource
        case 'Input port(s)'
        case 'Specify via dialog'
            switch block.TypePopup
            case 'IIR (all poles)'
            case 'FIR (all zeros)'
                switch block.FIRFiltStruct
                case{'Direct form',...
                    'Direct form symmetric',...
                    'Direct form antisymmetric',...
                    'Direct form transposed'}
                    v=validateDA(this,hC);
                otherwise

                end
            case 'IIR (poles & zeros)'
                v=validateDA(this,hC);
            end
        case 'dfilt object'
            v=validateDA(this,hC);
        end
    end

    if any(strncmp('serialpartition',fparams,15))&&~isempty(this.getImplParams('SerialPartition'))||...
        any(strncmp('reuseaccum',fparams,10))&&~isempty(this.getImplParams('ReuseAccum'))

        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');


        switch block.FilterSource
        case 'Input port(s)'
        case 'Specify via dialog'
            switch block.TypePopup
            case 'IIR (all poles)'
            case 'FIR (all zeros)'
                switch block.FIRFiltStruct
                case{'Direct form',...
                    'Direct form symmetric',...
                    'Direct form antisymmetric',...
                    'Direct form transposed'}
                    v=validateSerialPartition(this,hC);
                otherwise

                end
            case 'IIR (poles & zeros)'
                v=validateSerialPartition(this,hC);
            end
        case 'dfilt object'
            v=validateSerialPartition(this,hC);
        end
    end

    if any(strncmp('addpipelineregisters',fparams,20))&&~isempty(this.getImplParams('AddPipelineRegisters'))||...
        any(strncmp('multiplierinputpipeline',fparams,23))&&~isempty(this.getImplParams('MultiplierInputPipeline'))||...
        any(strncmp('multiplieroutputpipeline',fparams,24))&&~isempty(this.getImplParams('MultiplierOutputPipeline'))

        if any(strncmp('addpipelineregisters',fparams,20))
            iparam='overallpipe';
        elseif any(strncmp('multiplierinputpipeline',fparams,23))
            iparam='multinput';
        elseif any(strncmp('multiplieroutputpipeline',fparams,24))
            iparam='multoutput';
        else error(message('hdlcoder:validate:Internalerror'));
        end

        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');


        switch block.FilterSource
        case 'Specify via dialog'
            switch block.TypePopup
            case 'FIR (all zeros)'
                switch block.FIRFiltStruct
                case{'Direct form',...
                    'Direct form symmetric',...
                    'Direct form antisymmetric'}
                    hF=this.createHDLFilterObj(hC);
                    v=[v,validatePipelineRegisters(hF,iparam)];
                    v=[v,checkFullPrecision(hF)];
                case 'Direct form transposed'
                    hF=this.createHDLFilterObj(hC);
                    v=[v,validatePipelineRegisters(hF,iparam)];
                otherwise

                end
            case 'IIR (poles & zeros)'
                switch block.FIRFiltStruct
                case{'Biquad direct form I (SOS)',...
                    'Biquad direct form I transposed (SOS)',...
                    'Biquad direct form II (SOS)',...
                    'Biquad direct form II transposed (SOS)'}
                    hF=this.createHDLFilterObj(hC);
                    v=[v,validatePipelineRegisters(hF,iparam)];
                otherwise

                end
            otherwise

            end
        case 'dfilt object'
            hF=this.createHDLFilterObj(hC);
            v=[v,validatePipelineRegisters(hF,iparam)];
            v=[v,checkFullPrecision(hF)];
        otherwise

        end
    end
    v=[v,validateParallel(this,hC)];
    v=[v,this.validateMulticlockFilterParams(fparams,hC)];


    function v=validatePipelineRegisters(hF,iparam)





        v=hdlvalidatestruct;


        flags=hF.isPipelineSupported;
        switch iparam
        case 'overallpipe'
            if~flags.overallpipe
                err=1;
                v=hdlvalidatestruct(err,message('hdlcoder:filters:validate:UnsupportedImplParam','AddPipeLineRegisters'));
            end
        case 'multinput'
            if~flags.multinput
                err=1;
                v=hdlvalidatestruct(err,message('hdlcoder:filters:validate:UnsupportedImplParam','MultiplierInputPipeline'));
            end
        case 'multoutput'
            if~flags.multoutput
                err=1;
                v=hdlvalidatestruct(err,message('hdlcoder:filters:validate:UnsupportedImplParam','MultiplierOutputPipeline'));
            end
        end





