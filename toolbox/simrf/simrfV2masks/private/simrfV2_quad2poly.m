function poli=simrfV2_quad2poly(quads,varargin)

    poli=quads(1,:);
    for idx=2:size(quads,1)
        poli=conv(poli,quads(idx,:));
    end

    if nargin==1||(nargin==2&&varargin{1}~=0)
        poli=poli(find(poli,1,'first'):end);
    end

end