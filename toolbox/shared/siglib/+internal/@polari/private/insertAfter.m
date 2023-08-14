function[z,zi]=insertAfter(x,ix,y)















    Nx=numel(x);
    Nix=numel(ix);
    Ny=numel(y);
    Nz=Nx+Nix;
    zi=zeros(size(ix));

    if size(x,1)==1
        z=zeros(1,Nz);
        ix=[ix,Nz];
    else
        z=zeros(Nz,1);
        ix=[ix;Nz];
    end
    if Ny~=1&&Ny~=Nix
        error('Y must be a scalar or have the same number of elements as IX.');
    end

    xidx=1;
    ixidx=1;
    yidx=1;
    yidx_inc=Ny>1;

    for i=1:Nz
        if xidx==ix(ixidx)+1
            z(i)=y(yidx);
            zi(ixidx)=i;
            ixidx=ixidx+1;
            yidx=yidx+yidx_inc;
        else
            z(i)=x(xidx);
            xidx=xidx+1;
        end
    end
