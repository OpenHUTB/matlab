function openAndReplaceText(filepath,newText,requestLineNumber)




    doc=matlab.desktop.editor.openDocument(filepath);
    doc.Text=newText;
    if requestLineNumber>=0
        doc.goToLine(requestLineNumber)
    end
end
