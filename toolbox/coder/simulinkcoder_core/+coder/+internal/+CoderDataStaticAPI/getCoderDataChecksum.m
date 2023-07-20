function checksum=getCoderDataChecksum(sourceDD,mdlRefTargetType)
















    checksum='';
    if strcmp(mdlRefTargetType,'SIM')

        return;
    end

    slRoot=slroot;
    if slRoot.isValidSlObject(sourceDD)
        mdlH=get_param(bdroot,'Handle');
        checksum=coderdictionary.data.SlCoderDataClient.getModelCoderDictionaryChecksum(mdlH);
    else
        if ischar(sourceDD)


            if~isempty(sourceDD)
                checksum=coderdictionary.data.api.getSharedCoderDictionaryChecksum(sourceDD);
            end
        end
    end

