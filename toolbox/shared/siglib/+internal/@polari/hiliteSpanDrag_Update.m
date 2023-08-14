function hiliteSpanDrag_Update(p)





    hpatch=p.hSpanHilite;
    hspan=p.hAngleSpan;
    if isempty(hspan)

        hpatch.Visible='off';
        return
    end








    if isCloserToSpanStart(p,p.SpanDrag_PrevCplx)

        spanSide='end';
    else

        spanSide='start';
    end



    s=markersSurroundingSpan(p);
















    Noutside=numel(s.outside);
    Ninside=numel(s.inside);
    if strcmpi(spanSide,'start')
        if Ninside>0&&Noutside>0
            edgeDir='both';
        elseif Ninside>0
            edgeDir='cw';
        elseif Noutside>0
            edgeDir='ccw';
        else
            edgeDir='none';
        end
    else
        if Ninside>0&&Noutside>0
            edgeDir='both';
        elseif Ninside>0
            edgeDir='ccw';
        elseif Noutside>0
            edgeDir='cw';
        else
            edgeDir='none';
        end
    end




    switch edgeDir
    case 'ccw'
        dirIdx=1;
    case 'cw'
        dirIdx=2;
    case 'both'
        dirIdx=[1,2];
    case 'none'
        dirIdx=[];
    end

    if isempty(dirIdx)
        hpatch.Visible='off';
        return
    end



    if strcmpi(spanSide,'start')
        sideIdx=2;
    else
        sideIdx=1;
    end




    Narrows=numel(dirIdx);
    xA=zeros(4,Narrows);
    yA=xA;
    zA=xA;

    for j=1:Narrows



        c_j=hspan.SpanCplx{sideIdx};
        th=angle(c_j);


        rotccw=[cos(th),-sin(th);sin(th),cos(th)];






        rmin=0.08;
        ye=0.015;








        u=hpatch.UserData;


        arrow_i=dirIdx(j);
        u_i=u{arrow_i}*rmin;
        if arrow_i==1
            u_i(2,:)=u_i(2,:)+ye;
        else
            u_i(2,:)=u_i(2,:)-ye;
        end

        p_i=rotccw*u_i;



        r0=0.7;
        xA(:,j)=p_i(1,:)'+r0*real(c_j);
        yA(:,j)=p_i(2,:)'+r0*imag(c_j);
        zA(:,j)=0.25*ones(4,1);
    end


    fc=internal.ColorConversion.getRGBFromColor(p.GridBackgroundColor);
    ec=internal.ColorConversion.getRGBFromColor(p.pMagnitudeTickLabelColor);


    set(hpatch,...
    'FaceColor',fc,...
    'EdgeColor',ec,...
    'XData',xA,...
    'YData',yA,...
    'ZData',zA,...
    'Visible','on');
