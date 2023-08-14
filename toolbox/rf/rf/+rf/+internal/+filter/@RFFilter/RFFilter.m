classdef(Abstract)RFFilter<matlab.mixin.SetGet



    properties
FilterType
ResponseType
Zin
Zout
designData
    end

    properties(Dependent)
FilterOrder
PassbandFrequency
PassbandAttenuation
StopbandFrequency
StopbandAttenuation
Implementation
    end

    properties(Hidden)
        UseFilterOrder=true;
    end

    properties(Hidden,SetAccess=private)
DesignMethod
PassFreq_lp
PassFreq_hp
PassFreq_bs
PassFreq_bp
StopFreq_lp
StopFreq_hp
StopFreq_bs
StopFreq_bp
Rload
Rsrc
    end

    properties(Hidden,Access=protected)
privateFilterOrder
privatePassbandFreq
privateStopbandFreq
privateStopbandAttenuation
privatePassbandAttenuation
privateImplementation
    end

    properties(Access=protected,Constant)
        DefaultFilterType='Butterworth'
        DefaultResponseType='Lowpass'
        DefaultImplementation='LC Tee'
        DefaultFilterOrder=3
        DefaultPassFreq_lp=1e9
        DefaultPassFreq_hp=2e9
        DefaultPassFreq_bp=[2e9,3e9]
        DefaultPassFreq_bs=[1e9,4e9]
        DefaultStopFreq_lp=2e9
        DefaultStopFreq_hp=1e9
        DefaultStopFreq_bs=[2.1,2.9]*1e9
        DefaultStopFreq_bp=[1.5,3.5]*1e9
        DefaultPassAtten=10*log10(2)
        DefaultStopAtten=40
        DefaultZin=50
        DefaultZout=50
    end

    properties(Hidden,Constant)
        FilterTypeValues={'Butterworth','Chebyshev','InverseChebyshev'};
        ResponseTypeValues={'Lowpass','Highpass','Bandpass','Bandstop'};
        ImplementationValues={'Transfer function','LC Tee','LC Pi'};
    end

    properties(Constant,Access=protected)
        DefaultName='Filter'
    end

    methods(Access=protected,Hidden)
        function p=makeInputParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',obj.DefaultName);
            addParameter(p,'FilterType',obj.DefaultFilterType);
            addParameter(p,'ResponseType',obj.DefaultResponseType);
            addParameter(p,'Implementation',obj.DefaultImplementation);
            addParameter(p,'FilterOrder',obj.DefaultFilterOrder);
            addParameter(p,'PassbandFrequency',obj.DefaultPassFreq_lp);
            addParameter(p,'StopbandFrequency',obj.DefaultStopFreq_lp);
            addParameter(p,'PassbandAttenuation',obj.DefaultPassAtten);
            addParameter(p,'StopbandAttenuation',obj.DefaultStopAtten);
            addParameter(p,'Zin',obj.DefaultZin);
            addParameter(p,'Zout',obj.DefaultZout);
        end

        function setParsedProperties(obj,p)
            obj.FilterType=p.Results.FilterType;
            obj.ResponseType=p.Results.ResponseType;
            obj.Implementation=p.Results.Implementation;
            obj.FilterOrder=p.Results.FilterOrder;
            Fp_flag=any(strcmpi(p.UsingDefaults,'PassbandFrequency'));
            Fs_flag=any(strcmpi(p.UsingDefaults,'StopbandFrequency'));
            Rs_flag=any(strcmpi(p.UsingDefaults,'StopbandAttenuation'));
            Rp_flag=any(strcmpi(p.UsingDefaults,'PassbandAttenuation'));
            n_flag=~any(strcmpi(p.UsingDefaults,'FilterOrder'));
            isinvcheby=strcmpi(obj.FilterType,'inversechebyshev');
            if~isinvcheby
                if Fp_flag
                    switch obj.ResponseType
                    case 'Lowpass'
                        obj.PassbandFrequency=obj.DefaultPassFreq_lp;
                    case 'Highpass'
                        obj.PassbandFrequency=obj.DefaultPassFreq_hp;
                    case 'Bandpass'
                        obj.PassbandFrequency=obj.DefaultPassFreq_bp;
                    case 'Bandstop'
                        if~Rp_flag&&strcmpi(obj.FilterType,'Butterworth')
                            obj.PassbandFrequency=obj.DefaultPassFreq_bs;
                        end
                    end
                else
                    obj.PassbandFrequency=p.Results.PassbandFrequency;
                end

                if Fs_flag
                    switch obj.ResponseType
                    case 'Lowpass'
                        if~Rs_flag
                            obj.StopbandFrequency=obj.DefaultStopFreq_lp;
                        end
                    case 'Highpass'
                        if~Rs_flag
                            obj.StopbandFrequency=obj.DefaultStopFreq_hp;
                        end
                    case 'Bandpass'
                        if~Rs_flag
                            obj.StopbandFrequency=obj.DefaultStopFreq_bp;
                        end
                    case 'Bandstop'
                        obj.StopbandFrequency=obj.DefaultStopFreq_bs;
                    end
                else
                    obj.StopbandFrequency=p.Results.StopbandFrequency;
                end

                if Rs_flag
                    switch obj.ResponseType
                    case 'Bandstop'
                        obj.StopbandAttenuation=obj.DefaultStopAtten;
                    otherwise
                        if~Fs_flag
                            obj.StopbandAttenuation=obj.DefaultStopAtten;
                        end
                    end
                else
                    obj.StopbandAttenuation=p.Results.StopbandAttenuation;
                end

                if Rp_flag

                    if~strcmpi(obj.FilterType,'Butterworth')
                        obj.PassbandAttenuation=obj.DefaultPassAtten;
                    end

                    switch obj.ResponseType
                    case{'Lowpass','Highpass','Bandpass'}
                        obj.PassbandAttenuation=obj.DefaultPassAtten;
                    otherwise
                        if~Fp_flag
                            obj.PassbandAttenuation=obj.DefaultPassAtten;
                        end
                    end
                else
                    obj.PassbandAttenuation=p.Results.PassbandAttenuation;
                end
            else
                if~strcmp(obj.ResponseType,'Bandstop')

                    if Rs_flag


                        obj.StopbandAttenuation=obj.DefaultStopAtten;
                    else

                        obj.StopbandAttenuation=p.Results.StopbandAttenuation;
                    end

                    if~Fp_flag&&~Fs_flag


                        obj.StopbandFrequency=p.Results.StopbandFrequency;
                    end

                    if(~Fp_flag&&Fs_flag)||(~Fp_flag&&~Fs_flag)




                        obj.PassbandFrequency=p.Results.PassbandFrequency;
                    elseif Fp_flag&&~Fs_flag

                        obj.PassbandFrequency=p.Results.StopbandFrequency;
                    else

                        switch obj.ResponseType
                        case 'Lowpass'
                            obj.PassbandFrequency=obj.DefaultPassFreq_lp;
                        case 'Highpass'
                            obj.PassbandFrequency=obj.DefaultPassFreq_hp;
                        case 'Bandpass'
                            obj.PassbandFrequency=obj.DefaultPassFreq_bp;
                        end
                    end

                    if Fp_flag&&~Fs_flag


                        obj.PassbandAttenuation=obj.StopbandAttenuation;
                    else


                        if Rp_flag


                            obj.PassbandAttenuation=obj.DefaultPassAtten;
                        else
                            obj.PassbandAttenuation=p.Results.PassbandAttenuation;
                        end
                    end
                else
                    if Fp_flag
                        if~Rp_flag
                            obj.PassbandFrequency=obj.DefaultPassFreq_bs;
                        end
                    else
                        obj.PassbandFrequency=p.Results.PassbandFrequency;
                    end

                    if Fs_flag
                        obj.StopbandFrequency=obj.DefaultStopFreq_bs;
                    else
                        obj.StopbandFrequency=p.Results.StopbandFrequency;
                    end

                    if Rs_flag
                        obj.StopbandAttenuation=obj.DefaultStopAtten;
                    else
                        obj.StopbandAttenuation=p.Results.StopbandAttenuation;
                    end

                    if Rp_flag
                        if~Fp_flag
                            obj.PassbandAttenuation=obj.DefaultPassAtten;
                        end
                    else
                        obj.PassbandAttenuation=p.Results.PassbandAttenuation;
                    end
                end
            end

            if n_flag
                obj.UseFilterOrder=true;
            end
            obj.Zin=p.Results.Zin;
            obj.Zout=p.Results.Zout;
        end
    end

    methods
        function obj=RFFilter(varargin)
            p=makeInputParser(obj);
            parse(p,varargin{:});
            setParsedProperties(obj,p);
            filt_design(obj);
        end
    end

    methods
        function set.FilterType(obj,val)
            validstr=validatestring(val,obj.FilterTypeValues,...
            'rffilter','FilterType');
            obj.FilterType=validstr;
        end

        function set.ResponseType(obj,val)
            validstr=validatestring(val,obj.ResponseTypeValues,...
            'rffilter','ResponseType');
            obj.ResponseType=validstr;
        end

        function set.Implementation(obj,val)
            validstr=validatestring(val,obj.ImplementationValues,...
            'rffilter','Implementation');
            obj.privateImplementation=validstr;
        end

        function val=get.Implementation(obj)
            val=obj.privateImplementation;
        end

        function set.FilterOrder(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','integer','>=',2,'<=',60},...
            mfilename,'Filter order');
            obj.privateFilterOrder=val;
            obj.UseFilterOrder=true;
        end

        function val=get.FilterOrder(obj)
            val=obj.privateFilterOrder;
        end

        function set.PassbandFrequency(obj,val)
            switch obj.ResponseType
            case 'Lowpass'
                validateattributes(val,{'numeric'},...
                {'nonempty','scalar','finite',...
                'real','positive'},...
                mfilename,'Passband frequency')
            case 'Highpass'
                validateattributes(val,{'numeric'},...
                {'nonempty','scalar','finite',...
                'real','positive'},...
                mfilename,'Passband frequency')
            case 'Bandpass'
                validateattributes(val,{'numeric'},...
                {'nonempty','size',[1,2],'finite',...
                'real','positive',...
                'increasing'},mfilename,'Passband frequencies')



            case 'Bandstop'
                validateattributes(val,{'numeric'},...
                {'nonempty','size',[1,2],'finite',...
                'real','positive',...
                'increasing'},mfilename,'Passband frequencies')
                obj.UseFilterOrder=false;
            end
            obj.privatePassbandFreq=val;
        end

        function val=get.PassbandFrequency(obj)
            val=obj.privatePassbandFreq;
        end

        function set.StopbandFrequency(obj,val)
            switch obj.ResponseType
            case 'Lowpass'
                validateattributes(val,{'numeric'},...
                {'nonempty','scalar','finite','real','positive'},...
                mfilename,'Stopband frequency')
                obj.UseFilterOrder=false;
            case 'Highpass'
                validateattributes(val,{'numeric'},...
                {'nonempty','scalar','finite','real','positive'},...
                mfilename,'Stopband frequency')
                obj.UseFilterOrder=false;
            case 'Bandpass'
                validateattributes(val,{'numeric'},...
                {'nonempty','size',[1,2],'finite',...
                'real','positive',...
                'increasing'},mfilename,'Stopband frequencies')



                obj.UseFilterOrder=false;
            case 'Bandstop'
                validateattributes(val,{'numeric'},...
                {'nonempty','size',[1,2],'finite',...
                'real','positive',...
                'increasing'},mfilename,'Stopband frequencies')
            end
            obj.privateStopbandFreq=val;
        end

        function val=get.StopbandFrequency(obj)
            val=obj.privateStopbandFreq;
        end

        function set.StopbandAttenuation(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Stopband attenuation')
            if(strcmpi(obj.FilterType,'Butterworth')||...
                strcmpi(obj.FilterType,'Chebyshev'))...
                &&~strcmpi(obj.ResponseType,'Bandstop')
                obj.UseFilterOrder=false;
            end
            obj.privateStopbandAttenuation=val;
        end

        function val=get.StopbandAttenuation(obj)
            val=obj.privateStopbandAttenuation;
        end

        function set.PassbandAttenuation(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Passband attenuation')
            if strcmpi(obj.ResponseType,'Bandstop')&&...
                (strcmpi(obj.FilterType,'Butterworth')||...
                strcmpi(obj.FilterType,'InverseChebyshev'))
                obj.UseFilterOrder=false;
            end
            obj.privatePassbandAttenuation=val;
        end

        function val=get.PassbandAttenuation(obj)
            val=obj.privatePassbandAttenuation;
        end

        function set.Zin(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Source impedance')
            obj.Zin=val;
        end

        function set.Zout(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real','positive'},...
            mfilename,'Load impedance')
            obj.Zout=val;
        end

        function val=get.DesignMethod(obj)
            val=obj.FilterType;
        end

        function val=get.Rload(obj)
            val=obj.Zout;
        end

        function val=get.Rsrc(obj)
            val=obj.Zin;
        end

        function val=get.PassFreq_lp(obj)
            val=obj.PassbandFrequency;
        end

        function val=get.StopFreq_lp(obj)
            val=obj.StopbandFrequency;
        end

        function val=get.PassFreq_hp(obj)
            val=obj.PassbandFrequency;
        end

        function val=get.StopFreq_hp(obj)
            val=obj.StopbandFrequency;
        end

        function val=get.PassFreq_bp(obj)
            val=obj.PassbandFrequency;
        end

        function val=get.StopFreq_bp(obj)
            val=obj.StopbandFrequency;
        end

        function val=get.StopFreq_bs(obj)
            val=obj.StopbandFrequency;
        end

        function val=get.PassFreq_bs(obj)
            val=obj.PassbandFrequency;
        end
    end

    methods
        designData=filt_design_rat(obj)
        designData=filt_designpars(obj)
        designData=filt_design_lc(obj)
        [hline,haxes]=rfplot(obj,varargin)
        [num,den]=tf(obj)
    end

    methods(Abstract)
        [num21,num11,num22,den,designData]=filt_spars(obj,...
        designData)
        elVals=filt_exact(obj,designData)
        Wx=designWx(obj,filterOrder)
        filterOrder=filtOrder(obj,Wratio)
        op=objectProperties(obj,op)
        [NameArray,ValueArray]=rbBlockPVPairs(obj)
        [z,p,k]=zpk(obj)
    end

    methods
        function S=sparameters(obj,varargin)

            narginchk(2,3)

            switch obj.Implementation
            case{'LC Tee','LC Pi'}
                lcobj=lcladder(obj);
                S=sparameters(lcobj,varargin{:});
            otherwise
                xData=varargin{1}(:)';
                s11(1,:,:)=polyeval(obj.designData.Numerator11,...
                obj.designData.Denominator,xData);
                s21(1,:,:)=polyeval21(obj.designData,xData);
                s12=s21;
                s22(1,:,:)=polyeval(obj.designData.Numerator22,...
                obj.designData.Denominator,xData);
                S=sparameters([s11,s12;s21,s22],xData);
                if nargin==3
                    Z0=varargin{2};
                    S=sparameters(S,Z0);
                end
            end
        end

        function lcobj=lcladder(obj,varargin)

            validatestring(obj.Implementation,{'LC Tee','LC Pi'},...
            'rffilter','Implementation');
            topology=lower(sprintf('%s%s',obj.ResponseType,...
            obj.Implementation(4:end)));
            lcobj=lcladder(topology,...
            obj.designData.Inductors,obj.designData.Capacitors,varargin{:});
        end
    end

    methods(Hidden)
        function S=groupdelay(obj,varargin)

            narginchk(2,8)

            switch obj.Implementation
            case{'LC Tee','LC Pi'}
                topology=lower(sprintf('%s%s',obj.ResponseType,...
                obj.Implementation(4:end)));

                lcobj=lcladder(topology,...
                obj.designData.Inductors,obj.designData.Capacitors);
                S=groupdelay(lcobj,varargin{:});
            otherwise

                if~cellfun(@ischar,varargin)
                    omega=2*pi*varargin{1};
                    if nargin==3
                        error(message('rf:shared:GroupDelayMissingJ'));
                    elseif nargin==4
                        i=varargin{2};
                        validateattributes(i,{'numeric'},...
                        {'integer','scalar','positive','<=',2},...
                        'groupdelay','I')
                        j=varargin{3};
                        validateattributes(j,{'numeric'},...
                        {'integer','scalar','positive','<=',2},...
                        'groupdelay','J')
                        if i==1&&j==1
                            grpNum=groupPoly(...
                            obj.designData.Numerator11,omega);
                        elseif(i==2&&j==1)||(i==1&&j==2)
                            grpNum=groupPoly21(obj.designData,omega);
                        else
                            grpNum=groupPoly(...
                            obj.designData.Numerator22,omega);
                        end
                    else
                        grpNum=groupPoly21(obj.designData,omega);
                    end
                    grpDen=groupPoly(obj.designData.Denominator,omega);
                    S=grpDen-grpNum;
                    S=reshape(abs(S),numel(S),1);
                else

                    Sobj=sparameters(obj,varargin{1});
                    S=groupdelay(Sobj,varargin{:});
                end
            end
        end

        function fobj=typecastfilter(obj)






            prop=properties(obj);
            prop=setdiff(prop,'designData');

            values=get(obj,prop);
            index=cellfun(@isempty,values);
            prop(index)=[];
            values(index)=[];
            args=reshape([prop,values']',1,2*numel(prop));

            if~obj.UseFilterOrder
                index1=strcmp(args,'FilterOrder');
                index2=circshift(index1,1);
                index=index1|index2;
                args(index)=[];
            end
            switch obj.FilterType
            case 'Butterworth'
                fobj=rf.internal.filter.rfbutter(args{:});
            case 'Chebyshev'
                fobj=rf.internal.filter.rfchebyshev(args{:});
            case 'InverseChebyshev'
                fobj=rf.internal.filter.rfchebyshevinv(args{:});
            case 'Elliptic'
                fobj=rf.internal.filter.rfelliptic(args{:});
            end
        end
    end
end
