function hiliteMagAxisDrag_Update(p,arrowAng)











    action=p.pMagAxisHilite;


    if strcmpi(action,'none')
        return
    end


    hpatch=p.hMagAxisHilite;
    if isempty(hpatch)||~ishghandle(hpatch.up)
        return
    end




    hud=[hpatch.up,hpatch.dn];
    hlr=[hpatch.lt,hpatch.rt];
    hudlr=[hud,hlr];


    ht=p.hMagText;
    if isempty(ht)

        set(hudlr,'Visible','off');
        return
    end

    isUpper=strcmpi(action,'upper');
    isUpperLower=strcmpi(action,'upperlower');

    if p.MagDrag_ChangedMagnitudeLim

        set(hud,'Visible','on');
        set(hlr,'Visible','off');
    elseif p.MagDrag_ChangedAngle

        set(hud,'Visible','off');
        set(hlr,'Visible','on');
    else

        if isUpper
            set(hudlr,'Visible','on');
        else
            set(hud,'Visible','on');
        end
    end


    if isUpperLower
        hh2=ht([1,end]);
    elseif isUpper
        hh2=ht(end);
    else
        hh2=ht(1);
    end




    xUp=zeros(4,numel(ht));
    xDn=xUp;
    xLt=xUp;
    xRt=xUp;
    yUp=xUp;
    yDn=xUp;
    yLt=xUp;
    yRt=xUp;
    zUp=xUp;
    zDn=xUp;
    zLt=xUp;
    zRt=xUp;

    for j=1:numel(hh2)
        hh=hh2(j);


        origRot=hh.Rotation;
        origStr=hh.String;


        hh.Rotation=0;
        if isscalar(origStr)
            hh.String=['0',origStr];
        end
        ext=hh.Extent;
        hh.Rotation=origRot;
        hh.String=origStr;









        if nargin>1
            th=arrowAng*pi/180-pi/2;
        else
            S=p.pMagnitudeLabelCoords;
            th=(S.ang-90)*pi/180;
        end
        rotccw=[cos(th),-sin(th);sin(th),cos(th)];









        Nparts=4;
        x=NaN(4,Nparts);
        y=NaN(4,Nparts);






        rmin=min(ext(3:4));



        xe=ext(3)/2+max(0.02,0.05*ext(3));
        ye=ext(4)/2+max(0.01,0.03*ext(4));




        u=hpatch.up.UserData;
        for i=1:Nparts

            u_i=u{i}*rmin;



            if i==1
                u_i(2,:)=u_i(2,:)+ye;
            elseif i==2
                u_i(2,:)=u_i(2,:)-ye;
            elseif i==3
                u_i(1,:)=u_i(1,:)-xe;
            else
                u_i(1,:)=u_i(1,:)+xe;
            end


            p_i=rotccw*u_i;
            x(:,i)=p_i(1,:)';
            y(:,i)=p_i(2,:)';
        end


        pos=hh.Position;
        x=x+pos(1);
        y=y+pos(2);
        z=y;


        z(~isnan(z))=0.294;

        xUp(:,j)=x(:,1);
        xDn(:,j)=x(:,2);
        xLt(:,j)=x(:,3);
        xRt(:,j)=x(:,4);

        yUp(:,j)=y(:,1);
        yDn(:,j)=y(:,2);
        yLt(:,j)=y(:,3);
        yRt(:,j)=y(:,4);

        zUp(:,j)=z(:,1);
        zDn(:,j)=z(:,2);
        zLt(:,j)=z(:,3);
        zRt(:,j)=z(:,4);
    end







    if p.MagTickUpDnArrowColor==2



        ttc=internal.ColorConversion.getBWContrast(p.GridBackgroundColor);
        fc={ttc,ttc};
...
...
...
...
...
...
...
        fc=internal.ColorConversion.getRGBFromColor(fc);
        ec=[1,1,1;1,1,1];

    elseif p.MagTickUpDnArrowColor==1

        if isUpperLower
            fc={p.pMagnitudeTickLabelColor,p.pMagnitudeTickLabelColor};
        elseif isUpper
            fc={p.pMagnitudeTickLabelColor,p.GridBackgroundColor};
        else
            fc={p.GridBackgroundColor,p.pMagnitudeTickLabelColor};
        end
        fc=internal.ColorConversion.getRGBFromColor(fc);
        ec=fc;
    else


        fc=internal.ColorConversion.getRGBFromColor(p.GridBackgroundColor);
        fc=[fc;fc];
        ec=internal.ColorConversion.getRGBFromColor(p.pMagnitudeTickLabelColor);
        ec=[ec;ec];



        Nticks=numel(ht);
        Nvis=numel(hh2);
        if Nvis==1
            if Nticks==1
                if isUpper
                    fc(1,:)=ec(1,:);
                elseif~isUpperLower
                    fc(2,:)=ec(1,:);
                end
            end
        else
        end
    end


    set(hpatch.up,...
    'FaceColor',fc(1,:),...
    'EdgeColor',ec(2,:),...
    'XData',xUp,...
    'YData',yUp,...
    'ZData',zUp);
    set(hpatch.dn,...
    'FaceColor',fc(2,:),...
    'EdgeColor',ec(1,:),...
    'XData',xDn,...
    'YData',yDn,...
    'ZData',zDn);
    set(hpatch.lt,...
    'XData',xLt,...
    'YData',yLt,...
    'ZData',zLt);
    set(hpatch.rt,...
    'XData',xRt,...
    'YData',yRt,...
    'ZData',zRt);
end
