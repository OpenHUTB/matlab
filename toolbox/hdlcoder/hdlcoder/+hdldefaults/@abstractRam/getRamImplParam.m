function[hasClkEn,ramIsComplex]=getRamImplParam(this,inputData)






    hasClkEn=this.getImplParams('AddClockEnablePort');
    hasClkEn=isempty(hasClkEn)||strcmpi(hasClkEn,'on');


    if hdlsignaliscomplex(inputData)
        ramIsComplex=1;
    else
        ramIsComplex=0;
    end
