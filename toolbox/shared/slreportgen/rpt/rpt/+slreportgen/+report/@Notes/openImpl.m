function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2Cxoka0AQVPCeFmGh0Dva4H4zsAjeHDfAe56r7CDc3L5eYd/bSRLxh+ijGq'...
        ,'sdFlUL0DxDAsiDmFUHigUL3zgU1D+p18lwussDdxIc+SpBKxV9xTBp306qaA'...
        ,'uTu7FM5RimPgCmKaB/qJ3xI3n1A36MqZG5DV/MgDPkdYF2zMluP9/7ADOtSe'...
        ,'TLYcPyyI9tT45xoR7yNjX8p2lqCHXPxJ4bEihgUjAhZbSChAa7vPIDPxRBma'...
        ,'JhvC5ImFNKIrnAqQxj8URixIscRajOJ4E5KigOZmBB1FGBpV49D2hwXEaOQ='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end