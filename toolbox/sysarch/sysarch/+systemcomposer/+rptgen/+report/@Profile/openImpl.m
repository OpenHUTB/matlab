function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CRpMb0ABVPjNCaR3Wn42tONurfOLOQ7KrpbmHj54ww+cgVYliItHuTsdL5'...
        ,'gwQgmJ3SdTPZDtq1Ty9JNc18Rds3zrmSb0ONGIyXNeZ9d6bt5pfzayMEWh6K'...
        ,'Y+zdTo0uAmHb597OHz9UYhdCUMcwP08APe1rGRQMvox4LVLfI4/jrwrsynQ0'...
        ,'Ksu2Pqxs1yrmmmmR2/3w4PYb6wAdYA=='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end