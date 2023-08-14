classdef ExporterArgumentParser<handle





    properties
        parser;
    end

    methods
        function results=processArguments(obj,varargin)




            obj.setupParser();
            obj.parseInputParams(varargin{:});
            results=obj.parser.Results;
        end

    end
    methods(Static)
        function params=getParameterNames()

            params={'handle',...
            'destination',...
            'target',...
            'format',...
            'resolution',...
            'margins',...
            'background',...
            'vector',...
            'colorspace',...
            'append',...
            'size',...
            'units',...
            };
        end

        function defValue=getDefault(arg)

            defaults.handle=[];
            defaults.destination='';
            defaults.target='file';
            defaults.format='';
            defaults.resolution=150;
            defaults.margins=2;
            defaults.background=[1,1,1];
            defaults.vector='auto';
            defaults.colorspace='rgb';
            defaults.append=false;
            defaults.size='auto';
            defaults.units='auto';
            fnames=fieldnames(defaults);
            idx=find(strcmp(fnames,arg));
            if~isempty(idx)
                defValue=defaults.(fnames{idx});
            end
        end
    end
    methods(Access=protected)
        function setupParser(obj)
            import matlab.graphics.internal.export.ExporterValidator


            p=inputParser;

            p.addParameter('handle',obj.getDefault('handle'),@ExporterValidator.validateHandle);

            p.addParameter('destination',obj.getDefault('destination'),@ExporterValidator.validateDestination);


            p.addParameter('target',obj.getDefault('target'),@ExporterValidator.validateTarget);
            p.addParameter('format',obj.getDefault('format'),@ExporterValidator.validateFormat);
            p.addParameter('resolution',obj.getDefault('resolution'),@ExporterValidator.validateResolution);
            p.addParameter('margins',obj.getDefault('margins'),@ExporterValidator.validateMargins);
            p.addParameter('background',obj.getDefault('background'),@ExporterValidator.validateBackground);
            p.addParameter('vector',obj.getDefault('vector'),@ExporterValidator.validateVectorFlag);
            p.addParameter('colorspace',obj.getDefault('colorspace'),@ExporterValidator.validateColorspace);
            p.addParameter('append',obj.getDefault('append'),@ExporterValidator.validateAppendValue);

            p.addParameter('size',obj.getDefault('size'),@ExporterValidator.validateSize);
            p.addParameter('units',obj.getDefault('units'),@ExporterValidator.validateUnits);

            obj.parser=p;
        end

        function inputs=parseInputParams(obj,varargin)
            obj.parser.parse(varargin{:});
            inputs=obj.parser.Results;
        end

    end
end

