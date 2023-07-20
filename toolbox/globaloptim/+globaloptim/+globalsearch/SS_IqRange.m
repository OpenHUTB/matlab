function r=SS_IqRange(x)



















    if isempty(x)
        r=NaN;
        return
    end


    [nr,nc]=size(x);


    x=sort(x,1);


    nonnans=~isnan(x);


    if all(nonnans(:))



        q=[0,100*(0.5:(nr-0.5))./nr,100]';
        xx=[x(1,:);x(1:nr,:);x(nr,:)];
        y=interp1q(q,xx,[25;75]);


    else



        y=nan(2,nc);
        for j=1:nc
            nj=find(nonnans(:,j),1,'last');
            if nj>0
                q=[0,100*(0.5:(nj-0.5))./nj,100]';
                xx=[x(1,j);x(1:nj,j);x(nj,j)];
                y(:,j)=interp1q(q,xx,[25;75]);
            end
        end
    end


    r=diff(y);
