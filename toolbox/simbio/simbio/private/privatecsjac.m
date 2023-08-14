function[dfdy,g]=privatecsjac(func,y0,nF,cols,g,minthresh,varargin)















































    ny=length(y0);
    if isempty(cols)



        cols=(1:ny)';
        ncols=numel(cols);

        g=(1:ncols)';

        ng=ncols;
    else
        assert(~isempty(g),'privatecsjac must be called with column group argument.')
        ncols=numel(cols);
        ng=max(g);
    end

    h=eps(minthresh);

    yGroups=zeros(ny,1);
    for j=1:ncols
        yGroups(cols(j))=g(j);
    end
    Fev=complex(zeros(nF,ng));
    for j=1:ng
        Fev(:,j)=func(y0+1i*h*(yGroups==j),varargin{:});
    end
    dfdy=imag(Fev)/h;










end