function y=psi(k,x)



%#codegen

    coder.allowpcode('plain');
    coder.internal.errorIf(nargin<1,'MATLAB:minrhs');
    eml_invariant(isfloat(k)&&(nargin==1||isfloat(x)),...
    'MATLAB:psi:nonFloatInput');
    eml_invariant(isreal(k)&&(nargin==1||isreal(x)),...
    'MATLAB:psi:notReal');
    if nargin==1
        y=coder.internal.applyScalarFunction(mfilename,zeros('like',k),...
        @minusDoubleScalarPsi,k,0);
    else
        eml_invariant(isscalar(k),'MATLAB:psi:kScalar');
        eml_invariant((k(1)>=0&&floor(k(1))==k(1)&&...
        k(1)<=intmax('int32')),...
        'MATLAB:psi:validOrder');
        y=coder.internal.applyScalarFunction(mfilename,zeros('like',x),...
        @unscaledDoubleScalarPsi,x,double(k(1)));
    end



    function rval=unscaledDoubleScalarPsi(x,order)
        rval=DoubleScalarPsi(x,order);
        rval=unscale(double(order(1)),rval);



        function rval=minusDoubleScalarPsi(x,order)
            rval=-DoubleScalarPsi(x,order);



            function rval=DoubleScalarPsi(xin,order)

                coder.inline('always');
                coder.internal.prefer_const(order);
                coder.internal.errorIf(xin<0,'MATLAB:psi:negativeX');
                x=double(xin);
                if x<0||isnan(x)
                    rval=coder.internal.nan(class(x));
                elseif x==0
                    rval=coder.internal.inf(class(x));
                elseif isinf(x)
                    if order==0
                        rval=-coder.internal.inf(class(x));
                    else
                        rval=coder.internal.inf(class(x));
                    end
                elseif x<eps(class(x))
                    rval=x^(-double(order)-1);
                else
                    dorder=double(order);
                    dorderp1=dorder+1;

                    rln=log10(2)*53;
                    fln=rln-3;

                    yint=3.5+0.4*fln;
                    slope=0.21+fln*(0.0006038*fln+0.008677);
                    minx=floor(yint+slope*dorder)+1;
                    xln=log(x);
                    if order>0
                        xm=-2.302*rln-eml_min(0,xln);
                        arg=eml_min(xm/dorder,0);
                        epsilon=exp(arg);
                        xm=1-epsilon;
                        if abs(arg)<1e-3
                            xm=-arg;
                        end
                        fln=x*xm/epsilon;
                        xm=minx-x;
                        if xm>7&&fln<15

                            t1=dorderp1*xln;
                            s=exp(-t1);
                            den=x;
                            for i=0:fln
                                den=den+1;
                                s=s+den^(-dorderp1);
                            end
                            rval=s;
                            return
                        end
                    end
                    xdmy=x;
                    xdmln=xln;
                    xinc=0;
                    if x<minx
                        xinc=minx-floor(x);
                        xdmy=x+xinc;
                        xdmln=log(xdmy);
                    end

                    t=dorder*xdmln;


                    tss=exp(-t);
                    tt=0.5/xdmy;
                    t1=tt;
                    tst=eps*tt;
                    if order>0
                        t1=tt+1/dorder;
                    end
                    rxsq=1/(xdmy*xdmy);
                    ta=0.5*rxsq;
                    t=dorderp1*ta;
                    s=t/6;
                    if abs(s)>=tst

                        B=[1.00000000000000000e+00,...
                        -5.00000000000000000e-01,1.66666666666666667e-01,...
                        -3.33333333333333333e-02,2.38095238095238095e-02,...
                        -3.33333333333333333e-02,7.57575757575757576e-02,...
                        -2.53113553113553114e-01,1.16666666666666667e+00,...
                        -7.09215686274509804e+00,5.49711779448621554e+01,...
                        -5.29124242424242424e+02,6.19212318840579710e+03,...
                        -8.65802531135531136e+04,1.42551716666666667e+06,...
                        -2.72982310678160920e+07,6.01580873900642368e+08,...
                        -1.51163157670921569e+10,4.29614643061166667e+11,...
                        -1.37116552050883328e+13,4.88332318973593167e+14,...
                        -1.92965793419400681e+16];
                        tk=2;
                        for k=4:22
                            t=t*((tk+dorder+1)/(tk+1))*((tk+dorder)/(tk+2))*rxsq;
                            trm=t*B(k);
                            if abs(trm)<tst
                                break
                            end
                            s=s+trm;
                            tk=tk+2;
                        end
                    end
                    s=(s+t1)*tss;
                    if xinc>0

                        floorxinc=floor(xinc);
                        if order==0

                            for i=1:floorxinc
                                s=s+1/(x+(floorxinc-i));
                            end
                            rval=s-xdmln;
                            return
                        end
                        xincm1=xinc-1;
                        fx=x+xincm1;

                        for i=1:floorxinc
                            s=s+fx^(-dorderp1);
                            xincm1=xincm1-1;
                            fx=x+xincm1;
                        end
                    end
                    if dorder==0
                        s=s-xdmln;
                    end
                    rval=s;
                end



                function y=unscale(k0,y)
                    if k0>=19
                        y=-y;
                        for k=1:k0
                            y=-k*y;
                        end
                    else
                        s=-1;
                        for k=1:k0
                            s=-k*s;
                        end
                        y=s*y;
                    end


