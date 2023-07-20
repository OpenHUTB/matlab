function[isProp,D]=isproper(D,Explicit)















    if isempty(D.e)
        isProp=true;
    else

        d=D.d;


        [a,b,c,e,xco,eco]=smreal(D.a,D.b,D.c,D.e);
        nxsm=size(a,1);
        if~D.Scaled

            [a,b,c,e]=xscale(a,b,c,d,e,D.Ts);
        end
        [a,b,c,e,rkE]=minreal_inf(a,b,c,e);
        if rkE<size(a,1)

            [a,b,c,d,e]=elimAV(a,b,c,d,e,rkE,sqrt(eps));
        end
        nxr=size(a,1);
        isProp=(nxr==rkE);

        if nargout>1
            if nxr<nxsm

                InfCancel=true;
            else

                s=svd(D.e(~eco,~xco));
                tolsing=ltipack.getTolerance('rank');
                InfCancel=any(s<=tolsing*norm(e,1));
            end

            if InfCancel

                D.a=a;D.b=b;D.c=c;D.d=d;D.e=e;
                D.StateName=strings(0,1);
                D.StatePath=strings(0,1);
                D.StateUnit=strings(0,1);
                D.Scaled=false;
            end

            if isProp&&nargin>1&&Explicit

                e=D.e;diagE=diag(e);
                if isequal(e,diag(diagE))


                    s=1./diagE;
                    D.a=lrscale(D.a,s,[]);D.b=lrscale(D.b,s,[]);
                else
                    [D.a,D.b]=ltipack.utElimE(D.a,D.b,e);
                end
                D.e=[];
                D.Scaled=false;
            end
        end
    end