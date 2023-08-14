function utDisplayTablePreviewLinesWithContinuation(previewLines)


    previewLinesNoEmph=regexprep(previewLines,'</?strong>','');
    linesMatch=regexp(previewLinesNoEmph,'^(_|\s)+$');
    lineIdx=find(~cellfun(@isempty,linesMatch),1,'first');
    txtLine=previewLinesNoEmph{lineIdx};
    contLine=locGetContinuationLineFromContentLine(txtLine);
    fprintf('%s\n',previewLines{:},contLine);
end

function contLine=locGetContinuationLineFromContentLine(txtLine)


    firstNonSpaces=regexp(txtLine,'(^|(?<=\s))\S');
    if isempty(firstNonSpaces)




        firstNonSpaces=1;
    end

    contLine=repmat(' ',1,max(firstNonSpaces));

    contLine(firstNonSpaces)=':';
end

