function res=ConfigSSHasValidBlockChoice(handle)




    choice=get_param(handle,'BlockChoice');
    choice=regexprep(choice,'\n',' ');
    m=get_param(handle,'MemberBlocks');
    m1=regexprep(m,'\n',' ');
    if ischar(m1)&&~isempty(m1)
        memberStr=textscan(m1,'%s','delimiter',',');
        members=cellstr(memberStr{1});
        membersN=length(members);
        for index=1:membersN
            if strcmpi(members{index},choice)
                res=true;
                return
            end
        end
    end
    res=false;
end
