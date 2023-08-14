function GotoToTerm(block,BlockName)





    if strcmp(get_param([block,'/',BlockName],'blocktype'),'Goto')

        replace_block(block,'Followlinks','on','SearchDepth',1,'Name',BlockName,'Terminator','noprompt');
    end