function[contactPnts,groundDCM,wheelContact]=vehdyngrndplot(u,WheelP,WheelDCM,rayOrigins,dispFig,numAxles,numWheelsPerAxle,wheelRad,wheelWidth)




%#codegen
    coder.allowpcode('plain')

    persistent tCount contactP RoadShape InContact figHW x y z xp yp zp shp WheelEnvelZ meshHArray surfHArray patchHArray nomWheelVerts WheelVerts contactPntHArray


    if isempty(tCount)
        if builtin('license','test','Vehicle_Dynamics_Blockset')
            [~]=builtin('license','checkout','Vehicle_Dynamics_Blockset');
        else
            error(message('autoblks_shared:autosharederrAutoIcon:invalidLicense'));
        end
        tCount=0;
        numWheels=numAxles.*numWheelsPerAxle;
        contactP=zeros(numWheels,3);
        InContact=true(numWheels,1);
        x=rayOrigins(:,1);
        y=-rayOrigins(:,2);
        z=zeros(length(x),numWheels);
        xp=zeros(numWheels,4);
        yp=xp;
        zp=xp;
        phi=zeros(numWheels,1);
        theta=zeros(numWheels,1);
        groundDCM=zeros(3,3,numWheels);
        numRadPoints=3;
        numSectorPnts=40;
        numLatPnts=2;
        numWheelVerts=162;
        WheelEnvelY=zeros(numRadPoints,numSectorPnts,numLatPnts);%#ok<PREALL>
        WheelEnvelX=zeros(numRadPoints,numSectorPnts,numLatPnts);%#ok<PREALL>
        th=zeros(numRadPoints,numSectorPnts,numLatPnts);%#ok<PREALL>
        r=zeros(numRadPoints,numSectorPnts,numLatPnts);%#ok<PREALL>
        h=zeros(numRadPoints,numSectorPnts,numLatPnts);%#ok<PREALL>
        [th,r,h]=meshgrid(linspace(0,2*pi,numSectorPnts),[0,0.8,1],linspace(0,1,numLatPnts));
        [WheelEnvelZ,WheelEnvelX,WheelEnvelY]=pol2cart(th,r,h);
        P=[WheelEnvelX(:),WheelEnvelY(:),WheelEnvelZ(:)];
        P=unique(P,'rows');
        shp=alphaShape(P(:,1).*wheelRad,P(:,2).*wheelWidth-wheelWidth./2,P(:,3).*wheelRad,wheelRad*2.1);
        WheelVerts=zeros(numWheelVerts,3,numWheelsPerAxle.*numAxles);
        nomWheelVerts=zeros(numWheelVerts,3);%#ok<PREALL>
        [~,nomWheelVerts]=boundaryFacets(shp);
    end


    wheelNum=1;
    for idx=1:numAxles
        for idj=1:numWheelsPerAxle
            WheelVerts(:,:,wheelNum)=(WheelDCM(:,:,wheelNum)*(nomWheelVerts)')'+WheelP(wheelNum,:)+[0,0,wheelRad];

            z(:,wheelNum)=u(:,3,wheelNum);
            PRoadSurf=[x,y,z(:,wheelNum)];
            PGrnSurf=PRoadSurf-[0,0,1];
            RoadShape=alphaShape([PRoadSurf;PGrnSurf],10);

            [xp(wheelNum,:),yp(wheelNum,:),zp(wheelNum,:),contactP(wheelNum,:),~,InContact(wheelNum)]=groundcontact(RoadShape,WheelVerts(:,:,wheelNum),WheelP(wheelNum,:));

            phi(wheelNum)=atan(((zp(wheelNum,1)-zp(wheelNum,2))+(zp(wheelNum,4)-zp(wheelNum,3)))./max(abs(yp(wheelNum,1)-yp(wheelNum,2)),.001)./2);
            theta(wheelNum)=atan(((zp(wheelNum,1)-zp(wheelNum,4))+(zp(wheelNum,2)-zp(wheelNum,3)))./max(abs(xp(wheelNum,1)-xp(wheelNum,4)),0.001)./2);
            groundDCM(:,:,wheelNum)=angle2dcm([0,theta(wheelNum),phi(wheelNum)]);
            wheelNum=1+wheelNum;
        end
    end
    tCount=tCount+1;

    contactPnts=contactP;
    wheelContact=InContact;



    if isempty(figHW)||~ishandle(figHW)

        if dispFig
            figHW=figure('Name','Terrain Contact','NumberTitle','off','renderer','OpenGL','clipping','off','MenuBar','none','ToolBar','none');
            tlo=tiledlayout(numAxles,numWheelsPerAxle,'TileSpacing','tight');
            xlabel(tlo,'Terrain Feedback')
            surfHArray=zeros(numAxles,numWheelsPerAxle);
            patchHArray=surfHArray;
            meshHArray=surfHArray;
            contactPntHArray=surfHArray;
            wheelNum=1;
            [faceColor,faceAlpha]=updatePatch(InContact);
            for idx=1:numAxles
                for idj=1:numWheelsPerAxle
                    nexttile;
                    tileplotsetup(wheelNum);





                    surfHArray(idx,idj)=scatter3(x,y,z(:,wheelNum),10,'MarkerEdgeColor','k','MarkerFaceColor',[0,.75,.75]);
                    meshHArray(idx,idj)=plot(shp,'EdgeColor',[.5,.5,.5],'FaceAlpha',0.1);

                    patchHArray(idx,idj)=patch(xp(wheelNum,:),yp(wheelNum,:),zp(wheelNum,:),faceColor(wheelNum),'FaceAlpha',faceAlpha(wheelNum),'EdgeColor','k');

                    contactPntHArray(idx,idj)=plot3(contactP(wheelNum,1),contactP(wheelNum,2),contactP(wheelNum,3),'ro');
                    wheelNum=1+wheelNum;
                end
            end
        else
            figHW=gobjects(1);
        end

    else
        if~isempty(findobj(figHW))&&dispFig
            wheelNum=1;
            [faceColor,faceAlpha]=updatePatch(InContact);
            for idx=1:numAxles
                for idj=1:numWheelsPerAxle



                    set(surfHArray(idx,idj),'ZData',z(:,wheelNum));
                    set(meshHArray(idx,idj),'vertices',WheelVerts(:,:,wheelNum));
                    set(patchHArray(idx,idj),'ZData',zp(wheelNum,:),'FaceColor',faceColor(wheelNum),'FaceAlpha',faceAlpha(wheelNum));
                    set(contactPntHArray(idx,idj),'XData',contactP(wheelNum,1),'YData',contactP(wheelNum,2),'ZData',contactP(wheelNum,3));
                    wheelNum=1+wheelNum;
                end
            end
            drawnow limitrate;
        end
    end

end
function[xp,yp,zp,contactP,minContactDist,InContact]=groundcontact(RoadShape,wheelVerts,WheelP)
    coder.extrinsic('alphaShape','nearestNeighbor','inShape')
    N=162;
    id1=false(N,1);
    id1=inShape(RoadShape,wheelVerts);
    contactXPnts=wheelVerts(id1,1);
    contactYPnts=wheelVerts(id1,2);
    contactZPnts=wheelVerts(id1,3);

    if length(contactXPnts)<4
        minContactInd=1;%#ok<NASGU>
        minContactDist=0;%#ok<NASGU>
        [~,contactDist]=nearestNeighbor(RoadShape,wheelVerts(:,1),wheelVerts(:,2),wheelVerts(:,3));
        [minContactDist,minContactInd]=min(contactDist);
        xp=[.01,0.01,-.01,-.01];
        yp=[-.1,.1,.1,-.1];
        zp=zeros(1,4);
        contactP=[wheelVerts(minContactInd,1),wheelVerts(minContactInd,2),wheelVerts(minContactInd,3)-minContactDist];
        InContact=false;
    else



        B=[contactXPnts,contactYPnts,ones(size(contactZPnts,1),1)]\contactZPnts;
        minx=min(contactXPnts);maxx=max(contactXPnts);
        miny=min(contactYPnts);maxy=max(contactYPnts);
        xp=[maxx,maxx,minx,minx];
        yp=[miny,maxy,maxy,miny];
        zp=[xp(:),yp(:),ones(4,1)]*B;
        contactP=[mean(xp),mean(yp),mean(zp)];
        InContact=true;
        minContactDist=WheelP(3)-contactP(3);
    end
end
function dcm=angle2dcm(angles)
    cang=cos(angles);
    sang=sin(angles);
    r11=cang(:,2).*cang(:,1);
    r12=cang(:,2).*sang(:,1);
    r13=-sang(:,2);
    r21=sang(:,3).*sang(:,2).*cang(:,1)-cang(:,3).*sang(:,1);
    r22=sang(:,3).*sang(:,2).*sang(:,1)+cang(:,3).*cang(:,1);
    r23=sang(:,3).*cang(:,2);
    r31=cang(:,3).*sang(:,2).*cang(:,1)+sang(:,3).*sang(:,1);
    r32=cang(:,3).*sang(:,2).*sang(:,1)-sang(:,3).*cang(:,1);
    r33=cang(:,3).*cang(:,2);
    a=[r11,r21,r31,r12,r22,r32,r13,r23,r33];
    b=a.';
    dcm=reshape(b,3,3,[]);
end
function tileplotsetup(tileNum)
    coder.extrinsic('nexttile','set','xlabel','ylabel','zlabel','view');

    axH=nexttile(tileNum);
    set(axH,'NextPlot','add','fontsize',6)
    view(axH,[-1.263404066073698e+02,25.606128133704644]);

    set(axH,'xlim',[-.5,.5]);
    set(axH,'ylim',[-.5,.5]);
    set(axH,'zlim',[-.25,.75]);

    set(axH,'Box','on','XGrid','on','YGrid','on','ZGrid','on');
    xlabel('X Distance [m]');
    ylabel('Y Distance [m]');
    zlabel('Z Distance [m]');
    hold on;
end
function[faceColor,faceAlpha]=updatePatch(InContact)
    numWheels=length(InContact);
    faceColor=repmat('b',numWheels,1);
    faceAlpha=ones(numWheels,1);
    faceColor(~InContact)='g';
    faceAlpha(~InContact)=0;
end