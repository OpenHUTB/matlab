






function formattedName=formatFlaggedName(flaggedName,issueType,issuePosition,prefix)

    textBeforeIssue=flaggedName(1:issuePosition(1)-1);
    textIssue=flaggedName(issuePosition(1):issuePosition(2));
    textAfterIssue=flaggedName(issuePosition(2)+1:end);

    formattedName=[...
    textBeforeIssue,...
    '<mark>',textIssue,'</mark>',...
...
    textAfterIssue];

    if issueType==1
        formattedName=[...
        formattedName,...
        '&nbsp;<i>(',...
        Advisor.Utils.Naming.getDASText(prefix,'_Issue_ReservedIdentifier'),...
        ')</i>'];
    end

end



