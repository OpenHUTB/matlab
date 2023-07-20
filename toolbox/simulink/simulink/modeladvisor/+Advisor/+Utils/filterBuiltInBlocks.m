function usersOut=filterBuiltInBlocks(usersIn)

    flag=false(size(usersIn));

    for i=1:numel(usersIn)
        thisUser=usersIn{i};
        userType=get_param(thisUser,'Type');
        if strcmp(userType,'block')
            linkStatus=get_param(thisUser,'LinkStatus');
            if strcmp(linkStatus,'resolved')||strcmp(linkStatus,'implicit')
                referenceBlock=get_param(thisUser,'ReferenceBlock');
                libraryName=strtok(referenceBlock,'/');
                if strcmp(libraryName,'simulink')||strcmp(libraryName,'sflib')

                    thisUser=regexprep(thisUser,'(\d*)$','');
                    users=regexprep(usersIn,'(\d*)$','');
                    flag=flag|xor(startsWith(usersIn,thisUser),strcmp(users,thisUser));
                end
            end
        end
    end

    usersOut=usersIn(~flag);

end

