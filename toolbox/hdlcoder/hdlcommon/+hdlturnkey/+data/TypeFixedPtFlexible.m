


classdef TypeFixedPtFlexible<hdlturnkey.data.TypeFixedPt


    properties

        MaxWordLength=0;

    end

    methods

        function obj=TypeFixedPtFlexible(varargin)


            obj=obj@hdlturnkey.data.TypeFixedPt();

            p=inputParser;
            p.addParameter('MaxWordLength',0);

            p.parse(varargin{:});
            inputArgs=p.Results;

            obj.MaxWordLength=inputArgs.MaxWordLength;
        end


        function isa=isFlexibleWidth(obj)%#ok<*MANU>

            isa=true;
        end


        function maxWL=getMaxWordLength(obj)
            maxWL=obj.MaxWordLength;
        end
        function wl=getWordLength(obj)
            wl=obj.getMaxWordLength;
        end

    end
end

