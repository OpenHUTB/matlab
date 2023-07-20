function xi=piecewiseInterpolation(t,x,ti,method)


























    switch(method)
    case 'zoh'
        xi=localzoh(t,x,ti);
    otherwise
        xi=localpiecewiseinterp(t,x,ti,method);
    end
end


function xi=localzoh(t,x,ti)

    [~,~,bin]=histcounts(ti,[t;inf]);
    tfnzbin=(bin~=0);
    nzbin=bin(tfnzbin);
    xi(tfnzbin,:)=x(nzbin,:);
    xi(~tfnzbin,:)=NaN;
end

function xi=localpiecewiseinterp(t,x,ti,method)

    if numel(t)<2


        xi=nan(size(ti,1),size(x,2));
        return;
    end
    dt=diff(t);
    dte0=[false;dt==0;false];
    if any(dte0)


        rise=dte0(2:end)&(~dte0(1:end-1));
        fall=~dte0(2:end)&dte0(1:end-1);
        rise=find(rise);
        fall=find(fall);
        dupt=t(rise,:);


        [nbin,~,bin]=histcounts(ti,[-inf;dupt;inf]);

        risefall=[reshape(rise,1,numel(rise));...
        reshape(fall,1,numel(fall));];
        risefall=[1;risefall(:);numel(t)];


        numintrvls=numel(dupt)+1;
        xi=NaN(numel(ti),size(x,2));
        for c=1:numintrvls
            if nbin(c)>0
                tidx=risefall(2*c-1):risefall(2*c);
                tiidx=bin==c;

                if numel(tidx)==1

                    tiidxnum=find(tiidx);
                    exactmatch=ti(tiidxnum,:)==t(tidx);
                    Nexactmatch=nnz(exactmatch);
                    xi(tiidxnum(exactmatch),:)=repmat(x(tidx,:),Nexactmatch,1);

                    if Nexactmatch~=nnz(tiidx)
                        warning(message('SimBiology:SimData:resampleInterp1SingleDataPt'));
                        xi(tiidxnum(~exactmatch),:)=NaN;
                    end
                else
                    xi(tiidx,:)=interp1(t(tidx,:),x(tidx,:),ti(tiidx,:),method);
                end
            else

            end
        end
    else
        xi=interp1(t,x,ti,method);
    end
end