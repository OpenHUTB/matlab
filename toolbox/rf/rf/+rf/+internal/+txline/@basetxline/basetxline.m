classdef(Abstract,Hidden)basetxline<matlab.mixin.SetGet&rf.internal.rfbudget.Element




    properties

LineLength
    end

    properties(SetAccess=protected,Hidden)

        PV=[];
        Loss=[];
    end

    properties(Dependent)
StubMode
Termination
    end

    properties(Hidden,Access=protected)
privateName
privateStubMode
privateTermination
    end

    properties(Access=protected,Constant)
        DefaultLineLength=0.0100
        DefaultStubMode='NotAStub'
        DefaultTermination='NotApplicable'
    end

    properties(Hidden,Constant)
        StubModeValues={'NotAStub','Series','Shunt'};
        TerminationValues={'NotApplicable','Open','Short'};
    end

    methods(Access=protected,Hidden)
        function p=makeInputParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'LineLength',obj.DefaultLineLength);
            addParameter(p,'Termination',obj.DefaultTermination);
            addParameter(p,'StubMode',obj.DefaultStubMode);
        end

        function setParsedProperties(obj,p)
            obj.LineLength=p.Results.LineLength;
            obj.Termination=p.Results.Termination;
            obj.StubMode=p.Results.StubMode;
        end
    end

    methods
        function obj=basetxline(varargin)
            p=makeInputParser(obj);
            parse(p,varargin{:});
            setParsedProperties(obj,p);
        end
    end

    methods

        function set.LineLength(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','nonnan','finite','real','positive'}...
            ,'basetxline','LineLength');
            obj.LineLength=val;
        end

        function set.StubMode(obj,val)
            validstr=validatestring(val,obj.StubModeValues,...
            'basetxline','StubMode');
            obj.privateStubMode=validstr;
        end

        function set.Termination(obj,val)
            validstr=validatestring(val,obj.TerminationValues,...
            'basetxline','Termination');
            obj.privateTermination=validstr;
        end

        function val=get.StubMode(obj)
            val=obj.privateStubMode;
        end

        function val=get.Termination(obj)
            val=obj.privateTermination;
        end

        function set.PV(obj,val)
            obj.PV=val;
        end

        function set.Loss(obj,val)
            obj.Loss=val;
        end
    end

    methods

        function s=sparameters(h,freq,varargin)





            narginchk(2,3);
            checkStubMode(h)

            freq=checktxlineFrequency(h,freq);

            if nargin>=3
                zref=varargin{1};
            else
                zref=50;
            end





            netparameters=h.getabcd(freq);

            s_params=abcd2s(netparameters,zref);
            s=sparameters(s_params,freq,zref);

        end

        function char=getZ0(h,frequency)


            narginchk(2,2);
            checkStubMode(h);
            frequency=checktxlineFrequency(h,frequency);
            [~,zchar]=calckl(h,frequency);
            char=zchar;
        end

        function gd=groupdelay(h,freq,varargin)





            narginchk(2,6);

            checkStubMode(h);


            gd=[];
            freq=checktxlineFrequency(h,freq');
            m=numel(freq);

            p=inputParser;
            addParameter(p,'Aperture',[]);
            addParameter(p,'Impedance',50);
            parse(p,varargin{:});

            aperture=p.Results.Aperture;
            zref=p.Results.Impedance;

            CheckZ(h,zref,m);
            aperture=checkaperture(h,aperture,m);


            if(h.NumPorts==2)



                if isempty(aperture)

                    deltafreq=1e-4.*freq;

                    deltafreq(deltafreq<1)=1;
                    deltafreq_left=deltafreq;
                    deltafreq_right=deltafreq;

                    deltafreq_left(freq<=1)=0.0;


                    nfreq=numel(freq);
                    if(nfreq>=2)
                        diffsimf=diff(freq);
                        simdeltafreq_left(1,1)=freq(1);
                        simdeltafreq_left(2:nfreq,1)=diffsimf(1:nfreq-1);
                        simdeltafreq_right=diffsimf;
                        simdeltafreq_right(nfreq,1)=diffsimf(nfreq-1);
                        simdeltafreq=min(simdeltafreq_left,simdeltafreq_right);


                        idx=abs(deltafreq_right)>abs(simdeltafreq);
                        deltafreq_right(idx)=simdeltafreq(idx);
                        idx=abs(deltafreq_left)>abs(simdeltafreq);
                        deltafreq_left(idx)=simdeltafreq(idx);
                    end

                else

                    deltafreq=freq.*aperture/2;

                    idx=(abs(aperture)>=1);
                    deltafreq(idx)=aperture(idx)/2;
                    deltafreq_right=deltafreq;
                    deltafreq_left=deltafreq;

                    deltafreq_left(freq<=1)=0.0;

                    deltafreq_left(freq<=deltafreq_left)=0.0;
                end


                netparameters_plus=h.getabcd(freq+deltafreq_right);

                s_plus=abcd2s(netparameters_plus,zref);


                sparams_plus_delta=s_plus;

                netparameters_minus=h.getabcd(freq-deltafreq_left);
                s_minus=abcd2s(netparameters_minus,zref);

                sparams_minus_delta=s_minus;

                diff_s21_angle=unwrap(angle(sparams_plus_delta(2,1,:)))-...
                unwrap(angle(sparams_minus_delta(2,1,:)));
                gd=-diff_s21_angle(:)./(2*pi*(deltafreq_right+deltafreq_left));
            end

        end

        function nf=noisefigure(h,freq,varargin)




            narginchk(2,3);

            checkStubMode(h)

            freq=checktxlineFrequency(h,freq);
            m=numel(freq);

            if(h.NumPorts==2)

                cmatrix=[];
                if isempty(cmatrix)

                    if nargin>=3
                        zs=varargin{1};
                        CheckZ(h,zs,m);
                    else
                        zs=50;
                    end
                end


                netparameters=zeros(2,2,length(freq));

                switch upper(h.get('StubMode'))

                case 'NOTASTUB'
                    [e_negkl,zchar]=calckl(h,freq);
                    e_kl=1./e_negkl;
                    netparameters(1,1,:)=(e_kl+e_negkl)./2;
                    netparameters(1,2,:)=(e_kl-e_negkl).*zchar./2;
                    netparameters(2,1,:)=(e_kl-e_negkl)./zchar./2;
                    netparameters(2,2,:)=(e_kl+e_negkl)./2;

                case 'SERIES'
                    Z_in=calczin(h,freq);
                    netparameters(1,1,:)=1;
                    netparameters(1,2,:)=Z_in;
                    netparameters(2,1,:)=0;
                    netparameters(2,2,:)=1;

                case 'SHUNT'
                    Z_in=calczin(h,freq);
                    netparameters(1,1,:)=1;
                    netparameters(1,2,:)=0;
                    netparameters(2,1,:)=1./Z_in;
                    netparameters(2,2,:)=1;
                end

                cmatrix=[];
                T=290;
                K=rf.physconst('Boltzmann');
                nfreq=length(freq);
                if isempty(cmatrix)
                    abcd=netparameters;
                    if all(abcd(1,1,:)==1)&&all(abcd(1,2,:)==0)&&...
                        all(abcd(2,1,:)==0)&&all(abcd(2,2,:)==1)
                        cmatrix=zeros(2,2,nfreq);
                        ctype='ABCD CORRELATION MATRIX';
                    else
                        c=abcd(2,1,:);
                        if all(c==0)
                            y=abcd2y(abcd);
                            if allfinite(y)
                                cmatrix=T*K*rf.internal.makeHermitian(y);
                                ctype='Y CORRELATION MATRIX';
                            else
                                cmatrix=zeros(2,2,nfreq);
                                ctype='ABCD CORRELATION MATRIX';
                            end
                        end
                    end

                end
                if isempty(cmatrix)
                    z=abcd2z(netparameters);
                    if allfinite(z)
                        cmatrix=T*K*rf.internal.makeHermitian(z);
                        ctype='Z CORRELATION MATRIX';
                    else
                        y=abcd2y(netparameters);
                        if allfinite(y)
                            cmatrix=T*K*rf.internal.makeHermitian(y);
                            ctype='Y CORRELATION MATRIX';
                        else
                            cmatrix=zeros(2,2,nfreq);
                            ctype='ABCD CORRELATION MATRIX';
                        end

                    end
                end


                cmatrix=convertcorrelationmatrix(h,cmatrix,ctype,...
                'ABCD CORRELATION MATRIX',netparameters,'ABCD PARAMETERS',50);


                narginchk(2,3)
                if nargin<3
                    zs=50;
                end
                m=size(cmatrix,3);
                if isscalar(zs)
                    zs=zs*ones(m,1);
                end
                K=rf.physconst('Boltzmann');
                T=290;
                nf=zeros(m,1);
                for ii=1:m
                    z=[1,zs(ii)];
                    const=2*K*T*real(zs(ii));
                    nf(ii)=1+(z*cmatrix(:,:,ii)*z')/const;
                end
                nf(abs(nf)==0)=eps;
                nf=10.*log10(abs(nf));
            else
                nf=0;
            end

            if isempty(nf)
                error(message('rf:rftxline:EmptyNotAllowed',...
                prop_name,upper(class(h))));
            end
            nf=real(nf);
            [row,col]=size(squeeze(nf));
            if~isnumeric(nf)||min([row,col])~=1||any(isnan(nf))
                error(message('rf:rftxline:NotAPositiveVector',...
                prop_name,upper(class(h))));
            end
            if row==1
                nf=nf(:);
            end

            index=find(nf<0);
            if~isempty(index)
                nf(index)=0;
            end
            if any(nf<0)
                error(message('rf:rftxline:NotAPositiveVector',...
                prop_name,upper(class(h))));
            end

        end
    end
    methods(Hidden)
        function lines=exportRFEngineElement(obj,idx,node1,node2,ckt,simulateNoise)

            freq=ckt.HB.UniqueFreqs;
            s=sparameters(obj,freq);
            finite_chk=all(isfinite(s.Parameters),[1,2]);
            nobj=nport(sparameters(s.Parameters(:,:,finite_chk),freq(finite_chk)));
            lines=exportRFEngineElement(nobj,idx,node1,node2,ckt,simulateNoise);
        end
    end

    methods(Hidden)
        function checkStubMode(obj)
            checkStubMode=strcmp(obj.StubMode,'NotAStub');
            checkTermination=strcmp(obj.Termination,'NotApplicable');

            if checkStubMode&&~checkTermination
                error(message(['rf:rftxline:'...
                ,'TerminationIncompatible'],obj.Name,obj.Termination,obj.Termination));
            end
            if~checkStubMode&&checkTermination
                error(message(['rf:rftxline:'...
                ,'StubModeIncompatible'],obj.Name,obj.StubMode,obj.StubMode));
            end
        end

        function Z_in=calczin(h,freq,zterm)


            e_negkl=calckl(h,freq);
            termination=get(h,'Termination');
            [~,zchar]=calckl(h,freq);
            z0=zchar;



            if nargin>2

            elseif strcmpi(termination,'Short')
                zterm=0;
            elseif strcmpi(termination,'Open')
                zterm=inf;
            end

            z0=z0(:);

            e_kl=1./e_negkl;

            tempA=e_kl+e_negkl;
            tempB=e_kl-e_negkl;


            if isinf(zterm)
                Z_in=tempA./tempB.*z0;
            else
                Z_in=(zterm.*tempA+z0.*tempB)./(zterm.*tempB+z0.*tempA).*z0;
            end
        end

        function aperture=checkaperture(~,aperture,m)


            validateattributes(aperture,{'numeric'},...
            {'nonnan','finite','real','positive'}...
            ,'rftxline','aperture');

            if isempty(aperture)
                return
            end


            if~isvector(aperture)||((numel(aperture)~=1)&&(numel(aperture)~=m))
                error(message('rf:rftxline:WrongInput','aperture'));
            end


            if numel(aperture)==m
                aperture=reshape(aperture,[m,1]);
            else
                aperture=aperture*ones(m,1);
            end
        end

        function freq=checktxlineFrequency(~,freq)

            validateattributes(freq,{'numeric'},...
            {'nonempty','nonnan','finite','real','nonnegative'}...
            ,'rftxline','Frequency');

            result=[];

            freq=squeeze(freq);
            if isvector(freq)&&isnumeric(freq)&&isreal(freq)&&...
                all(freq>=0)&&~any(isinf(freq))&&~any(isnan(freq))
                result=unique(sort(freq(:)));
            end

            index=find(result==0.0);
            if~isempty(index)
                minfreq=eps;
                if index(end)<numel(result)
                    minfreq=0.001*result(index(end)+1);
                    if minfreq>1
                        minfreq=1;
                    end
                end
                result(index)=minfreq;
            end
            freq=result;
        end

        function z=CheckZ(~,z,m)


            validateattributes(z,{'numeric'},...
            {'nonempty','nonnan','finite','real','positive'}...
            ,'rftxline','Impedance');


            if~isvector(z)||((numel(z)~=1)&&(numel(z)~=m))
                error(message('rf:rftxline:WrongInput','Impedance'));
            end


            if numel(z)==m
                z=reshape(z,[1,1,m]);
            else
                z=z*ones(1,1,m);
            end
        end

        function netparameters=getabcd(obj,freq)

            nports=obj.NumPorts;
            netparameters=zeros(nports,nports,length(freq));

            switch upper(obj.get('StubMode'))

            case 'NOTASTUB'
                [e_negkl,zchar]=calckl(obj,freq);
                e_kl=1./e_negkl;
                netparameters(1,1,:)=(e_kl+e_negkl)./2;
                netparameters(1,2,:)=(e_kl-e_negkl).*zchar./2;
                netparameters(2,1,:)=(e_kl-e_negkl)./zchar./2;
                netparameters(2,2,:)=(e_kl+e_negkl)./2;

            case 'SERIES'
                Z_in=calczin(obj,freq);
                netparameters(1,1,:)=1;
                netparameters(1,2,:)=Z_in;
                netparameters(2,1,:)=0;
                netparameters(2,2,:)=1;
            case 'SHUNT'
                Z_in=calczin(obj,freq);
                netparameters(1,1,:)=1;
                netparameters(1,2,:)=0;
                netparameters(2,1,:)=1./Z_in;
                netparameters(2,2,:)=1;
            end
        end
        function outCMatrix=convertcorrelationmatrix(h,inCMatrix,inCType,...
            outCType,inNetParams,inNetParamsType,z0)


            if nargin<7
                z0=50;
            end

            inCType=upper(inCType);
            outCType=upper(outCType);


            outCMatrix=NaN;

            for iter=0:10
                if anynan(outCMatrix)

                    switch outCType
                    case 'ABCD CORRELATION MATRIX'
                        switch inCType
                        case 'Y CORRELATION MATRIX'
                            outCMatrix=cy2cabcd(h,inCMatrix,inNetParams,...
                            inNetParamsType,z0);
                        case 'Z CORRELATION MATRIX'
                            outCMatrix=cz2cabcd(h,inCMatrix,inNetParams,...
                            inNetParamsType,z0);
                        case 'ABCD CORRELATION MATRIX'
                            outCMatrix=inCMatrix;
                        end
                    end
                    z0=z0+eps(z0);
                else
                    return
                end
            end
        end

        function cabcd=cy2cabcd(h,cy,netparams,type,z0)
            abcd=convertmatrix(h,netparams,type,'ABCD_PARAMETERS',z0);
            nfreq=size(abcd,3);
            t=zeros(2,2,nfreq);
            t(2,1,:)=1;
            t(1,2,:)=abcd(1,2,:);
            t(2,2,:)=abcd(2,2,:);
            cabcd=zeros(2,2,nfreq);
            for ii=1:nfreq
                cabcd(:,:,ii)=t(:,:,ii)*cy(:,:,ii)*t(:,:,ii)';
            end
        end

        function cabcd=cz2cabcd(h,cz,netparams,type,z0)
            abcd=convertmatrix(h,netparams,type,'ABCD_PARAMETERS',z0);
            nfreq=size(abcd,3);
            t=zeros(2,2,nfreq);
            t(1,1,:)=1;
            t(1,2,:)=-abcd(1,1,:);
            t(2,2,:)=-abcd(2,1,:);
            cabcd=zeros(2,2,nfreq);
            for ii=1:nfreq
                cabcd(:,:,ii)=t(:,:,ii)*cz(:,:,ii)*t(:,:,ii)';
            end
        end
        function outMatrix=convertmatrix(~,inMatrix,inType,outType,~,...
            ~,~)


            outMatrix=[];

            inType=upper(inType);
            outType=upper(outType);


            switch inType
            case{'ABCD PARAMETERS','ABCD_PARAMETERS','ABCD-PARAMETERS','ABCD_PARAMS','ABCD-PARAMS','ABCD'}
                switch outType

                case{'ABCD PARAMETERS','ABCD_PARAMETERS','ABCD-PARAMETERS','ABCD_PARAMS','ABCD-PARAMS','ABCD'}
                    outMatrix=inMatrix;
                    return;
                end
            end
        end
    end
    methods(Hidden,Access=protected)

        function initializeTerminalsAndPorts(obj)
            obj.Ports={'p1','p2'};
            obj.Terminals={'p1+','p2+','p1-','p2-'};
        end

        function out=localClone(in)
            to=metaclass(in);
            t1=findobj(to.PropertyList,'GetAccess','public','-AND','SetAccess','public','-AND','Hidden',0);
            outProp=arrayfun(@(x)x.Name,t1,'UniformOutput',false);
            outtxline=eval(class(in));
            set(outtxline,outProp,get(in,outProp))
            out=outtxline;
        end
    end
    methods(Hidden)

        function Ca=getCa(~,~,stageS)
            z0=stageS.Impedance;
            S=stageS.Parameters;
            Cs=rfbudget.kT*(eye(2)-S*S');
            PR=[S(1,1)-1,z0*(1+S(1,1));S(2,1),z0*S(2,1)];
            Ca=4*z0*(PR\Cs/PR');
            Ca=(Ca+Ca')/2;
        end

        function gain=getGain(~,stageS)
            S=stageS.Parameters;
            gain=10*log10(abs(S(2,1))^2);
        end

        function NF=getNF(~,Ca)
            zs=50;
            zvect=[1,zs];
            denomZ=4*rfbudget.kT*zs;
            NF=10*log10(1+real(zvect*Ca*zvect')/denomZ);
        end

        function OIP3=getOIP3(obj)%#ok<MANU>
            OIP3=Inf;
        end
    end
end
