function dsmNames=getVariableDSMNames(varNames,varargin)

    dsmScope='';
    varHeader='xxx_PLC_';

    if~isempty(varargin)
        dsmScope=varargin{1};
    end

    if isempty(dsmScope)
        dsmNames=strcat(varHeader,'VAR_',varNames);
    else
        dsmNames=strcat(varHeader,dsmScope,'_TMP_',varNames);
    end

end