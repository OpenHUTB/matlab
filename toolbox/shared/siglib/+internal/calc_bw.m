function[BW,Angles,Indexs]=calc_bw(MagE,theta,phi,pwrdown,interp,isplot,fullCircle)



%#codegen
    coder.allowpcode('plain')
    matlabCoderFlag=coder.target('MATLAB');
    [peak_val,peak_index]=internal.findpeakvalandindex(MagE,1e-4);
    num_peaks=length(peak_val);
    BW=zeros(num_peaks,1);
    Angles=zeros(num_peaks,2);
    Indexs=zeros(num_peaks,2);
    for m=1:num_peaks
        mv=peak_val(m)-pwrdown;
        index1=find(MagE(1:1:peak_index(m))<mv,1,'last');
        partialdata=false;
        if isempty(index1)
            if fullCircle

                index1=peak_index(m)+find(MagE(peak_index(m):1:end)<...
                mv,1,'last')-1;
            else
                index1=find(isfinite(MagE),1,'first');
                partialdata=true;
            end
        end


        index2=peak_index(m)+find(MagE(peak_index(m):1:end)<mv,1,'first')-1;
        if isempty(index2)
            if fullCircle
                index2=find(MagE(1:1:peak_index(m))<mv,1,'first');
            else
                index2=find(isfinite(MagE),1,'last');
                partialdata=true;
            end
        end



        [index1,index2]=updateindex(MagE,mv,index1,index2);
        if matlabCoderFlag
            [BW(m),Angles(m,:),Indexs(m,:),angd]=AnglesIndexs(MagE,theta,...
            phi,index1,index2,mv,interp);
        else
            [BW(m),Angle,Index,angd]=AnglesIndexs(MagE,theta,phi,index1,...
            index2,mv,interp);
            Angles(m,:)=Angle(1,:);
            Indexs(m,:)=Index(1,:);
        end
        if~partialdata&&BW(m)~=360
            if matlabCoderFlag
                BW(m)=internal.polariCommon.angleDiff(angd(Indexs(m,:))...
                *pi/180)*180/pi;
            else
                BW(m)=diff(angd(Indexs(m,:)));
                if BW(m)<0
                    BW(m)=BW(m)+360;
                end
            end
        end



        if any(isnan(MagE))
            if Angles(m,2)<Angles(m,1)
                if fullCircle
                    index1n=find(isnan(MagE(1:1:peak_index(m))),1,'last')+1;
                    if isempty(index1n)
                        index1n=peak_index(m)+find(isnan(MagE(peak_index(m):1:end)),...
                        1,'last');
                    end
                    if index1n<index1
                        index1=index1n;
                    end
                    index2n=peak_index(m)+find(isnan(MagE(peak_index(m):1:end)),...
                    1,'first')-2;
                    if isempty(index2n)
                        index2n=find(isnan(MagE(1:1:peak_index(m))),1,'first')-1;
                    end
                    if index2n>index2
                        index2=index2n;
                    end

                elseif~fullCircle&&all(isnan(MagE([1,end])))...
                    &&any(~isnan(MagE([2,end-1])))

                    index1=find(MagE(1:1:peak_index(m))<...
                    mv,1,'last');
                    if isempty(index1)
                        index1=2;
                    end
                    index2=peak_index(m)+find(MagE(peak_index(m):1:end)<...
                    mv,1,'first')-1;

                    if isempty(index2)
                        index2=numel(MagE)-1;
                    end
                end
                if matlabCoderFlag
                    [BW(m),Angles(m,:),Indexs(m,:),angd]=AnglesIndexs(MagE,...
                    theta,phi,index1,index2,mv,interp);
                else
                    [BW(m),Angle,Index,angd]=AnglesIndexs(MagE,theta,phi,...
                    index1,index2,mv,interp);
                    Angles(m,:)=Angle(1,:);
                    Indexs(m,:)=Index(1,:);
                end
            end
        end
















    end


    [~,ia,~]=unique(Angles,'rows','stable');
    Angles=Angles(ia,:);
    BW=BW(ia);
    Indexs=Indexs(ia,:);


    if isplot
        peaksIdx=peak_index(ia);

        if size(BW,1)>1&&~isempty(peaksIdx)

            M=max(MagE(peaksIdx));
            MaxBW=MagE(peaksIdx)==M;
            [~,index]=max(BW(MaxBW));
            magPeak=angd(peaksIdx(index));
            if magPeak>180
                magPeak=magPeak-360;
            end

            index=(magPeak>Angles(:,1)&magPeak<Angles(:,2))|...
            (magPeak<Angles(:,1)&magPeak>Angles(:,2));
            i=find(index,1,'first');
            if isempty(i)
                i=1;
            end
            BW=BW(i);
            Angles=Angles(i,:);
            Indexs=Indexs(i,:);
            magPeak=angd(i);
            if(magPeak<Angles(:,1))&&(magPeak>Angles(:,2))
                Angles=flip(Angles);
                Indexs=flip(Indexs);
            end
        elseif size(BW,1)==1||(size(BW,1)>1&&isempty(peaksIdx))
            BW=BW(1);
            Angles=Angles(1,:);
            Indexs=Indexs(1,:);
            magPeak=angd(peaksIdx);
            if(magPeak<Angles(:,1))&&(magPeak>Angles(:,2))
                Angles=flip(Angles);
                Indexs=flip(Indexs);
            end
        else
            BW=[];
            Angles=[];
            Indexs=[];
        end
    end
