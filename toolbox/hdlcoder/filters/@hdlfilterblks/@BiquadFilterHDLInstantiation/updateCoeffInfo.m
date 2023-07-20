function hf=updateCoeffInfo(this,hf,hC,arith)








    cinfo=getCoeffInfo(this,hC,arith);


    [coeffs,scaleValues]=getCoeffsAndScaleValues(cinfo);


    hf.Coefficients=coeffs;



    hf.NumSections=size(coeffs,1);
    hf.scaleValues=ones(hf.NumSections+1,1);
    hf.scaleValues(1:length(scaleValues))=scaleValues;

    if~strcmpi(arith,'double')








        if cinfo.filterSourcePort


            nbt=cinfo.inSignals(2).Type.BaseType.BaseType;
            dbt=cinfo.inSignals(3).Type.BaseType.BaseType;
            numDT=numerictype(true,nbt.WordLength,-nbt.FractionLength);
            denDT=numerictype(true,dbt.WordLength,-dbt.FractionLength);

            if cinfo.scaleValuePort

                sbt=cinfo.inSignals(4).Type.BaseType.BaseType;
                scaleDT=numerictype(true,sbt.WordLength,-sbt.FractionLength);
            else

                scaleDT=numerictype(1,16,14);
            end

        else


            if strcmpi(cinfo.coeffMode,'Slope and bias scaling')
                error(message('hdlcoder:validate:unsupportedslopebias'));
            else
                numDT=cinfo.dataTypes.NumeratorCoefficientsDataType;
                denDT=cinfo.dataTypes.DenominatorCoefficientsDataType;
                scaleDT=cinfo.dataTypes.ScaleValuesDataType;
            end






            hf.Coefficients(:,1:3)=double(fi(coeffs(:,1:3),numDT,...
            'RoundingMethod','Nearest','OverflowAction','saturate'));
            hf.Coefficients(:,4)=coeffs(:,4);
            hf.Coefficients(:,5:6)=double(fi(coeffs(:,5:6),denDT,...
            'RoundingMethod','Nearest','OverflowAction','saturate'));



            nonunity_sv_indx=find(scaleValues~=1);
            scaleValues_tbq=scaleValues(nonunity_sv_indx);
            input_scaleValues=double(fi(scaleValues_tbq,scaleDT,...
            'RoundingMethod','Nearest','OverflowAction','Saturate'));
            hf.scaleValues=ones(hf.NumSections+1,1);
            hf.scaleValues(nonunity_sv_indx)=input_scaleValues;

        end

        [~,hf.numcoeffsltype]=hdlgettypesfromsizes(numDT.WordLength,numDT.FractionLength,true);
        [~,hf.dencoeffsltype]=hdlgettypesfromsizes(denDT.WordLength,denDT.FractionLength,true);
        [~,hf.scalesltype]=hdlgettypesfromsizes(scaleDT.WordLength,scaleDT.FractionLength,true);

    else
        hf.numcoeffsltype=hf.inputsltype;
        hf.dencoeffsltype=hf.inputsltype;
        hf.scalesltype=hf.inputsltype;
    end


    hf.SectionOrder=secorder(hf);

end



function cinfo=getCoeffInfo(this,hC,arith)











    cinfo.inSignals=hC.getInputSignals('data');

    if~isa(hC,'hdlcoder.sysobj_comp')

        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');

        cinfo.inSignalsComplex=block.CompiledPortComplexSignals.Inport;
        cinfo.filterSourcePort=strcmpi(block.FilterSource,'Input port(s)');

        if cinfo.filterSourcePort
            cinfo.scaleValuePort=strcmpi(block.ScaleValueMode,'Specify via input port (g)');
        else
            switch block.FilterSource
            case 'Dialog parameters'
                cinfo.coeffs=this.hdlslResolve('BiQuadCoeffs',bfp);
                cinfo.scaleValues=this.hdlslResolve('ScaleValues',bfp);
                cinfo.coeffMode=block.firstCoeffMode;
            case 'Filter object'
                sysObj=block.UserData.filter;
                cinfo.coeffs=sysObj.SOSMatrix;
                cinfo.scaleValues=sysObj.ScaleValues;
                cinfo.coeffMode=sysObj.NumeratorCoefficientsDataType;
            end
        end

        if~strcmpi(arith,'double')
            cinfo.dataTypes=getCompiledFixedPointInfo(block.getFullName());
        end

    else

        cinfo.inSignalsComplex(1:length(cinfo.inSignals))=deal(false);

        for ii=1:length(cinfo.inSignals)
            cinfo.inSignalsComplex(ii)=hdlsignaliscomplex(cinfo.inSignals(ii));
        end

        sysObj=hC.getSysObjImpl;
        cinfo.filterSourcePort=strcmpi(sysObj.SOSMatrixSource,'Input port');

        if cinfo.filterSourcePort
            cinfo.scaleValuePort=sysObj.ScaleValuesInputPort;
        else
            cinfo.coeffs=sysObj.SOSMatrix;
            cinfo.scaleValues=sysObj.ScaleValues;
        end

        cinfo.coeffMode=sysObj.NumeratorCoefficientsDataType;

        if~strcmpi(arith,'double')
            cinfo.dataTypes=getCompiledFixedPointInfo(sysObj);
        end

    end

end



function[coeffs,scaleValues]=getCoeffsAndScaleValues(cinfo)



    if cinfo.filterSourcePort


        if cinfo.inSignalsComplex(2)
            Num=0.985*(1:3)*(1+1j);
        else
            Num=0.985*(1:3);
        end

        if cinfo.inSignalsComplex(3)
            Den=0.985*(1:2)*(1+1j);
        else
            Den=0.985*(1:2);
        end

        coeffs=[Num,1,Den];

        if cinfo.scaleValuePort

            if cinfo.inSignalsComplex(4)
                scaleValues=0.985*(1:2)*(1+1j);
            else
                scaleValues=0.985*(1:2);
            end
        else

            scaleValues=[1,1];
        end

    else


        coeffs=cinfo.coeffs;
        scaleValues=cinfo.scaleValues;

    end

end



function n=secorder(hf)


    coeff=hf.Coefficients;
    nsec=hf.NumSections;


    n=2*ones(nsec,1);

    for i=1:nsec,
        if(coeff(i,3)==0&&coeff(i,6)==0),

            n(i)=1;
            if(coeff(i,2)==0&&coeff(i,5)==0),

                n(i)=0;
            end
        end
    end
end
