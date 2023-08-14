function hyperlink=createHyperlink(matlabCommand,hyperlinkText)









    matlabCommand=strrep(matlabCommand,newline,' ');
    hyperlinkText=strrep(hyperlinkText,newline,' ');

    hyperlink=strcat('<a href="matlab:',matlabCommand,'">',hyperlinkText,'</a>');

end