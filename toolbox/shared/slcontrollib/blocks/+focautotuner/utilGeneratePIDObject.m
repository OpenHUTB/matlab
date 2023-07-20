function[obj,gains]=utilGeneratePIDObject(typeidx,formidx,timedomainidx,Ts,ifidx,dfidx,P,I,D,N)
    formulas={'ForwardEuler';'BackwardEuler';'Trapezoidal'};
    if formidx==1


        switch typeidx
        case 1
            obj=pid(P);
            gains=P;
        case 2
            obj=pid(0,I);
            gains=I;
        case 3
            obj=pid(P,I);
            gains=[P,I];
        case 4
            obj=pid(P,0,D);
            gains=[P,D];
        case 5
            obj=pid(P,0,D,1/N);
            gains=[P,D,N];
        case 6
            obj=pid(P,I,D);
            gains=[P,I,D];
        case 7
            obj=pid(P,I,D,1/N);
            gains=[P,I,D,N];
        end
    else


        switch typeidx
        case 1
            obj=pidstd(P);
            gains=P;
        case 2

            obj=pid(0,I);
            gains=I;
        case 3
            if P==0

                obj=pid(0,I);
            else
                obj=pidstd(P,P/I);
            end
            gains=[P,I];
        case 4
            obj=pidstd(P,inf,P*D);
            gains=[P,D];
        case 5
            if P==0||D==0

                obj=pidstd(P,inf);
            else
                obj=pidstd(P,inf,P*D,P*D*N);
            end
            gains=[P,D,N];
        case 6
            if P==0

                obj=pid(0,I);
            else
                obj=pidstd(P,P/I,P*D);
            end
            gains=[P,I,D];
        case 7
            if P==0

                obj=pid(0,I);
            elseif D==0

                obj=pidstd(P,P/I);
            else
                obj=pidstd(P,P/I,P*D,P*D*N);
            end
            gains=[P,I,D,N];
        end
    end
    if timedomainidx==1
        set(obj,'Ts',Ts,'IF',formulas{ifidx},'DF',formulas{dfidx});
    end
end