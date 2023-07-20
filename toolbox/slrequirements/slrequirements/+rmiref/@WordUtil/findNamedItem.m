function findNamedItem(hWord,thisDoc,namedItem)




    found=rmiref.WordUtil.searchBookmarks(thisDoc,namedItem);
    if~found
        [found,aborted]=rmiref.WordUtil.searchHeadings(hWord,thisDoc,namedItem);
        if found
            chompSelection(thisDoc);
        elseif~aborted
            error(message('Slvnv:rmiref:WordUtil:findNamedItem',namedItem));
        end
    end

    function chompSelection(myDoc)

        selectedText=myDoc.ActiveWindow.Selection.Text;
        while any(double(selectedText(end))==[9:13,32])
            endOfSelection=myDoc.ActiveWindow.Selection.End;
            if endOfSelection==myDoc.ActiveWindow.Selection.Start
                break;
            else
                myDoc.ActiveWindow.Selection.End=endOfSelection-1;
            end
            selectedText=myDoc.ActiveWindow.Selection.Text;
        end
    end

end


