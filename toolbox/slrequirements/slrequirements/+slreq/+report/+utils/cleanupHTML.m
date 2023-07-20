function cleanHTML=cleanupHTML(rawText)





    removeDocType=regexprep(rawText,'<!DOCTYPE[^>]*?>\s*','','ignorecase');

    h1style=['<p style="font-size:2em;margin-top:0.67em;',...
    'margin-bottom:0.67em;margin-left:0;margin-right:0;',...
    'font-weight:bold;"'];
    h2style=['<p style="font-size:1.5em;margin-top:0.83em;',...
    'margin-bottom:0.83em;margin-left:0;margin-right:0;',...
    'font-weight:bold;"'];
    h3style=['<p style="font-size:1.17em;margin-top:1em;',...
    'margin-bottom:1em;margin-left:0;margin-right:0;',...
    'font-weight:bold;"'];

    h4style=['<p style="margin-top:1.33em;',...
    'margin-bottom:1.33em;margin-left:0;margin-right:0;',...
    'font-weight:bold;"'];

    h5style=['<p style="font-size:0.83em;margin-top:1.67em;',...
    'margin-bottom:1.67em;margin-left:0;margin-right:0;',...
    'font-weight:bold;"'];

    h6style=['<p style="font-size:.67em;margin-top:2.33em;',...
    'margin-bottom:2.33em;margin-left:0;margin-right:0;',...
    'font-weight:bold;"'];

    replaceHead1=regexprep(removeDocType,'<h1',h1style,'ignorecase');
    replaceHead2=regexprep(replaceHead1,'<h2',h2style,'ignorecase');
    replaceHead3=regexprep(replaceHead2,'<h3',h3style,'ignorecase');
    replaceHead4=regexprep(replaceHead3,'<h4',h4style,'ignorecase');
    replaceHead5=regexprep(replaceHead4,'<h5',h5style,'ignorecase');
    replaceHead6=regexprep(replaceHead5,'<h6',h6style,'ignorecase');

    replaceHead=replaceHead6;

    replaceHeading=regexprep(replaceHead,'</h\d>','</p>','ignorecase');

    currentRawText=replaceHeading;

    doubleQuotesPattern='(<[^>]*?)([^<>\=''"\s]+?)(\=)([^\=<>''"\s]+(?=([^>"]*"[^>"]*")))([^>]*?>)';

    while~isempty(regexp(currentRawText,doubleQuotesPattern,'match'))
        currentRawText=regexprep(currentRawText,doubleQuotesPattern,'$1$2$3"$4"$5');
    end

    singleQuotesPattern='(<[^>]*?)([^<>\=''"\s]+?)(\=)([^\=<>''"\s]+(?=([^>'']*''[^>'']*'')))([^>]*?>)';

    while~isempty(regexp(currentRawText,singleQuotesPattern,'match'))
        currentRawText=regexprep(currentRawText,singleQuotesPattern,'$1$2$3"$4"$5');
    end

    doubleQuoteEndsPattern='(<[^<>]*?\=)([^''">]*?)(>)';
    currentRawText=regexprep(currentRawText,doubleQuoteEndsPattern,'$1"$2"$3');
    addedQuotes=currentRawText;

    listofbooleanattributes={'checked','selected','disabled','readonly',...
    'multiple','ismap','defer','declare','noresize','nowrap','noshade','compact'};
    allbooleanatt=strjoin(listofbooleanattributes,'|');

    currentTextWithQuotes=addedQuotes;
    while~isempty(regexp(currentTextWithQuotes,['<[^<>]*?\s+(',allbooleanatt,')\s+[^<>]*?>'],'match'))
        currentTextWithQuotes=regexprep(currentTextWithQuotes,['(<[^<>]*?\s+)(',allbooleanatt,')(\s+[^<>]*?>)'],'$1$2=''true''$3','ignorecase');
    end

    replacedBool=currentTextWithQuotes;

    listofselfclosetags={'area','base','br','col','command','embed',...
    'hr','img','input','keygen','link','meta','param','source',...
    'track','wbr'};

    allselfclosingtags=strjoin(listofselfclosetags,'|');


    addedEndingTag=regexprep(replacedBool,['<(',allselfclosingtags,')([^>]*?)(?<!/)>'],'<$1$2/>','ignorecase');

    srcpattern='src=\s*"file:///(.*?")';
    standardizedSrc=regexprep(addedEndingTag,srcpattern,'src="$1');

    replaceHeightByRowHeight=regexprep(standardizedSrc,'(<tr[^>]*?[;''\s])height:','$1RowHeight:','ignorecase');
    combineDupStyle=regexprep(replaceHeightByRowHeight,'(<[^>]*?style=")([^"]*)(")(\s*style=")([^"]*)"','$1$2$5$3');
    combineDupStyle=regexprep(combineDupStyle,'(<[^>]*?style=")([^"]*)(")(\s*style='')([^'']*)''','$1$2$5$3');
    removeCollapse=regexprep(combineDupStyle,'(<[^>]*?)(border-collapse:collapse;)([^>]*?>)','$1$3');
    imgOnlinePattern='(<img )(src=")(http[s]*://[^"]*?)("[^>]*?)(/>)';
    newImgSrc=regexprep(removeCollapse,imgOnlinePattern,'<a href="$3$4>image</a>');

    cleanHTML=newImgSrc;
end
