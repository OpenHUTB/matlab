function[symmInfo,isSymmetry]=getCoefficientsSymmetry(this,subFilter,blockInfo,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,FOLDINGFACTOR)




    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',blockInfo.FilterStructure,...
    'FilterCoefficientSource',blockInfo.FilterCoefficientSource,...
    'CoefficientsDataType',blockInfo.CoefficientsDataType,...
    'FilterOutputDataType',blockInfo.FilterOutputDataType,...
    'FilterCoefficients',blockInfo.FilterCoefficient);

    inputDT=getInputDT(hFIR,blockInfo.CompiledInputDT);
    coefDT=getCoefficientsDT(hFIR,inputDT);
    if isempty(subFilter)


        symmInfo=hFIR.getSymmetryFIRS(blockInfo.FilterCoefficient,coefDT,blockInfo.FilterCoefficientSource);
        if symmInfo.isSymmetric~=0
            isSymmetry=true;
        else
            isSymmetry=false;
        end
    else
        if strcmpi(blockInfo.FilterStructure,'Direct form systolic')||strcmpi(blockInfo.FilterStructure,'Partly serial systolic')
            symmInfo=hFIR.getSymmetryFIRS(blockInfo.FilterCoefficient,coefDT,blockInfo.FilterCoefficientSource);
            if symmInfo.isSymmetric~=0
                isSymmetry=true;
            else
                isSymmetry=false;
            end
        else
            if isempty(blockInfo.Numerator)
                hFIR.SymmetryOptimization=false;
            end


            numerator=blockInfo.FilterCoefficient;
            if~isrow(blockInfo.FilterCoefficient)
                numerator=transpose(numerator);
            end
            symmetry=hFIR.getSymmetryFIRS(numerator,coefDT,blockInfo.FilterCoefficientSource);
            isAntiSymmetry=0;
            if symmetry.isSymmetric==-1
                isAntiSymmetry=1;
            end


            symmInfo=hFIR.getSymmetryFIRT(subFilter,blockInfo,OUTPUT_WORDLENGTH,OUTPUT_FRACTIONLENGTH,FOLDINGFACTOR);
            isSymmetry=false;
            for loop=1:length(symmInfo)
                if symmInfo(loop).Number~=-1
                    isSymmetry=true;
                    break
                end
            end
            symmInfo(1).isAntiSymm=isAntiSymmetry;
        end
    end

    release(hFIR);
    delete(hFIR);
end
