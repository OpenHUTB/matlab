function outputStr=refineHtmlContent(inputStr)


    outputStr=strrep(inputStr,'>','&gt;');
    outputStr=strrep(outputStr,'<','&lt;');
end

