

function candidates=getCandidateDisplayProperties(sysClassPropList)
    candidates=[];
    for propInd=1:length(sysClassPropList)
        metaProp=sysClassPropList(propInd);


        if~matlab.system.SystemProp.isPublicGetProp(metaProp)||metaProp.Abstract||metaProp.Hidden
            continue
        end


        if isempty(candidates)
            candidates=metaProp;
        else
            candidates(end+1)=metaProp;%#ok<AGROW>
        end
    end

end
