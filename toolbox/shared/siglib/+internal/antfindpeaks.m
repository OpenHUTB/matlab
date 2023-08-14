function[Ypk,Xpk,Wpk,Ppk]=antfindpeaks(Yin,varargin)

    cond=nargin>=1;
    if~cond
        coder.internal.assert(cond,'MATLAB:narginchk:notEnoughInputs');
    end

    cond=nargin<=22;
    if~cond
        coder.internal.assert(cond,'MATLAB:narginchk:tooManyInputs');
    end


    [y,yIsRow,x,xIsRow,minH,minP,minW,maxW,minD,minT,maxN,sortDir,annotate,refW]...
    =parse_inputs(Yin,varargin{:});


    [iFinite,iInfite,iInflect]=getAllPeaks(y);



    iPk=removePeaksBelowMinPeakHeight(y,iFinite,minH,refW);
    iPk=removePeaksBelowThreshold(y,iPk,minT);


    needWidth=minW>0||maxW<inf||minP>0||nargout>2||strcmp(annotate,'extents');

    if needWidth



        [iPk,bPk,bxPk,byPk,wxPk]=findExtents(y,x,iPk,iFinite,iInfite,iInflect,minP,minW,maxW,refW);
    else

        [iPk,bPk,bxPk,byPk,wxPk]=combinePeaks(iPk,iInfite);
    end


    idx=findPeaksSeparatedByMoreThanMinPeakDistance(y,x,iPk,minD);


    idx=orderPeaks(y,iPk,idx,sortDir);
    idx=keepAtMostNpPeaks(idx,maxN);


    iPk=iPk(idx);
    if needWidth
        [bPk,bxPk,byPk,wxPk]=fetchPeakExtents(idx,bPk,bxPk,byPk,wxPk);
    end

    if nargout>0

        if needWidth
            [Ypk,Xpk,Wpk,Ppk]=assignFullOutputs(y,x,iPk,wxPk,bPk,yIsRow,xIsRow);
        else
            [Ypk,Xpk]=assignOutputs(y,x,iPk,yIsRow,xIsRow);
        end
    else

        hAxes=plotSignalWithPeaks(x,y,iPk);
        if strcmp(annotate,'extents')
            plotExtents(hAxes,x,y,iPk,bPk,bxPk,byPk,wxPk,refW);
        end

        scalePlot(hAxes);
    end


    function[y,yIsRow,x,xIsRow,Ph,Pp,Wmin,Wmax,Pd,Th,NpOut,Str,Ann,Ref]=parse_inputs(Yin,varargin)


        validateattributes(Yin,{'numeric'},{'nonempty','real','vector'},...
        'findpeaks','Y');
        yIsRow=isrow(Yin);
        y=Yin(:);


        xIsRow=yIsRow;


        hasX=~isempty(varargin)&&isnumeric(varargin{1});

        if hasX
            startArg=2;
            if isscalar(varargin{1})

                Fs=varargin{1};
                validateattributes(Fs,{'double'},{'real','finite','positive'},'findpeaks','Fs');
                x=(0:numel(y)-1).'/Fs;
            else

                Xin=varargin{1};
                validateattributes(Xin,{'double'},{'real','finite','vector','increasing'},'findpeaks','X');
                if numel(Xin)~=numel(Yin)





                end
                xIsRow=isrow(Xin);
                x=Xin(:);
            end
        else
            startArg=1;

            x=(1:numel(y)).';
        end














        M=numel(y);
        cond=(M<3);




