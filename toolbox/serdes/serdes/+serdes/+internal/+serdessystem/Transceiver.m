classdef(Abstract)Transceiver<handle

    properties(SetAccess=protected)
        Blocks={}
Name
        AnalogModel=serdes.internal.serdessystem.AnalogModel;
    end


    methods
        function obj=Transceiver(varargin)

            p=inputParser;
            p.CaseSensitive=false;
            p.addParameter('Blocks',[]);
            p.addParameter('Name',[]);
            p.addParameter('AnalogModel',[]);
            p.parse(varargin{:});
            args=p.Results;

            obj.Name=args.Name;

            if~isempty(args.Blocks)
                obj.Blocks=args.Blocks;
            end
            if~isempty(args.AnalogModel)

                obj.AnalogModel=args.AnalogModel;
            end
        end
    end


    methods
        function set.AnalogModel(obj,val)
            coder.internal.errorIf(~isa(val,'serdes.internal.serdessystem.AnalogModel'),...
            'serdes:serdessystem:IncorrectInputDataType',...
            'AnalogModel');
            obj.AnalogModel=val;
        end


        function set.Blocks(obj,val)
            validateattributes(val,...
            {'cell'},...
            {},...
            '','Blocks');
            obj.Blocks=val;
        end


    end
end

