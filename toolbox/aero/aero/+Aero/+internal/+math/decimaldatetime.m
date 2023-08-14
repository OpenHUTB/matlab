function dt=decimaldatetime(input,action)









    smalleps=4.4*eps(2000);


    [nRows,nCols]=size(input);
    dxf=zeros(nRows,6);
    dxi=int32(dxf);
    dxi(:,1:nCols)=floor(input);
    dxf(:,1:nCols)=mod(input,1);


    dt=datetime(dxi);


    hasDecimalYMDHM=abs(max(dxf(:,1:5),[],2))>smalleps;
    hasDecimalS=~hasDecimalYMDHM&(abs(dxf(:,6))>smalleps);


    nDecimal=sum(hasDecimalYMDHM);
    if nDecimal>0
        strnd=sprintf('%d',nDecimal);
        switch action
        case 'warning'
            warning(message('aero:aeroephemerides:datetimeDecimalAdjusted',strnd));
        case 'error'
            error(message('aero:aeroephemerides:datetimeDecimalError',strnd));
        end
    end


    durations=...
    dxf(hasDecimalYMDHM,1).*(datetime(dxi(hasDecimalYMDHM,1)+1,dxi(hasDecimalYMDHM,2),dxi(hasDecimalYMDHM,3),dxi(hasDecimalYMDHM,4),dxi(hasDecimalYMDHM,5),dxi(hasDecimalYMDHM,6))-dt(hasDecimalYMDHM))+...
    dxf(hasDecimalYMDHM,2).*(datetime(dxi(hasDecimalYMDHM,1),dxi(hasDecimalYMDHM,2)+1,dxi(hasDecimalYMDHM,3),dxi(hasDecimalYMDHM,4),dxi(hasDecimalYMDHM,5),dxi(hasDecimalYMDHM,6))-dt(hasDecimalYMDHM))+...
    dxf(hasDecimalYMDHM,3).*(datetime(dxi(hasDecimalYMDHM,1),dxi(hasDecimalYMDHM,2),dxi(hasDecimalYMDHM,3)+1,dxi(hasDecimalYMDHM,4),dxi(hasDecimalYMDHM,5),dxi(hasDecimalYMDHM,6))-dt(hasDecimalYMDHM))+...
    dxf(hasDecimalYMDHM,4).*(datetime(dxi(hasDecimalYMDHM,1),dxi(hasDecimalYMDHM,2),dxi(hasDecimalYMDHM,3),dxi(hasDecimalYMDHM,4)+1,dxi(hasDecimalYMDHM,5),dxi(hasDecimalYMDHM,6))-dt(hasDecimalYMDHM))+...
    dxf(hasDecimalYMDHM,5).*(datetime(dxi(hasDecimalYMDHM,1),dxi(hasDecimalYMDHM,2),dxi(hasDecimalYMDHM,3),dxi(hasDecimalYMDHM,4),dxi(hasDecimalYMDHM,5)+1,dxi(hasDecimalYMDHM,6))-dt(hasDecimalYMDHM))+...
    dxf(hasDecimalYMDHM,6).*(datetime(dxi(hasDecimalYMDHM,1),dxi(hasDecimalYMDHM,2),dxi(hasDecimalYMDHM,3),dxi(hasDecimalYMDHM,4),dxi(hasDecimalYMDHM,5),dxi(hasDecimalYMDHM,6)+1)-dt(hasDecimalYMDHM));
    dt(hasDecimalYMDHM)=dt(hasDecimalYMDHM)+durations;


    dt(hasDecimalS)=dt(hasDecimalS)+duration(0,0,dxf(hasDecimalS,6));
end