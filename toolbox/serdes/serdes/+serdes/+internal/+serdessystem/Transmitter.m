classdef Transmitter<serdes.internal.serdessystem.Transceiver

    properties
        RiseTime=1e-12;
        VoltageSwingIdeal=1;
    end


    methods
        function tx=Transmitter(varargin)
            names=varargin(1:2:nargin);
            ParamTest=ismember(names,{'RiseTime','VoltageSwingIdeal'});

            input1=varargin([ParamTest;ParamTest]);
            input2=varargin(~[ParamTest;ParamTest]);
            tx=tx@serdes.internal.serdessystem.Transceiver(input2{:});

            tx.Name='TX';

            p=inputParser;
            p.CaseSensitive=false;
            p.addParameter('RiseTime',[]);
            p.addParameter('VoltageSwingIdeal',[]);
            p.parse(input1{:});
            args=p.Results;
            if~isempty(args.VoltageSwingIdeal)
                tx.VoltageSwingIdeal=args.VoltageSwingIdeal;
            end
            if~isempty(args.RiseTime)
                tx.RiseTime=args.RiseTime;
            end

        end
    end


    methods
        function set.RiseTime(obj,val)
            validateattributes(val,...
            {'numeric'},...
            {'scalar','nonnegative','finite'},...
            '','RiseTime');
            obj.RiseTime=double(val);
        end


        function set.VoltageSwingIdeal(obj,val)
            validateattributes(val,...
            {'numeric'},...
            {'scalar','positive','finite'},...
            '','VoltageSwingIdeal');
            obj.VoltageSwingIdeal=double(val);
        end
    end
end

