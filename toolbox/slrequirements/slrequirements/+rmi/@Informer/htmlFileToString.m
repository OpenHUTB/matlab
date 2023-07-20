function html=htmlFileToString(htmlFile)





    fid=fopen(htmlFile,'r');
    html=fread(fid,'*char')';
    fclose(fid);
    html=cleanupHtml(html);
    html=fullPathToImages(html,htmlFile);
end

function html=cleanupHtml(html)
    html=regexprep(html,'<head>[\s\S]+*?</head>','');
    html=regexprep(html,'^[\s\S]*<html[^>]*?>','');
    html=regexprep(html,'</html>[\s\S]*$','');
    html=regexprep(html,'<body[^>]*?>','');
    html=regexprep(html,'</body>','');
    html=regexprep(html,'\s+\n','\n');
    html=regexprep(html,'<span\s+style=[^>]+>&nbsp;</span>','');
    html=regexprep(html,'<!--[\s\S]*?-->','');
    htmlNoRmiDiv=regexprep(html,'<div id=RmiTarget[^>]*?>','');
    if~strcmp(htmlNoRmiDiv,html)
        html=regexprep(htmlNoRmiDiv,'</div>\s+$','');

        html=regexprep(html,' border=0',' border=1');

        html=regexprep(html,'<!\[if supportMisalignedColumns\]>[\s\S]+?<!\[endif\]>','');

        html=vshapeToImg(html);
    end
end

function html=vshapeToImg(origHtml)
    html=regexprep(origHtml,'<v:shapetype\s[\S\s]+?</v:shapetype>','');
    if strcmp(html,origHtml)

        return;
    end
    vshapeStart=regexp(html,'<v:shape\s');
    vshapeEnd=regexp(html,'</v:shape>');
    if~isempty(vshapeStart)&&length(vshapeStart)==length(vshapeEnd)
        tailLength=length('</v:shape>');
        for i=length(vshapeStart):-1:1
            vshapeData=regexp(html(vshapeStart(i):vshapeEnd(i)),'<v:shape\s+[^>]*?(style=''[^'']+'')[\S\s]+?<v:imagedata\s(src="[^"]+?")','tokens');
            if~isempty(vshapeData)
                myTokens=vshapeData{1};
                html=[html(1:vshapeStart(i)),'img ',myTokens{2},' ',myTokens{1},html(vshapeEnd(i)+tailLength-1:end)];
            end
        end
    end
end

function html=fullPathToImages(html,origFilePath)
    imgSrcAttr=' src="';
    srcAttrPositions=regexpi(html,'\ssrc="');
    if~isempty(srcAttrPositions)
        attrLength=length(imgSrcAttr);
        [parentDir,imageSubDir]=fileparts(origFilePath);
        matchLength=length(imageSubDir);
        insertionString=[parentDir,filesep];
        for i=length(srcAttrPositions):-1:1
            pos=srcAttrPositions(i);
            if strncmp(html(pos+attrLength:end),imageSubDir,matchLength)
                html=[html(1:pos+attrLength-1),insertionString,html(pos+attrLength:end)];
            end
        end
    end
end

