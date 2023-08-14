

classdef MATLABTokenRepository<coder.TokenRepository&matlab.mixin.Copyable
    properties(Hidden)
TokenMap
    end

    methods(Access=protected)

        function cpObj=copyElement(obj)

            cpObj=copyElement@matlab.mixin.Copyable(obj);


            cpObj.TokenMap=containers.Map(obj.TokenMap.keys,obj.TokenMap.values);
        end
    end

    methods


        function obj=MATLABTokenRepository()
            obj.TokenMap=containers.Map;


            verInfoMLC=coder.internal.cachedVer('matlabcoder');
            obj.setTokenValue('MATLABCoderVersion',verInfoMLC.Version);


            verInfoGPUC=coder.internal.cachedVer('gpucoder');
            if~isempty(verInfoGPUC)
                obj.setTokenValue('GPUCoderVersion',verInfoGPUC.Version);
            end


            verInfoEC=coder.internal.cachedVer('embeddedcoder');
            if(~isempty(verInfoEC))
                obj.setTokenValue('EmbeddedCoderVersion',verInfoEC.Version);
            end


            obj.setTokenValue('SourceGeneratedOn',datestr(now));

        end




        function val=getTokenValue(obj,tokenName)
            if isKey(obj.TokenMap,tokenName)
                val=obj.TokenMap(tokenName);
            else
                error(message('Coder:templates:missingKeyInTokenRepository',tokenName));
            end
        end

        function setTokenValue(obj,tokenName,tokenValue)
            obj.TokenMap(tokenName)=tokenValue;
        end





        function Tokens=getCurrentTokens(obj)
            Tokens=keys(obj.TokenMap);
        end




        function string=executeCallback(obj,callBackName)
            try
                string=feval(callBackName,coder.TokenMap(obj));
            catch
                error(message('Coder:templates:incorrectFcnCallBackName',...
                callBackName));
            end
            if(~ischar(string))
                error(message('Coder:templates:nonStringReturnFromCallBack',...
                callBackName));
            end
        end

    end
end

