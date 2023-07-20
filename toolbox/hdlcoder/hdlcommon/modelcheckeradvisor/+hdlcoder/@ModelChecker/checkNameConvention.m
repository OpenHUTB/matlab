function flag=checkNameConvention(this)







    flag=true;


    [candidateBlks,candidateSignals]=hdlcoder.ModelChecker.getInvalidNames(this.m_DUT);
    if~isempty(candidateBlks)||~isempty(candidateSignals)
        flag=false;
    end

    summary=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_name_error');

    for ii=1:numel(candidateBlks)
        path=getfullname(candidateBlks(ii));
        this.addCheck('warning',summary,path,0);
    end
    src_sigPaths={};


    for ii=1:numel(candidateSignals)
        sigH=candidateSignals(ii);
        blkH=get_param(sigH,'SrcBlockHandle');
        if ishandle(blkH)
            path=getfullname(blkH);
            src_sigPaths(end+1)=cellstr(path);
        end
    end

    unique_src_blocks=unique(src_sigPaths);
    for ii=1:numel(unique_src_blocks)
        this.addCheck('warning',summary,unique_src_blocks(ii),0);
    end
end

