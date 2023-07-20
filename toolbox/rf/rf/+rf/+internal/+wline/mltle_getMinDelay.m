function MinDelay=mltle_getMinDelay(tleData)
%#codegen



    MinDelay=min(1e-10,min(tleData.tau)/2.35);

end
