function cbDesc=findContextBlocksDesc(adSL,c,bType)






    if nargin<3
        bType='';
    elseif~isempty(bType)
        bType=[bType,' '];
    end

    switch lower(getContextType(adSL,c,logical(0)))
    case 'system'
        cbDesc=sprintf(getString(message('RptgenSL:rsl_appdata_sl:allSystemBlocksLabel')),bType);
    case 'model'
        cbDesc=sprintf(getString(message('RptgenSL:rsl_appdata_sl:allReportedSystemBlocksLabel')),bType);
    case 'signal'
        cbDesc=sprintf(getString(message('RptgenSL:rsl_appdata_sl:allConnectedBlocksLabel')),bType);
    case 'block'
        cbDesc=sprintf(getString(message('RptgenSL:rsl_appdata_sl:currentBlockLabel')),bType);
    case 'annotation'
        cbDesc=sprintf(getString(message('RptgenSL:rsl_appdata_sl:noAnnotationBlocksLabel')));
    case 'configset'
        cbDesc=sprintf(getString(message('RptgenSL:rsl_appdata_sl:noConfigSetBlocksLabel')));
    otherwise
        cbDesc=sprintf(getString(message('RptgenSL:rsl_appdata_sl:allModelBlocksLabel')),bType);
    end
