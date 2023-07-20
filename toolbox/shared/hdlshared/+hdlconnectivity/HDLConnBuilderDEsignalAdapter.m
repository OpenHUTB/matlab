classdef HDLConnBuilderDEsignalAdapter<hdlconnectivity.abstractHDLConnBuilderAdapter








    properties
        array_deref;
    end

    methods
        function this=HDLConnBuilderDEsignalAdapter(varargin)

            for ii=1:2:numel(varargin)-1,
                this.(varargin{ii})=varargin{ii+1};
            end
















            this.array_deref=hdlgetparameter('array_deref');
        end
    end

    methods

        function addDriverReceiverPair(this,driver,receiver,varargin)


            fail=false;


            if~(this.signalValidate(driver))||~(this.signalValidate(receiver)),
                error(message('HDLShared:hdlconnectivity:invalidDriverOrReceiver'));
            end


            unroll=true;
            realonly=false;
            driverIndices=[];
            receiverIndices=[];
            driverPath='';
            receiverPath='';
            boolck_h=@(x)islogical(x)||(x==1)||(x==0);

            for vv=1:2:(numel(varargin)-1),
                param=varargin{vv};
                val=varargin{vv+1};

                switch param,
                case 'unroll',
                    if boolck_h(val),unroll=val;else fail=true;break;end
                case 'realonly',
                    if boolck_h(val),realonly=val;else fail=true;break;end
                case 'driverIndices',
                    if isnumeric(val),driverIndices=val;else fail=true;break;end
                case 'receiverIndices',
                    if isnumeric(val),receiverIndices=val;else fail=true;break;end
                case 'driverPath',
                    if ischar(val),driverPath=val;else fail=true;break;end
                case 'receiverPath'
                    if ischar(val),receiverPath=val;else fail=true;break;end
                otherwise
                    error(message('HDLShared:hdlconnectivity:unknownParam',param));
                end
            end
            if fail,
                error(message('HDLShared:hdlconnectivity:badValue',param));
            end



            scalaropts=struct('driverPath',driverPath,'receiverPath',receiverPath);
            scalaropts.driverIndex=[];
            scalaropts.receiverIndex=[];


            if~isempty(driverIndices)

                if~isempty(receiverIndices),

                    if numel(driverIndices)~=numel(receiverIndices),
                        error(message('HDLShared:hdlconnectivity:hdlconnectivityUnequalDRLengths'));
                    else

                        for ii=1:numel(driverIndices),
                            scalaropts.driverIndex=driverIndices(ii);
                            scalaropts.receiverIndex=receiverIndices(ii);
                            this.scalarAddDriverReceiverPair(driver,receiver,scalaropts);


                            if~realonly&&hdlsignaliscomplex(driver)&&hdlsignaliscomplex(receiver),
                                this.scalarAddDriverReceiverPair(hdlsignalimag(driver),...
                                hdlsignalimag(receiver),scalaropts);
                            end
                        end
                    end

                else
                    for ii=1:numel(driverIndices),
                        scalaropts.driverIndex=driverIndices(ii);
                        this.scalarAddDriverReceiverPair(driver,receiver,scalaropts);


                        if~realonly&&hdlsignaliscomplex(driver)&&hdlsignaliscomplex(receiver),
                            this.scalarAddDriverReceiverPair(hdlsignalimag(driver),...
                            hdlsignalimag(receiver),scalaropts);
                        end
                    end
                end

            elseif~isempty(receiverIndices),

                for ii=1:numel(receiverIndices),
                    scalaropts.receiverIndex=receiverIndices(ii);
                    this.scalarAddDriverReceiverPair(driver,receiver,scalaropts);


                    if~realonly&&hdlsignaliscomplex(driver)&&hdlsignaliscomplex(receiver),
                        this.scalarAddDriverReceiverPair(hdlsignalimag(driver),...
                        hdlsignalimag(receiver),scalaropts);
                    end
                end


            else
                if unroll,

                    d=this.unrollsignal(driver);
                    r=this.unrollsignal(receiver);
                else
                    d=driver;
                    r=receiver;
                end


                if numel(d)~=numel(r),
                    error(message('HDLShared:hdlconnectivity:hdlconnectivityUnequalDRLengths2'));
                else

                    for ii=1:numel(d),
                        this.scalarAddDriverReceiverPair(d(ii),r(ii),scalaropts);
                    end


                    if~realonly&&hdlsignaliscomplex(d(1))&&hdlsignaliscomplex(r(1)),
                        for ii=1:numel(d),
                            this.scalarAddDriverReceiverPair(hdlsignalimag(d(ii)),hdlsignalimag(r(ii)),scalaropts);
                        end
                    end
                end
            end
        end


        function addRegister(this,input,output,clock,clock_enable,varargin)


            if~(this.signalValidate(input))||~(this.signalValidate(output))||...
                ~(this.clockValidate(clock))||~(this.clockEnableValidate(clock_enable)),
                error(message('HDLShared:hdlconnectivity:invalidArguments'));
            end
            unroll=true;
            realonly=false;
            inIndices=[];
            outIndices=[];
            boolck_h=@(x)islogical(x)||(x==1)||(x==0);
            fail=false;

            for vv=1:2:(numel(varargin)-1),
                param=varargin{vv};
                val=varargin{vv+1};

                switch param,
                case 'unroll',
                    if boolck_h(val),unroll=val;else fail=true;break;end
                case 'realonly',
                    if boolck_h(val),realonly=val;else fail=true;break;end
                case 'inIndices',
                    if isnumeric(val),inIndices=val;else fail=true;break;end
                case 'outIndices',
                    if isnumeric(val),outIndices=val;else fail=true;break;end
                otherwise
                    error(message('HDLShared:hdlconnectivity:unknownParam2',param));
                end
            end
            if fail,
                error(message('HDLShared:hdlconnectivity:badValue2',param));
            end

            scalaropts.inIndex=[];
            scalaropts.outIndex=[];





            if isempty(inIndices)&&isempty(outIndices)
                if unroll,
                    in=this.unrollsignal(input);
                    out=this.unrollsignal(output);
                else
                    in=input;
                    out=output;
                end


                if numel(in)~=numel(out),
                    error(message('HDLShared:hdlconnectivity:hdlconnectivityUnequalDRLengths3'));
                else

                    for ii=1:numel(in),
                        this.scalarAddRegister(in(ii),out(ii),clock,clock_enable,scalaropts);
                    end



                    if~realonly&&hdlsignaliscomplex(in(1))&&hdlsignaliscomplex(out(1)),
                        for ii=1:numel(in),
                            this.scalarAddRegister(hdlsignalimag(in(ii)),hdlsignalimag(out(ii)),clock,...
                            clock_enable,scalaropts);
                        end
                    end
                end
            else
                in=input;
                out=output;

                if~isempty(inIndices)&&~isempty(outIndices)&&...
                    numel(inIndices)~=numel(outIndices),
                    error(message('HDLShared:hdlconnectivity:hdlconnectivityUnequalDRLengths4'));
                end

                looplen=max(numel(inIndices),numel(outIndices));


                if~isempty(inIndices),
                    inIndexv=num2cell(inIndices);
                else
                    inIndexv=cell(1,looplen);
                end


                if~isempty(outIndices),
                    outIndexv=num2cell(outIndices);
                else
                    outIndexv=cell(1,looplen);
                end


                for ii=1:looplen
                    scalaropts.inIndex=inIndexv{ii};
                    scalaropts.outIndex=outIndexv{ii};
                    this.scalarAddRegister(in,out,clock,clock_enable,scalaropts);
                end



                if~realonly&&hdlsignaliscomplex(in)&&hdlsignaliscomplex(out),
                    for ii=1:looplen
                        scalaropts.inIndex=inIndexv{ii};
                        scalaropts.outIndex=outIndexv{ii};
                        this.scalarAddRegister(hdlsignalimag(in),hdlsignalimag(out),clock,...
                        clock_enable,scalaropts);
                    end
                end


            end


        end

        function addDriverReceiverRegistered(this,driver,output,clock,clock_enable)




            if~(iscell(driver))||~(this.signalValidate(output))||...
                ~(this.clockValidate(clock))||~(this.clockEnableValidate(clock_enable)),
                error(message('HDLShared:hdlconnectivity:invalidArguments2'));
            end



            for ii=1:numel(driver),
                dscalar(ii)=(numel(driver{ii})==1);
            end
            if all(dscalar)&&(numel(output)==1),
                this.scalarAddDriverReceiverRegistered(driver,output,clock,clock_enable);
            else
                error(message('HDLShared:hdlconnectivity:hdlconnectivityUnequalDregRLengths'));
            end

        end







        function tf=signalValidate(this,signal)
            tf=isa(signal,'hdlcoder.signal');
        end
        function tf=clockValidate(this,clk)
            tf=isa(clk,'hdlcoder.signal');
        end
        function tf=clockEnableValidate(this,enb)
            tf=isa(enb,'hdlcoder.signal');
        end




    end



    methods(Access=private)

        function scalarAddDriverReceiverPair(this,driver,receiver,opts)



            dnets=this.netFromSignal(driver,opts.driverPath,opts.driverIndex);
            rnets=this.netFromSignal(receiver,opts.receiverPath,opts.receiverIndex);

            if numel(dnets)~=numel(rnets),
                error(message('HDLShared:hdlconnectivity:hdlconnectivityUnequalHier'));
            else
                for ii=1:numel(dnets),
                    this.builder.bldrAddDriverReceiverPair(dnets(ii),rnets(ii));
                end
            end
        end

        function scalarAddRegister(this,in,out,clock,clock_enable,opts)



            insig=this.netFromSignal(in,'',opts.inIndex);
            outsig=this.netFromSignal(out,'',opts.outIndex);
            clksig=this.netFromSignal(clock,'');






            if isempty(clock_enable)
                for ii=1:numel(outsig),
                    clkensig(1,ii)=hdlconnectivity.hdlnet('name','',...
                    'path',outsig(ii).path,...
                    'connectivityOnly',true,...
                    'sltype','boolean');
                end
            else
                for kk=1:numel(clock_enable),
                    clkensig(kk,:)=this.netFromSignal(clock_enable(kk),'');
                end
            end




            if~all(bsxfun(@eq,numel(insig),[numel(outsig),numel(clksig),size(clkensig,2)])),
                error(message('HDLShared:hdlconnectivity:hdlconnectivityUnequalHier'));
            else
                for ii=1:numel(insig),


                    outsig(ii).isRegisterOutput=1;
                    clksig(ii).isClock=1;
                    clkens=clkensig(:,ii)';
                    for jj=1:numel(clkens),
                        clkens(jj).isClockEnable=1;
                    end

                    reg=hdlconnectivity.hdlregister('input',insig(ii),...
                    'output',outsig(ii),...
                    'clock',clksig(ii),...
                    'clock_enable',clkens);

                    this.builder.bldrAddRegister(reg);
                end
            end
        end

        function scalarAddDriverReceiverRegistered(this,d,o,clk,enb)


            for ii=1:numel(d),
                dnets{ii}=this.netFromSignal(d{ii},'');
            end






            for inst=1:numel(dnets{1}),

                tempNet=hdlconnectivity.hdlnet('name',hdlconnectivity.tempNetName,...
                'path',dnets{1}(inst).path,...
                'connectivityOnly',true);


                for inp=1:numel(dnets)
                    this.builder.bldrAddDriverReceiverPair(dnets{inp}(inst),tempNet);
                end


                onet=this.netFromSignal(o,dnets{1}(inst).path);
                clknet=this.netFromSignal(clk,dnets{1}(inst).path);







                if isempty(enb)
                    for ii=1:numel(onet),
                        enbnet(1,ii)=hdlconnectivity.hdlnet('name','',...
                        'path',onet(ii).path,...
                        'connectivityOnly',true,...
                        'sltype','boolean');
                    end
                else
                    for kk=1:numel(enb),
                        enbnet(kk)=this.netFromSignal(enb(kk),dnets{1}(inst).path);
                        enbnet(kk).isClockEnable=1;
                    end
                end
                onet.isRegisterOutput=1;
                clknet.isClock=1;


                reg=hdlconnectivity.hdlregister('input',tempNet,...
                'output',onet,...
                'clock',clknet,...
                'clock_enable',enbnet);


                this.builder.bldrAddRegister(reg);

            end
        end



        function vec=unrollsignal(this,signal)

            if hdlissignalvector(signal),
                vec=hdlexpandvectorsignal(signal);
            else
                vec=signal;
            end
        end

    end
    methods
        function net=netFromSignal(this,signal,pathin,index)





            if nargin>2&&~isempty(pathin),
                paths={pathin};
            else
                hCD=hdlconnectivity.getConnectivityDirector;
                paths=hCD.getNetworkHDLPath(signal.Owner);
            end


            if nargin>3&&~isempty(index),
                netname=[signal.Name,this.array_deref(1),num2str(index),this.array_deref(2)];
            else
                netname=signal.Name;
            end

            sltype=hdlsignalsltype(signal);
            net(numel(paths))=hdlconnectivity.hdlnet;
            set(net,'name',netname,{'path'},paths','sltype',sltype);
        end



    end



end


