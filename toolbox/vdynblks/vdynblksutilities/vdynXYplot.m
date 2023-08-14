function vdynXYplot(InertCGDisp,InertCGAng,InertCGVel,delta,vehRef,vehStats,tireF,bufferSize,figBorder,figWidth,w,a,b,extRef,extStats,extTireF,velNorm,tireFNorm)




%#codegen
    coder.allowpcode('plain')
    persistent t_count pathH VehDispHistX VehDispHistY vehH vehVelArrowH vehVertsxy tireFL tireFR tireRL tireRR tireVertsxy figH VehRefHistX VehRefHistY pathRefH txtbxHndl...
    tireFLFxArrowH tireFRFxArrowH tireRLFxArrowH tireRRFxArrowH tireFLFyArrowH tireFRFyArrowH tireRLFyArrowH tireRRFyArrowH


    [FLInertDisp,FRInertDisp,RLInertDisp,RRInertDisp]=hardpoints(InertCGDisp,InertCGAng(3),w/2,a,b);
    psi=atan2(FLInertDisp(2)-FRInertDisp(2),FLInertDisp(1)-FRInertDisp(1));

    InertCGVelNorm=max(1,sum(sqrt(InertCGVel.^2)))./velNorm;
    [InertCGxdotp,~]=div0protect(InertCGVel(1),1);
    velAng=atan2(InertCGVel(2),InertCGxdotp(1));
    VehVelVec=[InertCGDisp(2),InertCGDisp(1),InertCGVelNorm.*sin(velAng),InertCGVelNorm.*cos(velAng)];
    vehDCM=[cos(psi),-sin(psi);sin(psi),cos(psi)];
    tireFLDCM=[cos(delta(1)),-sin(delta(1));sin(delta(1)),cos(delta(1))];
    tireFRDCM=[cos(delta(2)),-sin(delta(2));sin(delta(2)),cos(delta(2))];
    tireRLDCM=[cos(delta(3)),-sin(delta(3));sin(delta(3)),cos(delta(3))];
    tireRRDCM=[cos(delta(4)),-sin(delta(4));sin(delta(4)),cos(delta(4))];
    vehVel=InertCGVel(1).*cos(InertCGAng(3))+InertCGVel(2).*sin(InertCGAng(3));
    if extTireF

        tempInds=abs(tireF)<20;
        tireF(tempInds)=.1;
        Fx=tireF(1,:)./tireFNorm;
        Fy=tireF(2,:)./tireFNorm;

        FtireFLx=vehDCM*(tireFLDCM*[0;Fx(1)]);
        FtireFLxvec=[FLInertDisp(2),FLInertDisp(1),FtireFLx(2),FtireFLx(1)];
        FtireFRx=vehDCM*(tireFRDCM*[0;Fx(2)]);
        FtireFRxvec=[FRInertDisp(2),FRInertDisp(1),FtireFRx(2),FtireFRx(1)];
        FtireRLx=vehDCM*(tireRLDCM*[0;Fx(3)]);
        FtireRLxvec=[RLInertDisp(2),RLInertDisp(1),FtireRLx(2),FtireRLx(1)];
        FtireRRx=vehDCM*(tireRRDCM*[0;Fx(4)]);
        FtireRRxvec=[RRInertDisp(2),RRInertDisp(1),FtireRRx(2),FtireRRx(1)];

        FtireFLy=vehDCM*(tireFLDCM*[Fy(1);0]);
        FtireFLyvec=[FLInertDisp(2),FLInertDisp(1),FtireFLy(2),FtireFLy(1)];
        FtireFRy=vehDCM*(tireFRDCM*[Fy(2);0]);
        FtireFRyvec=[FRInertDisp(2),FRInertDisp(1),FtireFRy(2),FtireFRy(1)];
        FtireRLy=vehDCM*(tireRLDCM*[Fy(3);0]);
        FtireRLyvec=[RLInertDisp(2),RLInertDisp(1),FtireRLy(2),FtireRLy(1)];
        FtireRRy=vehDCM*(tireRRDCM*[Fy(4);0]);
        FtireRRyvec=[RRInertDisp(2),RRInertDisp(1),FtireRRy(2),FtireRRy(1)];
    else
        FtireFLxvec=zeros(4,1);
        FtireFRxvec=zeros(4,1);
        FtireRLxvec=zeros(4,1);
        FtireRRxvec=zeros(4,1);

        FtireFLyvec=zeros(4,1);
        FtireFRyvec=zeros(4,1);
        FtireRLyvec=zeros(4,1);
        FtireRRyvec=zeros(4,1);

    end







    if isempty(figH)||~ishandle(figH)
        if builtin('license','test','Vehicle_Dynamics_Blockset')
            [~]=builtin('license','checkout','Vehicle_Dynamics_Blockset');
        else
            error(message('autoblks_shared:autosharederrAutoIcon:invalidLicense'));
        end
        t_count=1;
        [~]=vehdynicon('vehdyn2Dplot',gcb,0);
        VehDispHistX=single(ones(1,bufferSize)).*InertCGDisp(1);
        VehDispHistY=single(ones(1,bufferSize)).*InertCGDisp(2);


        figH=figure('Name','Vehicle Position','NumberTitle','off','renderer','OpenGL','clipping','off');

        axH=gca(figH);
        set(axH,'NextPlot','add','fontsize',15)


        xl=xlabel('Y Distance [m]');
        yl=ylabel('X Distance [m]');
        set(xl,'fontsize',18)
        set(yl,'fontsize',18)
        figH2=figH;
        updatelims(figH2,VehDispHistY,VehDispHistX,figWidth,figBorder,true)
        set(axH,'Box','on','XGrid','on','YGrid','on','ZGrid','on')
        pathH=plot(VehDispHistY,VehDispHistX,'ko');
        if extRef
            VehRefHistX=single(ones(1,bufferSize)).*vehRef(1);
            VehRefHistY=single(ones(1,bufferSize)).*vehRef(2);
            pathRefH=plot(VehRefHistX,VehRefHistY,'r.');
        else
            VehRefHistX=single(zeros(1,bufferSize));
            VehRefHistY=single(zeros(1,bufferSize));
            pathRefH=0;

        end


        vehX=[0.50;0.331460674157303;0.148314606741573;0.0505617977528090;0;0;0.0393258426966292;0.19;0.328089887640449;0.5];
        vehX=([vehX;flipud(1-vehX(2:end-1))]-.5).*w*1.3;
        vehY=[0;0;.025;.053;.083;.866;.900;.96;1;1];
        vertOffset=-.5;
        vehY=(([vehY;flipud(vehY(2:end-1))]+vertOffset).*(a+b))*1.5;
        vehVertsxy=[vehX';vehY'];

        vehVerts=vehDCM*vehVertsxy+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(vehVertsxy));
        vehH=patch('Vertices',flipud(vehVerts)','Faces',1:length(vehX),'AmbientStrength',0.46,'EdgeColor',[0,0,0],'FaceAlpha',0.1);
        vehVelArrowH=drawArrow([0,VehVelVec(3)]+InertCGDisp(2),[0,VehVelVec(4)]+InertCGDisp(1),{'Color','g','LineWidth',2,'HeadLength',10,'HeadWidth',10,'HeadStyle','cback1'},figH);
        if extTireF
            tireFLFxArrowH=drawArrow([0,FtireFLxvec(3)]+FtireFLxvec(1),[0,FtireFLxvec(4)]+FtireFLxvec(2),{'Color','b','LineWidth',1,'HeadLength',5,'HeadWidth',5,'HeadStyle','vback3'},figH);
            tireFRFxArrowH=drawArrow([0,FtireFRxvec(3)]+FtireFRxvec(1),[0,FtireFRxvec(4)]+FtireFRxvec(2),{'Color','b','LineWidth',1,'HeadLength',5,'HeadWidth',5,'HeadStyle','vback3'},figH);
            tireRLFxArrowH=drawArrow([0,FtireRLxvec(3)]+FtireRLxvec(1),[0,FtireRLxvec(4)]+FtireRLxvec(2),{'Color','b','LineWidth',1,'HeadLength',5,'HeadWidth',5,'HeadStyle','vback3'},figH);
            tireRRFxArrowH=drawArrow([0,FtireRRxvec(3)]+FtireRRxvec(1),[0,FtireRRxvec(4)]+FtireRRxvec(2),{'Color','b','LineWidth',1,'HeadLength',5,'HeadWidth',5,'HeadStyle','vback3'},figH);

            tireFLFyArrowH=drawArrow([0,FtireFLyvec(3)]+FtireFLyvec(1),[0,FtireFLyvec(4)]+FtireFLyvec(2),{'Color','r','LineWidth',1,'HeadLength',5,'HeadWidth',5,'HeadStyle','vback3'},figH);
            tireFRFyArrowH=drawArrow([0,FtireFRyvec(3)]+FtireFRyvec(1),[0,FtireFRyvec(4)]+FtireFRyvec(2),{'Color','r','LineWidth',1,'HeadLength',5,'HeadWidth',5,'HeadStyle','vback3'},figH);
            tireRLFyArrowH=drawArrow([0,FtireRLyvec(3)]+FtireRLyvec(1),[0,FtireRLyvec(4)]+FtireRLyvec(2),{'Color','r','LineWidth',1,'HeadLength',5,'HeadWidth',5,'HeadStyle','vback3'},figH);
            tireRRFyArrowH=drawArrow([0,FtireRRyvec(3)]+FtireRRyvec(1),[0,FtireRRyvec(4)]+FtireRRyvec(2),{'Color','r','LineWidth',1,'HeadLength',5,'HeadWidth',5,'HeadStyle','vback3'},figH);
        else
            tireFLFxArrowH=[];
            tireFRFxArrowH=[];
            tireRLFxArrowH=[];
            tireRRFxArrowH=[];
            tireFLFyArrowH=[];
            tireFRFyArrowH=[];
            tireRLFyArrowH=[];
            tireRRFyArrowH=[];
        end
        tireX=(w)/10*[1;0.98;0.95;-0.95;-0.98;-1;-1;-0.98;-0.95;0.95;0.98;1];
        tireY=((a+b)/8)*[0.60;0.90;1;1;0.90;0.60;-0.60;-0.90;-1;-1;-0.90;-0.60];

        tireVertsxy=[tireX';tireY'];

        cMap=[0,0,0];
        vetireFLVerts=vehDCM*(tireFLDCM*tireVertsxy+[w/2;a]*ones(1,length(tireVertsxy)))+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(tireVertsxy));
        vetireFRVerts=vehDCM*(tireFRDCM*tireVertsxy+[-w/2;a]*ones(1,length(tireVertsxy)))+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(tireVertsxy));
        vetireRLVerts=vehDCM*(tireRLDCM*tireVertsxy+[w/2;-b]*ones(1,length(tireVertsxy)))+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(tireVertsxy));
        vetireRRVerts=vehDCM*(tireRRDCM*tireVertsxy+[-w/2;-b]*ones(1,length(tireVertsxy)))+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(tireVertsxy));

        tireFL=patch('YData',vetireFLVerts(1,:),'XData',vetireFLVerts(2,:),'AmbientStrength',0.46,'FaceColor',cMap,'EdgeColor',[1,1,1],'FaceAlpha',0.5);
        tireFR=patch('YData',vetireFRVerts(1,:),'XData',vetireFRVerts(2,:),'AmbientStrength',0.46,'FaceColor',cMap,'EdgeColor',[1,1,1],'FaceAlpha',0.5);
        tireRL=patch('YData',vetireRLVerts(1,:),'XData',vetireRLVerts(2,:),'AmbientStrength',0.46,'FaceColor',cMap,'EdgeColor',[1,1,1],'FaceAlpha',0.5);
        tireRR=patch('YData',vetireRRVerts(1,:),'XData',vetireRRVerts(2,:),'AmbientStrength',0.46,'FaceColor',cMap,'EdgeColor',[1,1,1],'FaceAlpha',0.5);


        if extStats
            dim=[0.15,0.8,0.25,0.1];
            str={['Velocity: ',sprintf('%3.0f',round(vehVel)),' m/s'],['Engine: ',sprintf('%4.0f',round(vehStats(1)*30/pi)),' RPM'],['Gear: ',sprintf('%2.0f',round(vehStats(2)))]};
            txtbxHndl=annotation('textbox',dim,'String',str,'FitBoxToText','on');
        else
            txtbxHndl=0;
        end
    else
        axH=gca(figH);
        if~isempty(findobj(figH))
            VehDispHistX=[VehDispHistX(2:end),InertCGDisp(1)];
            VehDispHistY=[VehDispHistY(2:end),InertCGDisp(2)];
            VehRefHistX=[VehRefHistX(2:end),vehRef(1)];
            VehRefHistY=[VehRefHistY(2:end),vehRef(2)];
            newXlim=get(axH,'Xlim');
            newYlim=get(axH,'Ylim');
            minXlim=double(newXlim(1)).*0.8;
            maxXlim=double(newXlim(2)).*0.8;
            minYlim=double(newYlim(1)).*0.8;
            maxYlim=double(newYlim(2)).*0.8;
            if InertCGDisp(1)>maxXlim(1)||InertCGDisp(1)<minXlim(1)||InertCGDisp(2)>maxYlim(1)||InertCGDisp(2)<minYlim(1)
                figH2=figH;
                updatelims(figH2,VehDispHistY(end),VehDispHistX(end),figWidth,figBorder,false)
            end
            set(pathH,'XData',VehDispHistY);
            set(pathH,'YData',VehDispHistX);
            if extRef
                set(pathRefH,'XData',VehRefHistY);
                set(pathRefH,'YData',VehRefHistX);
            end
            vehVerts=vehDCM*vehVertsxy+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(vehVertsxy));

            set(vehH,'Vertices',flipud(vehVerts)');
            set(vehVelArrowH,'position',VehVelVec);

            vetireFLVerts=vehDCM*(tireFLDCM*tireVertsxy+[+w/2;a]*ones(1,length(tireVertsxy)))+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(tireVertsxy));
            vetireFRVerts=vehDCM*(tireFRDCM*tireVertsxy+[-w/2;a]*ones(1,length(tireVertsxy)))+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(tireVertsxy));
            vetireRLVerts=vehDCM*(tireRLDCM*tireVertsxy+[w/2;-b]*ones(1,length(tireVertsxy)))+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(tireVertsxy));
            vetireRRVerts=vehDCM*(tireRRDCM*tireVertsxy+[-w/2;-b]*ones(1,length(tireVertsxy)))+[InertCGDisp(1);InertCGDisp(2)]*ones(1,length(tireVertsxy));


            if extTireF
                set(tireFLFxArrowH,'position',FtireFLxvec);
                set(tireFRFxArrowH,'position',FtireFRxvec);
                set(tireRLFxArrowH,'position',FtireRLxvec);
                set(tireRRFxArrowH,'position',FtireRRxvec);

                set(tireFLFyArrowH,'position',FtireFLyvec);
                set(tireFRFyArrowH,'position',FtireFRyvec);
                set(tireRLFyArrowH,'position',FtireRLyvec);
                set(tireRRFyArrowH,'position',FtireRRyvec);
            end
            set(tireFL,'YData',vetireFLVerts(1,:),'XData',vetireFLVerts(2,:));
            set(tireFR,'YData',vetireFRVerts(1,:),'XData',vetireFRVerts(2,:));
            set(tireRL,'YData',vetireRLVerts(1,:),'XData',vetireRLVerts(2,:));
            set(tireRR,'YData',vetireRRVerts(1,:),'XData',vetireRRVerts(2,:));
            if extStats
                set(txtbxHndl,'String',{['Velocity: ',sprintf('%3.0f',round(vehVel)),' m/s'],['Engine: ',sprintf('%4.0f',round(vehStats(1)*30/pi)),' RPM'],['Gear: ',sprintf('%2.0f',round(vehStats(2)))]});
            end
            t_count=t_count+1;
            drawnow limitrate
        end
    end
