

function out=MakeMatrix(dae,id,varargin)
    if isempty(varargin)
        in=dae.inputs;
    else
        in=varargin{1};

    end
    in.M=dae.MODE(in);
    pr=dae.(id)(in);
    sp=dae.([id,'_P'])(in);
    [m,n]=size(sp);
    [i,j]=find(sp);
    out=sparse(i,j,pr,m,n);
end