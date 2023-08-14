function checkViaLocationLayerOnMetal(obj,viaLoc)

    if isequal(size(viaLoc,2),3)
        metalLayerIndx=checkLocOnMetal(obj,viaLoc(:,3));
        if~all(metalLayerIndx)
            error(message('antenna:antennaerrors:PcbStackViaNotSpecifiedOnMetalLayer'));
        end
    else
        metalLayerIndx1=checkLocOnMetal(obj,viaLoc(:,3));
        metalLayerIndx2=checkLocOnMetal(obj,viaLoc(:,4));
        if~all(metalLayerIndx1)||~all(metalLayerIndx2)
            error(message('antenna:antennaerrors:PcbStackViaNotSpecifiedOnMetalLayer'));
        end
    end
end