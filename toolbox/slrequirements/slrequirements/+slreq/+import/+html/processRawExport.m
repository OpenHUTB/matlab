function html=processRawExport(rawFile,resourceVarPath,srcType)




    fid=fopen(rawFile,'r');
    html=fread(fid,'*char')';
    fclose(fid);


    if contains(html,'<style id="RmiTarget_Styles">')
        styles=captureStyles(html);
    else
        styles='';
    end

    namespacesChar=captureNamespaces(html);


    html=removeComments(html);
    html=removeUnwantedBreaks(html);
    html=strtrim(extractBodyContent(html));

    html=insertNamespaces(html,namespacesChar);

    if strcmpi(srcType,'EXCEL')
        html=simplifyTableCellFormat(html);
    end
    html=removeOfficeTags(html);
    html=removeShapeTypeInfo(html);
    html=slreq.import.html.absPathToImages(html,resourceVarPath,srcType);

    if~isempty(styles)

        html=[styles,newline,html];
    end

    debugging=false;
    if debugging
        processedFile=strrep(rawFile,'.htm','_clean.htm');

        fod=fopen(processedFile,'w');
        fwrite(fod,html,'char*1');
        fclose(fod);
    end
end

function styles=captureStyles(html)
    matched=regexp(html,'(<style id="RmiTarget_Styles">[\s\S]+</style>)','tokens');
    if isempty(matched)
        styles='';
    else
        styles=matched{1}{1};
    end
end

function html=removeUnwantedBreaks(html)
    html=regexprep(html,'<br\s+clear=all[^>]*>','');
end

function html=removeOfficeTags(html)
    html=regexprep(html,'<o:p></o:p>','');
    html=regexprep(html,'<o:p>','<p>');
    html=regexprep(html,'</o:p>','</p>');
end

function html=simplifyTableCellFormat(html)
    html=regexprep(html,'<!\[if[^!]+!\[endif\]>','');


    html=regexprep(html,'<table\sborder=0\scellpadding=0\s','<table border=1 cellpadding=5 ');
end

function html=removeComments(html)
    html=regexprep(html,'<!--[\s\S]+?-->','');
end

function html=extractBodyContent(html)
    html=regexprep(html,'^[\s\S]+<body[^>]*>','');
    html=regexprep(html,'</body>[\s\S]*</html>','');
end

function html=removeShapeTypeInfo(html)
    html=regexprep(html,'<v:shapetype[\s\S]+?</v:shapetype>','');
end

function namespacesChar=captureNamespaces(html)
    namespacesChar='';
    matched=regexp(html,'(<html[^>]*>)','tokens');
    if isempty(matched)
        namespacesChar='';
    else
        htmlStartTag=matched{1}{1};
        matched=regexp(htmlStartTag,'([^=\s]+=[^\s^>]+)','tokens');
        if isempty(matched)
            namespacesChar='';
        else
            sz=size(matched);
            count=sz(2);
            for id=1:count
                namespacesChar=append(namespacesChar,matched{id}{1});
                namespacesChar=[namespacesChar,' '];
            end
        end
    end
end

function html=insertNamespaces(inHtml,namespacesChar)
    html=inHtml;
    if~isempty(namespacesChar)
        html=insertAfter(inHtml,'<div ',namespacesChar);
    end
end
