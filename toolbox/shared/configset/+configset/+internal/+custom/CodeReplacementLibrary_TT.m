function tt=CodeReplacementLibrary_TT(cs,~)




    tr=RTW.TargetRegistry.get;

    if isa(cs,'Simulink.ConfigSet')
        hSrc=cs.getComponent('Code Generation').getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        hSrc=cs.getComponent('Target');
    else
        hSrc=cs;
    end

    CRL=hSrc.CodeReplacementLibrary;
    index=0;
    tbllist={};
    try
        tbllist=coder.internal.getTflTableList(tr,CRL);
        for cnt=1:length(tbllist)
            if~strcmp(tbllist(cnt),'private_ansi_tfl_table_tmw.mat')&&...
                ~strcmp(tbllist(cnt),'private_iso_tfl_table_tmw.mat')
                index=index+1;
                tblstr{index}=char(tbllist(cnt));%#ok<AGROW>
            end
        end

        if strcmpi(CRL,'none')
            tt=configset.internal.getMessage('targetSoftwareMathTargetNoneToolTip');
        else
            description=coder.internal.getTfl(tr,CRL).Description;
            tt=message('RTW:configSet:targetSoftwareMathTargetToolTip',description).getString;
        end

    catch me
        tt=message('RTW:configSet:targetSoftwareMathTargetToolTip',me.message).getString;
    end


    for i=1:index
        tt=sprintf([tt,tblstr{i}]);
        if i<index
            tt=sprintf([tt,'\n']);
        end
    end


    if any(ismember({'ansi_tfl_table_tmw.mat','iso_tfl_table_tmw.mat','iso_cpp_tfl_table_tmw.mat'},tbllist))
        tgtlangstdlabel=regexprep(configset.internal.getMessage('RTWTargetLangStdName'),'\s*:\s*$','');
        tt=sprintf('%s\n\n* %s',...
        tt,message('RTW:configSet:crlIncludesLangStdTablesToolTip',tgtlangstdlabel).getString);
    end


