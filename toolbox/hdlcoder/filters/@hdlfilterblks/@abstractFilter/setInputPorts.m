function inPortOffset=setInputPorts(this,hF,hC,inPortOffset)%#ok





    dfname=hC.Name;
    ip=hdlgetparameter('instance_prefix');
    dfname=regexprep(dfname,['^',ip],'');
    finname=[dfname,'_in'];

    if(hC.SimulinkHandle==-1)
        inComplex=hF.InputComplex;
        numChannel=hF.numChannel;






    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        inComplex=block.CompiledPortComplexSignals.Inport;
        numChannel=block.CompiledPortWidths.Inport(1);
    end

    hF.inputvectorvtype=hC.PirInputSignals(4).VType;

    isChannelShared=0;
    fParams=this.filterImplParamNames;
    if any(strcmpi('channelsharing',fParams))
        if strcmpi(this.getImplParams('channelsharing'),'on')
            isChannelShared=1;
        end
    end

    if(numChannel==1)||~isChannelShared
        if inComplex(1)
            hC.setInputPortName(inPortOffset,[finname,hdlgetparameter('complex_real_postfix')]);
            hC.setInputPortName(inPortOffset+1,[finname,hdlgetparameter('complex_imag_postfix')]);
            inPortOffset=inPortOffset+2;
            hF.setHDLParameter('InputComplex','on');
        else
            hC.setInputPortName(inPortOffset,finname);
            inPortOffset=inPortOffset+1;
        end
    else
        if hdlgetparameter('isvhdl')&&(hdlgetparameter('ScalarizePorts')~=1)

            hCurrentDriver=hdlcurrentdriver;
            topentityname=hCurrentDriver.getEntityTop;
            pkgname=[topentityname,hdlgetparameter('package_suffix')];
            hdlsetparameter('vhdl_package_name',pkgname);
            hdlsetparameter('vhdl_package_required',1)
            if inComplex(1)
                hC.setInputPortName(inPortOffset,[finname,hdlgetparameter('complex_real_postfix')]);
                hC.setInputPortName(inPortOffset+1,[finname,hdlgetparameter('complex_imag_postfix')]);
                inPortOffset=inPortOffset+2;
                hF.setHDLParameter('InputComplex','on');
            else
                hC.setInputPortName(inPortOffset,finname);
                inPortOffset=inPortOffset+1;
            end
        else
            if inComplex(1)
                for n=1:numChannel
                    hC.setInputPortName(inPortOffset+n-1,[finname,num2str(n),hdlgetparameter('complex_real_postfix')]);
                    hC.setInputPortName(inPortOffset+n-1+numChannel,[finname,num2str(n),hdlgetparameter('complex_imag_postfix')]);
                end
                inPortOffset=inPortOffset+2*numChannel;
                hF.setHDLParameter('InputComplex','on');
            else
                for n=1:numChannel
                    hC.setInputPortName(inPortOffset+n-1,[finname,num2str(n)]);
                end
                inPortOffset=inPortOffset+numChannel;
            end
        end
    end
