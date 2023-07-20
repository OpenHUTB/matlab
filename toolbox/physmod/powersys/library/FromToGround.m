function FromToGround(block,BlockName)





    if strcmp(get_param([block,'/',BlockName],'blocktype'),'From')

        replace_block(block,'Followlinks','on','SearchDepth',1,'Name',BlockName,'Ground','noprompt');
    end