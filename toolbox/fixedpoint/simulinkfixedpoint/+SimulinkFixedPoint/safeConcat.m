function c=safeConcat(varargin)




    vec=[];
    for i=1:nargin
        vec=[vec(:);double(varargin{i}(:))];
    end
    c=reshape(vec,1,[]);





