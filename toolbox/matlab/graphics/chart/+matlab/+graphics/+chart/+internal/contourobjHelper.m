function varargout=contourobjHelper(functionName,varargin)






    narginchk(1,inf);

    if~matlab.graphics.internal.isCharOrString(functionName)
        error(message('MATLAB:contourobjHelper:firstInputString'));
    end

    switch(functionName)
    case 'parseargs'
        try
            [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}]=localParseargs(varargin{:});
        catch ME
            throwAsCaller(ME);
        end
    case 'contourLabelScaleParams'
        [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}]=localContourLabelScaleParams(varargin{:});
    case 'contourLabelRenderParams'
        [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6},varargout{7}]=localContourLabelRenderParams(varargin{:});
    case 'placelabels'
        [varargout{1},varargout{2}]=localPlaceLabels(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8});
    end
end

function[pvpairs,args,nargs,errmsg,warnmsg]=localParseargs(varargin)

    bmin=varargin{1};
    args=varargin(2:end);


    errmsg='';
    warnmsg='';

    allow_xy_nans=true;


    [args,pvpairs]=parseparams(args);
    pvpairs=matlab.graphics.internal.convertStringToCharArgs(pvpairs);

    if~isempty(pvpairs)
        [~,~,~,tmsg]=colstyle(pvpairs{1});
        if isempty(tmsg)
            args=[args,pvpairs(1)];
            pvpairs=pvpairs(2:end);
        end
        errmsg=matlab.graphics.chart.internal.checkpvpairs(pvpairs);
    end


    nargs=length(args);
    if nargs>0&&matlab.graphics.internal.isCharOrString(args{end})
        [lStyle,lColor,~,tmsg]=colstyle(args{end});
        if~isempty(tmsg)
            errmsg=getString(message('MATLAB:uistring:contourobjhelper:UnknownOption',args{end}));
        end
        if~isempty(lColor)
            pvpairs=[{'LineColor'},{lColor},pvpairs];
        end
        if~isempty(lStyle)
            pvpairs=[{'LineStyle'},{lStyle},pvpairs];
        end
        nargs=nargs-1;
    end


    x=[];
    y=[];
    z=[];
    l=[];


    levelarg=false;
    if(nargs==3)||(nargs==4)




        x=matlab.graphics.chart.internal.datachk(args{1});
        y=matlab.graphics.chart.internal.datachk(args{2});
        z=matlab.graphics.chart.internal.datachk(args{3});
        if(nargs==4)
            l=matlab.graphics.chart.internal.datachk(args{4});
            levelarg=true;
        end
    elseif(nargs==1)||(nargs==2)




        z=matlab.graphics.chart.internal.datachk(args{1});
        if(nargs==2)
            l=matlab.graphics.chart.internal.datachk(args{2});
            levelarg=true;
        end
    end


    for i=1:nargs
        if~isreal(args{i})
            error(message('MATLAB:contour:InputsMustBeReal'));
        end
        if ndims(args{i})>2
            error(message('MATLAB:contour:InputsMustHaveAtMost2Dimensions'));
        end
    end






    if~isempty(z)&&isvector(z)
        errmsg=message(...
        'MATLAB:contour:ZMustBeAtLeast2x2Matrix');
        return;
    end


    if isscalar(x)
        errmsg=message(...
        'MATLAB:contour:XMustNotBeScalar');
        return;
    end
    if isscalar(y)
        errmsg=message(...
        'MATLAB:contour:YMustNotBeScalar');
        return;
    end


    if~isempty(l)&&~isvector(l)
        errmsg=message(...
        'MATLAB:contour:LMustBeVectorOrScalar');
        return;
    end


    if(nargs>2)
        if isempty(z)
            if(~isempty(x)&&~isempty(y))
                errmsg=message(...
                'MATLAB:contour:LengthOfXandYMustMatchColsAndRowsInZ');
                return;
            elseif~isempty(x)
                errmsg=message(...
                'MATLAB:contour:LengthOfXMustMatchColsInZ');
                return;
            elseif~isempty(y)
                errmsg=message(...
                'MATLAB:contour:LengthOfYMustMatchRowsInZ');
                return;
            end
        else
            errmsg=matlab.graphics.chart.internal.xyzcheck(x,y,z);
            if~isempty(errmsg)
                return
            end
        end
    end

    if any(isnan(l))
        errmsg=message(...
        'MATLAB:contour:LMustBeFinite');
        return;
    end

    if isvector(x)
        if~isempty(find(~isfinite(x),1))
            errmsg=message(...
            'MATLAB:contour:XMustBeFinite');
            return;
        end

        diffx=diff(x);
        if any(diffx<=0)&&any(diffx>=0)
            errmsg=message(...
            'MATLAB:contour:VectorXMustBeUniqueMonotone');
            return;
        end
    elseif~allow_xy_nans
        if~isempty(find(~isfinite(x),1))
            errmsg=message(...
            'MATLAB:contour:XMustBeFinite');
            return;
        end
    end

    if isvector(y)
        if~isempty(find(~isfinite(y),1))
            errmsg=message(...
            'MATLAB:contour:YMustBeFinite');
            return;
        end

        diffy=diff(y);
        if any(diffy<=0)&&any(diffy>=0)
            errmsg=message(...
            'MATLAB:contour:VectorYMustBeUniqueMonotone');
            return;
        end
    elseif~allow_xy_nans
        if~isempty(find(~isfinite(y),1))
            errmsg=message(...
            'MATLAB:contour:YMustBeFinite');
            return;
        end
    end


    nLevels=0;
    nl=numel(l);
    if nl>0
        if(nl==1)
            nLevels=l(1);
            if(nLevels<0)
                errmsg=message(...
                'MATLAB:contour:NMustNotBeNegative');
                return;
            end
            nLevels=fix(nLevels);
        elseif(nl==2)&&(l(1)==l(2))
            nLevels=1;
        else
            nLevels=nl;
        end
    end


    if isempty(z)
        return
    end


    k=find(isfinite(z));
    zmin=min(z(k));
    zmax=max(z(k));



    if isempty(k)
        warnmsg=message('MATLAB:contour:NonFiniteData');
        if(nl==1)

            levelarg=false;
        end
    elseif(zmin==zmax)
        warnmsg=message('MATLAB:contour:ConstantData');
    end


    if(nargs>2)
        pvpairs=[{'XData'},{x},{'YData'},{y},{'ZData'},{z},pvpairs];
        args(1:3)=[];
        nargs=nargs-3;
    else
        pvpairs=[{'ZData'},{z},pvpairs];
        args(1)=[];
        nargs=nargs-1;
    end


    if levelarg
        if(nl==1)
            if nLevels==1
                levels=(zmin+zmax)/2;
            else
                levels=linspace(zmin,zmax,nLevels+2);
                levels=levels(2:end-1);
            end
            if bmin
                levels=[zmin,levels];
            end
        else
            levels=l(1:nLevels);
        end
        pvpairs=[{'LevelList'},{levels},pvpairs];
        args(1)=[];
        nargs=nargs-1;
    end