%#function dspopts.findpeaks
        defaultMinPeakHeight=-inf;
        defaultMinPeakProminence=0;
        defaultMinPeakWidth=0;
        defaultMaxPeakWidth=Inf;
        defaultMinPeakDistance=0;
        defaultThreshold=0;
        defaultNPeaks=[];
        defaultSortStr='none';
        defaultAnnotate='peaks';
        defaultWidthReference='halfprom';

        if coder.target('MATLAB')
            p=inputParser;
            addParameter(p,'MinPeakHeight',defaultMinPeakHeight);
            addParameter(p,'MinPeakProminence',defaultMinPeakProminence);
            addParameter(p,'MinPeakWidth',defaultMinPeakWidth);
            addParameter(p,'MaxPeakWidth',defaultMaxPeakWidth);
            addParameter(p,'MinPeakDistance',defaultMinPeakDistance);
            addParameter(p,'Threshold',defaultThreshold);
            addParameter(p,'NPeaks',defaultNPeaks);
            addParameter(p,'SortStr',defaultSortStr);
            addParameter(p,'Annotate',defaultAnnotate);
            addParameter(p,'WidthReference',defaultWidthReference);
            parse(p,varargin{startArg:end});
            Ph=p.Results.MinPeakHeight;
            Pp=p.Results.MinPeakProminence;
            Wmin=p.Results.MinPeakWidth;
            Wmax=p.Results.MaxPeakWidth;
            Pd=p.Results.MinPeakDistance;
            Th=p.Results.Threshold;
            Np=p.Results.NPeaks;
            Str=p.Results.SortStr;
            Ann=p.Results.Annotate;
            Ref=p.Results.WidthReference;
        else
            parms=struct('MinPeakHeight',uint32(0),...
            'MinPeakProminence',uint32(0),...
            'MinPeakWidth',uint32(0),...
            'MaxPeakWidth',uint32(0),...
            'MinPeakDistance',uint32(0),...
            'Threshold',uint32(0),...
            'NPeaks',uint32(0),...
            'SortStr',uint32(0),...
            'Annotate',uint32(0),...
            'WidthReference',uint32(0));
            pstruct=eml_parse_parameter_inputs(parms,[],varargin{startArg:end});
            Ph=eml_get_parameter_value(pstruct.MinPeakHeight,defaultMinPeakHeight,varargin{startArg:end});
            Pp=eml_get_parameter_value(pstruct.MinPeakProminence,defaultMinPeakProminence,varargin{startArg:end});
            Wmin=eml_get_parameter_value(pstruct.MinPeakWidth,defaultMinPeakWidth,varargin{startArg:end});
            Wmax=eml_get_parameter_value(pstruct.MaxPeakWidth,defaultMaxPeakWidth,varargin{startArg:end});
            Pd=eml_get_parameter_value(pstruct.MinPeakDistance,defaultMinPeakDistance,varargin{startArg:end});
            Th=eml_get_parameter_value(pstruct.Threshold,defaultThreshold,varargin{startArg:end});
            Np=eml_get_parameter_value(pstruct.NPeaks,defaultNPeaks,varargin{startArg:end});
            Str=eml_get_parameter_value(pstruct.SortStr,defaultSortStr,varargin{startArg:end});
            Ann=eml_get_parameter_value(pstruct.Annotate,defaultAnnotate,varargin{startArg:end});
            Ref=eml_get_parameter_value(pstruct.WidthReference,defaultWidthReference,varargin{startArg:end});
        end


        if isempty(Np)
            NpOut=M;
        else
            NpOut=Np;
        end


        if strcmp(Ref,'halfheight')
            Ph=max(Ph,0);
        end

        validateattributes(Ph,{'numeric'},{'real','scalar','nonempty'},'findpeaks','MinPeakHeight');
        validateattributes(Pd,{'numeric'},{'real','scalar','nonempty','nonnegative','<',x(M)-x(1)},'findpeaks','MinPeakDistance');
        validateattributes(Pp,{'numeric'},{'real','scalar','nonempty','nonnegative'},'findpeaks','MinPeakProminence');
        validateattributes(Wmin,{'numeric'},{'real','scalar','finite','nonempty','nonnegative'},'findpeaks','MinPeakWidth');
        validateattributes(Wmax,{'numeric'},{'real','scalar','nonnan','nonempty','nonnegative'},'findpeaks','MaxPeakWidth');
        validateattributes(Pd,{'numeric'},{'real','scalar','nonempty','nonnegative'},'findpeaks','MinPeakDistance');
        validateattributes(Th,{'numeric'},{'real','scalar','nonempty','nonnegative'},'findpeaks','Threshold');
        validateattributes(NpOut,{'numeric'},{'real','scalar','nonempty','integer','positive'},'findpeaks','NPeaks');
        Str=validatestring(Str,{'ascend','none','descend'},'findpeaks','SortStr');
        Ann=validatestring(Ann,{'peaks','extents'},'findpeaks','SortStr');
        Ref=validatestring(Ref,{'halfprom','halfheight'},'findpeaks','WidthReference');


        function[iPk,iInf,iInflect]=getAllPeaks(y)

            iInf=find(isinf(y)&y>0);


            yTemp=y;
            yTemp(iInf)=NaN;


            [iPk,iInflect]=findLocalMaxima(yTemp);



            function[iPk,iInflect]=findLocalMaxima(yTemp)

                yTemp=[NaN;yTemp;NaN];
                iTemp=(1:numel(yTemp)).';


                yFinite=~isnan(yTemp);
                iNeq=[1;1+find((yTemp(1:end-1)~=yTemp(2:end))&...
                (yFinite(1:end-1)|yFinite(2:end)))];
                iTemp=iTemp(iNeq);


                s=sign(diff(yTemp(iTemp)));


                iMax=1+find(diff(s)<0);


                iAny=1+find(s(1:end-1)~=s(2:end));


                iInflect=iTemp(iAny)-1;
                iPk=iTemp(iMax)-1;


                function iPk=removePeaksBelowMinPeakHeight(Y,iPk,Ph,widthRef)
                    if~isempty(iPk)
                        iPk=iPk(Y(iPk)>Ph);





                    end


                    function iPk=removePeaksBelowThreshold(Y,iPk,Th)

                        base=max(Y(iPk-1),Y(iPk+1));
                        iPk=iPk(Y(iPk)-base>=Th);


                        function[iPk,bPk,bxPk,byPk,wxPk]=findExtents(y,x,iPk,iFin,iInf,iInflect,minP,minW,maxW,refW)

                            yFinite=y;
                            yFinite(iInf)=NaN;


                            [bPk,iLB,iRB]=getPeakBase(yFinite,iPk,iFin,iInflect);


                            [iPk,bPk,iLB,iRB]=removePeaksBelowMinPeakProminence(yFinite,iPk,bPk,iLB,iRB,minP);


                            [wxPk,iLBh,iRBh]=getPeakWidth(yFinite,x,iPk,bPk,iLB,iRB,refW);


                            [iPk,bPk,bxPk,byPk,wxPk]=combineFullPeaks(y,x,iPk,bPk,iLBh,iRBh,wxPk,iInf);


                            [iPk,bPk,bxPk,byPk,wxPk]=removePeaksOutsideWidth(iPk,bPk,bxPk,byPk,wxPk,minW,maxW);



                            function[peakBase,iLeftSaddle,iRightSaddle]=getPeakBase(yTemp,iPk,iFin,iInflect)

                                [iLeftBase,iLeftSaddle]=getLeftBase(yTemp,iPk,iFin,iInflect);
                                [iRightBase,iRightSaddle]=getLeftBase(yTemp,flipud(iPk),flipud(iFin),flipud(iInflect));
                                iRightBase=flipud(iRightBase);
                                iRightSaddle=flipud(iRightSaddle);
                                peakBase=max(yTemp(iLeftBase),yTemp(iRightBase));


                                function[iBase,iSaddle]=getLeftBase(yTemp,iPeak,iFinite,iInflect)

                                    iBase=zeros(size(iPeak));
                                    iSaddle=zeros(size(iPeak));


                                    peak=zeros(size(iFinite));
                                    valley=zeros(size(iFinite));
                                    iValley=zeros(size(iFinite));

                                    n=0;
                                    i=1;
                                    j=1;
                                    k=1;


                                    v=NaN;
                                    iv=1;

                                    while k<=numel(iPeak)

                                        while iInflect(i)~=iFinite(j)
                                            v=yTemp(iInflect(i));
                                            iv=iInflect(i);
                                            if isnan(v)

                                                n=0;
                                            else

                                                while n>0&&valley(n)>v;
                                                    n=n-1;
                                                end
                                            end
                                            i=i+1;
                                        end

                                        p=yTemp(iInflect(i));


                                        while n>0&&peak(n)<p
                                            if valley(n)<v
                                                v=valley(n);
                                                iv=iValley(n);
                                            end
                                            n=n-1;
                                        end


                                        isv=iv;


                                        while n>0&&peak(n)<=p
                                            if valley(n)<v
                                                v=valley(n);
                                                iv=iValley(n);
                                            end
                                            n=n-1;
                                        end



                                        n=n+1;
                                        peak(n)=p;
                                        valley(n)=v;
                                        iValley(n)=iv;

                                        if iInflect(i)==iPeak(k)
                                            iBase(k)=iv;
                                            iSaddle(k)=isv;
                                            k=k+1;
                                        end

                                        i=i+1;
                                        j=j+1;
                                    end


                                    function[iPk,pbPk,iLB,iRB]=removePeaksBelowMinPeakProminence(y,iPk,pbPk,iLB,iRB,minP)

                                        Ppk=y(iPk)-pbPk;


                                        idx=find(Ppk>=minP);
                                        iPk=iPk(idx);
                                        pbPk=pbPk(idx);
                                        iLB=iLB(idx);
                                        iRB=iRB(idx);


                                        function[wxPk,iLBh,iRBh]=getPeakWidth(y,x,iPk,pbPk,iLB,iRB,wRef)
                                            if isempty(iPk)

                                                base=zeros(size(iPk));
                                                iLBh=zeros(size(iPk));
                                                iRBh=zeros(size(iPk));
                                            elseif strcmp(wRef,'halfheight')

                                                base=zeros(size(iPk));



                                                iLBh=[iLB(1);max(iLB(2:end),iRB(1:end-1))];
                                                iRBh=[min(iRB(1:end-1),iLB(2:end));iRB(end)];
                                                iGuard=iLBh>iPk;
                                                iLBh(iGuard)=iLB(iGuard);
                                                iGuard=iRBh<iPk;
                                                iRBh(iGuard)=iRB(iGuard);
                                            else

                                                base=pbPk;


                                                iLBh=iLB;
                                                iRBh=iRB;
                                            end


                                            wxPk=getHalfMaxBounds(y,x,iPk,base,iLBh,iRBh);


                                            function bounds=getHalfMaxBounds(y,x,iPk,base,iLB,iRB)
                                                bounds=zeros(numel(iPk),2);


                                                for i=1:numel(iPk)


                                                    refHeight=(y(iPk(i))+base(i))/2;


                                                    iLeft=findLeftIntercept(y,iPk(i),iLB(i),refHeight);
                                                    if iLeft<iLB(i)
                                                        xLeft=x(iLB(i));
                                                    else
                                                        xLeft=linterp(x(iLeft),x(iLeft+1),y(iLeft),y(iLeft+1),y(iPk(i)),base(i));
                                                    end


                                                    iRight=findRightIntercept(y,iPk(i),iRB(i),refHeight);
                                                    if iRight>iRB(i)
                                                        xRight=x(iRB(i));
                                                    else
                                                        xRight=linterp(x(iRight),x(iRight-1),y(iRight),y(iRight-1),y(iPk(i)),base(i));
                                                    end


                                                    bounds(i,:)=[xLeft,xRight];
                                                end


                                                function idx=findLeftIntercept(y,idx,borderIdx,refHeight)


                                                    while idx>=borderIdx&&y(idx)>refHeight
                                                        idx=idx-1;
                                                    end


                                                    function idx=findRightIntercept(y,idx,borderIdx,refHeight)


                                                        while idx<=borderIdx&&y(idx)>refHeight
                                                            idx=idx+1;
                                                        end


                                                        function xc=linterp(xa,xb,ya,yb,yc,bc)

                                                            xc=xa+(xb-xa).*(0.5*(yc+bc)-ya)./(yb-ya);


                                                            if isnan(xc)

                                                                if isinf(bc)

                                                                    xc=0.5*(xa+xb);
                                                                else

                                                                    xc=xb;
                                                                end
                                                            end


                                                            function[iPk,bPk,bxPk,byPk,wxPk]=removePeaksOutsideWidth(iPk,bPk,bxPk,byPk,wxPk,minW,maxW)

                                                                if isempty(iPk)||minW==0&&maxW==inf;
                                                                    return
                                                                end


                                                                w=diff(wxPk,1,2);
                                                                idx=find(minW<=w&w<=maxW);


                                                                iPk=iPk(idx);
                                                                bPk=bPk(idx);
                                                                bxPk=bxPk(idx,:);
                                                                byPk=byPk(idx,:);
                                                                wxPk=wxPk(idx,:);


                                                                function[iPkOut,bPk,bxPk,byPk,wxPk]=combinePeaks(iPk,iInf)
                                                                    iPkOut=union(iPk,iInf);
                                                                    bPk=zeros(0,1);
                                                                    bxPk=zeros(0,2);
                                                                    byPk=zeros(0,2);
                                                                    wxPk=zeros(0,2);


                                                                    function[iPkOut,bPkOut,bxPkOut,byPkOut,wxPkOut]=combineFullPeaks(y,x,iPk,bPk,iLBw,iRBw,wPk,iInf)
                                                                        iPkOut=union(iPk,iInf);


                                                                        [~,iFinite]=intersect(iPkOut,iPk);
                                                                        [~,iInfinite]=intersect(iPkOut,iInf);



                                                                        iPkOut=iPkOut(:);


                                                                        bPkOut=zeros(size(iPkOut));
                                                                        bPkOut(iFinite)=bPk;
                                                                        bPkOut(iInfinite)=0;


                                                                        iInfL=max(1,iInf-1);
                                                                        iInfR=min(iInf+1,numel(x));




                                                                        bxPkOut=zeros(size(iPkOut,1),2);
                                                                        bxPkOut(iFinite,1)=x(iLBw);
                                                                        bxPkOut(iFinite,2)=x(iRBw);
                                                                        bxPkOut(iInfinite,1)=0.5*(x(iInf)+x(iInfL));
                                                                        bxPkOut(iInfinite,2)=0.5*(x(iInf)+x(iInfR));


                                                                        byPkOut=zeros(size(iPkOut,1),2);
                                                                        byPkOut(iFinite,1)=y(iLBw);
                                                                        byPkOut(iFinite,2)=y(iRBw);
                                                                        byPkOut(iInfinite,1)=y(iInfL);
                                                                        byPkOut(iInfinite,2)=y(iInfR);




                                                                        wxPkOut=zeros(size(iPkOut,1),2);
                                                                        wxPkOut(iFinite,:)=wPk;
                                                                        wxPkOut(iInfinite,1)=0.5*(x(iInf)+x(iInfL));
                                                                        wxPkOut(iInfinite,2)=0.5*(x(iInf)+x(iInfR));


                                                                        function idx=findPeaksSeparatedByMoreThanMinPeakDistance(y,x,iPk,Pd)



                                                                            if isempty(iPk)||Pd==0
                                                                                idx=(1:numel(iPk)).';
                                                                                return
                                                                            end


                                                                            pks=y(iPk);
                                                                            locs=x(iPk);


                                                                            [~,sortIdx]=sort(pks,'descend');
                                                                            locs_temp=locs(sortIdx);

                                                                            idelete=ones(size(locs_temp))<0;
                                                                            for i=1:length(locs_temp)
                                                                                if~idelete(i)


                                                                                    idelete=idelete|(locs_temp>=locs_temp(i)-Pd)&(locs_temp<=locs_temp(i)+Pd);
                                                                                    idelete(i)=0;
                                                                                end
                                                                            end


                                                                            idx=sort(sortIdx(~idelete));




                                                                            function idx=orderPeaks(Y,iPk,idx,Str)

                                                                                if isempty(idx)||strcmp(Str,'none')
                                                                                    return
                                                                                end

                                                                                if strcmp(Str,'ascend')
                                                                                    [~,s]=sort(Y(iPk(idx)),'ascend');
                                                                                else
                                                                                    [~,s]=sort(Y(iPk(idx)),'descend');
                                                                                end

                                                                                idx=idx(s);



                                                                                function idx=keepAtMostNpPeaks(idx,Np)

                                                                                    if length(idx)>Np
                                                                                        idx=idx(1:Np);
                                                                                    end


                                                                                    function[bPk,bxPk,byPk,wxPk]=fetchPeakExtents(idx,bPk,bxPk,byPk,wxPk)
                                                                                        bPk=bPk(idx);
                                                                                        bxPk=bxPk(idx,:);
                                                                                        byPk=byPk(idx,:);
                                                                                        wxPk=wxPk(idx,:);


                                                                                        function[YpkOut,XpkOut]=assignOutputs(y,x,iPk,yIsRow,xIsRow)


                                                                                            Ypk=y(iPk);
                                                                                            Xpk=x(iPk);


                                                                                            if yIsRow
                                                                                                YpkOut=Ypk.';
                                                                                            else
                                                                                                YpkOut=Ypk;
                                                                                            end


                                                                                            if xIsRow
                                                                                                XpkOut=Xpk.';
                                                                                            else
                                                                                                XpkOut=Xpk;
                                                                                            end


                                                                                            function[YpkOut,XpkOut,WpkOut,PpkOut]=assignFullOutputs(y,x,iPk,wxPk,bPk,yIsRow,xIsRow)


                                                                                                Ypk=y(iPk);
                                                                                                Xpk=x(iPk);


                                                                                                Wpk=diff(wxPk,1,2);
                                                                                                Ppk=Ypk-bPk;


                                                                                                if yIsRow
                                                                                                    YpkOut=Ypk.';
                                                                                                    PpkOut=Ppk.';
                                                                                                else
                                                                                                    YpkOut=Ypk;
                                                                                                    PpkOut=Ppk;
                                                                                                end


                                                                                                if xIsRow
                                                                                                    XpkOut=Xpk.';
                                                                                                    WpkOut=Wpk.';
                                                                                                else
                                                                                                    XpkOut=Xpk;
                                                                                                    WpkOut=Wpk;
                                                                                                end


                                                                                                function hAxes=plotSignalWithPeaks(x,y,iPk)


                                                                                                    hLine=plot(x,y,'Tag','Signal');
                                                                                                    hAxes=ancestor(hLine,'Axes');

                                                                                                    grid on;


                                                                                                    color=get(hLine,'Color');
                                                                                                    hLine=line(x(iPk),y(iPk),'Parent',hAxes,...
                                                                                                    'Marker','o','LineStyle','none','Color',color,'tag','Peak');


                                                                                                    if coder.target('MATLAB')
                                                                                                        plotpkmarkers(hLine,y(iPk));
                                                                                                    end


                                                                                                    function plotExtents(hAxes,x,y,iPk,bPk,bxPk,byPk,wxPk,refW)


                                                                                                        if strcmp(refW,'halfheight')
                                                                                                            hm=0.5*y(iPk);
                                                                                                        else
                                                                                                            hm=0.5*(y(iPk)+bPk);
                                                                                                        end


                                                                                                        colors=get(0,'DefaultAxesColorOrder');


                                                                                                        if strcmp(refW,'halfheight')

                                                                                                            plotLines(hAxes,'Height',x(iPk),y(iPk),x(iPk),zeros(numel(iPk),1),colors(2,:));


                                                                                                            plotLines(hAxes,'HalfHeightWidth',wxPk(:,1),hm,wxPk(:,2),hm,colors(3,:));


                                                                                                            idx=find(byPk(:,1)>0);
                                                                                                            plotLines(hAxes,'Border',bxPk(idx,1),zeros(numel(idx),1),bxPk(idx,1),byPk(idx,1),colors(4,:));
                                                                                                            idx=find(byPk(:,2)>0);
                                                                                                            plotLines(hAxes,'Border',bxPk(idx,2),zeros(numel(idx),1),bxPk(idx,2),byPk(idx,2),colors(4,:));

                                                                                                        else

                                                                                                            plotLines(hAxes,'Prominence',x(iPk),y(iPk),x(iPk),bPk,colors(2,:));


                                                                                                            plotLines(hAxes,'HalfProminenceWidth',wxPk(:,1),hm,wxPk(:,2),hm,colors(3,:));


                                                                                                            idx=find(bPk(:)<byPk(:,1));
                                                                                                            plotLines(hAxes,'Border',bxPk(idx,1),bPk(idx),bxPk(idx,1),byPk(idx,1),colors(4,:));
                                                                                                            idx=find(bPk(:)<byPk(:,2));
                                                                                                            plotLines(hAxes,'Border',bxPk(idx,2),bPk(idx),bxPk(idx,2),byPk(idx,2),colors(4,:));
                                                                                                        end























                                                                                                        function plotLines(hAxes,tag,x1,y1,x2,y2,c)

                                                                                                            n=numel(x1);
                                                                                                            line(reshape([x1(:).';x2(:).';NaN(1,n)],3*n,1),...
                                                                                                            reshape([y1(:).';y2(:).';NaN(1,n)],3*n,1),...
                                                                                                            'Color',c,'Parent',hAxes,'tag',tag);


                                                                                                            function scalePlot(hAxes)









                                                                                                                minVal=Inf;
                                                                                                                maxVal=-Inf;

                                                                                                                if coder.target('MATLAB')
                                                                                                                    hLines=findall(hAxes,'Type','line');
                                                                                                                    for i=1:numel(hLines)
                                                                                                                        data=get(hLines(i),'YData');
                                                                                                                        data=data(isfinite(data));
                                                                                                                        if~isempty(data)
                                                                                                                            minVal=min(minVal,min(data(:)));
                                                                                                                            maxVal=max(maxVal,max(data(:)));
                                                                                                                        end
                                                                                                                    end

                                                                                                                    axis auto
                                                                                                                    xlimits=xlim;


                                                                                                                    p=.05;
                                                                                                                    y1=(1+p)*maxVal-p*minVal;
                                                                                                                    y2=(1+p)*minVal-p*maxVal;


                                                                                                                    hTempLine=line(xlimits([1,1]),[y1,y2],'Parent',hAxes);


                                                                                                                    ylimits=ylim;
                                                                                                                    delete(hTempLine);
                                                                                                                else
                                                                                                                    axis auto
                                                                                                                    ylimits=ylim;
                                                                                                                end


                                                                                                                axis tight
                                                                                                                ylim(ylimits);


