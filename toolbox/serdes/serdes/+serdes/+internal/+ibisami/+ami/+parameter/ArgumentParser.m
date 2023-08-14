classdef ArgumentParser<inputParser





    properties
    end

    methods
        function parser=ArgumentParser(varargin)
            parser=parser@inputParser(varargin{:});
            parser.CaseSensitive=false;
            parser.addParameter('Name',"")
            parser.addParameter('Description',"")
            parser.addParameter('Format',[])
            parser.addParameter('Usage',[])
            parser.addParameter('Type',[])
            parser.addParameter('CurrentValue',[])
        end
    end
end

