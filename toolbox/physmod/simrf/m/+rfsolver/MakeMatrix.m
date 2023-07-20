

function sp=MakeMatrix(dae,id,varargin)
    if isempty(varargin)
        in=dae.inputs;
    else
        in=varargin{1};

    end
    in.M=dae.MODE(in);
    pr=dae.(id)(in);
    sp=dae.([id,'_P'])(in);
    sp=double(sp);
    sp(sp~=0)=pr;
end