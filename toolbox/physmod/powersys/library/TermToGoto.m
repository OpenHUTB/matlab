function TermToGoto(block,BlockName,IsLibrary)






    if strcmp(get_param([block,'/',BlockName],'blocktype'),'Terminator')
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name',BlockName,'Goto','noprompt');
    end

    SetNewGotoTag([block,'/',BlockName],IsLibrary);