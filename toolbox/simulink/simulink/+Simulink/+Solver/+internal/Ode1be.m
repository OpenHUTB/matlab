function out=Ode1be(flag,varargin)
















    persistent EQNS DATA INTERP

    out=[];

    switch flag

    case 'restart'
        EQNS=[];
        DATA=[];
        INTERP=[];

    case 'reset'
        [eqns_,t0_,x0_,xp0_]=deal(varargin{:});
        out=lReset(eqns_,t0_,x0_,xp0_);

    case 'step'
        [tstop_,~]=deal(varargin{:});
        out=lStep(tstop_);

    case 't'
        out=DATA.t1;

    case 'x'
        out=DATA.x1;

    case 'h'

        out=DATA.t1-DATA.t0;

    case 'interp'
        [ti_]=deal(varargin{:});
        out=lInterp(ti_);

    otherwise
        assert(false,'Unrecognized method name: ''%s''',flag);

    end



    function out=lReset(eqns,t0,x0,xp0)%#ok


        EQNS=eqns;


        DATA.t0=t0;
        DATA.x0=x0;

        DATA.t1=t0;
        DATA.x1=x0;


        lPackInterp(t0,x0,t0,x0);

        out=[];
    end



    function out=lStep(tStop)

        t0=DATA.t1;
        x0=DATA.x1;


        h=EQNS.maxStep;
        if(t0+1.1*h>tStop)
            tnew=tStop;
        else
            tnew=t0+h;
        end
        [tnew,xnew]=lEvaluate(t0,x0,tnew);


        DATA.t0=t0;
        DATA.x0=x0;
        DATA.t1=tnew;
        DATA.x1=xnew;

        lPackInterp(t0,x0,tnew,xnew);


        out=DATA.t1;
    end



    function[tnew,xnew]=lEvaluate(t0,x0,t1)


        MAXITER=1;
        lineSearch=false;


        if evalin('base','exist(''ode1beNewtonIter'')')
            MAXITER=evalin('base','ode1beNewtonIter');
        end
        if evalin('base','exist(''ode1beLineSearch'')')
            lineSearch=evalin('base','ode1beLineSearch');
            disp('Turning line search on')
        end



        tnew=t1;
        x=x0;
        h=tnew-t0;


        z=zeros(size(x0));
        znew=z;
        J=lJacobian(tnew,x0);

        if(lineSearch)
            f0=lForcingFunction(tnew,x);
            m0=lMassMatrix(tnew,x);
            fVal=fcnEval(x0,f0,m0);
            fNorm=norm(fVal,'inf');
        end

        for iter=1:MAXITER


            Fnew=lForcingFunction(tnew,x);






            Mnew=lMassMatrix(tnew,x);


            rhs=h*Fnew-Mnew*z;



            [L,U]=lu(Mnew-h*J);
            delta=U\(L\rhs);


            if~lineSearch
                x=x+delta;
                z=z+delta;

            else




                maxProbe=15;
                lambda=1;
                needToBreak=false;
                for k=1:maxProbe
                    xLineSearch=x;
                    znew=z;
                    xLineSearch=xLineSearch+lambda*delta;
                    znew=znew+lambda*delta;

                    if(xLineSearch==x)

                        xLineSearch=x+delta;
                        needToBreak=true;
                    end

                    workF=lForcingFunction(tnew,xLineSearch);
                    fNewVal=fcnEval(xLineSearch,workF,Mnew);
                    newNorm=norm(fNewVal,'inf');

                    if(newNorm<fNorm||needToBreak)

                        break;
                    end

                    lambda=lambda/2;

                end
                x=xLineSearch;
                z=znew;
                fNorm=newNorm;
            end
            xnew=x;

        end



        function fval=fcnEval(x,ff,M)

            fval=M*(x-x0)-h*ff;
        end

    end




    function xi=lInterp(ti)

        alpha=(INTERP.t1-ti)/(INTERP.t1-INTERP.t0);
        xi=alpha*INTERP.x0+(1-alpha)*INTERP.x1;
    end



    function lPackInterp(t0,x0,t1,x1)
        INTERP=struct('t0',t0,'x0',x0,'t1',t1,'x1',x1);
    end



    function F=lForcingFunction(t,x)
        F=EQNS.forcingFunction(t,x);
    end



    function M=lMassMatrix(t,x)
        M=reshape(EQNS.massMatrix(t,x),EQNS.nx,EQNS.nx);
    end



    function J=lJacobian(t,x)
        J=reshape(EQNS.Jacobian(t,x),EQNS.nx,EQNS.nx);
    end


end
