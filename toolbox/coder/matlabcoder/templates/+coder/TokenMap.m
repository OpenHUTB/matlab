





classdef TokenMap
    properties(Hidden)
TokenRepository
    end

    methods


        function obj=TokenMap(a_tokenRepository)
            obj.TokenRepository=a_tokenRepository;
        end




        function string=getTokenValue(obj,token)
            string=obj.TokenRepository.getTokenValue(token);
        end

    end
end

