classdef HDLConnBuilderStringAdapter<hdlconnectivity.abstractHDLConnBuilderAdapter














    properties
        addDRip;
        addREGip;
        addDRregip;
    end

    methods
        function this=HDLConnBuilderStringAdapter(varargin)

            for ii=1:2:numel(varargin)-1,
                this.(varargin{ii})=varargin{ii+1};
            end
            this.initInputParsers;

            this.addREGip.addParamValue('path','',@char);
        end
    end

    methods

        function addDriverReceiverPair(this,driver,receiver,varargin)


            this.addDRip.parse(this,driver,receiver,varargin{:});
            opts=this.addDRip.Results;

            d=this.netFromSignal(driver,opts.driverPath);
            r=this.netFromSignal(receiver,opts.receiverPath);

            this.builder.bldrAddDriverReceiverPair(d,r);

        end

        function addRegister(this,input,output,clock,clock_enable,varargin)


            disp('String adapter called. Need sltype for Reg outputs.')


            this.addREGip.parse(this,input,output,clock,clock_enable,varargin{:})
            opts=this.addREGip.Results;


            in=this.netFromSignal(input,opts.path);
            out=this.netFromSignal(output,opts.path);
            if isempty(clock_enable),
                enb=hdlconnectivity.hdlnet('name','',...
                'sltype','boolean',...
                'isClockEnable',true,...
                'connectivityOnly',true,...
                'path',opts.path);
            else
                for ii=1:numel(clock_enable),
                    enb(ii)=this.netFromSignal(clock_enable,opts.path);
                    enb(ii).isClockEnable=1;
                end
            end
            clk=this.netFromSignal(clock,opts.path);

            reg=hdlconnectivity.hdlregister('input',in,...
            'output',out,...
            'clock',clk,...
            'clock_enable',enb);

            this.builder.bldrAddRegister(reg);

        end

        function addDriverReceiverRegistered(this,driver,output,clock,clock_enable,varargin)


            disp('String adapter called. Need sltype for Reg outputs.')


            this.addDRregip.parse(this,driver,output,clock,clock_enable,varargin{:});
            opts=this.addDRregip.Results;


            tempNet=hdlconnectivity.hdlnet('name',hdlconnectivity.tempNetName,...
            'path',{opts.path},...
            'connectivityOnly',true);


            for ii=1:numel(driver)
                d=this.netFromSignal(driver{ii},opts.driverPath);
                this.builder.bldrAddDriverReceiverPair(d,tempNet);
            end


            this.addRegister(tempNet.name,output,clock,clock_enable,'path',opts.path);
        end






        function tf=signalValidate(this,signal)
            tf=ischar(signal);
        end
        function tf=clockValidate(this,clk)
            tf=ischar(clk);
        end
        function tf=clockEnableValidate(this,enb)
            tf=ischar(enb);
        end



    end

    methods(Access=private)
        function net=netFromSignal(this,signalname,pathin)


            net=hdlconnectivity.hdlnet('name',signalname,...
            'sltype','',...
            'path',pathin);
        end

        function initInputParsers(this)




            this.addDRip=inputParser;

            this.addDRip.addRequired('adapter');
            this.addDRip.addRequired('driver',@(x)this.signalValidate(x));
            this.addDRip.addRequired('receiver',@(x)this.signalValidate(x));
            this.addDRip.addParamValue('driverPath','',@ischar);
            this.addDRip.addParamValue('receiverPath','',@ischar);


            this.addREGip=inputParser;
            this.addREGip.addRequired('adapter');
            this.addREGip.addRequired('input',@(x)this.signalValidate(x));
            this.addREGip.addRequired('output',@(x)this.signalValidate(x));
            this.addREGip.addRequired('clock',@(x)this.clockValidate(x));
            this.addREGip.addRequired('clockenable',@(x)this.clockEnableValidate(x));

            this.addDRregip=inputParser;
            this.addDRregip.addRequired('driver',@iscell);
            this.addDRregip.addRequired('output',@(x)this.signalValidate(x));
            this.addDRregip.addRequired('clock',@(x)this.signalValidate(x));
            this.addDRregip.addRequired('clockenable',@(x)this.signalValidate(x));
            this.addDRregip.addParamValue('path','',@ischar);
        end
    end

end


