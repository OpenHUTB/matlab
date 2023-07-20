function const=...
    getBlockDialogValue(~,slbh)




    const_slbh=find_system(getfullname(slbh),'findAll','on','SearchDepth','1',...
    'LookUnderMasks','all','FollowLinks','on','BlockType','Constant');

    rto=get_param(const_slbh,'RuntimeObject');

    constloc=0;

    for n=1:rto.NumRuntimePrms
        if strcmp(rto.RuntimePrm(n).Name,'Value')
            constloc=n;
            break;
        end
    end

    if constloc==0
        error(message('hdlcoder:validate:constantvaluenotfound'));
    end

    const=rto.RuntimePrm(constloc).Data;

    if isempty(const)
        error(message('hdlcoder:validate:constantvaluenotfound'));
    end


end
