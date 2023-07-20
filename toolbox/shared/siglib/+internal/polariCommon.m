classdef polariCommon






    methods(Static)
        function Lvec=deleteListenerStruct(Lvec)









            if~isempty(Lvec)
                validateattributes(Lvec,{'struct'},{},'deleteListenerStruct');
            end
            NLvec=numel(Lvec);
            for j=1:NLvec
                L=Lvec(j);
                f=fieldnames(L);
                for i=1:numel(f)
                    f_i=f{i};
                    v=L.(f_i);
                    if isstruct(v)

                        L.(f_i)=internal.polariCommon.deleteListenerStruct(v);
                    else

                        delete(v);
                    end
                    L.(f_i)=[];
                end
                Lvec(j)=L;
            end
        end
    end





    methods(Static)
        function methodsForDisplay(varname,varargin)
            if nargin==1
                s=getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureMissingVariable',varname));
                disp(s)
            else
                obj=varargin{1};
                classname=varargin{2};
                if~isa(obj,classname)
                    dots=strfind(classname,'.');
                    if~isempty(dots)
                        classname=classname(dots(end)+1:end);
                    end
                    s=getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureClassMismatch',varname,classname));
                    disp(s)
                else
                    try
                        methods(obj)
                    catch
                        s=getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureUnknown',varname));
                        disp(s)
                    end
                end
            end
        end

        function getForDisplay(varname,varargin)


            if nargin==1
                s=getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureMissingVariable',varname));
                disp(s)
            else
                obj=varargin{1};
                classname=varargin{2};
                if~isa(obj,classname)
                    dots=strfind(classname,'.');
                    if~isempty(dots)
                        classname=classname(dots(end)+1:end);
                    end
                    s=getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureClassMismatch',varname,classname));
                    disp(s)
                else
                    try

                        showAllProperties(obj)
                    catch
                        s=getString(message('MATLAB:graphicsDisplayText:FooterLinkFailureUnknown',varname));
                        disp(s)
                    end
                end
            end
        end
    end



    methods(Static)
        function cw=isCW(c1,c2)















            cw=imag(c1).*real(c2)-real(c1).*imag(c2)>=0;
        end

        function cw=isCWangle(a1,a2)
            c1=complex(cos(a1),sin(a1));
            c2=complex(cos(a2),sin(a2));
            cw=internal.polariCommon.isCW(c1,c2);
        end

        function[i1,i2]=cswapIdxIfCW(c,i1,i2)

            if internal.polariCommon.isCW(c(i1),c(i2))
                t=i2;i2=i1;i1=t;
            end
        end

        function[dCCW,dCW]=cangleDiff(A,B)















































            twoPi=2*pi;
            if nargin==1




                dCCW=angle(A(2:end).*conj(A(1:end-1)));
            else


                if~isscalar(A)
                    error('Input A must be a scalar value.');
                end
                dCCW=angle(B.*conj(A));
            end
            sel=dCCW<0;
            dCCW(sel)=dCCW(sel)+twoPi;
            if nargout>1
                dCW=twoPi-dCCW;
            end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
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

        function d=cangleDiffRel(A,B)









            if nargin==1




                d=angle(A(2:end).*conj(A(1:end-1)));
            else


                if~isscalar(A)
                    error('Input A must be a scalar value.');
                end
                d=angle(B.*conj(A));
            end
        end

        function d=cangleAbsDiff(A,B)




















            if nargin==1




                d=abs(angle(A(2:end).*conj(A(1:end-1))));
            else


                if~isscalar(A)
                    error('Input A must be a scalar value.');
                end
                d=abs(angle(B.*conj(A)));
            end
        end

        function varargout=angleDiff(angA,angB)













            if nargin==1

                [varargout{1:nargout}]=internal.polariCommon.cangleDiff(complex(cos(angA),sin(angA)));
            else

                [varargout{1:nargout}]=internal.polariCommon.cangleDiff(...
                complex(cos(angA),sin(angA)),...
                complex(cos(angB),sin(angB)));
            end
        end

        function d=angleAbsDiff(angA,angB)










            if nargin==1

                d=internal.polariCommon.cangleAbsDiff(complex(cos(angA),sin(angA)));
            else

                d=internal.polariCommon.cangleAbsDiff(...
                complex(cos(angA),sin(angA)),...
                complex(cos(angB),sin(angB)));
            end
        end

        function d=angleDiffRel(angA,angB)










            if nargin==1

                d=internal.polariCommon.cangleDiffRel(complex(cos(angA),sin(angA)));
            else

                d=internal.polariCommon.cangleDiffRel(...
                complex(cos(angA),sin(angA)),...
                complex(cos(angB),sin(angB)));
            end
        end

        function sel=anglesWithinSpan(ang,span)




            if numel(span)~=2
                error('SPAN must be a 2-element vector.');
            end
            s1=span(1);
            s2=span(2);
            sel=false(size(ang));
            TwoPi=2*pi;
            for i=1:numel(ang)
                d1=internal.polariCommon.angleDiff(s1,ang(i));
                d2=internal.polariCommon.angleDiff(ang(i),s2);
                sel(i)=d1+d2<=TwoPi;
            end
        end

        function idx=spanContainingAngle(spans,ref)












            if~ismatrix(spans)||(~isempty(spans)&&size(spans,2)~=2)
                error('SPANS must be an Nx2 matrix.');
            end
            N=size(spans,1);
            for i=1:N
                d1=internal.polariCommon.angleDiff(spans(i,1),ref);
                d2=internal.polariCommon.angleDiff(ref,spans(i,2));
                if d1+d2<=2*pi
                    idx=i;
                    return
                end
            end
            idx=[];
        end

        function[mag,idx]=polarInterp(ang,angVec,magVec)




            ang=internal.polariCommon.constrainAngleTwoPi(ang*pi/180);
            [angVecSort,sortIdx]=sort(internal.polariCommon.constrainAngleTwoPi(angVec*pi/180));


            adif=angVecSort-ang;
            i1=find(adif<=0,1,'last');
            i2=find(adif>=0,1,'first');
            if isempty(i1)||isempty(i2)

                mag=[];
                idx=[];
                return
            end
            if i1>=i2



                mag=magVec(sortIdx(i2));
                idx=sortIdx(i2);
                return
            end
            a1=angVecSort(i1);
            a2=angVecSort(i2);
            if abs(a1-a2)<=eps

                mag=magVec(sortIdx(i1));
                idx=sortIdx(i1);
                return
            end
            frac=(ang-a1)/(a2-a1);
            assert(frac>0&&frac<1)
            mag=(1-frac)*magVec(sortIdx(i1))+frac*magVec(sortIdx(i2));





            idx=sortIdx(i1)+frac;
        end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

        function ar=angleRecenter(a,b)
















            ar=mod(a+pi,pi+pi)-mod(b+pi,pi+pi)+b;
        end

        function a=constrainAnglePi(a)
            a=mod(a+pi,2*pi)-pi;
        end

        function a=constrainAngleTwoPi(a)
            a=mod(a,2*pi);
        end









        function[ar,f]=findAngleSpan(th,Nd)





















            if nargin<2
                Nd=2;
            end
            if isempty(th)
                ar=[];
                f=false;
                return
            end










            th2=internal.polariCommon.constrainAngleTwoPi(th);
            if abs(th2(1)-th2(end))>0.001*pi/180
                th2=[th2(:);th2(1)];
            end

            d=internal.polariCommon.angleAbsDiff(th2);
            minClearSpan=Nd*min(d);
            [maxClearSpan,exclIdx]=max(d);
            if maxClearSpan>=minClearSpan




                N=numel(d);

                if exclIdx==N
                    inclIdx=[1,N];
                elseif exclIdx==1
                    inclIdx=[2,1];
                else
                    inclIdx=[exclIdx+1,exclIdx];
                end
                ar=th2(inclIdx);
                f=false;
            else

                ar=th2([1,1]);
                f=true;
            end
        end

        function y=isBetweenAngles(a,s1,s2)






            y=internal.polariCommon.isBetweenAnglesRad(a*pi/180,s1*pi/180,s2*pi/180);
        end

        function y=isBetweenAnglesRad(a,s1,s2)













            TwoPi=2*pi;
            if s2>s1

                s2=s2-floor((s2-s1)/TwoPi)*TwoPi;
            elseif s1>s2
                s2=s2+ceil((s1-s2)/TwoPi)*TwoPi;
            end



            if abs(s1-s2)<100*eps

                y=true;
            else
                if a>s1

                    a=a-floor((a-s1)/TwoPi)*TwoPi;
                elseif s1>a
                    a=a+ceil((s1-a)/TwoPi)*TwoPi;
                end
                y=a>=s1&&a<=s2;
            end
        end

        function th=linspaceIncrRad(s1,s2,N)



            s1=mod(s1,2*pi);
            s2=mod(s2,2*pi);
            if s1<s2
                th=linspace(s1,s2,N);
            else
                th=linspace(s1,s2+2*pi,N);
            end
        end
    end



    methods(Static)
        function valleysIdx=findPolarValleys(data,peaksIdx,isCircle,units,maxHeight)









            if nargin<3
                isCircle=false;
            end
            if nargin<5
                maxHeight=inf;
            end
            cnt=0;
            valleysIdx=zeros(size(data));
            Np=numel(peaksIdx);
            Nd=numel(data);
            peaksIdx=sort(peaksIdx);
            for i=1:Np
                if i<Np
                    iR=peaksIdx(i):peaksIdx(i+1);
                    if nargin<5&&strcmp(units,'dB')
                        maxHeight=max(data([peaksIdx(i),peaksIdx(i+1)]))-3;
                    end
                else
                    if~isCircle
                        break
                    end
                    iR=[peaksIdx(i):Nd,1:peaksIdx(1)];
                    if nargin<5&&strcmp(units,'dB')
                        maxHeight=max(data([peaksIdx(i),peaksIdx(1)]))-3;
                    end
                end
                [~,vIdx]=internal.antfindpeaks(-data(iR),...
                'NPeaks',1,...
                'SortStr','descend',...
                'MinPeakHeight',-maxHeight);
                if isempty(vIdx)
                    [valValley,vIdx]=max(-data(iR));
                    if-valValley>maxHeight&&strcmp(units,'dB')
                        continue;
                    end
                end
                cnt=cnt+1;
                valleysIdx(cnt)=iR(vIdx);
            end
            valleysIdx=valleysIdx(1:cnt);
        end

        function peakIdxVec=getPeakMidpoints(mag,peakIdxVec)
























            thresh=10*eps;

            Nr=numel(mag);
            Ni=numel(peakIdxVec);
            for i=1:Ni
                pidx=peakIdxVec(i);
                pval=mag(pidx);

                pnextIdx=1+rem(pidx,Nr);
                if abs(mag(pnextIdx)-pval)<=thresh









                    p_rel_idx2=find(abs(mag(pidx:end)-pval)>thresh,1,'first');
                    if isempty(p_rel_idx2)




                        plast=numel(mag);
                        pidx=floor((pidx+plast)/2);
                    else












                        if p_rel_idx2>1
                            if rem(p_rel_idx2,2)==1


                                pidx=pidx+floor((p_rel_idx2-2)/2);
                            else
                                pidx=pidx+(p_rel_idx2-2)/2;
                            end
                        end
                    end

                    peakIdxVec(i)=pidx;
                end
            end
        end

        function peakIdxVec=getPeakMidpointsWithAngles(mag,ang,peakIdxVec)























            thresh=10*eps;

            Nr=numel(mag);
            Ni=numel(peakIdxVec);
            for i=1:Ni
                pidx=peakIdxVec(i);
                pval=mag(pidx);

                pnextIdx=1+rem(pidx,Nr);
                if abs(mag(pnextIdx)-pval)<=thresh









                    p_rel_idx2=find(abs(mag(pidx:end)-pval)>thresh,1,'first');
                    if isempty(p_rel_idx2)




                        plast=numel(mag);
                        pidx=floor((pidx+plast)/2);




                        if rem(ang(pidx),45)~=0&&rem(ang(pidx+1),45)==0

                            pidx=pidx+1;
                        end
                    else












                        if p_rel_idx2>1
                            if rem(p_rel_idx2,2)==1


                                pidx=pidx+floor((p_rel_idx2-2)/2);





                                if rem(ang(pidx),45)~=0&&rem(ang(pidx+1),45)==0

                                    pidx=pidx+1;
                                end
                            else
                                pidx=pidx+(p_rel_idx2-2)/2;
                            end
                        end
                    end

                    peakIdxVec(i)=pidx;
                end
            end
        end

        function peaksIdx=findPolarPeaks(varargin)




























            args=local_parsePolarPeaks(varargin{:});













            if args.circ
                r2=args.mag([args.minidx:end,1:args.minidx-1]);
            else
                r2=args.mag;
            end
            [~,pidx]=internal.antfindpeaks(r2,args.findpeaks{:});





            pidx=internal.polariCommon.getPeakMidpoints(r2,pidx);

            if args.circ




                peaksIdx=1+mod(pidx+args.minidx-2,numel(args.mag));
            else
                peaksIdx=pidx;
            end
        end
    end



    methods(Static)
        function[verts,faces]=sectorsPatchRounded(r,th,z0)






































            quick_dth=abs(th(2)-th(1));


            if(quick_dth>pi)&&rem(quick_dth,2*pi)<1000*eps
                dth=2*pi;
            else
                dth=internal.polariCommon.angleDiff(th);
            end


            angle_density=1.0*pi/180;




            dth_pts=max(2,ceil(dth/angle_density));

            Nv=1+sum(dth_pts);
            verts=zeros(Nv,3);


            Nr=numel(r);
            Nf=Nr;





            Nv_max=1+max(dth_pts);
            faces=NaN(Nf,Nv_max);
            faces(:,1)=1;





            r(r<=0)=eps;

            i_v=2;
            for i=1:Nr
                r_i=r(i);



                Nj=dth_pts(i);
                dth_i=dth(i);


                th_vec=th(i)+dth_i*(0:Nj-1)'/(Nj-1);

                x=r_i.*cos(th_vec);
                y=r_i.*sin(th_vec);
                z=z0*ones(size(x));

                verts(i_v:i_v+Nj-1,:)=[x,y,z];







                faces(i,2:Nj+1)=i_v:i_v+Nj-1;


                i_v=i_v+Nj;
            end





            verts(1,:)=[0,0,z0];
        end
    end



    methods(Static)
        function s=sprintfMaxNumTotalDigits(x,Ntot,forceCell)
















            if isempty(x)
                s='[]';
            elseif~isscalar(x)||nargin>2&&forceCell


                N=numel(x);
                s=cell(1,N);
                for i=1:N
                    s{i}=internal.polariCommon.sprintfMaxNumTotalDigits(x(i),Ntot);
                end
            else




                Ntot=abs(Ntot);



                if x==0
                    Nints=1;
                else
                    Nints=ceil(log10(abs(x)));
                end
                if Nints>=Ntot

                    Nfrac=0;
                else
                    Nfrac=Ntot-Nints;
                end
                th=1000*eps;

                if Nfrac==0
                    s=sprintf('%d',round(x));

                elseif(abs(x)-fix(abs(x))<th)

                    s=sprintf('%g',round(x));

                else



                    sc=10.^Nfrac;
                    x=round(x*sc);





                    y=x;
                    NIntDigitsAreZero=0;
                    for j=1:Nfrac
                        p10=10.^j;
                        y=round(y./p10)*p10;
                        if abs(y-x)>th
                            break;
                        end
                        NIntDigitsAreZero=NIntDigitsAreZero+1;
                    end
                    Nfrac=Nfrac-NIntDigitsAreZero;


                    x=x./sc;
                    s=sprintf('%*.*f',Nints,Nfrac,x);
                end





                if strcmpi(s,'-0')
                    s='0';
                end
            end
        end

        function s=sprintfNumTotalDigits(x,Ntot,forceCell)











            if isempty(x)
                s='[]';
            elseif~isscalar(x)||nargin>2&&forceCell


                N=numel(x);
                s=cell(1,N);
                for i=1:N
                    s{i}=internal.polariCommon.sprintfNumTotalDigits(x(i),Ntot);
                end
            else


                suppressFracIfInt=Ntot<0;
                Ntot=abs(Ntot);



                if x==0
                    Nints=1;
                else
                    Nints=ceil(log10(abs(x)));
                end
                if Nints>=Ntot

                    Nfrac=0;
                else
                    Nfrac=Ntot-Nints;
                end

                if Nfrac==0
                    s=sprintf('%d',round(x));

                elseif suppressFracIfInt&&(abs(x)-fix(abs(x))<1000*eps)

                    s=sprintf('%g',round(x));

                else

                    sc=10.^Nfrac;
                    x=round(x*sc)./sc;
                    s=sprintf('%*.*f',Nints,Nfrac,x);
                end





                if strcmpi(s,'-0')
                    s='0';
                end
            end
        end

        function s=sprintfNumTotalDigitsAsVector(x,Ntot)
















            t=internal.polariCommon.sprintfNumTotalDigits(x,Ntot);
            if~iscell(t)

                s=t;
            else

                Nt=numel(t);
                s='[';
                for i=1:Nt
                    s=[s,t{i}];%#ok<AGROW>
                    if i<Nt
                        s=[s,', '];%#ok<AGROW>
                    end
                end
                s=[s,']'];
            end
        end

        function s=sprintfMaxNumFracDigits(x,Nfrac,forceCell)

















            if~isscalar(x)||nargin>2&&forceCell


                N=numel(x);
                s=cell(1,N);
                for i=1:N
                    s{i}=internal.polariCommon.sprintfMaxNumFracDigits(x(i),Nfrac);
                end
            else



                Nfrac=abs(Nfrac);



                if x==0
                    Nints=1;
                else


                    Nints=max(1,ceil(log10(abs(x))));
                end


                th=1000*eps;
                if Nfrac==0
                    s=sprintf('%d',round(x));

                elseif(abs(x)-fix(abs(x))<th)



                    s=sprintf('%*g',Nints,round(x));
                else


                    sc=10.^Nfrac;
                    x=round(x*sc);





                    y=x;
                    NIntDigitsAreZero=0;
                    for j=1:Nfrac
                        p10=10.^j;
                        y=round(y./p10)*p10;
                        if abs(y-x)>th
                            break;
                        end
                        NIntDigitsAreZero=NIntDigitsAreZero+1;
                    end
                    Nfrac=Nfrac-NIntDigitsAreZero;


                    x=x./sc;

                    s=sprintf('%*.*f',Nints,Nfrac,x);
                end





                if strcmpi(s,'-0')
                    s='0';
                end
            end
        end

        function s=sprintfNumFracDigits(x,Nfrac,forceCell)



















            if~isscalar(x)||nargin>2&&forceCell


                N=numel(x);
                s=cell(1,N);
                for i=1:N
                    s{i}=internal.polariCommon.sprintfNumFracDigits(x(i),Nfrac);
                end
            else



                suppressFracIfInt=Nfrac<0;
                Nfrac=abs(Nfrac);



                if x==0
                    Nints=1;
                else


                    Nints=max(1,ceil(log10(abs(x))));
                end


                if suppressFracIfInt&&(abs(x)-fix(abs(x))<1000*eps)



                    s=sprintf('%*g',Nints,round(x));
                else
                    s=sprintf('%*.*f',Nints,Nfrac,x);
                end





                if strcmpi(s,'-0')
                    s='0';
                end
            end
        end

        function s=sprintfNumFracDigitsAsVector(x,Nfrac)




















            t=internal.polariCommon.sprintfNumFracDigits(x,Nfrac);


            Nt=numel(t);
            s='[';
            for i=1:Nt
                s=[s,t{i}];%#ok<AGROW>
                if i<Nt
                    s=[s,', '];%#ok<AGROW>
                end
            end
            s=[s,']'];
        end

        function y=roundDigitsNoRescale(x,N)










            y=x;





            sgn=sign(x);
            lx=log10(abs(x));


            Nl=N-1;
            delta=lx-Nl;
            selSm=delta<=0;
            ySm=delta(selSm);
            fSm=ceil(-ySm);

            fSm=min(fSm,Nl);
            y(selSm)=10.^fSm.*x(selSm);


