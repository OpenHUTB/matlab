classdef ChannelData












    properties
Impulse
dt

        ChannelLossdB=8;
        ChannelLossFreq=5e9;
        ChannelDifferentialImpedance=100;


        EnableCrosstalk=false;
        CrosstalkSpecification='CEI-28G-SR';
        fb=14e9;
        FEXTICN=15e-3;
        Aft=1.200;
        Tft=9.6e-12;
        NEXTICN=10e-3;
        Ant=1.200;
        Tnt=9.6e-12;
    end

    properties(SetAccess=private)
        OptionSel=0;
    end

    methods



        function obj=set.EnableCrosstalk(obj,val)
            validateattributes(val,{'numeric','logical'},...
            {'scalar','binary'},'','EnableCrosstalk');
            obj.EnableCrosstalk=logical(val);
        end
        function obj=set.CrosstalkSpecification(obj,val)
            validateattributes(val,{'char','string'},...
            {'vector'},'','CrosstalkSpecification');
            xSpec={'CEI-28G-SR','CEI-25G-LR','CEI-28G-VSR','100GBASE-CR4','Custom'};
            ismemberTest=strcmpi(xSpec,val);
            coder.internal.errorIf(~any(ismemberTest),...
            'serdes:serdessystem:XtalkSpecIncorrect',...
            val,'CrosstalkSpecification',...
            '"CEI-28G-SR" | "CEI-25G-LR" | "CEI-28G-VSR" | "100GBASE-CR4" | "Custom"');
            obj.CrosstalkSpecification=xSpec{ismemberTest};
        end
        function obj=set.fb(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite'},'','fb');
            obj.fb=double(val);
        end
        function obj=set.FEXTICN(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite'},'','FEXTICN');
            obj.FEXTICN=double(val);
        end
        function obj=set.Aft(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite'},'','Aft');
            obj.Aft=double(val);
        end
        function obj=set.Tft(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite'},'','Tft');
            obj.Tft=double(val);
        end
        function obj=set.NEXTICN(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite'},'','NEXTICN');
            obj.NEXTICN=double(val);
        end
        function obj=set.Ant(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite'},'','Ant');
            obj.Ant=double(val);
        end
        function obj=set.Tnt(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite'},'','Tnt');
            obj.Tnt=double(val);
        end
        function obj=set.Impulse(obj,val)
            validateattributes(val,{'numeric'},...
            {'2d','finite'},'','Impulse');
            obj.Impulse=double(val);
        end
        function obj=set.dt(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite'},'','dt');
            obj.dt=double(val);
        end
        function obj=set.ChannelLossFreq(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','positive'},'','ChannelLossFreq');
            obj.ChannelLossFreq=double(val);
        end
        function obj=set.ChannelDifferentialImpedance(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','positive'},'',...
            'ChannelDifferentialImpedance');
            obj.ChannelDifferentialImpedance=double(val);
        end
        function obj=set.ChannelLossdB(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','finite','real'},'',...
            'ChannelLossdB');


            minLoss=1;
            coder.internal.errorIf(~(val==0||val>=minLoss),...
            'serdes:serdessystem:LossValueRange',...
            sprintf('%g',minLoss));

            obj.ChannelLossdB=double(val);
        end

        function obj=ChannelData(varargin)


            p=inputParser;
            p.CaseSensitive=false;
            p.addParameter('Impulse',[]);
            p.addParameter('dt',[]);

            p.addParameter('ChannelLossdB',[]);
            p.addParameter('ChannelDifferentialImpedance',[]);
            p.addParameter('ChannelLossFreq',[]);

            p.addParameter('EnableCrosstalk',[]);
            p.addParameter('CrosstalkSpecification',[]);
            p.addParameter('fb',[]);
            p.addParameter('FEXTICN',[]);
            p.addParameter('Aft',[]);
            p.addParameter('Tft',[]);
            p.addParameter('NEXTICN',[]);
            p.addParameter('Ant',[]);
            p.addParameter('Tnt',[]);

            p.parse(varargin{:});
            args=p.Results;









            if(~isempty(args.Impulse))&&(~isempty(args.dt))


                localImpulse=args.Impulse;
                impulseSize=size(localImpulse);
                coder.internal.errorIf(impulseSize(2)>impulseSize(1),...
                'serdes:serdessystem:ImpulseWaveShouldBeColumnMatrix2');
                obj.Impulse=localImpulse;
                obj.dt=args.dt;
                obj.OptionSel=1;



                if impulseSize(2)>1
                    obj.EnableCrosstalk=true;
                end


                thisOptionStr='Impulse and dt';


                if~isempty(args.ChannelLossdB)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','ChannelLossdB',thisOptionStr);
                elseif~isempty(args.ChannelLossFreq)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','ChannelLossFreq',thisOptionStr);
                elseif~isempty(args.ChannelDifferentialImpedance)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','ChannelDifferentialImpedance',thisOptionStr);
                elseif~isempty(args.fb)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','fb',thisOptionStr);
                elseif~isempty(args.FEXTICN)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','FEXTICN',thisOptionStr);
                elseif~isempty(args.Aft)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','Aft',thisOptionStr);
                elseif~isempty(args.Tft)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','Tft',thisOptionStr);
                elseif~isempty(args.NEXTICN)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','NEXTICN',thisOptionStr);
                elseif~isempty(args.Ant)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','Ant',thisOptionStr);
                elseif~isempty(args.Tnt)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','Tnt',thisOptionStr);
                elseif~isempty(args.CrosstalkSpecification)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','CrosstalkSpecification',thisOptionStr);
                elseif~isempty(args.EnableCrosstalk)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','EnableCrosstalk',thisOptionStr);
                end





















            else

                if~isempty(args.ChannelLossdB)
                    obj.ChannelLossdB=args.ChannelLossdB;
                end
                if~isempty(args.ChannelDifferentialImpedance)
                    obj.ChannelDifferentialImpedance=args.ChannelDifferentialImpedance;
                end
                if~isempty(args.ChannelLossFreq)
                    obj.ChannelLossFreq=args.ChannelLossFreq;
                end
                if~isempty(args.EnableCrosstalk)
                    obj.EnableCrosstalk=args.EnableCrosstalk;
                end
                if~isempty(args.CrosstalkSpecification)
                    obj.CrosstalkSpecification=args.CrosstalkSpecification;
                end
                if~isempty(args.fb)
                    obj.fb=args.fb;
                end
                if~isempty(args.FEXTICN)
                    obj.FEXTICN=args.FEXTICN;
                end
                if~isempty(args.Aft)
                    obj.Aft=args.Aft;
                end
                if~isempty(args.Tft)
                    obj.Tft=args.Tft;
                end
                if~isempty(args.NEXTICN)
                    obj.NEXTICN=args.NEXTICN;
                end
                if~isempty(args.Ant)
                    obj.Ant=args.Ant;
                end
                if~isempty(args.Tnt)
                    obj.Tnt=args.Tnt;
                end
                obj.OptionSel=3;


                thisOptionStr='ChannelLossdB, ChannelLossFreq and ChannelDifferentialImpedance';
                if~isempty(args.Impulse)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','Impulse',thisOptionStr);
                elseif~isempty(args.dt)
                    coder.internal.warning('serdes:serdessystem:ChannelInputIgnored','dt',thisOptionStr);


                end
            end

        end
    end
end

