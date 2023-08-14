function result=getObjAttribute(moduleIdStr,objNum,attribute,varargin)




    objNumStr=rmidoors.getNumericStr(objNum,moduleIdStr);

    isAnyAttribute=false;
    switch attribute
    case 'labelText'
        cmdStr=['dmiObjLabel_("',moduleIdStr,'",',objNumStr,')'];
    case 'isValid?'
        cmdStr=['dmiObjIsValid_("',moduleIdStr,'",',objNumStr,')'];
    case 'user attributes'
        cmdStr=['dmiObjGetAttributes_("',moduleIdStr,'",',objNumStr,', "false")'];
    case 'all attributes'
        cmdStr=['dmiObjGetAttributes_("',moduleIdStr,'",',objNumStr,', "true")'];
    case 'textAsHtml'
        cmdStr=['dmiObjGetHtml_("',moduleIdStr,'",',objNumStr,',"Object Text")'];
    case 'picture'
        pictureFileName=strrep(varargin{1},'\','\\');
        cmdStr=['dmiObjGetPicture_("',moduleIdStr,'",',objNumStr,', "',pictureFileName,'")'];
    otherwise
        if attribute(1)=='@'
            columnIdx=attribute(2:end);
            cmdStr=['dmiObjColToHtml_("',moduleIdStr,'",',objNumStr,',',columnIdx,')'];
        else
            isAnyAttribute=true;
            cmdStr=['dmiObjGet_("',moduleIdStr,'",',objNumStr,',"',attribute,'")'];
        end
    end


    hDoors=rmidoors.comApp();
    rmidoors.invoke(hDoors,cmdStr);
    doorsResult=hDoors.Result;

    if strncmp(doorsResult,'DMI Error:',10)
        if isAnyAttribute

            matched=regexp(doorsResult,'attribute ''(.+)'' does not exist','tokens');
            if~isempty(matched)
                badName=matched{1}{1};
                error(message('Slvnv:reqmgt:InvalidAttributeName',badName,objNumStr,moduleIdStr));
            else
                error(message('Slvnv:reqmgt:DoorsApiError',doorsResult));
            end
        else
            error(message('Slvnv:reqmgt:DoorsApiError',doorsResult));
        end
    else
        doEval=any(strcmpi(attribute,{'ExternalLinks','ChildIds','user attributes','all attributes'}));
        if doEval

            doorsResult=rmiut.filterChars(doorsResult,false);
            if strcmp(attribute,'ExternalLinks')&&contains(doorsResult,'<!DOCTYPE HTML ')


                doorsResult=removeRichAnnotationContent(doorsResult);
            end
            try
                result=eval(doorsResult);
            catch ex
                if strcmpi(attribute,'ChildIds')&&any(doorsResult=='[')









                    doorsResult=rmidoors.fixUnevenTable(doorsResult);
                    try
                        result=eval(doorsResult);
                    catch ex2
                        rmiut.warnNoBacktrace('Slvnv:reqmgt:doors_obj_open:FailedToEvaluate',...
                        doorsResult,ex2.identifier,ex2.message);
                        result=[];
                    end
                else

                    rmiut.warnNoBacktrace('Slvnv:reqmgt:doors_obj_open:FailedToEvaluate',...
                    doorsResult,ex.identifier,ex.message);
                    result=[];
                end
            end
        else
            result=strtrim(doorsResult);
            if~isempty(result)&&strcmp(attribute,'textAsHtml')

                result=replaceBulletPoints(result);
                if containsTable(result)
                    html=restoreHtmlTables(result);


                    result=removeEmptyCellsFixStyles(html);
                end
            end
        end
    end
end

function html=replaceBulletPoints(html)
    if contains(html,'src=bullet.gif')
        html=strrep(html,'<img src=bullet.gif alt="Bullet point">','<font face=Symbol>&#183;&nbsp;&nbsp;</font>');
    end
end

function noHtml=removeRichAnnotationContent(withHtml)
    noHtml=regexprep(withHtml,'<!DOCTYPE HTML .+ \(annotation\)','RICH_TEXT_ANNOTATION');
end



















function tf=containsTable(html)
    tf=~isempty(regexp(html,'<DIV style="margin-left: \d+px"> <br>[^\n]+&nbsp;&nbsp;&nbsp;&#9;','once'));
end

function html=restoreHtmlTables(fromDOORS)













    while true

        noEmptyStyles=regexprep(fromDOORS,'<[^/>]+> </[^>]+>',' ');
        if strcmp(noEmptyStyles,fromDOORS)
            break;
        else
            fromDOORS=noEmptyStyles;
        end
    end
    noClosingDiv=strrep(noEmptyStyles,[newline,'</DIV>'],newline);
    withTableStarts=regexprep(noClosingDiv,'<DIV style="margin-left: \d+px"> <br>',[newline,'<TABLE border=1 cellspacing=0>',newline,'<TR><TD>']);
    styleRowSeparators=regexprep(withTableStarts,'&nbsp;&nbsp;&nbsp;&#9;</(\S+)> <br> <br>',['</TD></$1></TR>',newline,'<TR><TD>']);
    withRowSeparators=strrep(styleRowSeparators,'&nbsp;&nbsp;&nbsp;&#9; <br> <br>',['</TD></TR>',newline,'<TR><TD>']);
    withTableEnds=strrep(withRowSeparators,['&nbsp;&nbsp;&nbsp;&#9; <br>',newline],['</TD></TR>',newline,'</TABLE>',newline]);

    html=strrep(withTableEnds,'&nbsp;&nbsp;&nbsp;&#9;','</TD><TD>');
end

function html=removeEmptyCellsFixStyles(html)


    if contains(html,'<TD></TD>')||~isempty(regexp(html,'</TD></[^T]'))%#ok<RGXP1>
        rows=strsplit(html,newline);
        html='';
        colCount=0;
        for i=1:numel(rows)
            row=rows{i};
            if startsWith(row,'<TABLE')||endsWith(row,'</TABLE>')
                colCount=0;
            elseif startsWith(row,'<TR>')||endsWith(row,'</TR>')
                myCount=max([numel(strfind(row,'<TD>')),numel(strfind(row,'</TD>'))]);
                if colCount==0
                    colCount=myCount;
                else

                    while myCount>colCount&&contains(row,'<TD></TD>')
                        row=strrep(row,'<TD></TD>','');
                        myCount=myCount-1;
                    end
                end
                matchStyleClosingTag=regexp(row,'</TD>(</[^T]+?)</TR>','tokens');
                if~isempty(matchStyleClosingTag)
                    closingTag=matchStyleClosingTag{1}{1};
                    openingTag=reverseTag(closingTag);

                    row=strrep(row,openingTag,'');

                    row=strrep(row,'<TD>',['<TD>',openingTag]);
                    row=strrep(row,'</TD>',[closingTag,'</TD>']);
                end
            end
            html=[html,row,newline];%#ok<AGROW>
        end
        html(end)=[];
    end

    function out=reverseTag(in)
        out='';
        for j=length(in):-1:1
            c=in(j);
            switch c
            case '/'
                continue;
            case '<'
                c='>';
            case '>'
                c='<';
            otherwise
            end
            out=[out,c];%#ok<AGROW>
        end
    end
end

