function GroundToFrom(block,BlockName,IsLibrary)






    if strcmp(get_param([block,'/',BlockName],'blocktype'),'Ground')
        replace_block(block,'Followlinks','on','SearchDepth',1,'Name',BlockName,'From','noprompt');
    end

    SetNewGotoTag([block,'/',BlockName],IsLibrary);