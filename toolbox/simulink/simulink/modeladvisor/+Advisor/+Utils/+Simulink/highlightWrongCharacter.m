function formattedName=highlightWrongCharacter(flaggedName,issuePosition)



    [rows,~]=size(issuePosition);

    for r=1:rows
        textBeforeIssue=flaggedName(1:issuePosition(r,1)-1);
        textIssue=flaggedName(issuePosition(r,1):issuePosition(r,2));
        textAfterIssue=flaggedName(issuePosition(r,2)+1:end);
        flaggedName=[textBeforeIssue,'<mark>',textIssue,'</mark>',textAfterIssue];
        issuePosition=issuePosition+13;
    end

    formattedName=flaggedName;

end