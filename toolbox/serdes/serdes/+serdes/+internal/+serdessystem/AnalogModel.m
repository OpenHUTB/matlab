classdef AnalogModel<handle

    properties
        R=50;
        C=1e-15;
    end


    methods
        function obj=AnalogModel(varargin)

            p=inputParser;
            p.CaseSensitive=false;
            p.addParameter('R',[]);
            p.addParameter('C',[]);
            p.parse(varargin{:});
            args=p.Results;

            if~isempty(args.R)
                obj.R=args.R;
            end
            if~isempty(args.C)
                obj.C=args.C;
            end
        end
    end


    methods
        function set.R(obj,val)
            validateattributes(val,...
            {'numeric'},...
            {'scalar','finite','positive','<=',100e6},...
            '','R');
            obj.R=double(val);
        end


        function set.C(obj,val)
            validateattributes(val,...
            {'numeric'},...
            {'scalar','finite','nonnegative'},...
            '','C');
            obj.C=double(val);
        end
    end

end

