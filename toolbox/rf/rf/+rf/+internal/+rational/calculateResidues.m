function[errdb,d,c,resp]=calculateResidues(data,s,poles,TendsToZero,errorMetric,noiseFloor)




%#codegen

    [rows,cols]=size(data);
    np=numel(poles);
    npo=np+1-TendsToZero;
    lowerrows=1:rows;
    upperrows=(rows+1):(2*rows);

    DF=rf.internal.rational.residuematrix(poles,s,TendsToZero);
    d=zeros(1,cols);
    c=complex(zeros(np,cols));
    rhs=[real(data);imag(data)];


    A3=zeros(2*rows,npo);
    if strcmpi(errorMetric,'Default')
        A3(lowerrows,:)=real(DF);
        A3(upperrows,:)=imag(DF);
        col_norm=max(abs(A3));
        col_norm(col_norm==0)=1;
        if isempty(coder.target)
            A3=A3./col_norm;
        else

            A3=bsxfun(@(x,y)x./y,A3,col_norm);
        end

        if isempty(coder.target)
            warnstate=warning('off','MATLAB:rankDeficientMatrix');
        end
        xall=A3\rhs;
        if isempty(coder.target)
            warning(warnstate);
        end
        if isempty(coder.target)
            x=xall./col_norm';
        else

            x=bsxfun(@(x,y)x./y,xall,col_norm');
        end
        x(~isfinite(x))=0;
    else
        scale=1./rf.internal.rational.datanz(data,noiseFloor);
        rhs=[scale;scale].*rhs;
        x=zeros(npo,cols);
        for col=1:cols
            wDF=DF.*scale(:,col);
            A3(lowerrows,:)=real(wDF);
            A3(upperrows,:)=imag(wDF);
            col_norm=max(abs(A3));
            col_norm(col_norm==0)=1;
            A3=A3./col_norm;

            if isempty(coder.target)
                warnstate=warning('off','MATLAB:rankDeficientMatrix');
            end
            xtemp=A3\rhs(:,col);
            if isempty(coder.target)
                warning(warnstate);
            end
            if isempty(coder.target)
                xc=xtemp./col_norm';
            else

                xc=bsxfun(@(x,y)x./y,xtemp,col_norm');
            end
            xc(~isfinite(xc))=0;
            x(:,col)=xc;
        end
    end


    k=1;
    while k<=np
        if imag(poles(k))==0
            c(k,:)=x(k,:);
            k=k+1;
        else
            c(k,:)=complex(x(k,:),x(k+1,:));
            c(k+1,:)=complex(x(k,:),-x(k+1,:));
            k=k+2;
        end
    end
    if~TendsToZero
        d=x(np+1,:);
    end



    resp=complex(repmat(d,rows,1));
    if np>0
        if isempty(coder.target)
            y=1./(s-poles.');
        else

            yrecip=bsxfun(@minus,s,poles.');
            y=1./yrecip;
        end
        resp=resp+y*c;
    end
    err=resp-data;
    [~,errdb]=rf.internal.rational.errcalc(err,data,errorMetric,noiseFloor);
end
