classdef JitterAndNoise<handle

    properties
        RxClockMode='clocked';

        Tx_DCD=SimpleJitter('Flavor','DCD');
        Tx_Rj=SimpleJitter('Flavor','Rj');
        Tx_Dj=SimpleJitter('Flavor','Dj');
        Tx_Sj=SimpleJitter('Flavor','Sj');
        Tx_Sj_Frequency=SimpleJitter('Type','Float','Flavor','Fixed')

        Rx_DCD=SimpleJitter('Flavor','DCD');
        Rx_Rj=SimpleJitter('Flavor','Rj');
        Rx_Dj=SimpleJitter('Flavor','Dj');
        Rx_Sj=SimpleJitter('Flavor','Sj');
        Rx_Clock_Recovery_Mean=SimpleJitter('Flavor','Fixed');
        Rx_Clock_Recovery_Rj=SimpleJitter('Flavor','Rj');
        Rx_Clock_Recovery_Dj=SimpleJitter('Flavor','Dj');
        Rx_Clock_Recovery_Sj=SimpleJitter('Flavor','Sj');
        Rx_Clock_Recovery_DCD=SimpleJitter('Flavor','DCD');
        Rx_Receiver_Sensitivity=SimpleJitter('Type','Float','Flavor','Fixed')

        Rx_GaussianNoise=SimpleJitter('Type','Float','Flavor','Rj')
        Rx_UniformNoise=SimpleJitter('Type','Float','Flavor','Dj')

    end


    methods
        function obj=JitterAndNoise(varargin)

            p=inputParser;
            p.CaseSensitive=false;
            p.addParameter('RxClockMode',[]);
            p.addParameter('Tx_DCD',[]);
            p.addParameter('Tx_Rj',[]);
            p.addParameter('Tx_Dj',[]);
            p.addParameter('Tx_Sj',[]);
            p.addParameter('Tx_Sj_Frequency',[]);
            p.addParameter('Rx_DCD',[]);
            p.addParameter('Rx_Rj',[]);
            p.addParameter('Rx_Dj',[]);
            p.addParameter('Rx_Sj',[]);
            p.addParameter('Rx_Clock_Recovery_Mean',[]);
            p.addParameter('Rx_Clock_Recovery_Rj',[]);
            p.addParameter('Rx_Clock_Recovery_Dj',[]);
            p.addParameter('Rx_Clock_Recovery_Sj',[]);
            p.addParameter('Rx_Clock_Recovery_DCD',[]);
            p.addParameter('Rx_Receiver_Sensitivity',[]);
            p.addParameter('Rx_GaussianNoise',[]);
            p.addParameter('Rx_UniformNoise',[]);
            p.parse(varargin{:});
            args=p.Results;

            if~isempty(args.RxClockMode)
                obj.RxClockMode=args.RxClockMode;
            end
            if~isempty(args.Tx_DCD)
                obj.Tx_DCD=args.Tx_DCD;
            end
            if~isempty(args.Tx_Rj)
                obj.Tx_Rj=args.Tx_Rj;
            end
            if~isempty(args.Tx_Dj)
                obj.Tx_Dj=args.Tx_Dj;
            end
            if~isempty(args.Tx_Sj)
                obj.Tx_Sj=args.Tx_Sj;
            end
            if~isempty(args.Tx_Sj_Frequency)
                obj.Tx_Sj_Frequency=args.Tx_Sj_Frequency;
            end
            if~isempty(args.Rx_DCD)
                obj.Rx_DCD=args.Rx_DCD;
            end
            if~isempty(args.Rx_Rj)
                obj.Rx_Rj=args.Rx_Rj;
            end
            if~isempty(args.Rx_Dj)
                obj.Rx_Dj=args.Rx_Dj;
            end
            if~isempty(args.Rx_Sj)
                obj.Rx_Sj=args.Rx_Sj;
            end
            if~isempty(args.Rx_Clock_Recovery_Mean)
                obj.Rx_Clock_Recovery_Mean=args.Rx_Clock_Recovery_Mean;
            end
            if~isempty(args.Rx_Clock_Recovery_Rj)
                obj.Rx_Clock_Recovery_Rj=args.Rx_Clock_Recovery_Rj;
            end
            if~isempty(args.Rx_Clock_Recovery_Dj)
                obj.Rx_Clock_Recovery_Dj=args.Rx_Clock_Recovery_Dj;
            end
            if~isempty(args.Rx_Clock_Recovery_Sj)
                obj.Rx_Clock_Recovery_Sj=args.Rx_Clock_Recovery_Sj;
            end
            if~isempty(args.Rx_Clock_Recovery_DCD)
                obj.Rx_Clock_Recovery_DCD=args.Rx_Clock_Recovery_DCD;
            end
            if~isempty(args.Rx_Receiver_Sensitivity)
                obj.Rx_Receiver_Sensitivity=args.Rx_Receiver_Sensitivity;
            end
            if~isempty(args.Rx_GaussianNoise)
                obj.Rx_GaussianNoise=args.Rx_GaussianNoise;
            end
            if~isempty(args.Rx_UniformNoise)
                obj.Rx_UniformNoise=args.Rx_UniformNoise;
            end
        end


        function set.RxClockMode(obj,val)
            validateattributes(val,{'char','string'},{},'','RxClockMode');
            val=lower(strtrim(val));
            mustBeMember(val,{'ideal','convolved','clocked','normal'})
            if strcmp(val,'normal')
                val='ideal';
            end
            obj.RxClockMode=val;
        end


        function set.Tx_DCD(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='DCD';
                obj.Tx_DCD=val;
            else
                obj.Tx_DCD=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','DCD');
            end
        end


        function set.Tx_Rj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Rj';
                obj.Tx_Rj=val;
            else
                obj.Tx_Rj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Rj');
            end
        end


        function set.Tx_Dj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Dj';
                obj.Tx_Dj=val;
            else
                obj.Tx_Dj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Dj');
            end
        end


        function set.Tx_Sj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Sj';
                obj.Tx_Sj=val;
            else
                obj.Tx_Sj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Sj');
            end
        end


        function set.Tx_Sj_Frequency(obj,val)


            if isa(val,'SimpleJitter')
                if~isequal(val.Type,'Float')
                    coder.internal.warning('serdes:serdessystem:FloatNotUI')
                    val.Type='Float';
                end
                val.Flavor='Fixed';
                obj.Tx_Sj_Frequency=val;
            else
                obj.Tx_Sj_Frequency=SimpleJitter(...
                'Value',val,'Include',true,'Type','Float','Flavor','Fixed');
            end
        end


        function set.Rx_DCD(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='DCD';
                obj.Rx_DCD=val;
            else
                obj.Rx_DCD=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','DCD');
            end
        end


        function set.Rx_Rj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Rj';
                obj.Rx_Rj=val;
            else
                obj.Rx_Rj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Rj');
            end
        end
        function set.Rx_Dj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Dj';
                obj.Rx_Dj=val;
            else
                obj.Rx_Dj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Dj');
            end
        end
        function set.Rx_Sj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Sj';
                obj.Rx_Sj=val;
            else
                obj.Rx_Sj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Sj');
            end
        end
        function set.Rx_Clock_Recovery_Mean(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Fixed';
                obj.Rx_Clock_Recovery_Mean=val;
            else
                obj.Rx_Clock_Recovery_Mean=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Fixed');
            end
        end
        function set.Rx_Clock_Recovery_Rj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Rj';
                obj.Rx_Clock_Recovery_Rj=val;
            else
                obj.Rx_Clock_Recovery_Rj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Rj');
            end
        end
        function set.Rx_Clock_Recovery_Dj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Dj';
                obj.Rx_Clock_Recovery_Dj=val;
            else
                obj.Rx_Clock_Recovery_Dj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Dj');
            end
        end
        function set.Rx_Clock_Recovery_Sj(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='Sj';
                obj.Rx_Clock_Recovery_Sj=val;
            else
                obj.Rx_Clock_Recovery_Sj=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','Sj');
            end
        end
        function set.Rx_Clock_Recovery_DCD(obj,val)

            if isa(val,'SimpleJitter')
                val.Flavor='DCD';
                obj.Rx_Clock_Recovery_DCD=val;
            else
                obj.Rx_Clock_Recovery_DCD=SimpleJitter(...
                'Value',val,'Include',true,'Flavor','DCD');
            end
        end
        function set.Rx_Receiver_Sensitivity(obj,val)


            if isa(val,'SimpleJitter')
                if~isequal(val.Type,'Float')
                    coder.internal.warning('serdes:serdessystem:FloatNotUI')
                    val.Type='Float';
                end
                val.Flavor='Fixed';
                obj.Rx_Receiver_Sensitivity=val;
            else
                obj.Rx_Receiver_Sensitivity=SimpleJitter(...
                'Value',val,'Include',true,'Type','Float','Flavor','Fixed');
            end
        end
        function set.Rx_GaussianNoise(obj,val)


            if isa(val,'SimpleJitter')
                if~isequal(val.Type,'Float')
                    coder.internal.warning('serdes:serdessystem:FloatNotUI')
                    val.Type='Float';
                end
                val.Flavor='Rj';
                obj.Rx_GaussianNoise=val;
            else
                obj.Rx_GaussianNoise=SimpleJitter(...
                'Value',val,'Include',true,'Type','Float','Flavor','Rj');
            end
        end
        function set.Rx_UniformNoise(obj,val)


            if isa(val,'SimpleJitter')
                if~isequal(val.Type,'Float')
                    coder.internal.warning('serdes:serdessystem:FloatNotUI')
                    val.Type='Float';
                end
                val.Flavor='Dj';
                obj.Rx_UniformNoise=val;
            else
                obj.Rx_UniformNoise=SimpleJitter(...
                'Value',val,'Include',true,'Type','Float','Flavor','Dj');
            end
        end
    end
end