function hf=createHDLFilterObj(this,hC)







    bfp=hC.SimulinkHandle;

    cpdt=get_param(bfp,'CompiledPortDataTypes');
    in_sltype=char(cpdt.Inport(1));
    [inputWL,inputFL]=hdlgetsizesfromtype(in_sltype);

    if inputWL==0
        arithmetic='double';
    else
        arithmetic='fixed';
    end


    options.mapstates=[];


    options.arithmetic=arithmetic;
    options.inputformat=[inputWL,inputFL];


    if strncmp(options.arithmetic,'double',6)||strncmp(options.arithmetic,'single',6)
        options.arithmetic='double';
        options.fixedMode=false;
    elseif strncmp(options.arithmetic,'fixed',5)
        options.fixedMode=true;
    else
        error(message('hdlcoder:validate:InvalidArithmetic'));
    end


    if~isnumeric(options.inputformat)||~isvector(options.inputformat)||...
        (length(options.inputformat)~=2)
        error(message('hdlcoder:validate:InvalidInputFormat'));
    end
    options.inputformat=double(options.inputformat);

    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    if~isa(block,'Simulink.SFunction')
        error(message('hdlcoder:validate:InvalidBlockInput'));
    end
    switch block.FilterSource
    case{'Specify via dialog','Dialog parameters','Auto'}
        hf=getHDLFiltObjFromBlockInfo(this,block,hC,options);
    case 'Filter object'
        hf=getHDLFiltObjFromFiltObj(this,block,hC,options);
    otherwise
        error(message('hdlcoder:validate:InvalidFIRDIBlockMode'));
    end

    inComplex=block.CompiledPortComplexSignals.Inport;

    hf.InputComplex=inComplex;





    function hf=getHDLFiltObjFromBlockInfo(this,block,hC,options)




        fixedMode=options.fixedMode;
        inputformat=options.inputformat;


        if fixedMode
            if(strncmpi(block.roundingMode,'ceiling',7))
                roundMode='ceil';
            elseif(strncmpi(block.roundingMode,'convergent',10))
                roundMode='convergent';
            elseif(strncmpi(block.roundingMode,'floor',5))
                roundMode='floor';
            elseif(strncmpi(block.roundingMode,'nearest',7))
                roundMode='nearest';
            elseif(strncmpi(block.roundingMode,'round',5))
                roundMode='round';
            elseif(strncmpi(block.roundingMode,'simplest',8))
                roundMode='floor';
            else
                roundMode='fix';
            end

            if(strncmpi(block.overflowMode,'off',3))
                overflowMode=false;
            else
                overflowMode=true;
            end
        else
            roundMode='floor';
            overflowMode=false;
        end

        hf=hdlfilter.firinterp;

        hf.FilterStructure='Direct-Form FIR Polyphase Interpolator';


        arith=options.arithmetic;


        hf.RoundMode=roundMode;
        hf.OverflowMode=overflowMode;


        hf=updateFixedPointInfo(this,hf,hC,block,arith,inputformat);



        function hf=updateFixedPointInfo(this,hf,hC,block,arith,inputformat)






            if~strcmpi(arith,'double')

                blockfullname=[block.Path,'/',block.Name];
                typeInfo=getCompiledFixedPointInfo(blockfullname);
            else
                typeInfo.CoefficientsDataType=[];
                typeInfo.ProductDataType=[];
                typeInfo.AccumulatorDataType=[];
                typeInfo.OutputDataType=[];
            end


            hf=updateInputInfo(hf,inputformat,arith);


            hf=updateCoeffInfo(this,hf,hC,arith,typeInfo.CoefficientsDataType,block);


            hf=updateProdInfo(hf,arith,typeInfo.ProductDataType);


            hf=updateAccumInfo(hf,arith,typeInfo.AccumulatorDataType);


            hf=updateOutputInfo(hf,arith,typeInfo.OutputDataType);



            function hf=updateInputInfo(hf,inputformat,arith)


                if strcmpi(arith,'double')
                    hf.inputsltype='double';
                else
                    [~,hf.inputsltype]=hdlgettypesfromsizes(inputformat(1),inputformat(2),true);
                end



                function hf=updateCoeffInfo(this,hf,hC,arith,typeInfo,block)%#ok<INUSL>






                    bfp=hC.SimulinkHandle;


                    switch block.FilterSource
                    case 'Filter object'
                        coeffs=hf.PolyphaseCoefficients(:);
                        interpfact=hf.InterpolationFactor;
                    otherwise
                        ud=get_param(bfp,'UserData');
                        interpfact=ud.filterConstructorArgs{1};
                        coeffs=ud.filterConstructorArgs{2};
                    end

                    hf.InterpolationFactor=interpfact;
                    hf.PolyphaseCoefficients=polyphase_coeffs(coeffs,interpfact);


                    if~strcmpi(arith,'double')


                        issigned=typeInfo.Signed;
                        wordlength=typeInfo.WordLength;
                        fraclength=typeInfo.FractionLength;


                        [~,hf.coeffsltype]=hdlgettypesfromsizes(wordlength,fraclength,issigned);


                        coeffs=double(fi(coeffs,issigned,wordlength,fraclength,'RoundingMethod','Nearest','OverflowAction','Saturate'));
                        hf.PolyphaseCoefficients=polyphase_coeffs(coeffs,interpfact);

                    else

                        hf.coeffsltype=hf.inputsltype;
                    end



                    function hf=updateProdInfo(hf,arith,typeInfo)




                        if~strcmpi(arith,'double')


                            issigned=typeInfo.Signed;
                            wordlength=typeInfo.WordLength;
                            fraclength=typeInfo.FractionLength;


                            [~,hf.productsltype]=hdlgettypesfromsizes(wordlength,fraclength,issigned);

                        else

                            hf.productsltype=hf.inputsltype;

                        end



                        function hf=updateAccumInfo(hf,arith,typeInfo)




                            if~strcmpi(arith,'double')


                                issigned=typeInfo.Signed;
                                wordlength=typeInfo.WordLength;
                                fraclength=typeInfo.FractionLength;


                                [~,hf.accumSLtype]=hdlgettypesfromsizes(wordlength,fraclength,issigned);

                            else
                                hf.accumsltype=hf.inputsltype;
                            end



                            function hf=updateOutputInfo(hf,arith,typeInfo)





                                if strcmpi(arith,'double')

                                    hf.outputsltype='double';

                                else


                                    issigned=typeInfo.Signed;
                                    wordlength=typeInfo.WordLength;
                                    fraclength=typeInfo.FractionLength;


                                    [~,hf.outputsltype]=hdlgettypesfromsizes(wordlength,fraclength,issigned);

                                end



                                function pp_coeffs=polyphase_coeffs(coeffs,decimfact)


                                    rows=decimfact;
                                    columns=ceil(length(coeffs)/decimfact);
                                    pp_coeffs=zeros(rows,columns);
                                    coeffs_expand=zeros(1,rows*columns);
                                    coeffs_expand(1:length(coeffs))=coeffs;
                                    for n=1:columns
                                        pp_coeffs(:,n)=coeffs_expand((n-1)*decimfact+1:n*decimfact).';
                                    end



                                    function hf=getHDLFiltObjFromFiltObj(this,block,hC,options)

                                        filtObjName=block.FilterObject;
                                        if~isempty(filtObjName)
                                            ud=block.UserData;
                                            if isfield(ud,'filter')

                                                if isa(ud.filter,'dsp.FIRInterpolator')

                                                    hd=clone(ud.filter);
                                                else

                                                    hd=copy(ud.filter);


                                                    if isfdtbxinstalled
                                                        mfiltArithmetic=lower(hd.arithmetic);
                                                    else
                                                        mfiltArithmetic='double';
                                                    end
                                                end
                                            else
                                                error(message('hdlcoder:validate:undefinedDFILT',filtObjName));
                                            end
                                        else
                                            error(message('hdlcoder:validate:emptyDFILT'));
                                        end

                                        if~isempty(options.mapstates)
                                            if options.mapstates
                                                hd.PersistentMemory=true;
                                            end
                                        end

                                        if~isa(ud.filter,'dsp.FIRInterpolator')

                                            if~strcmp(mfiltArithmetic,options.arithmetic)

                                                if(strcmp(options.arithmetic,'double')||...
                                                    strcmp(options.arithmetic,'single'))

                                                    hd.arithmetic=options.arithmetic;
                                                    hf=createhdlfilter(hd);
                                                else

                                                    hd.arithmetic='fixed';

                                                    hd.specifyall;
                                                    hd.RoundMode='floor';
                                                    hd.OverflowMode='wrap';

                                                    hd.InputWordLength=options.inputformat(1);

                                                    hd.CoeffWordLength=hd.InputWordLength;
                                                    hd.CoeffAutoScale=true;


                                                    hf=createhdlfilter(hd);


                                                    hf=updateFixedPointInfo(this,hf,hC,block,hd.arithmetic,options.inputformat);
                                                end
                                            else
                                                if strcmp(mfiltArithmetic,'fixed')
                                                    dfiltInputFormat=[hd.InputWordLength,hd.InputFracLength];
                                                    if~isequal(dfiltInputFormat,options.inputformat)
                                                        error(message('hdlcoder:validate:InputFormatMismatch',filtObjName,num2str(dfiltInputFormat(1)),num2str(dfiltInputFormat(2)),num2str(options.inputformat(1)),num2str(options.inputformat(2))));
                                                    end
                                                end
                                                hf=createhdlfilter(hd);
                                            end
                                        else

                                            coeffs=hd.Numerator;
                                            interpfactor=hd.InterpolationFactor;


                                            hf=hdlfilter.firinterp;
                                            hf.InterpolationFactor=interpfactor;
                                            hf.PolyphaseCoefficients=polyphase_coeffs(coeffs,interpfactor);


                                            hf=updateFixedPointInfo(this,hf,hC,block,options.arithmetic,options.inputformat);
                                        end
