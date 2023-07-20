function usersOut=filterUsersInShippingLibraries(usersIn)





    keep=true(size(usersIn));

    for i=1:numel(usersIn)
        thisUser=usersIn{i};
        userType=get_param(thisUser,'Type');
        if strcmp(userType,'block')
            linkStatus=get_param(thisUser,'LinkStatus');
            if strcmp(linkStatus,'resolved')||strcmp(linkStatus,'implicit')
                referenceBlock=get_param(thisUser,'ReferenceBlock');
                libraryName=strtok(referenceBlock,'/');
                switch libraryName
                case 'simulink'
                    keep(i)=false;
                    continue;
                otherwise
                    libraryPath=which(libraryName);
                    toolboxRoot=[matlabroot,filesep,'toolbox'];
                    if strncmp(libraryPath,toolboxRoot,numel(toolboxRoot))
                        keep(i)=false;
                        continue;
                    end
                end
            end
        end
    end

    usersOut=usersIn(keep);

end