end

function[a1,idx]=interpLargelyIncrX(MagE,a,index1,index2,mv)

    m1=MagE(index1);
    m2=MagE(index2);
    frac=(mv-m1)/(m2-m1);
    idx=index1+frac;
    a1=a(index1)+frac*...
    internal.polariCommon.angleDiffRel([a(index1),a(index2)]*pi/180)*180/pi;
end

function[BW,Angles,Indexs,angd]=AnglesIndexs(MagE,theta,phi,index1,index2,mv,interp)


    if isscalar(theta)
        angd=phi;
        if isempty(index1)||isempty(index2)
            BW=max(phi)-min(phi);
            [Ang1,i1]=min(phi);
            [Ang2,i2]=max(phi);
            Angles=[Ang1,Ang2];
            Indexs=[i1,i2];
        else
            if interp
                [a1,index1]=interpLargelyIncrX(MagE,phi,index1,index1+1,mv);
                [a2,index2]=interpLargelyIncrX(MagE,phi,index2,index2-1,mv);
                BW=abs(a1-a2);
                Angles=[a1,a2];
            else
                BW=abs(phi(index2)-phi(index1));
                Angles=[phi(index1),phi(index2)];
            end
            Indexs=[index1,index2];
        end
    end

    if isscalar(phi)
        angd=-(theta-90);
        if isempty(index1)||isempty(index2)
            BW=max(theta)-min(theta);
            [Ang1,i1]=min(theta);
            [Ang2,i2]=max(theta);
            Angles=90-[Ang1,Ang2];
            Indexs=[i1,i2];
        else
            if interp
                [a1,index1]=interpLargelyIncrX(MagE,theta,index1,index1+1,mv);
                [a2,index2]=interpLargelyIncrX(MagE,theta,index2-1,index2,mv);
                BW=abs(a1-a2);
                Angles=90-[a1,a2];
            else
                BW=abs(theta(index2)-theta(index1));
                Angles=90-[theta(index1),theta(index2)];
            end
            Indexs=[index1,index2];
        end
    end

end

function[index1,index2]=updateindex(MagE,mv,index1,index2)



    dist_err=abs(max(MagE)-mv);
    disterr1=abs(MagE(index1)-mv);
    if min(disterr1)>min(dist_err)&index1<numel(MagE)&~isnan(MagE(index1+1))%#ok<AND2>
        index1=index1+1;
    end
    disterr2=abs(MagE(index2)-mv);
    if min(disterr2)>min(dist_err)&(index2>2)&~isnan(MagE(index2-1))%#ok<AND2>
        index2=index2-1;
    end
end