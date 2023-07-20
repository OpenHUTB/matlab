function[html,summary,targetFilePath]=paragsToHtml(this,label,startP,endP,richText,ignoreOutlineNumbers)




    if richText
        this.initPaths();
    end

    if nargin<5
        richText=true;
    end

    if nargin<6
        ignoreOutlineNumbers=false;
    end




    myRange=this.hTempDoc.Range;
    myRange.Start=this.iStarts(startP);
    myRange.End=this.iEnds(endP);


    paragIdx=startP;
    paragText=this.getText(paragIdx);

    while isempty(paragText)&&paragIdx<endP

        paragIdx=paragIdx+1;
        paragText=this.getText(paragIdx);
    end
    if~isempty(paragText)
        if this.iLevels(startP)>0

            summary=this.makeSummary(paragText,true);
        else



            summary=this.getLabel(startP);
        end
    else


        summary=sprintf('parag-%d-%d',startP,endP);
    end

    if richText

        targetFilePath=rmidotnet.getCacheFilePath(this.htmlFileDir,this.sName,label);














        myFormat=Microsoft.Office.Interop.Word.WdSaveFormat.wdFormatFilteredHTML;







        outlineNumbersConverted=false;
        try


            if myRange.Paragraphs.Count>0



                if~ignoreOutlineNumbers
                    myRange.ListFormat.ConvertNumbersToText();
                    outlineNumbersConverted=true;
                else
                    topParag=myRange.Paragraphs.Item(1);
                    isBodyText=strcmp(topParag.OutlineLevel,'wdOutlineLevelBodyText');
                    if~isBodyText
                        topParagRange=topParag.Range;
                        topParagRange.ListFormat.RemoveNumbers();
                        outlineNumbersConverted=true;
                    end
                end
            end
        catch ex
            if strcmp(ex.identifier,'MATLAB:NET:CLRException:MethodInvoke')
                rmiut.warnNoBacktrace('Slvnv:slreq_import:LocalOutlineNumbers',label);
            else
                rethrow(ex);
            end
        end

        try

            myRange.ExportFragment(targetFilePath,myFormat);
        catch ex
            plainText=myRange.Text.char;
            if outlineNumbersConverted
                this.hTempDoc.Undo();
            end
            rmiut.warnNoBacktrace('Slvnv:slreq_import:PlainTextNoRichText',...
            sprintf('%d-%d',startP,endP),ex.message,plainText);
            infoMsg=getString(message('Slvnv:slreq_import:PlainTextVersionBelow'));
            html=sprintf(...
            '<font color="red">%s</font><br/><br/>%s',infoMsg,plainText);
            return;
        end

        if outlineNumbersConverted
            this.hTempDoc.Undo();
        end



        html=slreq.import.html.processRawExport(targetFilePath,this.resourcePath,'WORD');

    else


        targetFilePath='';







        html='';

        for paragIdx=startP:endP

            paragText=this.getText(paragIdx);

            if isempty(paragText)
                html=[html,'<br/>',newline];%#ok<AGROW>
            else
                paragText=rmiut.plainToHtml(paragText);
                paragLevel=this.iLevels(paragIdx);
                if paragLevel<0
                    html=[html,paragText,'<br/>',newline];%#ok<AGROW>
                elseif paragLevel>6


                    html=[html,'<b>',paragText,'</b><hr/>',newline];%#ok<AGROW>
                else
                    headerTags{1}=['<h',num2str(paragLevel),'>'];
                    headerTags{2}=strrep(headerTags{1},'<','</');
                    html=[html,headerTags{1},paragText,headerTags{2},newline];%#ok<AGROW>
                end
            end

        end
    end
end


