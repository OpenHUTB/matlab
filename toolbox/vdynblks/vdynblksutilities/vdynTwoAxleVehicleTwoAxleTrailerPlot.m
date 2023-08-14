function vdynTwoAxleVehicleTwoAxleTrailerPlot(InertCGDisp,InertCGAng,InertCGVel,delta,vehRef,w,a,c,dh,bufferSize,figBorder,figWidth,extRef)




%#codegen
    coder.allowpcode('plain')
    persistent t_count pathH VehDispHistX VehDispHistY vehH vehVelArrowH vehVertsxy tireFL tireFR tireRL tireRR tireVertsxy figH VehRefHistX VehRefHistY pathRefH

    psi=zeros(1,2);
    VehVelVec=zeros(2,4);
    acorr=zeros(1,2);
    vehX=zeros(18,2);
    vehY=zeros(18,2);
    tireX=zeros(12,2);
    tireY=zeros(12,2);
    if isempty(VehDispHistX)VehDispHistX=single(ones(2,bufferSize));end
    if isempty(VehDispHistY)VehDispHistY=single(ones(2,bufferSize));end
    if isempty(pathH)pathH=zeros(1,2);end
    if isempty(VehRefHistX)VehRefHistX=single(ones(2,bufferSize));end
    if isempty(VehRefHistY)VehRefHistY=single(ones(2,bufferSize));end
    if isempty(pathRefH)pathRefH=zeros(1,2);end
    if isempty(vehVelArrowH)vehVelArrowH=zeros(1,2);end
    if isempty(vehVertsxy)vehVertsxy=zeros(4,18);end
    vehVerts=zeros(2,18);
    if isempty(tireVertsxy)tireVertsxy=zeros(4,12);end
    vetireFLVerts=zeros(2,12);
    vetireFRVerts=zeros(2,12);
    vetireRLVerts=zeros(2,12);
    vetireRRVerts=zeros(2,12);
    if isempty(tireFL)tireFL=zeros(1,2);end
    if isempty(tireFR)tireFR=zeros(1,2);end
    if isempty(tireRL)tireRL=zeros(1,2);end
    if isempty(tireRR)tireRR=zeros(1,2);end
    if isempty(vehH)vehH=zeros(1,2);end

    tireYScale=(dh(1)+c(1))/20;


    for VehicleType=1:2

        [FLInertDisp,FRInertDisp,~,~]=hardpoints(InertCGDisp(VehicleType,:),InertCGAng(VehicleType,3),w(VehicleType)/2,a(VehicleType),c(VehicleType));
        psi(VehicleType)=atan2(FLInertDisp(2)-FRInertDisp(2),FLInertDisp(1)-FRInertDisp(1));


        InertCGVelNorm=max(1,sum(sqrt(InertCGVel(VehicleType,:).^2)));
        [InertCGxdotp,~]=div0protect(InertCGVel(VehicleType,1),1);
        velAng=atan2(InertCGVel(VehicleType,2),InertCGxdotp(1));
        VehVelVec(VehicleType,:)=[InertCGDisp(VehicleType,2),InertCGDisp(VehicleType,1),InertCGVelNorm.*sin(velAng),InertCGVelNorm.*cos(velAng)];

        if VehicleType==1
            acorr(VehicleType)=a(VehicleType);
        else
            acorr(VehicleType)=-a(VehicleType);
        end

    end

    if isempty(figH)||~ishandle(figH)
        t_count=1;
        [~]=vehdynicon('vehdyn2Dplot',gcb,0);

        for VehicleType=1:2
            VehDispHistX(VehicleType,:)=single(ones(1,bufferSize)).*InertCGDisp(VehicleType,1);
            VehDispHistY(VehicleType,:)=single(ones(1,bufferSize)).*InertCGDisp(VehicleType,2);
        end


        figH=figure('Name','Vehicle Position','NumberTitle','off','renderer','OpenGL','clipping','off');


        axH=gca(figH);
        set(axH,'NextPlot','add','fontsize',15)


        xl=xlabel('Y Distance [m]');
        yl=ylabel('X Distance [m]');
        set(xl,'fontsize',18)
        set(yl,'fontsize',18)
        updatelims(VehDispHistY,VehDispHistX,figWidth,figBorder,true)
        set(axH,'Box','on','XGrid','on','YGrid','on','ZGrid','on')

        for VehicleType=1:2
            pathH(VehicleType)=plot(VehDispHistY(VehicleType,:),VehDispHistX(VehicleType,:),'ko');

            if extRef
                VehRefHistX(VehicleType,:)=single(ones(1,bufferSize)).*vehRef(VehicleType,1);
                VehRefHistY(VehicleType,:)=single(ones(1,bufferSize)).*vehRef(VehicleType,2);
                pathRefH(VehicleType)=plot(VehRefHistX(VehicleType,:),VehRefHistY(VehicleType,:),'r.');
            else
                VehRefHistX(VehicleType,:)=single(zeros(1,bufferSize));
                VehRefHistY(VehicleType,:)=single(zeros(1,bufferSize));
                pathRefH(VehicleType)=0;
            end

            vehXTmp=[0.50;0.331460674157303;0.148314606741573;0.0505617977528090;0;0;0.0393258426966292;0.19;0.328089887640449;0.5];
            vehXTmp=([vehXTmp;flipud(1-vehXTmp(2:end-1))]-.5).*w(VehicleType)*1.3;
            vehX(:,VehicleType)=vehXTmp;

            vehYTmp=[0;0;.025;.053;.083;.866;.900;.96;1;1];

            if VehicleType==1
                vertOffset=-0.6;
            else
                vertOffset=-.5;
            end

            vehYTmp=(([vehYTmp;flipud(vehYTmp(2:end-1))]+vertOffset).*(a(VehicleType)+c(VehicleType)))*1.5;
            vehY(:,VehicleType)=vehYTmp;

            vehVertsxy(2*VehicleType-1:2*VehicleType,:)=[vehX(:,VehicleType)';vehY(:,VehicleType)'];
            vehDCM=[cos(psi(VehicleType)),-sin(psi(VehicleType));sin(psi(VehicleType)),cos(psi(VehicleType))];
            vehVerts=vehDCM*vehVertsxy(2*VehicleType-1:2*VehicleType,:)+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(vehVertsxy(2*VehicleType-1:2*VehicleType,:)));
            vehH(VehicleType)=patch('Vertices',flipud(vehVerts)','Faces',1:length(vehX),'AmbientStrength',0.46,'EdgeColor',[0,0,0],'FaceAlpha',0.1);
            vehVelArrowH(VehicleType)=drawArrow([0,VehVelVec(VehicleType,3)]+InertCGDisp(VehicleType,2),[0,VehVelVec(VehicleType,4)]+InertCGDisp(VehicleType,1),{'Color','g','LineWidth',2});

            tireX(:,VehicleType)=(w(VehicleType))/10*[1;0.98;0.95;-0.95;-0.98;-1;-1;-0.98;-0.95;0.95;0.98;1];
            tireY(:,VehicleType)=tireYScale*[0.60;0.90;1;1;0.90;0.60;-0.60;-0.90;-1;-1;-0.90;-0.60];

            tireVertsxy(2*VehicleType-1:2*VehicleType,:)=[tireX(:,VehicleType)';tireY(:,VehicleType)'];

            tireFLDCM=[cos(delta(VehicleType,1)),-sin(delta(VehicleType,1));sin(delta(VehicleType,1)),cos(delta(VehicleType,1))];
            tireFRDCM=[cos(delta(VehicleType,2)),-sin(delta(VehicleType,2));sin(delta(VehicleType,2)),cos(delta(VehicleType,2))];
            tireRLDCM=[cos(delta(VehicleType,3)),-sin(delta(VehicleType,3));sin(delta(VehicleType,3)),cos(delta(VehicleType,3))];
            tireRRDCM=[cos(delta(VehicleType,4)),-sin(delta(VehicleType,4));sin(delta(VehicleType,4)),cos(delta(VehicleType,4))];

            cMap=[0,0,0];
            vetireFLVerts=vehDCM*(tireFLDCM*tireVertsxy(2*VehicleType-1:2*VehicleType,:)+[w(VehicleType)/2;acorr(VehicleType)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:))))+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:)));
            vetireFRVerts=vehDCM*(tireFRDCM*tireVertsxy(2*VehicleType-1:2*VehicleType,:)+[-w(VehicleType)/2;acorr(VehicleType)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:))))+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:)));
            vetireRLVerts=vehDCM*(tireRLDCM*tireVertsxy(2*VehicleType-1:2*VehicleType,:)+[w(VehicleType)/2;-c(VehicleType)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:))))+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:)));
            vetireRRVerts=vehDCM*(tireRRDCM*tireVertsxy(2*VehicleType-1:2*VehicleType,:)+[-w(VehicleType)/2;-c(VehicleType)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:))))+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:)));

            tireFL(VehicleType)=patch('YData',vetireFLVerts(1,:),'XData',vetireFLVerts(2,:),'AmbientStrength',0.46,'FaceColor',cMap,'EdgeColor',[1,1,1],'FaceAlpha',0.5);
            tireFR(VehicleType)=patch('YData',vetireFRVerts(1,:),'XData',vetireFRVerts(2,:),'AmbientStrength',0.46,'FaceColor',cMap,'EdgeColor',[1,1,1],'FaceAlpha',0.5);
            tireRL(VehicleType)=patch('YData',vetireRLVerts(1,:),'XData',vetireRLVerts(2,:),'AmbientStrength',0.46,'FaceColor',cMap,'EdgeColor',[1,1,1],'FaceAlpha',0.5);
            tireRR(VehicleType)=patch('YData',vetireRRVerts(1,:),'XData',vetireRRVerts(2,:),'AmbientStrength',0.46,'FaceColor',cMap,'EdgeColor',[1,1,1],'FaceAlpha',0.5);

        end

    else

        if~isempty(findobj(figH))

            for VehicleType=1:2
                VehDispHistX(VehicleType,:)=[VehDispHistX(VehicleType,2:end),InertCGDisp(VehicleType,1)];
                VehDispHistY(VehicleType,:)=[VehDispHistY(VehicleType,2:end),InertCGDisp(VehicleType,2)];
                VehRefHistX(VehicleType,:)=[VehRefHistX(VehicleType,2:end),vehRef(VehicleType,1)];
                VehRefHistY(VehicleType,:)=[VehRefHistY(VehicleType,2:end),vehRef(VehicleType,2)];
            end

            newXlim=single([0,0]);
            newYlim=single([0,0]);
            newXlim=get(gca,'Xlim');
            newYlim=get(gca,'Ylim');
            minXlim=double(newXlim(1)).*0.8;
            maxXlim=double(newXlim(2)).*0.8;
            minYlim=double(newYlim(1)).*0.8;
            maxYlim=double(newYlim(2)).*0.8;

            if max(InertCGDisp(:,1))>maxXlim(1)||min(InertCGDisp(:,1))<minXlim(1)||max(InertCGDisp(:,2))>maxYlim(1)||min(InertCGDisp(:,2))<minYlim(1)
                updatelims(VehDispHistY(:,end),VehDispHistX(:,end),figWidth,figBorder,false)
            end

            for VehicleType=1:2

                set(pathH(VehicleType),'XData',VehDispHistY(VehicleType,:));
                set(pathH(VehicleType),'YData',VehDispHistX(VehicleType,:));

                if extRef
                    set(pathRefH(VehicleType),'XData',VehRefHistY(VehicleType,:));
                    set(pathRefH(VehicleType),'YData',VehRefHistX(VehicleType,:));
                end

                vehDCM=[cos(psi(VehicleType)),-sin(psi(VehicleType));sin(psi(VehicleType)),cos(psi(VehicleType))];
                vehVerts=vehDCM*vehVertsxy(2*VehicleType-1:2*VehicleType,:)+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(vehVertsxy(2*VehicleType-1:2*VehicleType,:)));

                set(vehH(VehicleType),'Vertices',flipud(vehVerts)');
                set(vehVelArrowH(VehicleType),'position',VehVelVec(VehicleType,:));

                tireFLDCM=[cos(delta(VehicleType,1)),-sin(delta(VehicleType,1));sin(delta(VehicleType,1)),cos(delta(VehicleType,1))];
                tireFRDCM=[cos(delta(VehicleType,2)),-sin(delta(VehicleType,2));sin(delta(VehicleType,2)),cos(delta(VehicleType,2))];
                tireRLDCM=[cos(delta(VehicleType,3)),-sin(delta(VehicleType,3));sin(delta(VehicleType,3)),cos(delta(VehicleType,3))];
                tireRRDCM=[cos(delta(VehicleType,4)),-sin(delta(VehicleType,4));sin(delta(VehicleType,4)),cos(delta(VehicleType,4))];

                vetireFLVerts=vehDCM*(tireFLDCM*tireVertsxy(2*VehicleType-1:2*VehicleType,:)+[+w(VehicleType)/2;acorr(VehicleType)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:))))+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:)));
                vetireFRVerts=vehDCM*(tireFRDCM*tireVertsxy(2*VehicleType-1:2*VehicleType,:)+[-w(VehicleType)/2;acorr(VehicleType)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:))))+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:)));
                vetireRLVerts=vehDCM*(tireRLDCM*tireVertsxy(2*VehicleType-1:2*VehicleType,:)+[w(VehicleType)/2;-c(VehicleType)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:))))+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:)));
                vetireRRVerts=vehDCM*(tireRRDCM*tireVertsxy(2*VehicleType-1:2*VehicleType,:)+[-w(VehicleType)/2;-c(VehicleType)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:))))+[InertCGDisp(VehicleType,1);InertCGDisp(VehicleType,2)]*ones(1,length(tireVertsxy(2*VehicleType-1:2*VehicleType,:)));

                set(tireFL(VehicleType),'YData',vetireFLVerts(1,:),'XData',vetireFLVerts(2,:));
                set(tireFR(VehicleType),'YData',vetireFRVerts(1,:),'XData',vetireFRVerts(2,:));
                set(tireRL(VehicleType),'YData',vetireRLVerts(1,:),'XData',vetireRLVerts(2,:));
                set(tireRR(VehicleType),'YData',vetireRRVerts(1,:),'XData',vetireRRVerts(2,:));

            end

            drawnow limitrate
            t_count=t_count+1;

        end
    end
