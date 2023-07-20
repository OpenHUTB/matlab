function y=sin_cos_fi_lut_private(u_in,FI_SIN_COS_LUT)




%#codegen

    coder.allowpcode('plain');

    inCodegenMode=~isempty(coder.target);

    if inCodegenMode
        eml_prefer_const(FI_SIN_COS_LUT);
    end







    uWL=get(u_in,'WordLength');
    uFL=get(u_in,'FractionLength');

    uCanBeOutOfRange=issigned(u_in)||(~issigned(u_in)&&((uWL-uFL)>2));



    fmForProd32=fimath(...
    'RoundMode','floor','OverflowMode','wrap',...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',32,'ProductFractionLength',16,...
    'SumMode','FullPrecision','MaxSumWordLength',128);
    fi_two_pi_16=fi(2*pi,0,16,fmForProd32);
    if uCanBeOutOfRange

        u=cast(mod(u_in,fi(2*pi,0,32)),'like',fi_two_pi_16);
    else
        u=cast(u_in,'like',fi_two_pi_16);
    end



    inpInRangeNT=numerictype(0,16,13);
    inpValInRange=coder.nullcopy(fi(0,inpInRangeNT,fmForProd32));

    normConstant=fi(65536/51472,0,32,31,fmForProd32);


    fullScaleIndex=coder.nullcopy(fi(0,numerictype(0,16,0),fmForProd32));


    y=coder.nullcopy(fi(zeros(size(u)),numerictype(FI_SIN_COS_LUT)));

    for k=1:numel(u)





        if inCodegenMode
            inpValInRange(:)=u(k);
        else
            setElement(inpValInRange,getElement(u,k),1);
        end


        idxUFIX16=fi(storedInteger(inpValInRange),numerictype(0,16,0),fmForProd32);




        if inCodegenMode
            fullScaleIndex(:)=normConstant*idxUFIX16;
            idxUFIX16(:)=fullScaleIndex;
            y(k)=fixed.internal.trig_lut_fi_private(FI_SIN_COS_LUT,idxUFIX16);
        else
            setElement(fullScaleIndex,(normConstant*idxUFIX16),1);
            setElement(idxUFIX16,getElement(fullScaleIndex,1),1);
            setElement(y,fixed.internal.trig_lut_fi_private(FI_SIN_COS_LUT,idxUFIX16),k);
        end

    end

end
