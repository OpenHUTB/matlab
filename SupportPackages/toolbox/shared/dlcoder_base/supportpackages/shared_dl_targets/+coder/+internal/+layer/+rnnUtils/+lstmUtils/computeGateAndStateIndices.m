function[iInd,fInd,oInd,zInd]=computeGateAndStateIndices(numHiddenUnits,ignoreStateIndices)





%#codegen


    coder.allowpcode('plain');

    if coder.const(ignoreStateIndices)
        assert(nargout<4);
        iInd=1:numHiddenUnits;
        fInd=1+numHiddenUnits:2*numHiddenUnits;
        oInd=1+2*numHiddenUnits:3*numHiddenUnits;
    else
        iInd=1:numHiddenUnits;
        fInd=1+numHiddenUnits:2*numHiddenUnits;
        zInd=1+2*numHiddenUnits:3*numHiddenUnits;
        oInd=1+3*numHiddenUnits:4*numHiddenUnits;
    end

end
