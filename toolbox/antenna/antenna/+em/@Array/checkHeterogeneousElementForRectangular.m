function checkHeterogeneousElementForRectangular(obj,propVal)
    if numel(propVal)>1
        checkProbeFeedStatusForForHeterogeneousElement(obj,propVal);




        if~isa(propVal(1),'helix')||(isa(propVal(1),'helix')&&isDielectricSubstrate(propVal(1)))
            checkSubstrateForHetereogeneousElement(obj,propVal);
        end
        if~isequal(size(propVal),obj.ArraySize)
            obj.ArrayElementModeUnlock=true;
            obj.Size=[size(propVal,1),size(propVal,2)];
            obj.ArrayElementModeUnlock=false;
        end
    end
end