function hf=updateCoeffInfo(this,hf,hC,arith)










    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        coeffs_port=strcmpi(sysObjHandle.NumeratorSource,'Input port');
        if coeffs_port
            coeffSignal=hC.PirInputSignals(2);
            if hdlissignalvector(coeffSignal)
                numCoeffs=double(max(coeffSignal.Type.Dimensions));
            else
                numCoeffs=1;
            end
            isComplexCoeff=hdlsignaliscomplex(coeffSignal);
        else
            coeffs=sysObjHandle.Numerator;
        end
        if~strcmpi(arith,'double')
            csltype=getBlockParam(sysObjHandle,'CoefDataTypeName');
        end
    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');

        coeffs_port=strcmpi(block.coefsource,'Input port');
        if coeffs_port
            numCoeffs=block.CompiledPortWidths.Inport(2);
            isComplexCoeff=block.CompiledPortComplexSignals.Inport(2);
        else
            coeffs=this.hdlslResolve('Coefficients',bfp);
        end
        if~strcmpi(arith,'double')
            csltype=block.CoefDataTypeName;
        end
    end

    if coeffs_port


        if isComplexCoeff
            coeffs=0.985*complex([1:numCoeffs],[1:numCoeffs]);%#ok<NBRAK>
        else
            coeffs=0.985*[1:numCoeffs];%#ok<NBRAK>
        end
    end

    hf.Coefficients=coeffs;

    if strcmpi(arith,'fixed')
        hf.coeffsltype=csltype;
        [csize,cbp_num,sgn]=hdlgetsizesfromtype(csltype);
        if~coeffs_port
            hf.Coefficients=double(fi(coeffs,sgn,csize,cbp_num,'RoundingMethod','Nearest','OverflowAction','Saturate'));
        end
    else
        hf.coeffsltype=hf.inputsltype;
        hf.Coefficients=double(coeffs);
    end

