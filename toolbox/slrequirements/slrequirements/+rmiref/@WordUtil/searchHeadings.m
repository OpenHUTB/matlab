function[found,aborted]=searchHeadings(hWord,comDocument,namedItem)

    if~isempty(hWord.Selection)
        hWord.Selection.Start=1;
        hWord.Selection.End=hWord.Selection.Start;
        hWord.Selection.HomeKey;
    end

    maxIteration=1000;
    prevViewMode='';
    if~strcmp(comDocument.ActiveWindow.View.Type,'wdNormalView')
        prevViewMode=comDocument.ActiveWindow.View.Type;
        comDocument.ActiveWindow.View.Type='wdNormalView';
    end


    aborted=false;
    found=false;
    hWord.Selection.Find.Text=namedItem;
    if(~hWord.Selection.Find.Execute)
        return;
    end
    comParagraph=hWord.Selection.Paragraphs.Item(1);
    idx=1;
    hDiag=[];
    while true
        drawnow;
        if(idx==maxIteration)
            hDiag=msgbox(...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:Abort')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_word:SearchingHeadersWait')));
        end
        if(idx>maxIteration&&(isempty(hDiag)||~ishandle(hDiag)))
            if ishandle(hDiag)
                delete(hDiag);
            end
            aborted=true;
            break;
        end

        level=getHeaderLevel(comParagraph);

        if level>=0
            comParagraph.Range.Select;
            if(ishandle(hDiag))
                delete(hDiag);
            end
            found=true;
            break;
        end

        if(~hWord.Selection.Find.Execute)
            if(ishandle(hDiag))
                delete(hDiag);
            end
            break;
        end

        comParagraph=hWord.Selection.Paragraphs.Item(1);
        idx=idx+1;
    end

    if~isempty(prevViewMode)
        comDocument.ActiveWindow.View.Type=prevViewMode;
    end



    function level=getHeaderLevel(paragraph)
        outlineLevel=paragraph.OutlineLevel;
        if strcmp(outlineLevel,'wdOutlineLevelBodyText')
            level=-1;
        else
            level=sscanf(outlineLevel,'wdOutlineLevel%d');
        end
    end

end
