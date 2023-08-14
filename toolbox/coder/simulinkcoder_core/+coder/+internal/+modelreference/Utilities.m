classdef Utilities<handle
    methods(Static,Access=public)
        function fieldData=getFieldData(data,fieldName)
            if isfield(data,fieldName)
                fieldData=data.(fieldName);
                if~iscell(fieldData)
                    fieldData={fieldData};
                end
            else
                fieldData={};
            end
        end

        function retVal=GetBlockFullPathWithEscaping(blkPathPassedIn,...
            rmPaddingAndSperator,...
            doubleEscaping)


















            if rmPaddingAndSperator

                retVal=deblank(blkPathPassedIn);
                if~isempty(retVal)

                    retVal=retVal(1:end-1);
                end
            else
                retVal=blkPathPassedIn;
            end
            retVal=...
            coder.internal.modelreference.Utilities.HandleSpecialCharacter(...
            retVal,'\');
            retVal=...
            coder.internal.modelreference.Utilities.HandleSpecialCharacter(...
            retVal,'"');

            if(doubleEscaping)



                retVal=...
                coder.internal.modelreference.Utilities.HandleSpecialCharacter(...
                retVal,'\');
            end
        end
    end

    methods(Static,Access=private)
        function retVal=HandleSpecialCharacter(origStr,specialChar)
            foundSpecialChar=strfind(origStr,specialChar);
            if isempty(foundSpecialChar)
                retVal=origStr;
            else

                retVal=[];
                startOffset=1;

                nSpecialChars=length(foundSpecialChar);
                for qIdx=1:nSpecialChars

                    qPos=foundSpecialChar(qIdx);
                    retVal=strcat(retVal,origStr(startOffset:qPos-1));
                    retVal(end+1)='\';
                    retVal(end+1)=specialChar;
                    startOffset=qPos+1;
                end
                retVal=strcat(retVal,origStr(startOffset:end));
            end
        end
    end
end
