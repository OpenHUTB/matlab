function str=addFLBanner(FileLoc,Prefix,SLSysSub,TopModel)
    if~isempty(SLSysSub)&&~isempty(get_param(SLSysSub,'Description'))

        str=char(join(cellfun(@(x)[Prefix,l_rep_fmt_ch(l_tok_exp(x,FileLoc,SLSysSub)),'\n'],...
        splitlines(get_param(SLSysSub,'Description')),'UniformOutput',false),''));
    elseif~isempty(get_param(TopModel,'Description'))

        str=char(join(cellfun(@(x)[Prefix,l_rep_fmt_ch(l_tok_exp(x,FileLoc,TopModel)),'\n'],...
        splitlines(get_param(TopModel,'Description')),'UniformOutput',false),''));
    else

        str=addUVMGeneratedBy(FileLoc,Prefix);
    end
end

function new_dline=l_tok_exp(dline,fileloc,SLSys)





    tok={'%<Date>','%<FileName>','%<FilePath>','%<HDLV_Ver>','%<MATLAB_Ver>',...
    '%<ModelName>','%<ModelVersion>','%<LastModifiedDate>'};
    if~contains(dline,tok)
        new_dline=dline;
        return;
    end

    [fp,fn,e]=fileparts(fileloc);
    fp=strrep(fp,'\','/');

    tm=ver('matlab');
    vm=['MATLAB ',tm.Version];
    thdlv=ver('hdlverifier');
    if isempty(thdlv)
        vhdlv='';
    else
        vhdlv=['HDL Verifier ',thdlv.Version];
    end

    new_dline=replace(dline,tok,...
    {datestr(now,31),[fn,e],fp,vhdlv,vm,...
    bdroot(SLSys),get_param(bdroot(SLSys),'ModelVersion'),...
    get_param(bdroot(SLSys),'LastModifiedDate')});
end

function str=l_rep_fmt_ch(strwbs)
    str=replace(strwbs,{'\','%'},{'\\','%%'});
end
