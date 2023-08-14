function libraryTooltip=getTooltip(lTargetRegistry,aCrlName,lineBreaker)

    index=0;
    tbllist={};%#ok<NASGU>
    tblstr={};

    try
        tbllist=coder.internal.getTflTableList(lTargetRegistry,aCrlName);
        for cnt=1:length(tbllist)
            if~strcmp(tbllist(cnt),'private_ansi_tfl_table_tmw.mat')&&...
                ~strcmp(tbllist(cnt),'private_iso_tfl_table_tmw.mat')
                index=index+1;
                tblstr{index}=char(tbllist(cnt));%#ok<AGROW>
            end
        end

        if strcmpi(aCrlName,'none')
            libraryTooltip='';
        else
            libraryTooltip=coder.internal.getTfl(lTargetRegistry,aCrlName).Description;
        end

    catch me %#ok<NASGU>
        libraryTooltip='';
    end

    if~isempty(tblstr)
        libraryTooltip=sprintf([libraryTooltip,lineBreaker,'The selected library contains:',lineBreaker]);
    end

    for i=1:index
        libraryTooltip=sprintf([libraryTooltip,tblstr{i}]);
        if i<index
            libraryTooltip=sprintf([libraryTooltip,lineBreaker]);
        end
    end

end