end
function updatelims(figH,VehDispHistX,VehDispHistY,figWidth,figBorder,Init)
%#codegen
    coder.extrinsic('set')
    set(0,"currentfigure",figH)
    axH=gca(figH);
    Scale=1;
    XLim=[min(VehDispHistX)-figBorder,max(VehDispHistX)+figBorder];
    rangeX=XLim(2)-XLim(1);
    YLim=[min(VehDispHistY)-figBorder,max(VehDispHistY)+figBorder];
    if Init
        rangeY=YLim(2)-YLim(1);
        figHeight=Scale*figWidth*rangeY/rangeX;

        set(figH,'Position',[0,40,figWidth,figHeight])

        set(figH,'PaperPosition',[0,0,figWidth,figHeight])

        set(figH,'PaperSize',[figWidth,figHeight])

    end
    set(axH,'XLim',XLim)
    set(axH,'YLim',YLim)
end
function[h]=drawArrow(x,y,props,figH)
%#codegen
    coder.extrinsic('annotation')
    h=annotation('arrow');
    set(h,'parent',gca(figH),...
    'position',[x(1),y(1),x(2)-x(1),y(2)-y(1)],...
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
function[FL,FR,RL,RR]=hardpoints(u,theta,w,a,b)
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
    RL(1)=u(1)-b*costheta+w*sintheta;
    RL(2)=u(2)-b*sintheta-w*costheta;
    RR(1)=u(1)-b*costheta-w*sintheta;
    RR(2)=u(2)-b*sintheta+w*costheta;
end