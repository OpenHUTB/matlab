function labelMagnitudes(p)





    S=p.pMagnitudeLabelCoords;


    magVals=p.pMagnitudeTick_Scaled;
    Nt=numel(magVals);
    if Nt>0

        slim=p.pMagnitudeLim_Scaled;
        magNorm=(magVals-slim(1))./(slim(2)-slim(1));

        costh=S.costh;
        sinth=S.sinth;
        txtAng=S.textAngle;







        thresh=p.MagnitudeTickAngleOrientationThreshold;
        ang=S.ang;
        if(abs(ang)<thresh)||(abs(ang+180)<thresh)||(abs(ang-180)<thresh)
            txtAng=0;
        end


















        ht=p.hMagRegionRect;
        if isempty(ht)||~ishghandle(ht)
            ht=patch(...
            'Parent',p.hAxes,...
            'HandleVisibility','off',...
            'FaceAlpha',0.01,...
            'EdgeAlpha',0.01,...
            'FaceColor','w',...
            'EdgeColor','w',...
            'Clipping','on',...
            'Visible','off');
            p.hMagRegionRect=ht;


            b=hggetbehavior(ht,'DataCursor');
            b.Enable=false;
            b=hggetbehavior(ht,'Plotedit');
            b.Enable=false;


            set(ht,'uicontextmenu',p.UIContextMenu_MagTicks);
        end
        x=S.hoverRect.x;
        y=S.hoverRect.y;
        z=0.25*ones(size(x));
        set(ht,...
        'XData',x,...
        'YData',y,...
        'ZData',z);










        txtH=0.04;
        magNorm=magNorm-0.01;
        magNorm(magNorm>(1-txtH))=1-txtH;
        xl=costh*magNorm(:);
        yl=sinth*magNorm(:);
        zl=0.25*ones(size(xl));

        magFontSize=getMagFontSize(p);


        ht=p.hMagText;
        diffNum=Nt~=numel(ht);
        if diffNum
            delete(ht);
        end
        if diffNum||isempty(ht)||~ishghandle(ht(1))
            ht=text(xl,yl,zl,'',...
            'Parent',p.hAxes,...
            'HandleVisibility','off',...
            'FontName',p.FontName,...
            'FontSize',magFontSize,...
            'Clipping','on',...
            'HorizontalAlignment','center');
            p.hMagText=ht;


            for i=1:numel(xl)
                b=hggetbehavior(ht(i),'Plotedit');
                b.Enable=false;
            end


            set(ht,'uicontextmenu',p.UIContextMenu_MagTicks);
        end

        cstr=internal.polariCommon.sprintfMaxNumFracDigits(magVals,2,true);
        for i=1:Nt
            set(ht(i),...
            'Position',[xl(i),yl(i),zl(i)],...
            'String',cstr{i},...
            'Rotation',txtAng,...
            'Color',p.pMagnitudeTickLabelColor);
        end





        ht=p.hMagAxisLocator;
        if isempty(ht)||~ishghandle(ht)
            ht=line(...
            'Parent',p.hAxes,...
            'HandleVisibility','off',...
            'Color',p.GridForegroundColor,...
            'Clipping','on',...
            'Visible','off');
            p.hMagAxisLocator=ht;


            b=hggetbehavior(ht,'Plotedit');
            b.Enable=false;
            b=hggetbehavior(ht,'DataCursor');
            b.Enable=false;


            set(ht,'uicontextmenu',p.UIContextMenu_MagTicks);
        end
        updateMagAxisLocator(p);




    end
    hiliteMagAxisDrag_Update(p);



    ht=p.hMagScale;
    if isempty(ht)||~ishghandle(ht)
        ht=text(0,0,0.25,'',...
        'Parent',p.hAxes,...
        'HandleVisibility','off',...
        'Rotation',0,...
        'FontName',p.FontName,...
        'FontSize',magFontSize,...
        'Clipping','on',...
        'HorizontalAlignment','center');
        p.hMagScale=ht;


        b=hggetbehavior(ht,'Plotedit');
        b.Enable=false;


        set(ht,'uicontextmenu',p.UIContextMenu_MagTicks);
    end





    uStr=strtrim(p.MagnitudeUnits);
    if isempty(uStr)&&(p.pMagnitudeScale==1)
        str='';
    else

        mksUnit=p.pMagnitudeUnits;
        if isempty(uStr)



            str=sprintf('x1e%g',log10(1/p.pMagnitudeScale));
        else

            if any(uStr=='%')

                str=sprintf(uStr,mksUnit);
            else

                str=[mksUnit,uStr];
            end
        end
    end









    lineInTopHalf=(S.ang>=0&&S.ang<=180)||(S.ang==-180);
    if lineInTopHalf

        cstr={'','',str};
    else

        cstr={str,'',''};
    end


    set(ht,...
    'Position',[0,0,.25],...
    'String',cstr,...
    'Color',p.pMagnitudeTickLabelColor);

    overrideMagnitudeTickLabelVis(p,'default');
