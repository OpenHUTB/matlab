function ret=isErtTarget(systemH)













    try
        cfgSet=getMdlConfigSet(bdroot(systemH));
        sysTgt=get_param(cfgSet,'IsERTTarget');
        ret=logical(strcmpi(sysTgt,'on'));
        if isempty(ret)
            ret=false;
        end

    catch Me %#ok<NASGU>
        ret=false;
    end
