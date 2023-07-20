function hf=updateCoeffInfo(this,hf,hC,arith)








    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if~isSysObj
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        inSignalsComplex=block.CompiledPortComplexSignals.Inport;
    else
        inSignals=hC.getInputSignals('data');
        inSignalsComplex(1:length(inSignals))=deal(false);
        for ii=1:length(inSignals)
            inSignalsComplex(ii)=hdlsignaliscomplex(inSignals(ii));
        end
        sysObjHandle=hC.getSysObjImpl;
    end

    if isFilterFIR(hf)
        if~isSysObj
            coeffs=this.hdlslResolve('NumCoeffs',bfp);
        else
            coeffs=sysObjHandle.Numerator;
        end
        coeffs=coeffs(:).';
    elseif isFilterSOS(hf)
        if~isSysObj
            filterSourcePort=strcmpi(block.FilterSource,'Input port(s)');
        else
            filterSourcePort=strcmpi(sysObjHandle.SOSMatrixSource,'Input port');
        end
        if filterSourcePort

            if inSignalsComplex(2)
                Num=0.985*(1:3)*(1+1j);
            else
                Num=0.985*(1:3);
            end
            if inSignalsComplex(3)
                Den=0.985*(1:2)*(1+1j);
            else
                Den=0.985*(1:2);
            end
            coeffs=[Num,1,Den];

            if~isSysObj
                scaleValuePort=strcmpi(block.ScaleValueMode,'Specify via input port (g)');
            else
                scaleValuePort=sysObjHandle.ScaleValuesInputPort;
            end

            if scaleValuePort

                if inSignalsComplex(4)
                    scaleValues=0.985*(1:2)*(1+1j);
                else
                    scaleValues=0.985*(1:2);
                end
            else
                scaleValues=[1,1];
            end

        else
            if~isSysObj
                coeffs=this.hdlslResolve('BiQuadCoeffs',bfp);
                scaleValues=this.hdlslResolve('ScaleValues',bfp);
            else
                coeffs=sysObjHandle.SOSMatrix;
                scaleValues=sysObjHandle.ScaleValues;
            end
        end
    end

    hf.Coefficients=coeffs;
    if(isFilterSOS(hf))

        hf.NumSections=size(hf.Coefficients,1);
        hf.scaleValues=ones(hf.NumSections+1,1);
        hf.scaleValues(1:length(scaleValues))=scaleValues;

        hf.SectionOrder=secorder(hf);
    end

    if~strcmpi(arith,'double')&&~strcmpi(arith,'single')
        if isFilterSOS(hf)
            if~isSysObj
                filterSourcePort=strcmpi(block.FilterSource,'Input port(s)');
                if filterSourcePort
                    scaleValueSourcePort=strcmpi(block.ScaleValueMode,'Specify via input port (g)');
                else
                    scaleValueSourcePort=false;
                end
            else
                filterSourcePort=strcmpi(sysObjHandle.SOSMatrixSource,'Input port');
                if filterSourcePort
                    scaleValueSourcePort=sysObjHandle.ScaleValuesInputPort;
                else
                    scaleValueSourcePort=false;
                end
            end
        end

        if isFilterSOS(hf)&&filterSourcePort
            if~isSysObj

                hf.numcoeffsltype=block.CompiledPortDataTypes.Inport{2};
                hf.dencoeffsltype=block.CompiledPortDataTypes.Inport{3};
                if scaleValueSourcePort
                    hf.scalesltype=block.CompiledPortDataTypes.Inport{4};
                else
                    hf.scalesltype='sfix16_En14';
                end
            else

                hf.numcoeffsltype=getsltypefrompirsignal(inSignals(2));
                hf.dencoeffsltype=getsltypefrompirsignal(inSignals(3));
                if scaleValueSourcePort
                    hf.scalesltype=getsltypefrompirsignal(inSignals(4));
                else
                    hf.scalesltype='sfix16_En14';
                end
            end
        else
            if~isSysObj
                coeffMode=block.firstCoeffMode;
            else
                if isFilterFIR(hf)
                    coeffMode=sysObjHandle.CoefficientsDataType;
                else
                    coeffMode=sysObjHandle.NumeratorCoefficientsDataType;
                end
            end
            switch coeffMode
            case{'Same word length as input','Specify word length'}
                if strncmpi(coeffMode,'Same word length as input',25)

                    csize=hdlgetsizesfromtype(hf.inputsltype);
                else
                    csize=this.hdlslResolve('firstCoeffWordLength',bfp);
                end
                if(isFilterFIR(hf))
                    cbp_num=getBestPrecFracLength(this,...
                    coeffs,csize,1);
                elseif(isFilterSOS(hf))
                    cbp_num=getBestPrecFracLength(this,...
                    coeffs(:,1:3),csize,1);
                    cbp_den=getBestPrecFracLength(this,...
                    coeffs(:,5:6),csize,1);
                    scalebp=getScaleValuesFracLenforSOS(this,hC,scaleValues,...
                    csize);
                end
            case{'Binary point scaling','Custom'}
                if~isSysObj
                    csize=this.hdlslResolve('firstCoeffWordLength',bfp);
                else
                    cDataType=sysObjHandle.CustomNumeratorCoefficientsDataType;
                    csize=cDataType.WordLength;
                end
                if(isFilterFIR(hf)||isFilterSOS(hf))
                    if~isSysObj
                        cbp_num=this.hdlslResolve('firstCoeffFracLength',bfp);
                    else
                        cDataType=sysObjHandle.CustomNumeratorCoefficientsDataType;
                        cbp_num=cDataType.FractionLength;
                    end
                end
                if(isFilterSOS(hf))
                    if~isSysObj
                        cbp_den=this.hdlslResolve('secondCoeffFracLength',bfp);
                        scalebp=this.hdlslResolve('scaleValueFracLength',bfp);
                    else
                        cDenDataType=sysObjHandle.CustomDenominatorCoefficientsDataType;
                        cbp_den=cDenDataType.FractionLength;
                        scalebp=sysObjHandle.CustomScaleValuesDataType.FractionLength;
                    end
                end

            case{'Slope and bias scaling'}

                error(message('hdlcoder:validate:unsupportedslopebias'));

            otherwise
                error(message('hdlcoder:validate:InvalidCoeffMode',block.firstCoeffMode,block.Name));
            end


            if(isFilterFIR(hf))
                [~,hf.coeffsltype]=hdlgettypesfromsizes(csize,cbp_num,true);

                hf.Coefficients=double(fi(coeffs,true,csize,cbp_num,'RoundingMethod','Nearest','OverflowAction','saturate'));
            elseif(isFilterSOS(hf))
                [~,hf.numcoeffsltype]=hdlgettypesfromsizes(csize,cbp_num,true);
                [~,hf.dencoeffsltype]=hdlgettypesfromsizes(csize,cbp_den,true);
                [~,hf.scalesltype]=hdlgettypesfromsizes(csize,scalebp,true);

                hf.Coefficients(:,1:3)=double(fi(coeffs(:,1:3),true,csize,cbp_num,'RoundingMethod','Nearest','OverflowAction','saturate'));
                hf.Coefficients(:,5:6)=double(fi(coeffs(:,5:6),true,csize,cbp_den,'RoundingMethod','Nearest','OverflowAction','saturate'));

                hf.scaleValues=ones(hf.NumSections+1,1);
                nonunity_sv_indx=find(scaleValues~=1);
                scaleValues_tbq=scaleValues(nonunity_sv_indx);


                input_scaleValues=double(fi(scaleValues_tbq,true,csize,scalebp,'RoundingMethod','Nearest','OverflowAction','Saturate'));
                hf.scaleValues(nonunity_sv_indx)=input_scaleValues;
            end
        end
    else

        if(isFilterFIR(hf))
            hf.coeffsltype=hf.inputsltype;
        elseif(isFilterSOS(hf))
            hf.numcoeffsltype=hf.inputsltype;
            hf.dencoeffsltype=hf.inputsltype;
            hf.scalesltype=hf.inputsltype;
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


        function isSOS=isFilterSOS(hf)
            isSOS=(isa(hf,'hdlfilter.df1sos')||...
            isa(hf,'hdlfilter.df1tsos')||...
            isa(hf,'hdlfilter.df2sos')||...
            isa(hf,'hdlfilter.df2tsos'));



            function isFIR=isFilterFIR(hf)
                isFIR=(isa(hf,'hdlfilter.dffir')||...
                isa(hf,'hdlfilter.dffirt')||...
                isa(hf,'hdlfilter.dfsymfir')||...
                isa(hf,'hdlfilter.dfasymfir'));



                function sltype=getsltypefrompirsignal(inSig)


                    bt=inSig.Type.BaseType;
                    wl=bt.WordLength;
                    fl=-1*bt.FractionLength;
                    s=bt.Signed;
                    sltype=hdlgetsltypefromsizes(wl,fl,s);


