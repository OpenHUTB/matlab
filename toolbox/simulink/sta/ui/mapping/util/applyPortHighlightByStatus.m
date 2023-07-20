function applyPortHighlightByStatus(inputMap,shadowH,shadowPortNum,status)











    setMappingHighlight(get_param(inputMap.Destination.BlockPath,'Handle'),status);


    if~isempty(shadowPortNum)


        if~isempty(inputMap.PortNumber)


            isSHADOWED=[shadowPortNum{:}]==inputMap.PortNumber;


            shadowPortIdxToHighlight=find(isSHADOWED==1);


            for kShadow=1:length(shadowPortIdxToHighlight)


                setMappingHighlight(shadowH{shadowPortIdxToHighlight(kShadow)},status);

            end
        end
    end