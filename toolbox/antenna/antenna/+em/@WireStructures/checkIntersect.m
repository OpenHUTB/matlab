function[res,distGrid,sumRad]=checkIntersect(obj,distGrid,radFactor)

    if nargin<3
        radFactor=1;
    end


    P0=zeros(3,0);
    P1=P0;
    ConnectedSegsInd=[];
    wireInitInd=ones(length(obj.Wires),1);
    wireEndInd=ones(length(obj.Wires),1)*...
    (size(obj.Wires{1}.wireNodesOrig,2)-1);
    for wireInd=1:length(obj.Wires)
        if wireInd>1
            wireInitInd(wireInd)=wireInitInd(wireInd)+...
            wireEndInd(wireInd-1);
            wireEndInd(wireInd)=wireEndInd(wireInd-1)+...
            size(obj.Wires{wireInd}.wireNodesOrig,2)-1;
        end
        ConnectedSegsInd=[ConnectedSegsInd...
        ,[wireInitInd(wireInd):wireEndInd(wireInd)-1...
        ,wireInitInd(wireInd)+1:wireEndInd(wireInd);...
        wireInitInd(wireInd)+1:wireEndInd(wireInd)...
        ,wireInitInd(wireInd):wireEndInd(wireInd)-1]];%#ok<AGROW>
        P0=[P0,obj.Wires{wireInd}.wireNodesOrig(:,1:end-1)];%#ok<AGROW>
        P1=[P1,obj.Wires{wireInd}.wireNodesOrig(:,2:end)];%#ok<AGROW>
    end

    for extraConnInd=1:length(obj.ExtraConnsWireInd)
        if obj.ExtraConns{extraConnInd}.PrevSegSides==0
            wireIndprevPart=wireInitInd(...
            obj.ExtraConnsWireInd{extraConnInd}.PrevParts(1));
        else
            wireIndprevPart=wireEndInd(...
            obj.ExtraConnsWireInd{extraConnInd}.PrevParts(1));
        end
        for nextPartInd=1:length(obj.ExtraConnsWireInd{...
            extraConnInd}.NextParts)
            if obj.ExtraConns{extraConnInd}.NextSegSides(nextPartInd)==0
                wireIndnextPart=wireInitInd(obj.ExtraConnsWireInd{...
                extraConnInd}.NextParts(nextPartInd));
            else
                wireIndnextPart=wireEndInd(obj.ExtraConnsWireInd{...
                extraConnInd}.NextParts(nextPartInd));
            end
            ConnectedSegsInd=[ConnectedSegsInd...
            ,[wireIndprevPart,wireIndnextPart;
            wireIndnextPart,wireIndprevPart]];%#ok<AGROW>
        end
    end



    r=cell2mat(cellfun(@(x)repmat(x.SegmentRadius,1,...
    size(x.wireNodesOrig,2)-1),obj.Wires,'UniformOutput',false));
    [rMat,rMatT]=meshgrid(r);
    sumRad=radFactor*(rMat+rMatT);

    if nargin<2||isempty(distGrid)



        P0xMat=meshgrid(P0(1,:));
        P0yMat=meshgrid(P0(2,:));
        P0zMat=meshgrid(P0(3,:));



        uxVec=P1(1,:)-P0(1,:);
        uyVec=P1(2,:)-P0(2,:);
        uzVec=P1(3,:)-P0(3,:);

        uxMat=meshgrid(uxVec);
        uyMat=meshgrid(uyVec);
        uzMat=meshgrid(uzVec);




        vxMat=uxMat';
        vyMat=uyMat';
        vzMat=uzMat';



        w0xMat=P0xMat-P0xMat';
        w0yMat=P0yMat-P0yMat';
        w0zMat=P0zMat-P0zMat';

        uuVec=uxVec.^2+uyVec.^2+uzVec.^2;








        a=meshgrid(uuVec);
        b=uxMat.*vxMat+uyMat.*vyMat+uzMat.*vzMat;
        c=a';
        d=uxMat.*w0xMat+uyMat.*w0yMat+uzMat.*w0zMat;
        e=vxMat.*w0xMat+vyMat.*w0yMat+vzMat.*w0zMat;
        D=a.*c-b.^2;



        sN=(b.*e-c.*d);
        sD=D;
        tN=(a.*e-b.*d);
        tD=D;
        isParallel=(D<eps(min(sum(uuVec,1))));



        sN(isParallel)=0;
        sD(isParallel)=1;

        tN(isParallel)=e(isParallel);
        tD(isParallel)=c(isParallel);


















        issEq0Vis=(sN<0);
        sN(issEq0Vis)=0;


        tN(issEq0Vis)=e(issEq0Vis);
        tD(issEq0Vis)=c(issEq0Vis);

        isSEq1Vis=(sN>sD);
        sN(isSEq1Vis)=sD(isSEq1Vis);

        tN(isSEq1Vis)=e(isSEq1Vis)+b(isSEq1Vis);
        tD(isSEq1Vis)=c(isSEq1Vis);




        isOntEq0=(tN<0);
        tN(isOntEq0)=0;




        isOntEq0sEq0Corner=isOntEq0&(-d<0);
        isOntEq0sEq1Corner=isOntEq0&(-d>a);
        isOntEq0Mid=isOntEq0&(~(-d<0)&~(-d>a));
        sN(isOntEq0sEq0Corner)=0;
        sN(isOntEq0sEq1Corner)=sD(isOntEq0sEq1Corner);

        sN(isOntEq0Mid)=-d(isOntEq0Mid);
        sD(isOntEq0Mid)=a(isOntEq0Mid);



        isOntEq1=(tN>tD);
        tN(isOntEq1)=tD(isOntEq1);




        isOntEq1sEq0Corner=isOntEq1&(-d+b<0);
        isOntEq1sEq1Corner=isOntEq1&(-d+b>a);
        isOntEq1Mid=isOntEq1&(~(-d+b<0)&~(-d+b>a));
        sN(isOntEq1sEq0Corner)=0;
        sN(isOntEq1sEq1Corner)=sD(isOntEq1sEq1Corner);

        sN(isOntEq1Mid)=-d(isOntEq1Mid)+b(isOntEq1Mid);
        sD(isOntEq1Mid)=a(isOntEq1Mid);


        sc=sN./sD;
        tc=tN./tD;




        distxMat=w0xMat+(sc.*uxMat)-(tc.*vxMat);
        distyMat=w0yMat+(sc.*uyMat)-(tc.*vyMat);
        distzMat=w0zMat+(sc.*uzMat)-(tc.*vzMat);
        distGrid=sqrt(distxMat.^2+distyMat.^2+distzMat.^2);
    end



    mask2Ignore=logical(eye(length(r)));
    mask2Ignore(sub2ind([wireEndInd(end),wireEndInd(end)],...
    ConnectedSegsInd(1,:),ConnectedSegsInd(2,:)))=true;

    res=any(any(distGrid<=sumRad&~mask2Ignore));

end
