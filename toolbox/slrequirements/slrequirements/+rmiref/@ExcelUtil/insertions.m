function count=insertions(method,varargin)


    persistent inserted;
    if isempty(inserted)
        inserted.dummy='';
    end
    switch method
    case 'reset'
        inserted='';
        count=0;
    case 'store'
        cell=varargin{1};
        if isfield(inserted,cell)
            count=inserted.(cell)+1;
        else
            count=1;
        end
        inserted.(cell)=count;
    case 'count'
        cell=varargin{1};
        if isfield(inserted,cell)
            count=inserted.(cell);
        else
            count=0;
        end
    end
end

