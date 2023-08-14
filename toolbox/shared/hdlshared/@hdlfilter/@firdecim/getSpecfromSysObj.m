function getSpecfromSysObj(this,hS,inputnumerictype)





    FilterStructure='FIR Decimator';



    [ipsize,ipbp]=hdlfilter.getSizesfromNumericType(inputnumerictype);
    inputformat=[ipsize,ipbp];

    DecimationFactor=hS.DecimationFactor;
    this.set('DecimationFactor',DecimationFactor,...
    'FilterStructure',FilterStructure);


    if strcmpi(inputnumerictype.DataTypeMode,'Double')
        fixedMode=0;
    else
        fixedMode=1;
    end


    if fixedMode
        if(strncmpi(hS.RoundingMethod,'ceiling',7))
            roundMode='ceil';
        elseif(strncmpi(hS.RoundingMethod,'convergent',10))
            roundMode='convergent';
        elseif(strncmpi(hS.RoundingMethod,'floor',5))
            roundMode='floor';
        elseif(strncmpi(hS.RoundingMethod,'nearest',7))
            roundMode='nearest';
        elseif(strncmpi(hS.RoundingMethod,'round',5))
            roundMode='round';
        elseif(strncmpi(hS.RoundingMethod,'simplest',8))
            roundMode='floor';
        else
            roundMode='fix';
        end

        if(strncmpi(hS.OverflowAction,'wrap',4))
            overflowMode=false;
        else
            overflowMode=true;
        end
        updateInputInfo(this,inputformat);


        updateCoeffInfo(this,hS);


        updateProdInfo(this,hS);


        updateAccumInfo(this,hS);


        updatePolyAccumInfo(this);


        updateOutputInfo(this,hS);


        updateStateInfo(this);
    else
        roundMode='floor';
        overflowMode=false;
        this.inputsltype='double';
        this.coeffsltype='double';
        this.productsltype='double';
        this.accumsltype='double';
        this.StateSLType='double';
        this.polyAccumSLType='double';
    end

    this.RoundMode=roundMode;
    this.OverflowMode=overflowMode;




    function updateInputInfo(this,inputformat)


        this.inputsltype=hdlgetsltypefromsizes(inputformat(1),inputformat(2),true);


        function updateCoeffInfo(this,hS)


            coeffs=hS.Numerator;
            decimfact=hS.DecimationFactor;
            this.DecimationFactor=decimfact;
            this.PolyphaseCoefficients=polyphase_coeffs(coeffs,decimfact);


            switch hS.CoefficientsDataType
            case 'Same word length as input'
                csize=hdlgetsizesfromtype(this.inputsltype);
                cbp_num=getBestPrecFracLength(...
                coeffs,csize);
            case 'Custom'
                cntype=hS.CustomCoefficientsDataType;
                [csize,cbp_num]=hdlfilter.getSizesfromNumericType(cntype);

            otherwise
                error(message('HDLShared:hdlfilter:InvalidCoeffMode',hS.CoefficientsDataType));
            end


            this.coeffsltype=hdlgetsltypefromsizes(csize,cbp_num,true);

            coeffs=double(fi(coeffs,true,csize,cbp_num,'RoundMode','nearest','OverflowMode','saturate'));
            this.PolyphaseCoefficients=polyphase_coeffs(coeffs,decimfact);



            function this=updateProdInfo(this,hS)


                switch hS.ProductDataType
                case 'Same as input'
                    this.productsltype=this.inputsltype;
                case 'Custom'
                    pntype=hS.CustomProductDataType;
                    [prodsize,prodbp]=hdlfilter.getSizesfromNumericType(pntype);
                    this.productsltype=hdlgetsltypefromsizes(prodsize,prodbp,true);








                otherwise
                    error(message('HDLShared:hdlfilter:InvalidProdOutputMode',hS.ProductDataType));
                end



                function this=updateAccumInfo(this,hS)

                    switch hS.AccumulatorDataType
                    case 'Same as input'

                        this.accumsltype=this.inputsltype;
                    case 'Same as product'
                        this.accumsltype=this.productsltype;
                    case 'Custom'
                        antype=hS.CustomAccumulatorDataType;
                        [accumsize,accumbp]=hdlfilter.getSizesfromNumericType(antype);
                        this.accumsltype=hdlgetsltypefromsizes(accumsize,accumbp,true);






                    otherwise
                        error(message('HDLShared:hdlfilter:InvalidAccumMode',hS.AccumulatorDataType));
                    end




                    function updateStateInfo(this)

                        if istransposedFIR(this)

                            this.StateSLType=this.Accumsltype;

                        end

                        function updatePolyAccumInfo(this)

                            if istransposedFIR(this)

                                this.polyAccumSLType=this.Accumsltype;
                            end


                            function this=updateOutputInfo(this,hS)

                                switch hS.OutputDataType
                                case 'Same as input'

                                    this.outputSLtype=this.InputSLtype;
                                case 'Same as accumulator'
                                    this.outputSLtype=this.AccumSLtype;
                                case 'Same as product'
                                    this.outputSLtype=this.ProductSLtype;
                                case 'Custom'
                                    ontype=hS.CustomOutputDataType;
                                    [outsize,outbp]=hdlfilter.getSizesfromNumericType(ontype);
                                    this.outputsltype=hdlgetsltypefromsizes(outsize,outbp,true);
                                otherwise
                                    error(message('HDLShared:hdlfilter:InvalidOutputMode',hS.OutputDataType));
                                end



                                function fracLength=getBestPrecFracLength(values,wordLength)




                                    if(wordLength<2)
                                        fracLength=0;
                                    else
                                        fracLength=0;
                                        if~isempty(values)
                                            valuesCol=double(values(:));
                                            if isreal(values)
                                                minVal=min(valuesCol);
                                                maxVal=max(valuesCol);
                                            else
                                                realValues=real(valuesCol);
                                                imagValues=imag(valuesCol);


                                                realMinVal=min(realValues);
                                                imagMinVal=min(imagValues);
                                                minVal=min([realMinVal;imagMinVal]);


                                                realMaxVal=max(realValues);
                                                imagMaxVal=max(imagValues);
                                                maxVal=max([realMaxVal;imagMaxVal]);
                                            end



                                            if abs(minVal)>abs(maxVal)
                                                valueToUse=minVal;
                                            else
                                                valueToUse=maxVal;
                                            end


                                            fracLength=-fixptbestexp(valueToUse,double(wordLength),1.0);
                                        end
                                    end


                                    function isFIRt=istransposedFIR(this)
                                        isFIRt=(isa(this,'hdlfilter.firtdecim'));



                                        function pp_coeffs=polyphase_coeffs(coeffs,decimfact)

                                            rows=decimfact;
                                            columns=ceil(length(coeffs)/decimfact);
                                            pp_coeffs=zeros(rows,columns);
                                            coeffs_expand=zeros(1,rows*columns);
                                            coeffs_expand(1:length(coeffs))=coeffs;
                                            for n=1:columns
                                                pp_coeffs(:,n)=coeffs_expand((n-1)*decimfact+1:n*decimfact).';
                                            end



