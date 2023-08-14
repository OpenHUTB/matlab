function uniqueName=getUniqueWebPanelName(blockDiagramHandle,panelName)
    if(isempty(panelName))
        uniqueName="";
        return;
    end

    uniqueName=panelName;
    panelNameNumericSuffix="";

    while~SLM3I.SLDomain.isPanelNameUnique(blockDiagramHandle,uniqueName)
        if(panelNameNumericSuffix=="")
            numericSuffixIndex=regexp(panelName,"\d+$");
            if(numericSuffixIndex)
                panelNameNumericSuffix=extractAfter(panelName,numericSuffixIndex-1);
                panelName=extractBefore(panelName,numericSuffixIndex);
            else
                panelNameNumericSuffix="1";
            end
        else
            panelNameNumericSuffix=int2str(str2double(panelNameNumericSuffix)+1);
        end
        uniqueName=strcat(panelName,panelNameNumericSuffix);
    end
end
