function checkFeedLocationLayerOnMetal(obj,feedLoc)

    if isequal(size(feedLoc,2),3)
        metalLayerIndx=checkLocOnMetal(obj,feedLoc(:,3));
        if~all(metalLayerIndx)
            error(message('antenna:antennaerrors:PcbStackFeedNotSpecifiedOnMetalLayer'));
        end
    else
        metalLayerIndx1=checkLocOnMetal(obj,feedLoc(:,3));
        metalLayerIndx2=checkLocOnMetal(obj,feedLoc(:,4));
        if~all(metalLayerIndx1)||~all(metalLayerIndx2)
            error(message('antenna:antennaerrors:PcbStackFeedNotSpecifiedOnMetalLayer'));
        end
    end
end