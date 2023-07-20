function hf=updateCoeffInfoSysObj(this,hf,hC,arith)










    sysObj=hC.getSysObjImpl;
    inSignals=hC.getInputSignals('data');
    if isFilterFIR(hf)
        coeffs=sysObj.Numerator;
    elseif isFilterSOS(hf)
        if strcmp(sysObj.SOSMatrixSource,'Input port')

            if inSignals(2).Type.isComplexType
                Num=0.985*(1:3)*(1+1j);
            else
                Num=0.985*(1:3);
            end
            if inSignals(3).Type.isComplexType
                Den=0.985*(1:2)*(1+1j);
            else
                Den=0.985*(1:2);
            end
            coeffs=[Num,1,Den];

            if sysObj.ScaleValuesInputPort

                if inSignals(4).Type.isComplexType
                    scaleValues=0.985*(1:2)*(1+1j);
                else
                    scaleValues=0.985*(1:2);
                end
            else
                scaleValues=[1,1];
            end

        else
            coeffs=sysObj.SOSMatrix;
            scaleValues=sysObj.ScaleValues;
        end
    end

    hf.Coefficients=coeffs;
    if(isFilterSOS(hf))

        hf.NumSections=size(hf.Coefficients,1);
        hf.scaleValues=ones(hf.NumSections+1,1);
        hf.scaleValues(1:length(scaleValues))=scaleValues;

        hf.SectionOrder=secorder(hf);
    end

    if~strcmpi(arith,'double')

        if isFilterSOS(hf)&&strcmp(sysObj.SOSMatrixSource,'Input port')
            hf.numcoeffsltype=block.CompiledPortDataTypes.Inport{2};
            hf.dencoeffsltype=block.CompiledPortDataTypes.Inport{3};
            if sysObj.ScaleValuesInputPort
                hf.scalesltype=block.CompiledPortDataTypes.Inport{4};
            else
                hf.scalesltype='sfix16_En14';
            end
        else
            switch sysObj.NumeratorCoefficientsDataType
            case{'Same word length as input','Specify word length'}
                if strncmpi(sysObj.NumeratorCoefficientsDataType,'Same word length as input',25)

                    csize=hdlgetsizesfromtype(hf.inputsltype);
                else
                    csize=sysObj.CustomNumeratorCoefficientsDataType.WordLength;
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
            case{'Binary point scaling'}
                csize=sysObj.CustomNumeratorCoefficientsDataType.WordLength;
                if(isFilterFIR(hf)||isFilterSOS(hf))
                    cbp_num=sysObj.CustomNumeratorCoefficientsDataType.FractionLength;
                end
                if(isFilterSOS(hf))
                    cbp_den=sysObj.CustomDenominatorCoefficientsDataType.FractionLength;
                    scalebp=sysObj.CustomScaleValuesDataType.FractionLength;
                end

            case{'Slope and bias scaling'}

                error(message('hdlcoder:validate:unsupportedslopebias'));

            otherwise
                error(message('hdlcoder:validate:InvalidCoeffMode',sysObj.NumeratorCoefficientsDataType,class(sysObj)));
            end


            if(isFilterFIR(hf))
                [~,hf.coeffsltype]=hdlgettypesfromsizes(csize,cbp_num,true);

                hf.Coefficients=double(fi(coeffs,true,csize,cbp_num,'roundmode','nearest','overflowmode','saturate'));
            elseif(isFilterSOS(hf))
                [~,hf.numcoeffsltype]=hdlgettypesfromsizes(csize,cbp_num,true);
                [~,hf.dencoeffsltype]=hdlgettypesfromsizes(csize,cbp_den,true);
                [~,hf.scalesltype]=hdlgettypesfromsizes(csize,scalebp,true);

                hf.Coefficients(:,1:3)=double(fi(coeffs(:,1:3),true,csize,cbp_num,'roundmode','nearest','overflowmode','saturate'));
                hf.Coefficients(:,5:6)=double(fi(coeffs(:,5:6),true,csize,cbp_den,'roundmode','nearest','overflowmode','saturate'));

                hf.scaleValues=ones(hf.NumSections+1,1);
                nonunity_sv_indx=find(scaleValues~=1);
                scaleValues_tbq=scaleValues(nonunity_sv_indx);


                input_scaleValues=double(fi(scaleValues_tbq,true,csize,scalebp,'roundmode','nearest','overflowmode','saturate'));
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


