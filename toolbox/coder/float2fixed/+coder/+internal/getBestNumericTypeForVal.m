function T=getBestNumericTypeForVal(minV,maxV,alwaysInt,typeProposalSettings)


    if~isscalar(minV)||~isscalar(maxV)

        T='';
        return;
    end

    defaultWL=double(typeProposalSettings.defaultWL);
    defaultFL=double(typeProposalSettings.defaultFL);
    proposeWLForDefFL=double(typeProposalSettings.proposeWLForDefFL);
    proposeFLForDefWL=double(typeProposalSettings.proposeFLForDefWL);
    safetyMargin=double(typeProposalSettings.safetyMargin);

    propseTargetContainerTypes=typeProposalSettings.proposeTargetContainerTypes;

    rangeFactorForSimMinMax=SafetyMargin2RangeFactor(safetyMargin);
    scaledValues=[minV,maxV]*rangeFactorForSimMinMax;

    if isempty(typeProposalSettings.defaultSignedness)
        isSigned=minV<0||maxV<0;
    else
        isSigned=typeProposalSettings.defaultSignedness;
    end




    if minV==0&&maxV==0||minV==1&&maxV==1
        T=NumericTypeForZeroOrOneValue(isSigned,propseTargetContainerTypes);
        return;
    end

    optimizeWholeNumber=typeProposalSettings.optimizeWholeNumber;
    if optimizeWholeNumber&&alwaysInt
        if minV==0&&maxV==1
            T=NumericTypeForZeroOrOneValue(isSigned,propseTargetContainerTypes);
            return;
        end

        defaultFL=0;
        proposeWLForDefFL=true;
        proposeFLForDefWL=false;
    end

    if isinf(minV)||isinf(maxV)

        T=coder.internal.Helper.getTargetType(isSigned,defaultWL,1000,propseTargetContainerTypes);
        return;
    end

    if proposeFLForDefWL
        proposedFL=-1*fixptFL(scaledValues,defaultWL,isSigned);
        proposedFL=min(proposedFL);
        T=coder.internal.Helper.getTargetType(isSigned,defaultWL,proposedFL,propseTargetContainerTypes);
    elseif proposeWLForDefFL
        proposedWL=fixptWL(scaledValues,defaultFL,isSigned);
        proposedWL=max((proposedWL));
        T=coder.internal.Helper.getTargetType(isSigned,proposedWL,defaultFL,propseTargetContainerTypes);
    else
        assert(false,'Unknown type proposal option.');
    end

end


function T=NumericTypeForZeroOrOneValue(isSigned,propseTargetContainerTypes)
    if~isSigned
        T=coder.internal.Helper.getTargetType(0,1,0,propseTargetContainerTypes);
    else
        T=coder.internal.Helper.getTargetType(1,2,0,propseTargetContainerTypes);
    end
end


function exp=fixptFL(realWorldValue,totalBits,isSigned)

    exp=fixed.GetBestPrecisionExponent(realWorldValue,totalBits,isSigned);
end


function minwl=fixptWL(realWorldValue,fracBits,isSigned)
    minwl=fixed.GetMinWordLength(realWorldValue,fracBits,isSigned);
end


function RangeFactor=SafetyMargin2RangeFactor(SafetyMargin)
    RangeFactor=1+(SafetyMargin/100);
end
