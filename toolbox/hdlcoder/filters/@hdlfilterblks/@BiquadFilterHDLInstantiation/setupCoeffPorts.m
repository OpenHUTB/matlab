function setupCoeffPorts(this,hF,hC,inPortOffset)%#ok<INUSL>






    if~(hC.SimulinkHandle==-1)
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        inComplex=block.CompiledPortComplexSignals.Inport;
        scale_port=strcmpi(block.ScaleValueMode,'Specify via input port (g)');
    else

        scale_port=hF.scalePort;
        inComplex(1)=hF.InputComplex;


        inComplex(2)=~isreal(hF.Coefficients(1:3));
        inComplex(3)=~isreal(hF.Coefficients(4:6));
        inComplex(4)=~isreal(hF.ScaleValues);
        inSignals=hC.getInputSignals('data');





    end

    dfname=hC.Name;
    ip=hdlgetparameter('instance_prefix');
    dfname=regexprep(dfname,['^',ip],'');

    cinname=dfname;
    hF.setHDLParameter('CoeffPrefix',cinname);

    if scale_port
        hF.HDLParameters.INI.setProp('filter_generate_biquad_scale_port',1);
        if(hC.SimulinkHandle~=-1)
            hF.coeffvectorvtype={hC.SLInputSignals(2).VType,...
            hC.SLInputSignals(3).VType,hC.SLInputSignals(4).VType};
        else
            hF.coeffvectorvtype={inSignals(2).VType,...
            inSignals(3).VType,inSignals(4).VType};
        end
    else
        if(hC.SimulinkHandle~=-1)
            hF.coeffvectorvtype={hC.SLInputSignals(2).VType,...
            hC.SLInputSignals(3).VType};
        else
            hF.coeffvectorvtype={inSignals(2).VType,...
            inSignals(3).VType};
        end
    end

    if hdlgetparameter('isvhdl')&&(hdlgetparameter('ScalarizePorts')~=1)

        hCurrentDriver=hdlcurrentdriver;
        topentityname=hCurrentDriver.getEntityTop;
        pkgname=[topentityname,hdlgetparameter('package_suffix')];
        hdlsetparameter('vhdl_package_name',pkgname);
        hdlsetparameter('vhdl_package_required',1)


        if inComplex(2)
            hC.setInputPortName(inPortOffset,[cinname,'_num',hdlgetparameter('complex_real_postfix')])
            hC.setInputPortName(inPortOffset+1,[cinname,'_num',hdlgetparameter('complex_imag_postfix')]);
            inPortOffset=inPortOffset+2;
        else
            hC.setInputPortName(inPortOffset,[cinname,'_num']);
            inPortOffset=inPortOffset+1;
        end


        if inComplex(3)
            hC.setInputPortName(inPortOffset,[cinname,'_den',hdlgetparameter('complex_real_postfix')])
            hC.setInputPortName(inPortOffset+1,[cinname,'_den',hdlgetparameter('complex_imag_postfix')]);
            inPortOffset=inPortOffset+2;
        else
            hC.setInputPortName(inPortOffset,[cinname,'_den']);
            inPortOffset=inPortOffset+1;
        end


        if scale_port
            if inComplex(4)
                hC.setInputPortName(inPortOffset,[cinname,'_g',hdlgetparameter('complex_real_postfix')])
                hC.setInputPortName(inPortOffset+1,[cinname,'_g',hdlgetparameter('complex_imag_postfix')]);
                inPortOffset=inPortOffset+2;%#ok<NASGU>
            else
                hC.setInputPortName(inPortOffset,[cinname,'_g']);
                inPortOffset=inPortOffset+1;%#ok<NASGU>
            end
        end
    else

        if inComplex(2)
            for n=1:3
                hC.setInputPortName(inPortOffset+(n-1),...
                [cinname,'_num',num2str(n),hdlgetparameter('complex_real_postfix')]);
            end
            for n=1:3
                hC.setInputPortName(inPortOffset+(n+2),...
                [cinname,'_num',num2str(n),hdlgetparameter('complex_imag_postfix')]);
            end
            inPortOffset=inPortOffset+6;
        else
            for n=1:3
                hC.setInputPortName(inPortOffset+n-1,[cinname,'_num',num2str(n)]);
            end
            inPortOffset=inPortOffset+3;
        end


        if inComplex(3)
            for n=1:2
                hC.setInputPortName(inPortOffset+(n-1),...
                [cinname,'_den',num2str(n+1),hdlgetparameter('complex_real_postfix')]);
            end
            for n=1:2
                hC.setInputPortName(inPortOffset+(n+1),...
                [cinname,'_den',num2str(n+1),hdlgetparameter('complex_imag_postfix')]);
            end
            inPortOffset=inPortOffset+4;
        else
            for n=1:2
                hC.setInputPortName(inPortOffset+n-1,[cinname,'_den',num2str(n+1)]);
            end
            inPortOffset=inPortOffset+2;
        end


        if scale_port
            if inComplex(4)
                for n=1:2
                    hC.setInputPortName(inPortOffset+(n-1),...
                    [cinname,'_g',num2str(n),hdlgetparameter('complex_real_postfix')]);
                end
                for n=1:2
                    hC.setInputPortName(inPortOffset+(n+1),...
                    [cinname,'_g',num2str(n),hdlgetparameter('complex_imag_postfix')]);
                end
            else
                for n=1:2
                    hC.setInputPortName(inPortOffset+n-1,[cinname,'_g',num2str(n)]);
                end
            end
        end
    end