classdef(Hidden=true)Base64Utils
    methods(Static=true)
        function outStr=encode(obj)
            outStr=base64utils_mex(1,getByteStreamFromArray(obj));
        end

        function obj=decode(inStr)
            inStr=convertStringsToChars(inStr);
            validateattributes(inStr,{'char','uint8'},{'row'},'polyspace.internal.Base64Utils.decode','',1);
            if~ischar(inStr)
                inStr=char(inStr);
            end
            obj=getArrayFromByteStream(base64utils_mex(0,inStr));
        end
    end
end
