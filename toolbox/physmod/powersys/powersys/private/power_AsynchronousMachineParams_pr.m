function[params,varargout]=power_AsynchronousMachineParams_pr(spec,options)















































































    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_AsynchronousMachineParams'));
    end


    errMsgIdPrefix='SpecializedPowerSystems:PowerAsynchronousMachineParams:';


    if(nargin<1||nargin>2)
        msgId=[errMsgIdPrefix,'InvalidInputParamCount'];
        errMsg=['Function power_AsynchronousMachineParams called with wrong number of ',...
        'input arguments (must be 1 or 2).'];
        error(msgId,errMsg);
    end

    if(nargout<1||nargout>4)
        msgId=[errMsgIdPrefix,'InvalidOutputParamCount'];
        errMsg=['Function power_AsynchronousMachineParams called with wrong number of ',...
        'output arguments (must be 1, 2, 3 or 4).'];
        error(msgId,errMsg);
    end


    defaultDisplayDetails=0;
    defaultDrawGraphs=0;
    defaultUnits='SI';
    defaultGraphUnits='SI';

    if(nargin==1)
        options.DisplayDetails=defaultDisplayDetails;
        options.DrawGraphs=defaultDrawGraphs;
        options.units=defaultUnits;
        options.graphUnits=defaultGraphUnits;
    else


        if~isfield(options,'DisplayDetails')
            options.DisplayDetails=defaultDisplayDetails;
        else

            if~isempty(options.DisplayDetails)
                validateLogicalField(options,'DisplayDetails',errMsgIdPrefix);
            else
                options.DisplayDetails=defaultDisplayDetails;
            end
        end
        if~isfield(options,'DrawGraphs')
            options.DrawGraphs=defaultDrawGraphs;
        else

            if~isempty(options.DrawGraphs)
                validateLogicalField(options,'DrawGraphs',errMsgIdPrefix);
            else
                options.DrawGraphs=defaultDrawGraphs;
            end
        end
        if~isfield(options,'units')
            options.units=defaultUnits;
        else

            if~isempty(options.units)
                validateUnitsField(options,'units',errMsgIdPrefix);
            else
                options.units=defaultUnits;
            end
        end
        if~isfield(options,'graphUnits')
            options.graphUnits=defaultGraphUnits;
        else

            if~isempty(options.graphUnits)
                validateUnitsField(options,'graphUnits',errMsgIdPrefix);
            else
                options.graphUnits=defaultGraphUnits;
            end
        end
    end


    spec=augmentSpec(spec,errMsgIdPrefix);



    s=[0:0.001:1,spec.sn];
    [s,idx]=sort(s);
    idx_sn=find(idx==length(s));


    [spec,params]=getParams(spec,s,idx_sn,errMsgIdPrefix);



    [curves,Tmax]=steadyStateValues(spec,params,s,errMsgIdPrefix);


    if options.DrawGraphs
        drawGraphs(s,curves,spec,options.graphUnits,errMsgIdPrefix);
    end


    [errors,specOut]=getErrors(spec,curves,options,idx_sn,Tmax);
    maxError=max(abs([errors.In,errors.Tn,errors.pf,errors.Ist,errors.Ist_In,...
    errors.Tst,errors.Tst_Tn,errors.Tbr,errors.Tbr_Tn]));
    errors.maxError=maxError;

    if(nargout>1)
        varargout(1)={spec};
    end

    if(nargout>2)



        varargout(2)={errors};
    end

    if(nargout>3)

        varargout(3)={specOut};
    end

    switch options.units
    case 'SI'

    case 'p.u.'
        params=convertToPerUnit(spec,params);
    otherwise
        msgId=[errMsgIdPrefix,'InvalidInputParam'];
        errMsg=['Unknown units ''',options.units,''' in function ''',...
        mfilename,'''.'];
        error(msgId,errMsg);
    end

    function spec=augmentSpec(spec,errMsgIdPrefix)


        specHasPolePairs=0;
        specHasSynchronousSpeed=0;


        if isfield(spec,'p')
            if~isempty(spec.p)
                if(spec.p>=1&&((round(spec.p)-spec.p)==0))
                    specHasPolePairs=1;
                end
            end
        end


        if isfield(spec,'Ns')
            if~isempty(spec.Ns)
                if(spec.Ns>=0)
                    specHasSynchronousSpeed=1;
                end
            end
        end










        result=specHasPolePairs+2*specHasSynchronousSpeed;
        msgId=[errMsgIdPrefix,'InvalidInputParam'];

        switch result
        case 0

            errMsg=['Function ''',mfilename,''': you must specify at ',...
            'least one of two input parameters: spec.p (pole pairs, ',...
            'integer greater than 0) or spec.Ns (synchronous speed in ',...
            'rpm).'];
            error(msgId,errMsg);
        case 1

            spec.Ns=60*spec.fn/spec.p;
        case 2

            spec.p=60*spec.fn/spec.Ns;
            if~((round(spec.p)-spec.p)==0)


                errMsg=['Function ''',mfilename,''': pole pairs computed ',...
                'from provided inputs is not an integer. Input ',...
                'frequency and/or synchronous speed provided are ',...
                'inconsistent.'];
                error(msgId,errMsg);
            end
        case 3


            myPolePairs=60*spec.fn/spec.Ns;
            if((myPolePairs-spec.p)~=0)


                errMsg=['Function ''',mfilename,''': both pole pairs and ',...
                'synchronous speed provided, but inconsistent among ',...
                'themselves or with respect to input nominal frequency.',...
                newline,newline,'Values supplied:',newline,newline...
                ,'  Pole pairs: ',num2str(spec.p),newline,...
                '  Nominal frequency (Hz): ',num2str(spec.fn),newline,...
                '  Synchronous speed (rpm): ',num2str(spec.Ns)];
                error(msgId,errMsg);
            end
        otherwise

            errMsg=['Function ''',mfilename,''': Internal error.'];
            error(msgId,errMsg);
        end

        spec.cosphi=spec.pf/100;
        spec.we=2*pi*spec.fn;
        spec.Vin=spec.Vn/sqrt(3);
        spec.sn=(spec.Ns-spec.Nn)/spec.Ns;

        spec.Ist=spec.Ist_In*spec.In;
        spec.Tst=spec.Tst_Tn*spec.Tn;
        spec.Tbr=spec.Tbr_Tn*spec.Tn;
        spec.Pn=spec.Tn*spec.Nn*pi/30;

        function[spec,params]=getParams(spec,s,idx_sn,~)

            Qn=3*spec.Vin*spec.In*sqrt(1-spec.cosphi^2);
            Xm=3*spec.Vin^2/Qn;
            Lm=Xm/spec.we;
            Rr=3*spec.Vin^2*spec.sn/spec.Pn;


            Xsd=0.05*Xm;
            Rr1=Rr;
            Rr2=5*Rr1;
            Llr2=Xsd/spec.we;
            Llr1=1.2*Xsd/spec.we;
            Rs=0.5*Rr1;
            X0=[Rr1,Rr2,Lm,Llr2,Llr1,Rs];


            lb=X0/1000;
            ub=X0*1000;

            f=@(x)optim(x,spec,s,idx_sn);


            x=BoxDogleg(f,X0',lb',ub',600,2000);


            params.Rs=x(6);
            params.Lls=x(4);
            params.Lm=x(3);
            params.Llr1=x(4)+x(5);
            params.Rr1=x(1);
            params.Llr2=x(4);
            params.Rr2=x(1)+x(2);


            function F=optim(x,spec,s,idx_sn)
                Rr1=x(1);
                Rr2=x(1)+x(2);
                Lm=x(3);
                Llr2=x(4);
                Llr1=x(4)+x(5);
                Lls=Llr2;
                Rs=x(6);
                Xsd=Lls*spec.we;
                Xm=Lm*spec.we;
                X1d=Llr1*spec.we;
                X2d=Llr2*spec.we;

                Zp=1./(1/(1j*Xm)+1./(Rr1./s+1j*X1d)+1./(Rr2./s+1j*X2d));
                Is=spec.Vin./(Rs+1j*Xsd+Zp);
                I1=abs(-Zp.*Is./(Rr1./s+1j*X1d));
                I2=abs(-Zp.*Is./(Rr2./s+1j*X2d));
                PF=cos(angle(Is));
                Te1=3*spec.p/spec.we*(I1.^2.*Rr1./s);
                Te2=3*spec.p/spec.we*(I2.^2.*Rr2./s);
                Te=Te1+Te2;


                IN=abs(Is(idx_sn));
                COSPHI=PF(idx_sn);
                TN=Te(idx_sn);


                IST=abs(Is(end));
                TST=Te(end);


                idx_MaxTorque=find(Te==max(Te));%#ok<MXFND>
                idx_BD=max(idx_MaxTorque);
                TBR=max(Te(idx_BD));

                F=[(TN-spec.Tn)/spec.Tn;(IN-spec.In)/spec.In;...
                (COSPHI-spec.cosphi)/spec.cosphi;(IST-spec.Ist)/spec.Ist;...
                (TBR-spec.Tbr)/spec.Tbr;(TST-spec.Tst)/spec.Tst];

                function[res,Tmax]=steadyStateValues(spec,params,s,errMsgIdPrefix)

                    Xsd=params.Lls*spec.we;
                    Xm=params.Lm*spec.we;
                    X1d=params.Llr1*spec.we;
                    X2d=params.Llr2*spec.we;

                    Rr1=params.Rr1;
                    Rr2=params.Rr2;

                    Zp=1./(1/(1j*Xm)+1./(Rr1./s+1j*X1d)+1./(Rr2./s+1j*X2d));
                    Is=spec.Vin./(params.Rs+1j*Xsd+Zp);
                    I1=abs(-Zp.*Is./(Rr1./s+1j*X1d));
                    I2=abs(-Zp.*Is./(Rr2./s+1j*X2d));
                    cosphi=cos(angle(Is));
                    Te1=3*spec.p/spec.we*(I1.^2.*Rr1./s);
                    Te2=3*spec.p/spec.we*(I2.^2.*Rr2./s);
                    Te=Te1+Te2;

                    res.Is=abs(Is);
                    res.pf=cosphi*100;
                    res.Te=Te;
                    [Tmax,idxTmax]=max(Te);

                    if idxTmax==length(Te)
                        msgId=[errMsgIdPrefix,'UnreliableResults'];
                        errMsg='Maximum torque at zero speed, results unreliable.';
                        error(msgId,errMsg);
                    end


                    function[errors,specOut]=getErrors(specIn,curves,options,idx_sn,Tmax)


                        specOut.In=curves.Is(idx_sn);
                        specOut.Tn=curves.Te(idx_sn);
                        specOut.pf=curves.pf(idx_sn);


                        specOut.Ist=curves.Is(end);
                        specOut.Ist_In=specOut.Ist/specOut.In;
                        specOut.Tst=curves.Te(end);
                        specOut.Tst_Tn=specOut.Tst/specOut.Tn;


                        specOut.Tbr=Tmax;
                        specOut.Tbr_Tn=specOut.Tbr/specOut.Tn;


                        errors.In=(specOut.In-specIn.In)/specIn.In*100;
                        errors.Tn=(specOut.Tn-specIn.Tn)/specIn.Tn*100;
                        errors.pf=(specOut.pf-specIn.pf)/specIn.pf*100;
                        errors.Ist=(specOut.Ist-specIn.Ist)/specIn.Ist*100;
                        errors.Ist_In=(specOut.Ist_In-specIn.Ist_In)/specIn.Ist_In*100;
                        errors.Tst=(specOut.Tst-specIn.Tst)/specIn.Tst*100;
                        errors.Tst_Tn=(specOut.Tst_Tn-specIn.Tst_Tn)/specIn.Tst_Tn*100;
                        errors.Tbr=(specOut.Tbr-specIn.Tbr)/specIn.Tbr*100;
                        errors.Tbr_Tn=(specOut.Tbr_Tn-specIn.Tbr_Tn)/specIn.Tbr_Tn*100;

                        if options.DisplayDetails
                            fprintf('\nAsynchronous machine parameter estimation results\n');
                            fprintf('-------------------------------------------------------------\n');
                            fprintf('  Parameter        Specified       Obtained         Error (%%)\n');
                            fprintf('  ---------        ---------       ---------        --------- \n');
                            fprintf('  In (A)           %7g         %7g          %6.2f\n',...
                            specIn.In,specOut.In,errors.In);
                            fprintf('  Tn (N.m)         %7g         %7g          %6.2f\n',...
                            specIn.Tn,specOut.Tn,errors.Tn);
                            fprintf('  Ist (A)          %7g         %7g          %6.2f\n',...
                            specIn.Ist,specOut.Ist,errors.Ist);
                            fprintf('  Ist/In ()        %7g         %7g          %6.2f\n',...
                            specIn.Ist_In,specOut.Ist_In,errors.Ist_In);
                            fprintf('  Tst (N.m)        %7g         %7g          %6.2f\n',...
                            specIn.Tst,specOut.Tst,errors.Tst);
                            fprintf('  Tst/Tn ()        %7g         %7g          %6.2f\n',...
                            specIn.Tst_Tn,specOut.Tst_Tn,errors.Tst_Tn);
                            fprintf('  Tmax (N.m)       %7g         %7g          %6.2f\n',...
                            specIn.Tbr,specOut.Tbr,errors.Tbr);
                            fprintf('  Tbr/Tn ()       %7g          %7g          %6.2f\n',...
                            specIn.Tbr_Tn,specOut.Tbr_Tn,errors.Tbr_Tn);
                            fprintf('  pf (%%)          %7g          %7g          %6.2f\n\n',...
                            specIn.pf,specOut.pf,errors.pf);
                        end


                        function[]=drawGraphs(s,curves,spec,units,errMsgIdPrefix)


                            switch units
                            case 'SI'
                                Nmult=spec.Ns;
                                Ndiv=1;
                                imult=1;
                                Tmult=1;
                                Nunits='rpm';
                                iunits='A';
                                Tunits='N.m';
                            case 'p.u.'
                                Nmult=1;
                                Ndiv=spec.Ns;
                                imult=1/(sqrt(2/3)*spec.Pn/spec.Vn);
                                Tmult=1/spec.Tn;
                                Nunits='p.u.';
                                iunits='p.u.';
                                Tunits='p.u.';
                            otherwise
                                msgId=[errMsgIdPrefix,'InvalidUnits'];
                                errMsg=['Unsupported units ''',units,''' in function ''',...
                                mfilename,'->drawGraphs''.'];
                                error(msgId,errMsg);
                            end

                            Te=curves.Te*Tmult;
                            Tmax=spec.Tbr_Tn*spec.Tn*Tmult;
                            Tst=spec.Tn*spec.Tst_Tn*Tmult;
                            is=curves.Is*imult;
                            speed=(1-s)*Nmult;
                            Nn=spec.Nn/Ndiv;
                            Tn=spec.Tn*Tmult;
                            In=spec.In*imult;
                            Ist=spec.Ist_In*spec.In*imult;

                            figure();
                            subplot(2,1,1)
                            h=plot(speed,Te);
                            set(h(1),'LineWidth',2);
                            hold on
                            h=line([speed(1),speed(end)],[Tmax,Tmax]);
                            set(h,'LineWidth',2);
                            set(h,'LineStyle','--');
                            set(h,'Color',[1,0,0]);

                            plot(0,Tst,'r+','LineWidth',5);
                            plot(Nn,Tn,'r+','LineWidth',5);
                            title('Torque = f(speed)');
                            ylabel(['T_m (',Tunits,')']);
                            grid on;

                            subplot(2,1,2)
                            plot(speed,is)
                            hold on
                            plot(0,Ist,'r+','LineWidth',5)
                            plot(Nn,In,'r+','LineWidth',5)
                            grid on
                            title('Stator current = f(speed)');
                            xlabel(['Speed (',Nunits,')']);
                            ylabel(['i_s (',iunits,')']);


                            function params=convertToPerUnit(spec,params)

                                Zb=spec.Vn^2/spec.Pn;
                                Lb=Zb/spec.we;
                                params.Rs=params.Rs/Zb;
                                params.Rr1=params.Rr1/Zb;
                                params.Rr2=params.Rr2/Zb;
                                params.Lls=params.Lls/Lb;
                                params.Llr1=params.Llr1/Lb;
                                params.Llr2=params.Llr2/Lb;
                                params.Lm=params.Lm/Lb;


                                function[]=validateLogicalField(options,field,errMsgIdPrefix)

                                    field_val=getfield(options,field);%#ok<*GFLD>
                                    msgId=[errMsgIdPrefix,'InvalidInputParam'];
                                    errMsg=['Invalid field ''',field,''' in options structure. This ',...
                                    'field must contain a value that converts to logical (0 or 1).'];
                                    if~isnumeric(field_val)&&~islogical(field_val)
                                        error(msgId,errMsg);
                                    elseif isnumeric(field_val)&&~any(field_val==[0,1])
                                        error(msgId,errMsg);
                                    end


                                    function[]=validateUnitsField(options,field,errMsgIdPrefix)
                                        myField=getfield(options,field);

                                        if~(strcmp(myField,'SI')||strcmp(myField,'p.u.'))
                                            msgId=[errMsgIdPrefix,'InvalidInputParam'];
                                            errMsg=['Invalid field ''',field,''' in options structure. This ',...
                                            'field indicates units and must contain either ''SI'' or ',...
                                            '''p.u.'''];
                                            error(msgId,errMsg);
                                        end

                                        function x=BoxDogleg(F,x,LowerBound,UpperBound,maxiterations,maxFevaluations)






                                            epsilon=100*eps;
                                            Deltamin=sqrt(eps);
                                            abstol=1.0e-6;
                                            reltol=0;


                                            fx=feval(F,x);
                                            Fevaluations=1;
                                            normfx=norm(fx);
                                            stoptol=abstol+reltol*normfx;


                                            beta1=0.0902;
                                            beta2=0.2908;
                                            beta3=0.7703;
                                            delta1=0.3721;
                                            delta2=1.8781;
                                            thetal=0.9995;


                                            iterations=0;
                                            nbx=length(x);

                                            while normfx>stoptol&&iterations<maxiterations&&Fevaluations<maxFevaluations

                                                iterations=iterations+1;

                                                fnrm0=normfx;


                                                ApproxJacobian=ones(nbx);

                                                for j=1:nbx


                                                    if x(j)==0
                                                        h=sqrt(eps);
                                                    else
                                                        h=sqrt(eps)*sign(x(j))*max(abs(x(j)),norm(x,1)/nbx);
                                                    end

                                                    xhj=x(j)+h;

                                                    if xhj<LowerBound(j)||xhj>UpperBound(j)

                                                        h=-h;
                                                        xhj=x(j)+h;
                                                    end

                                                    xh=x;
                                                    xh(j)=xhj;

                                                    f1=feval(F,xh);
                                                    ApproxJacobian(:,j)=(f1-fx)/h;

                                                end

                                                grad=ApproxJacobian'*fx;


                                                OF=0;
                                                nbx=length(x);
                                                d=ones(nbx,1);
                                                dm1=ones(nbx,1);
                                                dm2=ones(nbx,1);

                                                for i=1:nbx

                                                    if grad(i)<0
                                                        if UpperBound(i)~=Inf
                                                            diff=UpperBound(i)-x(i);
                                                            sqdiff=sqrt(diff);
                                                            if diff>=(1/realmax)
                                                                d(i)=1/sqdiff;
                                                                dm1(i)=sqdiff;
                                                                dm2(i)=diff;
                                                            else
                                                                OF=1;
                                                            end
                                                        end

                                                    else
                                                        if LowerBound(i)~=-Inf
                                                            diff=x(i)-LowerBound(i);
                                                            sqdiff=sqrt(diff);
                                                            if diff>=(1/realmax)
                                                                d(i)=1/sqdiff;
                                                                dm1(i)=sqdiff;
                                                                dm2(i)=diff;
                                                            else
                                                                OF=1;
                                                            end
                                                        end
                                                    end

                                                end

                                                if OF==1
                                                    break;
                                                end

                                                jjac=ApproxJacobian'*ApproxJacobian;

                                                if norm(dm1.*grad)<epsilon
                                                    break;
                                                end


                                                if iterations==1
                                                    Delta=norm(dm1.*grad);
                                                end


                                                sn=-pinv(ApproxJacobian)*fx;


                                                dm2grad=dm2.*grad;
                                                vert=(norm(dm1.*grad)/norm(ApproxJacobian*dm2grad))^2;

                                                pcv=-vert*dm2grad;


                                                snc=d.*sn;
                                                pcc=d.*pcv;


                                                rhof=0;

                                                while rhof<beta2&&Delta>Deltamin


                                                    if norm(pcc)>Delta
                                                        pcv=-Delta*dm2grad/norm(dm1.*grad);
                                                    end


                                                    pciv=pcv;
                                                    alp=ones(1,nbx);

                                                    for i=1:nbx
                                                        if pcv(i)~=0
                                                            alp(i)=max((LowerBound(i)-x(i))/pcv(i),(UpperBound(i)-x(i))/pcv(i));
                                                        else
                                                            alp(i)=Inf;
                                                        end
                                                    end

                                                    alpha=min(alp);

                                                    if(alpha<=1)
                                                        pciv=max(thetal,1-norm(pcv))*alpha*pcv;
                                                    end

                                                    if norm(snc)<=Delta



                                                        p=sn;
                                                        np=norm(p);

                                                        for i=1:nbx
                                                            if p(i)~=0
                                                                alp(i)=max((LowerBound(i)-x(i))/p(i),(UpperBound(i)-x(i))/p(i));
                                                            else
                                                                alp(i)=Inf;
                                                            end
                                                        end

                                                        alpha=min(alp);

                                                        if(alpha<=1)
                                                            p=max(thetal,1-np)*alpha*p;
                                                        end

                                                    else
                                                        if norm(pcc)>=Delta


                                                            p=pciv;

                                                        else



                                                            a=norm(snc-pcc)^2;
                                                            b=(pcc'*snc-norm(pcc)^2);
                                                            c=norm(pcc)^2-Delta^2;
                                                            g=(-b+sign(-b)*sqrt(b^2-a*c))/a;
                                                            e=c/(g*a);
                                                            doglegstep=pcc+max(g,e)*(snc-pcc);

                                                            pd=dm1.*doglegstep;
                                                            npd=norm(pd);
                                                            p=pd;

                                                            for i=1:nbx
                                                                if pd(i)~=0
                                                                    alp(i)=max((LowerBound(i)-x(i))/pd(i),(UpperBound(i)-x(i))/pd(i));
                                                                else
                                                                    alp(i)=Inf;
                                                                end
                                                            end

                                                            alpha=min(alp);

                                                            if(alpha<=1)
                                                                p=max(thetal,1-npd)*alpha*pd;
                                                            end

                                                        end
                                                    end


                                                    rhoc=(grad'*p+0.5*p'*jjac*p)/(grad'*pciv+0.5*pciv'*jjac*pciv);
                                                    if rhoc<beta1

                                                        p=pciv;
                                                    end

                                                    xpp=x+p;
                                                    fxpp=feval(F,xpp);
                                                    Fevaluations=Fevaluations+1;
                                                    fnrmxpp=norm(fxpp);
                                                    rhof=(fnrmxpp^2-normfx^2)*0.5/(grad'*p+0.5*p'*jjac*p);
                                                    Deltas=Delta;
                                                    Delta=min(delta1*Delta,0.5*norm(d.*p));

                                                end

                                                if Delta<=Deltamin&&rhof<beta2
                                                    break
                                                end

                                                Delta=Deltas;
                                                x=xpp;
                                                fx=fxpp;
                                                normfx=fnrmxpp;

                                                if abs(normfx-fnrm0)<=epsilon*normfx&&normfx>stoptol
                                                    break
                                                end


                                                if rhof>beta3&&rhoc>beta1
                                                    Delta=max(Delta,delta2*norm(d.*p));
                                                end
                                            end

                                            if any(x==inf)
                                                error('boxdogleg failed to find a solution')
                                            end