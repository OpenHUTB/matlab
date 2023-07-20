function[errorcode,varargout]=distchck(nparms,varargin)




    errorcode=0;
    varargout=varargin;

    if nparms==1
        return;
    end


    isscalar=(cellfun('prodofsize',varargin)==1);


    if(all(isscalar)),return;end

    n=nparms;

    for j=1:n
        sz{j}=size(varargin{j});
    end
    t=sz(~isscalar);
    size1=t{1};


    for j=1:n
        sizej=sz{j};
        if(isscalar(j))
            t=zeros(size1);
            t(:)=varargin{j};
            varargout{j}=t;
        elseif(~isequal(sizej,size1))
            errorcode=1;
            return;
        end
    end