end

function updatelims(VehDispHistX,VehDispHistY,figWidth,figBorder,Init)
%#codegen
    figH=gcf;
    axH=gca;

    Scale=1;
    XLim=(max(VehDispHistX(:))+min(VehDispHistX(:)))/2+[-figBorder,figBorder];
    rangeX=XLim(2)-XLim(1);
    YLim=(max(VehDispHistY(:))+min(VehDispHistY(:)))/2+[-figBorder,figBorder];

    if Init
        rangeY=YLim(2)-YLim(1);
        figHeight=Scale*figWidth*rangeY/rangeX;

        set(figH,'Position',[0,0,figWidth,figHeight])

        set(figH,'PaperPosition',[0,0,figWidth,figHeight])

        set(figH,'PaperSize',[figWidth,figHeight])

    end

    set(axH,'XLim',XLim);
    set(axH,'YLim',YLim);
end

function[h]=drawArrow(x,y,props)

%#codegen
    coder.extrinsic('annotation')
    h=annotation('arrow');
    set(h,'parent',gca,...
    'position',[x(1),y(1),x(2)-x(1),y(2)-y(1)],...
    'HeadLength',10,'HeadWidth',10,'HeadStyle','cback1',...
    props{:});

end


function[y,yabs]=div0protect(u,tol)

%#codegen
    yabs=abs(u);
    ytolinds=yabs<tol;
    yabs(ytolinds)=2.*tol(ytolinds)./(3-(yabs(ytolinds)./tol(ytolinds)).^2);
    yneginds=u<0;
    y=yabs;
    y(yneginds)=-yabs(yneginds);

end


function[FL,FR,RL,RR]=hardpoints(u,theta,w,a,c)

%#codegen
    sintheta=sin(theta);
    costheta=cos(theta);

    FL=zeros(3,1);
    FR=zeros(3,1);
    RL=zeros(3,1);
    RR=zeros(3,1);

    FL(1)=u(1)+a*costheta+w*sintheta;
    FL(2)=u(2)+a*sintheta-w*costheta;
    FR(1)=u(1)+a*costheta-w*sintheta;
    FR(2)=u(2)+a*sintheta+w*costheta;
    RL(1)=u(1)-c*costheta+w*sintheta;
    RL(2)=u(2)-c*sintheta-w*costheta;
    RR(1)=u(1)-c*costheta-w*sintheta;
    RR(2)=u(2)-c*sintheta+w*costheta;

end