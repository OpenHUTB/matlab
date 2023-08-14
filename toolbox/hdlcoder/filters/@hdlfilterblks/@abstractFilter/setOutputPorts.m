function setOutputPorts(this,hF,hC)%#ok<INUSL>





    if(hC.SimulinkHandle~=-1)
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        numChannel=block.CompiledPortWidths.Inport(1);
    else


        numChannel=hF.numChannel;
    end

    outComplex=hF.isOutputPortComplex;

    dfname=hC.Name;
    ip=hdlgetparameter('instance_prefix');
    dfname=regexprep(dfname,['^',ip],'');
    foutname=[dfname,'_out'];

    hF.outputvectorvtype=hC.PirOutputSignals(1).VType;

    isChannelShared=0;
    fParams=this.filterImplParamNames;
    if any(strcmpi('channelsharing',fParams))
        if strcmpi(this.getImplParams('channelsharing'),'on')
            isChannelShared=1;
        end
    end

    if(numChannel==1)||~isChannelShared
        if outComplex
            hC.setOutputPortName(0,[foutname,hdlgetparameter('complex_real_postfix')]);
            hC.setOutputPortName(1,[foutname,hdlgetparameter('complex_imag_postfix')]);
        else
            hC.setOutputPortName(0,foutname);
        end
    else
        if hdlgetparameter('isvhdl')&&(hdlgetparameter('ScalarizePorts')~=1)
            if outComplex
                hC.setOutputPortName(0,[foutname,hdlgetparameter('complex_real_postfix')]);
                hC.setOutputPortName(1,[foutname,hdlgetparameter('complex_imag_postfix')]);
            else
                hC.setOutputPortName(0,foutname);
            end
        else
            if outComplex
                for n=1:numChannel
                    hC.setOutputPortName(n-1,[foutname,num2str(n),hdlgetparameter('complex_real_postfix')]);
                    hC.setOutputPortName(n-1+numChannel,[foutname,num2str(n),hdlgetparameter('complex_imag_postfix')]);
                end
            else
                for n=1:numChannel
                    hC.setOutputPortName(n-1,[foutname,num2str(n)]);
                end
            end
        end
    end
