































classdef MATLABCodeTemplate<coder.CodeTemplate&matlab.mixin.Copyable

    properties(Hidden)
TokenRepository
    end

    methods(Access=protected)

        function cpObj=copyElement(obj)

            cpObj=copyElement@matlab.mixin.Copyable(obj);


            cpObj.CGTFile=obj.CGTFile;
            cpObj.orderedSectionHeaders=obj.orderedSectionHeaders;
            cpObj.TokenRepository=copy(obj.TokenRepository);
            cpObj.rawSectionsMap=containers.Map(obj.rawSectionsMap.keys,obj.rawSectionsMap.values);
        end
    end

    methods(Access=public)


        function obj=MATLABCodeTemplate(CGTFile)
            if nargin==0
                CGTFileArg='matlabcoder_default_template.cgt';
            else
                CGTFile=convertStringsToChars(CGTFile);
                CGTFileArg=CGTFile;
            end
            obj=obj@coder.CodeTemplate(CGTFileArg);
            obj.TokenRepository=coder.MATLABTokenRepository;

        end




        function setTokenValue(obj,tokenName,tokenValue)
            tokenName=convertStringsToChars(tokenName);
            tokenValue=convertStringsToChars(tokenValue);
            obj.TokenRepository.setTokenValue(tokenName,tokenValue);
        end

        function val=getTokenValue(obj,tokenName)
            tokenName=convertStringsToChars(tokenName);
            val=obj.TokenRepository.getTokenValue(tokenName);
        end

        function Tokens=getCurrentTokens(obj)
            Tokens=obj.TokenRepository.getCurrentTokens;
        end





        function stringBuffer=emitSection(obj,sectionName,isCPPComment)
            sectionName=convertStringsToChars(sectionName);
            stringBuffer=obj.createAndEmitSection(sectionName,obj.TokenRepository,isCPPComment);
        end

    end
end

