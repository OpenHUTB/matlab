function vdynggplot(axyz,gScale,axesType)




%#codegen
    coder.allowpcode('plain')

    persistent cMap colorIndex figH txtbxHndl P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P20 P21 P22 P23 P24 defaultPatchProps
    defaultPatchProps={'FaceAlpha',0.5,...
    'AmbientStrength',0.46,...
    'FaceColor',[0.901960784313726,0.901960784313726,0.901960784313726],...
    'EdgeColor',[0.149019607843137,0.149019607843137,0.149019607843137]};

    switch axesType




    case 1
        ax=-axyz(1);
        ay=-axyz(2);
    case 2
        ax=axyz(1);
        ay=axyz(2);






    otherwise
        ax=axyz(1);
        ay=axyz(2);
    end

    aMag=gScale^0.5*(ax^2+ay^2)^0.5;
    aAng=atan2(ax,ay);
    angSeg=pi/6;
    edge1=0.25*gScale;
    edge2=0.5*gScale;
    edge3=.75*gScale;
    edge4=gScale;
    if isempty(figH)||~ishandle(figH)
        if builtin('license','test','Vehicle_Dynamics_Blockset')
            [~]=builtin('license','checkout','Vehicle_Dynamics_Blockset');
        else
            error(message('autoblks_shared:autosharederrAutoIcon:invalidLicense'));
        end
        R1=edge1*(1-tan(angSeg));
        R2=edge2*(1-tan(angSeg));
        R3=edge3*(1-tan(angSeg));
        R4=edge4*(1-tan(angSeg));
        N=10;



        Cx1=edge1*tan(angSeg);
        Cy1=edge1*tan(angSeg);
        [arc1x,arc1y]=arcgen(Cx1,Cy1,R1,0,pi/2,N);

        Cx2=edge2*tan(angSeg);
        Cy2=edge2*tan(angSeg);
        [arc2x,arc2y]=arcgen(Cx2,Cy2,R2,0,pi/2,N);

        Cx3=edge3*tan(angSeg);
        Cy3=edge3*tan(angSeg);
        [arc3x,arc3y]=arcgen(Cx3,Cy3,R3,0,pi/2,N);

        Cx4=edge4*tan(angSeg);
        Cy4=edge4*tan(angSeg);
        [arc4x,arc4y]=arcgen(Cx4,Cy4,R4,0,pi/2,N);


        P1x=[-edge1*tan(angSeg),edge1*tan(angSeg),edge2*tan(angSeg),-edge2*tan(angSeg)];
        P1y=[edge1,edge1,edge2,edge2];

        P2x=[-edge2*tan(angSeg),edge2*tan(angSeg),edge3*tan(angSeg),-edge3*tan(angSeg)];
        P2y=[edge2,edge2,edge3,edge3];

        P3x=[-edge3*tan(angSeg),edge3*tan(angSeg),edge4*tan(angSeg),-edge4*tan(angSeg)];
        P3y=[edge3,edge3,edge4,edge4];

        P4x=P1x;
        P4y=-P1y;

        P5x=P2x;
        P5y=-P2y;

        P6x=P3x;
        P6y=-P3y;

        P7x=P1y;
        P7y=-P1x;

        P8x=P2y;
        P8y=-P2x;

        P9x=P3y;
        P9y=-P3x;

        P10x=-P7x;
        P10y=P7y;

        P11x=-P8x;
        P11y=P8y;

        P12x=-P9x;
        P12y=P9y;

        screenDims=get(0,'ScreenSize');
        screenWidth=screenDims(3);
        figH=figure('Name','G-diagram','NumberTitle','off','renderer','OpenGL','clipping','off','MenuBar','none','Position',[floor(.75*screenWidth),40,floor(.25*screenWidth),floor(.25*screenWidth)]);
        set(0,"currentfigure",figH)
        Ncolors=10;
        cMap=colormap(jet(Ncolors));
        colorIndex=linspace(0,gScale,Ncolors);
        axH=axes('parent',figH);
        xl=xlabel('Lateral Acceleration [G]');
        yl=ylabel('Longitudinal Acceleration [G]');
        set(xl,'fontsize',15)
        set(yl,'fontsize',15)
        box on;
        set(axH,'FontSize',15);

        P1=patch('XData',P1x,'YData',P1y,defaultPatchProps{:});
        P2=patch('XData',P2x,'YData',P2y,defaultPatchProps{:});
        P3=patch('XData',P3x,'YData',P3y,defaultPatchProps{:});
        P4=patch('XData',P4x,'YData',P4y,defaultPatchProps{:});
        P5=patch('XData',P5x,'YData',P5y,defaultPatchProps{:});
        P6=patch('XData',P6x,'YData',P6y,defaultPatchProps{:});
        P7=patch('XData',P7x,'YData',P7y,defaultPatchProps{:});
        P8=patch('XData',P8x,'YData',P8y,defaultPatchProps{:});
        P9=patch('XData',P9x,'YData',P9y,defaultPatchProps{:});
        P10=patch('XData',P10x,'YData',P10y,defaultPatchProps{:});
        P11=patch('XData',P11x,'YData',P11y,defaultPatchProps{:});
        P12=patch('XData',P12x,'YData',P12y,defaultPatchProps{:});

        P13=patch('XData',[arc1x,fliplr(arc2x)],'YData',[arc1y,fliplr(arc2y)],defaultPatchProps{:});
        P14=patch('XData',[arc2x,fliplr(arc3x)],'YData',[arc2y,fliplr(arc3y)],defaultPatchProps{:});
        P15=patch('XData',[arc3x,fliplr(arc4x)],'YData',[arc3y,fliplr(arc4y)],defaultPatchProps{:});

        P16=patch('XData',-[arc1x,fliplr(arc2x)],'YData',[arc1y,fliplr(arc2y)],defaultPatchProps{:});
        P17=patch('XData',-[arc2x,fliplr(arc3x)],'YData',[arc2y,fliplr(arc3y)],defaultPatchProps{:});
        P18=patch('XData',-[arc3x,fliplr(arc4x)],'YData',[arc3y,fliplr(arc4y)],defaultPatchProps{:});

        P19=patch('XData',-[arc1x,fliplr(arc2x)],'YData',-[arc1y,fliplr(arc2y)],defaultPatchProps{:});
        P20=patch('XData',-[arc2x,fliplr(arc3x)],'YData',-[arc2y,fliplr(arc3y)],defaultPatchProps{:});
        P21=patch('XData',-[arc3x,fliplr(arc4x)],'YData',-[arc3y,fliplr(arc4y)],defaultPatchProps{:});

        P22=patch('XData',[arc1x,fliplr(arc2x)],'YData',-[arc1y,fliplr(arc2y)],defaultPatchProps{:});
        P23=patch('XData',[arc2x,fliplr(arc3x)],'YData',-[arc2y,fliplr(arc3y)],defaultPatchProps{:});
        P24=patch('XData',[arc3x,fliplr(arc4x)],'YData',-[arc3y,fliplr(arc4y)],defaultPatchProps{:});



        set(axH,'XLim',[-1,1].*gScale.*1.1)
        set(axH,'YLim',[-1,1].*gScale.*1.1)
        dim=[0.457142857142857,0.575,0.0,0.0];
        str={[sprintf('%1.1f',aMag),'G']};
        txtbxHndl=annotation('textbox',dim,'String',str,'FitBoxToText','off','LineStyle','none','fontsize',18);
    else
        patchVec=[P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24];
        set(txtbxHndl,'String',[sprintf('%1.1f',aMag),'G']);
        if aMag<.01
            set(patchVec,defaultPatchProps{:});
        else
            newColor=[0,0,0];%#ok<NASGU> % this line shouldn't be needed but SL won't compile without it.
            if aMag>gScale
                aMag=gScale;
            end
            newColor=interp1(colorIndex,cMap,aMag);
            litPatchProps={'FaceColor',newColor};
            if(aAng>=pi/2-angSeg)&&(aAng<=pi/2+angSeg)
                set(P1,litPatchProps{:});
                setSectorColors([P1,P2,P3],defaultPatchProps,litPatchProps,aMag,[edge2,edge3]);
                activePatches=1:3;
            elseif(aAng>angSeg)&&(aAng<=2*angSeg)
                set(P13,litPatchProps{:});
                setSectorColors([P13,P14,P15],defaultPatchProps,litPatchProps,aMag,[edge2,edge3]);
                activePatches=13:15;
            elseif(aAng>=pi/2+angSeg)&&(aAng<pi-angSeg)
                set(P16,litPatchProps{:});
                setSectorColors([P16,P17,P18],defaultPatchProps,litPatchProps,aMag,[edge2,edge3]);
                activePatches=16:18;
            elseif(abs(aAng)<=angSeg)
                set(P7,litPatchProps{:});
                setSectorColors([P7,P8,P9],defaultPatchProps,litPatchProps,aMag,[edge2,edge3]);
                activePatches=7:9;
            elseif(abs(aAng)>=pi-angSeg)
                set(P10,litPatchProps{:});
                setSectorColors([P10,P11,P12],defaultPatchProps,litPatchProps,aMag,[edge2,edge3]);
                activePatches=10:12;
            elseif(aAng<=-pi/2-angSeg)&&(aAng>=-pi+angSeg)
                set(P19,litPatchProps{:});
                setSectorColors([P19,P20,P21],defaultPatchProps,litPatchProps,aMag,[edge2,edge3]);
                activePatches=19:21;
            elseif(aAng<=-angSeg)&&(aAng>=-pi/2+angSeg)
                set(P22,litPatchProps{:});
                setSectorColors([P22,P23,P24],defaultPatchProps,litPatchProps,aMag,[edge2,edge3]);
                activePatches=22:24;
            elseif(aAng>=-pi/2-angSeg)&&(aAng<=-pi/2+angSeg)
                set(P4,litPatchProps{:});
                setSectorColors([P4,P5,P6],defaultPatchProps,litPatchProps,aMag,[edge2,edge3]);
                activePatches=4:6;
            else
                set(patchVec,defaultPatchProps{:});
                activePatches=[];
            end
            inactiveVec=true(1,24);
            inactiveVec(activePatches)=false;
            set(patchVec(inactiveVec),defaultPatchProps{:});
            drawnow limitrate
        end
    end
end
function setSectorColors(patches,defaultPatchProps,litPatchProps,aMag,edges)
    if aMag<edges(1)
        set(patches(2:3),defaultPatchProps{:});
    elseif aMag>=edges(2)
        set(patches(2:3),litPatchProps{:});
    else
        set(patches(2),litPatchProps{:});
        set(patches(3),defaultPatchProps{:});
    end
end
function[xr,yr]=arcgen(Cx,Cy,R,theata1,theata2,N)
    thetas=linspace(theata1,theata2,N);
    xr=R*cos(thetas)+Cx;
    yr=R*sin(thetas)+Cy;
end