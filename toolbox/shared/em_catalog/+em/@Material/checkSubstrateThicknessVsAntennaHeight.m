function checkSubstrateThicknessVsAntennaHeight(obj,propVal)

    T=obj.Thickness;



    tf=abs(cumsum(T)-propVal)<sqrt(eps);
    if~any(tf)
        error(message('antenna:antennaerrors:SubstrateLayerCrossesRadiator'));
    end
end