end

function[xDir,yDir,axScaleXPos,axScaleYPos,dummyExtent]=localContourLabelScaleParams(cax,xLim,yLim)
    if(strcmp(get(cax,'XDir'),'reverse'))
        xDir=-1;
    else
        xDir=1;
    end
    if(strcmp(get(cax,'YDir'),'reverse'))
        yDir=-1;
    else
        yDir=1;
    end








    parent=get(cax,'Parent');
    axUnits=get(cax,'Units');
    posProp='Position_I';
    if strcmp(axUnits,'normalized')&&strcmp(get(parent,'Type'),'figure')
        axUnits=get(parent,'Units');
        set(parent,'Units','points');
        axPos=get(parent,'Position');
        set(parent,'Units',axUnits);
        axPos=axPos.*get(cax,posProp);
    else
        axPos=hgconvertunits(ancestor(parent,'figure'),get(cax,posProp),...
        axUnits,'points',parent);
    end


    axScaleXPos=axPos(3)/diff(xLim);
    axScaleYPos=axPos(4)/diff(yLim);



    dummyExtent=5.65;
end

function[bValid,zLevel,lab,lp,xc,yc,trot]=localContourLabelRenderParams(cs,i,k,labels,dummyExtent,xDir,yDir,axScaleXPos,axScaleYPos,bManual,p,labelSpacing,textList,getStartParam)

    lp=0;
    xc=[];
    yc=[];
    trot=[];

    zLevel=cs(1,i);
    nPoints=cs(2,i);
    xp=cs(1,i+(1:nPoints));
    yp=cs(2,i+(1:nPoints));


    lab=labels(k,labels(k,:)~=' ');

    len_lab=dummyExtent/2*length(lab)/size(labels,2);



    sx=xp*axScaleXPos;
    sy=yp*axScaleYPos;
    d=[0,sqrt(diff(sx).^2+diff(sy).^2)];

    section=cumsum(isnan(d));
    d(isnan(d))=0;
    d=cumsum(d);

    if bManual
        psn=min(max(max(d(p),d(2)+eps*d(2)),d(1)+len_lab),d(end)-len_lab);
        psn=max(0,min(psn,max(d)));
        bValid=true;
    else
        len_contour=max(0,d(nPoints)-3*len_lab);
        slop=(len_contour-floor(len_contour/labelSpacing)*labelSpacing);
        start=1.5*len_lab+max(len_lab,slop)*getStartParam();
        psn=start:labelSpacing:d(nPoints)-1.5*len_lab;
        bValid=(isempty(textList)||any(abs(zLevel-textList)/max(eps+abs(textList))<.00001));
    end

    if~bValid
        return
    end

    lp=size(psn,2);
    bValid=(lp>0)&&isfinite(zLevel);

    if~bValid
        return
    end

    Ic=sum(d(ones(1,lp),:)'<psn(ones(1,nPoints),:),1);
    Il=sum(d(ones(1,lp),:)'<=psn(ones(1,nPoints),:)-len_lab,1);
    Ir=sum(d(ones(1,lp),:)'<psn(ones(1,nPoints),:)+len_lab,1);


    out=(Ir<1|Ir>length(d)-1)|...
    (Il<1|Il>length(d)-1)|...
    (Ic<1|Ic>length(d)-1);
    Ir=max(1,min(Ir,length(d)-1));
    Il=max(1,min(Il,length(d)-1));
    Ic=max(1,min(Ic,length(d)-1));


    Il(out)=Ic(out);
    Ir(out)=Ic(out);


    bad=(section(Il)~=section(Ir));
    Il(bad)=[];
    Ir(bad)=[];
    Ic(bad)=[];
    psn(:,bad)=[];
    out(bad)=[];
    lp=length(Il);
    in=~out;

    bValid=~isempty(Il);
    if~bValid
        return
    end


    wl=(d(Il+1)-psn+len_lab.*in)./(d(Il+1)-d(Il));
    wr=(psn-len_lab.*in-d(Il))./(d(Il+1)-d(Il));
    xl=xp(Il).*wl+xp(Il+1).*wr;
    yl=yp(Il).*wl+yp(Il+1).*wr;

    wl=(d(Ir+1)-psn-len_lab.*in)./(d(Ir+1)-d(Ir));
    wr=(psn+len_lab.*in-d(Ir))./(d(Ir+1)-d(Ir));
    xr=xp(Ir).*wl+xp(Ir+1).*wr;
    yr=yp(Ir).*wl+yp(Ir+1).*wr;

    trot=atan2((yr-yl)*yDir*axScaleYPos,(xr-xl)*xDir*axScaleXPos)*180/pi;
    backang=abs(trot)>90;
    trot(backang)=trot(backang)+180;


    wl=(d(Ic+1)-psn)./(d(Ic+1)-d(Ic));
    wr=(psn-d(Ic))./(d(Ic+1)-d(Ic));
    xc=xp(Ic).*wl+xp(Ic+1).*wr;
    yc=yp(Ic).*wl+yp(Ic+1).*wr;


    shiftfrac=.5;

    xc=xc*(1-shiftfrac)+(xr+xl)/2*shiftfrac;
    yc=yc*(1-shiftfrac)+(yr+yl)/2*shiftfrac;
end

function[label_out,cut_out]=localPlaceLabels(contour,perform_cut,cax,~,ptch_in,...
    getAxesPosition,getStringBounds,getStartParam)










    label_out=[];
    cut_out=[];

    if isempty(contour)
        return;
    end

    CS=contour.contourmatrix;
    v=unique(contour.textlist);
    lab_int=contour.labelspacing;

    if(strcmp(cax.XDir,'reverse'))
        XDir=-1;
    else
        XDir=1;
    end
    if(strcmp(cax.YDir,'reverse'))
        YDir=-1;
    else
        YDir=1;
    end

    PA=getAxesPosition();



    lCS=size(CS,2);

    XL=cax.XLim;
    YL=cax.YLim;

    Aspx=PA(3)/diff(XL);

    Aspy=PA(4)/diff(YL);



    labels=getlabels(CS);


    EX=getStringBounds(repmat('9',1,size(labels,2)));

    ii=1;k=0;
    while(ii<lCS)
        k=k+1;

        l=CS(2,ii);
        x=CS(1,ii+(1:l));
        y=CS(2,ii+(1:l));

        lvl=CS(1,ii);


        lab=labels(k,labels(k,:)~=' ');

        len_lab=EX(3)/2*length(lab)/size(labels,2);



        sx=x*Aspx;
        sy=y*Aspy;
        d=[0,sqrt(diff(sx).^2+diff(sy).^2)];

        section=cumsum(isnan(d));
        d(isnan(d))=0;
        d=cumsum(d);

        len_contour=max(0,d(l)-3*len_lab);
        slop=(len_contour-floor(len_contour/lab_int)*lab_int);
        start=1.5*len_lab+max(len_lab,slop)*getStartParam();
        psn=start:lab_int:d(l)-1.5*len_lab;
        oldbreaks=ptch_in(k).LevelBreaks;
        psn=sort([oldbreaks,psn]);
        lp=size(psn,2);

        if(lp>0)&&isfinite(lvl)&&...
            (isempty(v)||any(abs(lvl-v)/max(eps+abs(v))<.00001))

            Ic=sum(d(ones(1,lp),:)'<psn(ones(1,l),:),1);
            Il=sum(d(ones(1,lp),:)'<=psn(ones(1,l),:)-len_lab,1);
            Ir=sum(d(ones(1,lp),:)'<psn(ones(1,l),:)+len_lab,1);


            out=(Ir<1|Ir>length(d)-1)|...
            (Il<1|Il>length(d)-1)|...
            (Ic<1|Ic>length(d)-1);
            Ir=max(1,min(Ir,length(d)-1));
            Il=max(1,min(Il,length(d)-1));
            Ic=max(1,min(Ic,length(d)-1));


            Il(out)=Ic(out);
            Ir(out)=Ic(out);


            bad=(section(Il)~=section(Ir));
            Il(bad)=[];
            Ir(bad)=[];
            Ic(bad)=[];
            psn(:,bad)=[];
            out(bad)=[];
            lp=length(Il);
            in=~out;

            if~isempty(Il)


                wl=(d(Il+1)-psn+len_lab.*in)./(d(Il+1)-d(Il));
                wr=(psn-len_lab.*in-d(Il))./(d(Il+1)-d(Il));
                xl=x(Il).*wl+x(Il+1).*wr;
                yl=y(Il).*wl+y(Il+1).*wr;

                wl=(d(Ir+1)-psn-len_lab.*in)./(d(Ir+1)-d(Ir));
                wr=(psn+len_lab.*in-d(Ir))./(d(Ir+1)-d(Ir));
                xr=x(Ir).*wl+x(Ir+1).*wr;
                yr=y(Ir).*wl+y(Ir+1).*wr;

                trot=atan2((yr-yl)*YDir*Aspy,(xr-xl)*XDir*Aspx)*180/pi;
                backang=abs(trot)>90;
                trot(backang)=trot(backang)+180;


                wl=(d(Ic+1)-psn)./(d(Ic+1)-d(Ic));
                wr=(psn-d(Ic))./(d(Ic+1)-d(Ic));
                xc=x(Ic).*wl+x(Ic+1).*wr;
                yc=y(Ic).*wl+y(Ic+1).*wr;


                shiftfrac=.5;

                xc=xc*(1-shiftfrac)+(xr+xl)/2*shiftfrac;
                yc=yc*(1-shiftfrac)+(yr+yl)/2*shiftfrac;




                dr=d(Ir)+sqrt(((xr-x(Ir))*Aspx).^2+((yr-y(Ir))*Aspy).^2);
                dl=d(Il)+sqrt(((xl-x(Il))*Aspx).^2+((yl-y(Il))*Aspy).^2);












                f1=accumarray([ones(lp,1),Il.'],ones(1,lp),[1,l]);
                f2=accumarray([ones(lp,1),Ir.'],ones(1,lp),[1,l]);
                irem=find(cumsum(f1)-cumsum(f2))+1;
                x(irem)=[];
                y(irem)=[];
                d(irem)=[];
                l=l-size(irem,2);



                xf=[x(1:l),xl,NaN(size(xc)),xr];
                yf=[y(1:l),yl,yc,yr];

                [~,If]=sort([d(1:l),dl,psn,dr]);






                z=ptch_in(k).ZData;
                offset=numel(cut_out);
                if perform_cut

                    cut_out(offset+1).Segment=k;
                    cut_out(offset+1).XData=xf;
                    cut_out(offset+1).YData=yf;
                    cut_out(offset+1).ZData=z;
                    cut_out(offset+1).Indices=If;
                    cut_out(offset+1).Level=lvl;
                end

                offset=numel(label_out);
                for jj=1:lp
                    label_out(offset+jj).String=lab;
                    label_out(offset+jj).Position=[xc(jj),yc(jj),0];
                    label_out(offset+jj).Rotation=trot(jj);
                    label_out(offset+jj).Level=lvl;
...
...
...
...
...
...
...
...
...
                end
            end
        end

        ii=ii+1+CS(2,ii);
    end



end

function labels=getlabels(CS)

    v=[];i=1;
    while i<size(CS,2)
        v=[v,CS(1,i)];
        i=i+CS(2,i)+1;
    end
    labels=num2str(v');
end

