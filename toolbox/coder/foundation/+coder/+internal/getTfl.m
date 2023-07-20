function TflHdl=getTfl(lTargetRegistry,Tfl_QueryString)










    if(isempty(Tfl_QueryString)||strcmpi(Tfl_QueryString,'none'))
        TflHdl=[];
        return;
    end


    refreshCRL(lTargetRegistry);

    libs=lTargetRegistry.TargetFunctionLibraries;
    for i=1:length(libs)
        if strcmp(Tfl_QueryString,libs(i).Name)||any(strcmp(Tfl_QueryString,libs(i).Alias))
            TflHdl=libs(i);
            return;
        end
    end


    DAStudio.error('RTW:targetRegistry:noNameMatch',Tfl_QueryString);




