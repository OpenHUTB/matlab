function setupCoeffPorts(this,hF,hC,inPortOffset)%#ok<INUSL>




    if(hC.SimulinkHandle~=-1)
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        inComplex=block.CompiledPortComplexSignals.Inport;
    else
        inComplex=hF.InputComplex;
    end

    dfname=hC.Name;
    ip=hdlgetparameter('instance_prefix');
    dfname=regexprep(dfname,['^',ip],'');

    cinname=[dfname,'_',hdlgetparameter('filter_coeff_name')];
    hF.setHDLParameter('CoeffPrefix',cinname);
    hF.coeffvectorvtype=hC.PirInputSignals(end).VType;
    if hdlgetparameter('isvhdl')&&(hdlgetparameter('ScalarizePorts')~=1)

        hCurrentDriver=hdlcurrentdriver;
        topentityname=hCurrentDriver.getEntityTop;
        pkgname=[topentityname,hdlgetparameter('package_suffix')];
        hdlsetparameter('vhdl_package_name',pkgname);
        hdlsetparameter('vhdl_package_required',1)

        if inComplex(2)
            hC.setInputPortName(inPortOffset,[cinname,hdlgetparameter('complex_real_postfix')]);
            hC.setInputPortName(inPortOffset+1,[cinname,hdlgetparameter('complex_imag_postfix')]);
        else
            hC.setInputPortName(inPortOffset,cinname);
        end
    else
        if inComplex(2)
            for n=1:length(hF.Coefficients)
                hC.setInputPortName(inPortOffset+(n-1),...
                [cinname,num2str(n),hdlgetparameter('complex_real_postfix')]);
            end
            for n=1:length(hF.Coefficients)
                hC.setInputPortName(inPortOffset+length(hF.Coefficients)+(n-1),...
                [cinname,num2str(n),hdlgetparameter('complex_imag_postfix')]);
            end
        else
            for n=1:length(hF.Coefficients)
                hC.setInputPortName(inPortOffset+n-1,[cinname,num2str(n)]);
            end
        end
    end