...
...
...
...
...
...
...
...
...

            y=round(y);
            y(selSm)=y(selSm).*10.^(-fSm);

            y=y.*sgn;
        end

        function h=figRectNorm(fig,pos)







            if nargin==1
                pos=fig;
                fig=gcf;
            end
            ax=axes('parent',fig,...
            'Units','norm',...
            'XLim',[0,1],...
            'YLim',[0,1],...
            'Position',[0,0,1,1],...
            'Visible','off');
            h=line('parent',ax,...
            'XData',[pos(1),pos(1),pos(1)+pos(3),pos(1)+pos(3),pos(1)],...
            'YData',[pos(2),pos(2)+pos(4),pos(2)+pos(4),pos(2),pos(2)]);
        end
    end



    methods(Static)
        function arg=xlatExtendedASCII(arg,dir)
















































            patterns={...
            '#copy',char(169);
            '#reg',char(174);
            '#dagger',char(134);
            '#copy',char(169);
            '#deg',char(176);
            '#plusmn',char(177);
            '#infin',char(8734);
            '#micro',char(181);
            '#sup1',char(185);
            '#sup2',char(178);
            '#sup3',char(179);
            '#nabla',char(8711);
            '#ohm',char(937);
            '#Alpha',char(913);
            '#Beta',char(914);
            '#Gamma',char(915);
            '#Delta',char(916);
            '#Epsilon',char(917);
            '#Zeta',char(918);
            '#Eta',char(919);
            '#Theta',char(920);
            '#Iota',char(921);
            '#Kappa',char(922);
            '#Lambda',char(923);
            '#Mu',char(924);
            '#Nu',char(925);
            '#Xi',char(926);
            '#Omicron',char(927);
            '#Pi',char(928);
            '#Rho',char(929);
            '#Sigma',char(931);
            '#Tau',char(932);
            '#Upsilon',char(933);
            '#Phi',char(934);
            '#Chi',char(935);
            '#Psi',char(936);
            '#Omega',char(937);
            '#alpha',char(945);
            '#beta',char(946);
            '#gamma',char(947);
            '#delta',char(948);
            '#epsilon',char(949);
            '#zeta',char(950);
            '#eta',char(951);
            '#theta',char(952);
            '#iota',char(953);
            '#kappa',char(954);
            '#lambda',char(955);
            '#mu',char(956);
            '#nu',char(957);
            '#xi',char(958);
            '#omicron',char(959);
            '#pi',char(960);
            '#rho',char(961);
            '#sigmaf',char(962);
            '#sigma',char(963);
            '#tau',char(964);
            '#upsilon',char(965);
            '#phi',char(966);
            '#chi',char(967);
            '#psi',char(968);
            '#omega',char(969)};

            if nargin==0

                if nargout>0
                    arg=patterns(:,1);
                else
                    disp('Text markup symbols supported:');
                    disp(patterns(:,1));
                end
                return
            end

            if~ischar(arg)&&~(isstring(arg)&&isscalar(arg))&&~iscellstr(arg)&&~isstring(arg)
                error('Input must be a string or a cell-array of strings');
            end
            if nargin<2||strcmpi(dir,'forward')

                i_src=1;
                i_dst=2;
            else

                i_src=2;
                i_dst=1;
            end


            if ischar(arg)||(isstring(arg)&&isscalar(arg))

                arg=xlatExtendedASCII_convertOneCharMatrix(arg,patterns,i_src,i_dst);
            else

                for i=1:numel(arg)
                    arg{i}=xlatExtendedASCII_convertOneCharMatrix(arg{i},patterns,i_src,i_dst);
                end
            end
        end

        function s=removeExtendedASCII(s)





            assert(ischar(s));
            t=cellstr(s);
            for i=1:numel(t)
                t_i=t{i};
                t_i(fix(t_i)==fix(native2unicode([226,146,182],'UTF-8')))='';
                t{i}=t_i;
            end
            s=char(t);
        end

        function strs=convertEmbeddedCRsToCharMatrices(strs)







            is_cell=iscellstr(strs);
            if~is_cell
                strs={strs};
            end
            CR=sprintf('\n');
            for i=1:numel(strs)




                c_i=cellstr(strs{i});

                Nc=numel(c_i);
                for j=1:Nc
                    c_j=c_i{j};
                    idx=find(c_j==CR);
                    Ncr=numel(idx);
                    if Ncr>0
                        t=cell(Ncr+1,1);
                        i2=0;
                        for k=1:Ncr
                            i1=i2;
                            i2=idx(k);
                            t{k}=c_j(i1+1:i2-1);
                        end
                        t{end}=c_j(i2+1:end);
                        c_i{j}=char(t);
                    end
                end
                strs{i}=char(c_i);
            end
            if~is_cell
                strs=strs{1};
            end
        end

        function strs=convertEmbeddedCellsToCharMatrices(strs)












            if~iscellstr(strs)&&~isstring(strs)&&~ischar(strs)&&~(isstring(strs)&&isscalar(strs))
                for i=1:numel(strs)
                    if iscell(strs{i})


                        strs{i}=char(strs{i});
                    end
                end
            end
        end

        function strs=convertStringMatrixToCR(strs)



            CR=sprintf('\n');
            if iscell(strs)
                Ns=numel(strs);
                for i=1:Ns
                    s_i=strs{i};
                    Nr=size(s_i,1);
                    if ischar(s_i)||(isstring(s_i)&&isscalar(s_i))&&Nr>1
                        t=[s_i';repmat(CR,1,Nr)];
                        strs{i}=t(:)';
                    end
                end
            else
                Nr=size(strs,1);
                if Nr>1
                    t=[strs';repmat(CR,1,Nr)];
                    strs=t(:)';
                    strs=strs(1:end-1);
                end
            end
        end
    end



    methods(Static)
        function c=getUTFCircleChar(ch)












            if isstrprop(ch,'upper')
                if fix(ch)>=fix('K')
                    dec=[226,147,128];
                    ch=ch-fix('K');
                else
                    dec=[226,146,182];
                    ch=ch-fix('A');
                end

            elseif isstrprop(ch,'lower')
                dec=[226,147,144];
                ch=ch-fix('a');

            elseif isstrprop(ch,'digit')
                if strcmp(ch,'0')
                    dec=[226,147,170];
                    ch=0;
                else
                    dec=[226,145,160];
                    ch=ch-fix('1');
                end
            end
            c=native2unicode(dec+[0,0,fix(ch)],'UTF-8');
        end

        function c=getUTFCircleNumber(nums)















            validateattributes(nums,{'double','single'},...
            {'real','finite','integer','>=',-20,'<=',20});

            for i=numel(nums):-1:1
                n_i=nums(i);
                if n_i==0
                    dec=[226,147,170];
                elseif n_i>0
                    dec=[226,145,159+n_i];



                else






                end
                c(i)=native2unicode(dec,'UTF-8');
            end
        end

        function c=getUTFSubscriptNumber(num,style)



























            validateattributes(num,{'double','single'},...
            {'real','finite','nonnegative','integer'});
            if num==0
                digits=0;
            else
                Nd=ceil(log10(num+1));
                digits=zeros(1,Nd);
                for i=1:Nd
                    hi=floor(num/10);
                    lo=num-hi*10;
                    digits(Nd+1-i)=lo;
                    num=hi;
                end
            end


            if nargin<2
                str='subscript';
            else
                str=validatestring(style,{'superscript','subscript'},mfilename,'STYLE',2);
            end
            if strcmpi(str,'subscript')

                for i=numel(digits):-1:1
                    c(i)=native2unicode([226,130,128+digits(i)],'UTF-8');
                end
            else

                for i=numel(digits):-1:1
                    d_i=digits(i);
                    if d_i==0
                        code=[226,129,176];
                    elseif d_i==1
                        code=[194,185];
                    elseif d_i==2
                        code=[194,178];
                    elseif d_i==3
                        code=[194,179];
                    else
                        code=[226,129,176+d_i];
                    end
                    c(i)=native2unicode(code,'UTF-8');
                end
            end
        end
    end



    methods(Static)
        function y=fevalArgSets(fcn,argSlices)





            N=numel(argSlices);
            y=cell(1,N);
            for i=1:N
                y{i}=feval(fcn,argSlices{i}{:});
            end

        end

        function allSlices=createArgSets(varargin)





















            Nargs=numel(varargin);
            Nel=zeros(1,Nargs);
            for i=1:Nargs
                v_i=varargin{i};
                if ischar(v_i)||(isstring(v_i)&&isscalar(v_i))
                    Nel(i)=1;
                else
                    Nel(i)=numel(v_i);
                end
            end



            Nel_nonscalar=Nel;
            Nel_nonscalar(Nel==1)=[];
            if numel(unique(Nel_nonscalar))>1
                error('All arguments must be scalar or have the same length.');
            end
            if isempty(Nel_nonscalar)
                Nmaxel=1;
            else
                Nmaxel=Nel_nonscalar(1);
            end

            allSlices=cell(1,Nmaxel);
            oneSlice=cell(1,Nargs);
            for i=1:Nmaxel
                for j=1:Nargs
                    t=varargin{j};
                    if Nel(j)==1
                        val=t;
                    else
                        if iscell(t)
                            val=t{i};
                        else
                            val=t(i);
                        end
                    end
                    oneSlice{j}=val;
                end
                allSlices{i}=oneSlice;
            end

        end
    end
end

function arg=xlatExtendedASCII_convertOneCharMatrix(arg,patterns,i_src,i_dst)




    assert(~iscell(arg))

    if size(arg,1)<2




        for i=1:size(patterns,1)
            arg=strrep(arg,patterns{i,i_src},patterns{i,i_dst});
        end
    else

        t=cellstr(arg);
        N=numel(t);
        for i=1:size(patterns,1)


            for k=1:N
                t{k}=strrep(t{k},patterns{i,i_src},patterns{i,i_dst});
            end
        end
        arg=char(t);
    end
end

function x=trigFixup(x)

    vals=[0,1,-1];
    for i=1:numel(x)
        sel=abs(x(i)-vals)<2*eps;
        if any(sel)
            x(i)=vals(sel);
        end
    end

end

function args=local_parsePolarPeaks(mag,varargin)



























    narginchk(1,5);
    if~isempty(mag)
        validateattributes(mag,{'numeric'},...
        {'vector','real'},'findPolarPeaks');
    end
    args.mag=mag;





    argAttrs={...
    {{'logical'},{'scalar','real'},'findPolarPeaks'},'circ',true,false;...
    {{'numeric'},{'scalar','real','nonnegative'},'findPolarPeaks'},'Npeaks',inf,false;...
    {{'numeric'},{'vector','real','numel',2},'findPolarPeaks'},'magLim',[],false;...
    {{'cell'},{'vector','even'},'findPolarPeaks'},'userOpts',{},true};

    Nattrs=size(argAttrs,1);
    Nargs=numel(varargin);
    argInputIdx=1;
    argAttrIdx=1;



    for i=1:Nattrs
        args.(argAttrs{i,2})=argAttrs{i,3};
    end

    while(argInputIdx<=Nargs)&&(argAttrIdx<=Nattrs)
        try %#ok<TRYNC>
            val=varargin{argInputIdx};





            t=argAttrs{argAttrIdx,4};
            if~t||~isempty(val)

                t=argAttrs{argAttrIdx,1};
                validateattributes(val,t{:});
            end



            args.(argAttrs{argAttrIdx,2})=val;


            argInputIdx=argInputIdx+1;
        end


        argAttrIdx=argAttrIdx+1;
    end


    if argInputIdx<=Nargs
        error('Invalid input argument #%d.\n',argInputIdx-1);
    end






    mag=args.mag;
    if isempty(args.magLim)







        [minmag,minidx]=min(mag);
        args.magLim=[minmag,max(mag)];
    else





        [~,minidx]=min(mag);
    end
    args.minidx=minidx;



    if isinf(args.Npeaks)
        args.Npeaks=[];
    end





    magLim=args.magLim;
    if isempty(magLim)
        mpp=0;
        mph=0;
    else
        mpp=(magLim(2)-magLim(1))*0.05;
        mph=magLim(1);
    end
    t={'MinPeakHeight',mph,'MinPeakProminence',mpp};
    if~isempty(args.userOpts)
        t=[t,args.userOpts(:).'];
    end

    args.findpeaks=[t,{'SortStr','descend','NPeaks',args.Npeaks}];

end
