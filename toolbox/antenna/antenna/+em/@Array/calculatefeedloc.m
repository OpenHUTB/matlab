
function feedloc=calculatefeedloc(asize,drow,dcol,...
    startpoint,lattice,skew,spacing)
    [m,~]=size(startpoint);
    N=prod(asize)*m;
    Nrow=asize(1);
    Ncol=asize(2);
    feedloc=zeros(3,N);
    if m==1
        feedloc(:,1)=startpoint';
    else
        feedloc(:,1:m)=startpoint';
    end
    if isscalar(drow)
        drow=ones(1,Nrow-1)*drow;
    end
    if isscalar(dcol)
        dcol=ones(1,Ncol-1)*dcol;
    end
    rowoffset=[0,cumsum(drow)];
    if m==1
        rowoffset=feedloc(2,1)-rowoffset;
    else
        for i=1:Nrow
            row{i}=feedloc(2,1:2)-rowoffset(i);%#ok<AGROW>
        end
        rowoffset=cell2mat(row);
    end
    coloffset=[0,cumsum(dcol)];
    if m==1
        coloffset=feedloc(1,1)+coloffset;
    else
        for i=1:Ncol
            col{i}=feedloc(1,1:2)+coloffset(i);%#ok<AGROW>            
        end
        coloffset=cell2mat(col);
    end

    feedy=repmat(rowoffset,1,Ncol);
    temp=repmat(coloffset,Nrow,1);
    feedx=temp(:).';

    if m~=1
        if Nrow>1||m==2
            feedloc(1,:)=feedx;
            feedloc(2,:)=feedy;
            feedloc(3,:)=repmat(startpoint(5:6),1,N/m).*ones(size(feedy));
        else
            feedloc(1,:)=feedx;
            feedloc(3,:)=repmat(startpoint(5:6),1,N/m).*ones(size(feedy));
        end
    else
        feedloc(1,:)=feedx;
        feedloc(2,:)=feedy;
        feedloc(3,:)=startpoint(3).*ones(size(feedy));
    end

    feedloc=feedloc';
    if m>1
        for i=2:2:N
            if feedy(i)>0
                feedloc(i)=feedloc(i)+2*abs(spacing);
            elseif feedy(i)<0
                feedloc(i)=feedloc(i)-2*abs(spacing);
            end
        end
    end
    offset_x=dcol(1)*skew;

    if strcmpi(lattice,'Triangular')
        for m=2:2:asize(1)
            feedloc(m:asize(1):end,1)=...
            feedloc(m:asize(1):end,1)+offset_x;
        end
    end

    if strcmpi(lattice,'Parallelogram')
        for m=2:asize(1)
            feedloc(m:asize(1):end,1)=feedloc(m:asize(1):end,1)...
            +offset_x;
            offset_x=(m)*dcol(1)*skew;
        end
    end
end