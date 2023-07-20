function[u,J]=cutSequenceOnCircle(c,v,I)























































































    if nargin<3
        I=(1:length(v))';
    end
    I(isnan(v))=NaN;

    d=map.internal.clip.minorArcLengthOnCircle(c,v);


    u=adjustValuesThatMapToCut(v,c,d);


    [J,u]=cutCrossingsWithPointsOnCut(I,u,c,d);


    [J,u]=cutRegularCrossings(J,u,c);



    u=wrapd(u,c);
end


function u=adjustValuesThatMapToCut(u,c,d)


    [first,last]=findSequencesCoincidentWithCut(d);
    if~isempty(first)

        n=[true;isnan(d);true];
        q=(n(first)&n(last+2));
        q=q';
        for k=find(q)
            t=u(first(k):last(k));
            t(t<c)=c;
            t(t>c+360)=c+360;
            u(first(k):last(k))=t;
        end
        first(q)=[];
        last(q)=[];
    end

    if~isempty(first)

        n=[true;isnan(d);true];
        t=[0;d;0];
        t(t==-180|t==180)=0;
        q=(n(first)&t(last+2)>0)...
        |(n(last+2)&t(first)>0)...
        |(t(first)>0&t(last+2)>0);
        q=q';
        for k=find(q)
            u(first(k):last(k))=c;
        end
        first(q)=[];
        last(q)=[];
    end

    if~isempty(first)

        n=[true;isnan(d);true];
        t=[0;d;0];
        t(t==-180|t==180)=0;
        q=(n(first)&t(last+2)<0)...
        |(n(last+2)&t(first)<0)...
        |(t(first)<0&t(last+2)<0);
        q=q';
        for k=find(q)
            u(first(k):last(k))=c+360;
        end
    end
end


function[first,last]=findSequencesCoincidentWithCut(d)





    t=(d(:)==0);
    first=find(t&[true;~t(1:end-1)]);
    last=find(t&[~t(2:end);true]);
end


function[J,u]=cutCrossingsWithPointsOnCut(I,v,c,d)


    [crossing,westbound,v]=findCrossingsOnCut(v,c,d);
    if~isempty(crossing)



        newValue=c+zeros(size(crossing));
        newValue(westbound)=c+360;


        n=numel(crossing);
        J=NaN(size(I)+[2*n,0]);
        u=J;


        p=1;
        s=1;

        for m=1:n
            k=crossing(m);






            e=s+(k-p);
            J(s:e)=I(p:k);
            u(s:e)=v(p:k);
            J(e+2)=I(k);
            u(e+2)=newValue(m);


            p=k+1;
            s=e+3;
        end


        J(s:end)=I(p:end);
        u(s:end)=v(p:end);
    else
        J=I;
        u=v;
    end
end


function[crossing,westbound,v]=findCrossingsOnCut(v,c,d)



    [first,last]=findInteriorSequencesCoincidentWithCut(d);
    if any(first)






        dprev=d(first-1);
        eastboundOnArrival=dprev<0;
        westboundOnArrival=dprev>0;

        dnext=d(last+1);
        eastboundOnDeparture=dnext>0;
        westboundOnDeparture=dnext<0;




        updatedValue=c+zeros(size(first));
        updatedValue(eastboundOnArrival)=updatedValue(eastboundOnArrival)+360;
        for k=1:length(first)
            v(first(k):last(k))=updatedValue(k);
        end



        westbound=westboundOnArrival&westboundOnDeparture;
        crosses=westbound|(eastboundOnArrival&eastboundOnDeparture);
        crossing=last;
        crossing(~crosses)=[];
        westbound(~crosses)=[];
    else
        crossing=[];
        westbound=[];
    end
end


function[first,last]=findInteriorSequencesCoincidentWithCut(d)









    [first,last]=findSequencesCoincidentWithCut(d);


    if~isempty(first)&&(first(1)==1)
        first(1)=[];
        last(1)=[];
    end


    if~isempty(last)&&(last(end)==length(d))
        first(end)=[];
        last(end)=[];
    end



    q=isnan(d(first-1))|isnan(d(last+1));
    first(q)=[];
    last(q)=[];
end


function[J,u]=cutRegularCrossings(I,v,c)












    d=map.internal.clip.minorArcLengthOnCircle(c,v);
    dprev=d(1:end-1);
    dnext=d(2:end);
    q=abs(dprev)+abs(dnext)<180;
    westToEast=find(q&dprev<0&0<dnext);
    eastToWest=find(q&0<dprev&dnext<0);

    if isempty(westToEast)&&isempty(eastToWest)
        J=I;
        u=v;
    else
        wezeros=zeros(length(westToEast),1);
        ewzeros=zeros(length(eastToWest),1);

        side=[...
        2+wezeros,1+wezeros;...
        1+ewzeros,2+ewzeros];

        [crossing,Isort]=sort([westToEast;eastToWest]);
        side=side(Isort,:);
        vCrossing=[c,c+360];


        n=numel(crossing);
        J=NaN(size(I)+[3*n,0]);
        u=J;


        p=1;
        s=1;

        for m=1:n

            k=crossing(m);
            w=abs(map.internal.clip.minorArcLengthOnCircle(v(k),c)...
            /map.internal.clip.minorArcLengthOnCircle(v(k),v(k+1)));




            e=s+(k-p);
            J(s:e)=I(p:k);
            u(s:e)=v(p:k);



            J(e+[1,3])=(1-w)*I(k)+w*I(k+1);
            u(e+1)=vCrossing(side(m,1));
            u(e+3)=vCrossing(side(m,2));


            p=k+1;
            s=e+4;
        end


        J(s:end)=I(p:end);
        u(s:end)=v(p:end);
    end
end


function u=wrapd(u,c)












    outOfRange=(u<c)|(u>c+360);
    t=mod(u(outOfRange),360);
    tooSmall=(t<c);
    tooLarge=(t>c+360);
    t(tooSmall)=t(tooSmall)+360;
    t(tooLarge)=t(tooLarge)-360;
    u(outOfRange)=t;
end
