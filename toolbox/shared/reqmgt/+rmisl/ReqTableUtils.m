classdef ReqTableUtils<handle

    methods(Static)
        function tf=isEmbeddedReqIdString(id)
            [mdlName,tableSID,reqSID]=rmis.ReqTableUtils.splitEmbeddedReqIdString(id);
            tf=~any(cellfunc(@isempty,{mdlName,tableSID,reqSID}));
        end

        function[modelName,tableSID,reqSID]=splitEmbeddedReqIdString(id)

            modelName=[];
            tableSID=[];
            reqSID=[];

            id=convertStringsToChars(id);

            if ischar(id)

                tokens=split(id,'~');
                if length(tokens)>1
                    reqSID=tokens{end};
                    reqSetNameWithExt=strjoin(tokens(1:end-1),'~');

                    [~,reqSetName,fExt]=fileparts(reqSetNameWithExt);
                    if strcmp(fExt,'.slreqx')
                        nameTokens=split(reqSetName,'_');
                        if length(nameTokens)>1
                            tableSID=nameTokens{end};
                            modelName=strjoin(nameTokens(1:end-1),'_');
                        end
                    end
                end
            end
        end
    end
end