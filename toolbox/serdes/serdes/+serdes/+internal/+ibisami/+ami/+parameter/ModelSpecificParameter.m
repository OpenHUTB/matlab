classdef ModelSpecificParameter<serdes.internal.ibisami.ami.parameter.AmiParameter





    methods
        function parameter=ModelSpecificParameter(varargin)



            parameter=parameter@serdes.internal.ibisami.ami.parameter.AmiParameter(varargin{:});
            if nargin>1



                p=serdes.internal.ibisami.ami.parameter.ArgumentParser;
                p.parse(varargin{:});
                args=p.Results;
                format=args.Format;
                usage=args.Usage;
                type=args.Type;
                currentValue=args.CurrentValue;
                if~isempty(format)
                    parameter.Format=format;
                end
                if~isempty(usage)
                    parameter.Usage=usage;
                end
                if~isempty(type)
                    if isscalar(type)||ischar(type)
                        parameter.Type=type;
                    else
                        parameter.Types=type;
                    end
                end
                if~isempty(currentValue)
                    parameter.CurrentValue=currentValue;
                end
            end
        end
    end
end
