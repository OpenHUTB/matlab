function[symmInfo,isSymmetry]=getCoefficientsSymmetry(this,blockInfo)%#ok<INUSL>




    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',blockInfo.FilterStructure,...
    'FilterCoefficientSource',blockInfo.NumeratorSource,...
    'CoefficientsDataType',blockInfo.CoefficientsDataType,...
    'FilterOutputDataType',blockInfo.OutputDataType,...
    'FilterCoefficients',blockInfo.Numerator);

    inputDT=getInputDT(hFIR,blockInfo.CompiledInputDT);
    coefDT=getCoefficientsDT(hFIR,inputDT);

    symmInfo=hFIR.getSymmetryFIRS(blockInfo.Numerator,coefDT,blockInfo.NumeratorSource);
    exception1=strcmpi(blockInfo.FilterStructure,'Partly serial systolic')&&strcmpi(blockInfo.SerializationOption,'Minimum number of cycles between valid input samples')&&blockInfo.SharingFactor>1;
    exception2=strcmpi(blockInfo.FilterStructure,'Partly serial systolic')&&strcmpi(blockInfo.SerializationOption,'Maximum number of multipliers');

    if(exception1||exception2)&&symmInfo.Exception(1)==1
        symmInfo.isSymmetric=0;
    end

    if symmInfo.isSymmetric~=0
        isSymmetry=true;
    else
        isSymmetry=false;
    end

    release(hFIR);
    delete(hFIR);
end
