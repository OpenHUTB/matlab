


function aProcessedMessage=processhtmllinks(aIncomingMessage,aComponent,aCategory,iSeverity,aStageId)
    if isempty(aCategory)
        aCategory='';
    end

    aProcessedMessage=aIncomingMessage;


    if contains(aProcessedMessage,'\')
        expr='(href\s*=\s*")(.*?)("\s*>)';
        aProcessedMessage=regexprep(aProcessedMessage,expr,'$1${strrep($2, ''\\'', ''%5c'')}$3');
    end


    if~i_NeedsHTMLProcessing(aProcessedMessage,aComponent,aStageId,iSeverity)
        return;
    end

    old_sllasterror=sllasterror();%#ok<SLLERR>
    old_lasterror=lasterror();%#ok<LERR>


    [s,e,types]=find_links_l(aProcessedMessage,aCategory);


    aProcessedMessage=process_text(s,e,types,aProcessedMessage);

    sllasterror(old_sllasterror);%#ok<SLLERR>
    lasterror(old_lasterror);%#ok<LERR>

end

function tf=is_in_a_hyperlink(s,sv_hl,ev_hl)
    tf=false;
    for i=1:length(sv_hl)




        if(s+1)>=sv_hl(i)&&s<=ev_hl(i)
            tf=true;
            break;
        end
    end
end

function white_list=get_white_list()
    persistent white_list_storage;
    if isempty(white_list_storage)
        white_list_storage=containers.Map();
        white_list_storage('Dataset')=true;
    end
    white_list=white_list_storage;
end


function[S,E,linkTypes]=find_links_l(stream,category)
    switch category
    case{'Lex','Parse'}
        findFiles=0;
    otherwise
        findFiles=1;
    end

    S=[];
    E=[];
    linkTypes={};

    try




        warningState=warning;
        warning('off','REGEXP:multibyteCharacters');

        [begin_links,end_links]=regexp(stream,'<a href=.*?>.*?</a>');
        pattern='#\d+(\.\d+)*';
        [sv,ev]=regexp(stream,pattern);
        link_ndx=1;
        id_is_inside_link=false;
        warning(warningState);

        for i=1:length(sv)
            s=sv(i);
            e=ev(i);




            if size(begin_links,2)>0
                while link_ndx<=size(begin_links,2)&&end_links(link_ndx)<s
                    link_ndx=link_ndx+1;
                end
                if link_ndx<=size(begin_links,2)&&s>=begin_links(link_ndx)

                    id_is_inside_link=true;
                end
            end

            if s>0&&s<e&&~id_is_inside_link
                S=[S;s];%#ok<AGROW>
                E=[E;e];%#ok<AGROW>
                linkTypes{end+1}='id';%#ok<AGROW>
            end
        end

        if findFiles






            [sv,ev]=regexp(stream,...
            '"[^\x00-\x09\x0B\x0C\x0E-\x1F]*?"|''[^\x00-\x09\x0B\x0C\x0E-\x1F]*?''');











            [sv_hl,ev_hl]=regexp(stream,'(<[ab].*>)(.*?)(</[ab]>)');



            file_hyperlink_white_list=get_white_list();

            for i=1:length(sv)
                s=sv(i);
                e=ev(i);
                if s>0&&s<e&&~is_in_a_hyperlink(s,sv_hl,ev_hl)
                    si=s+1;
                    ei=e-1;
                    if si<ei
                        txt=stream(si:ei);
                        if file_hyperlink_white_list.isKey(txt)
                            continue;
                        end
                        if is_absolute_path_l(txt)
                            [isFile,fileType]=is_a_file_l(txt);
                        else
                            [isFile,fileType]=is_a_file_l(txt);
                        end

                        if isFile
                            S=[S;s];%#ok<AGROW>
                            E=[E;e];%#ok<AGROW>
                            linkTypes{end+1}=fileType;%#ok<AGROW>
                        end
                    end
                end
            end
        end
    catch %#ok<CTCH>

    end

    if~isempty(S)
        S=S-1;
        if any(S<0)
            error('bad');
        end
    end
end


function htmlText=process_text(sv,ev,typesv,infoText)
    htmlText='';

    [b,indx]=sortrows(sv);%#ok<ASGLU>
    sv=sv(indx);
    ev=ev(indx);
    typesv=typesv(indx);

    if(isempty(sv))
        htmlText=infoText;
    else
        for i=1:length(sv)
            s=sv(i)+1;
            e=ev(i);
            linkType=typesv{i};


            if(i==1)
                if(s~=1)
                    firstPart=infoText(1:(s-1));
                else
                    firstPart='';
                end
            else
                firstPart=infoText(ev(i-1)+1:(s-1));
            end


            linkText=infoText(s:e);
            t=linkText;


            if(isspace(t(1)))
                t(1)=[];
            end



            if(isequal(linkType,'id'))
                t(1)=[];
            else
                firstPart=[firstPart,linkText(1)];
                ev(i)=ev(i)-1;
                linkText([1,end])=[];
                t([1,end])=[];
            end






            if isequal(linkType,'mdl')
                t=strrep(t,newline,' ');



                linkText=strrep(linkText,newline,' ');
            end

            t=['''',t,''''];%#ok<AGROW> %put back in single quotes
            t=strrep(t,'\','%5c');
            linkOp=['das_dv_hyperlink(''','DAS',''',''',linkType,''',',t,')"'];

            link=['<a href="matlab:',linkOp,'>',linkText];

            htmlText=[htmlText,firstPart,link,'</a>'];%#ok<AGROW>
        end
    end
    if(~isempty(sv))
        lastLinkIndex=ev(end);
    else
        lastLinkIndex=0;
    end

    if(lastLinkIndex>0&&lastLinkIndex<length(infoText))
        htmlText=[htmlText,infoText((lastLinkIndex+1):end)];
    end

end


function[isFile,fileType]=is_a_file_l(file)
    isFile=0;
    fileType='';

    oldWarn=warning;
    warning off all;
    file=strtrim(file);

    try
        switch exist(file,'file')
        case 0
            try
                get_param(file,'handle');
                isFile=1;
                fileType='mdl';
            catch
                if(evalin('base',['exist(''',file,''', ''var'')']))
                    if(evalin('base',['isa(',file,', ''Simulink.Bus'')']))
                        isFile=1;
                        fileType='bus';
                    end
                end
            end

        case 2
            if file_has_good_extension(file)&&exist(file,'builtin')==0
                isFile=1;
                fileType='txt';
            end
        case 4

            filePath=which(file);
            [~,~,fileExtension]=fileparts(filePath);
            if strcmp(fileExtension,'.slxp')
                isFile=0;
            else
                isFile=1;
                fileType='mdl';
            end
        case 7
            x=dir(file);
            if~isempty(x)
                isFile=1;
                fileType='dir';
            end
        end

    catch exp
        warning(oldWarn);
        rethrow(exp);
    end

    warning(oldWarn);

end


function bIsGoodExtension=file_has_good_extension(aFile)
    bIsGoodExtension=false;
    [~,~,aFileExt]=fileparts(aFile);
    switch aFileExt
    case{'m','mlx','c','cpp','h','hpp'}
        bIsGoodExtension=true;
    end
end


function isAbsPath=is_absolute_path_l(fileName)
    isAbsPath=0;
    if(length(fileName)>=2)
        if(fileName(2)==':'||fileName(1)==filesep)
            isAbsPath=1;
        end

    else
        if(length(fileName)>=1&&(fileName(1)=='/'||fileName(1)=='\'))
            isAbsPath=1;
        end
    end

end


function bNeedsProcessing=i_NeedsHTMLProcessing(aMessage,aComponent,aStageId,iSeverity)


    if strcmp(aStageId,'Simulink:SLMsgViewer:Model_Load_Stage_Name')
        bNeedsProcessing=false;
        return;
    end

    if strcmp(aComponent,'S-function Builder')
        bNeedsProcessing=true;
        return;
    end

    if strcmp(aComponent,'Stateflow')||strcmp(aComponent,'MATLAB Function')||strcmp(aComponent,'Simulink Test')
        bNeedsProcessing=false;
        return;
    end

    if(isequal(iSeverity,slmsgviewer.m_InfoSeverity))
        bNeedsProcessing=false;
        return;
    end

    bNeedsProcessing=~i_IsHyperLinked(aMessage);
end



function bIsAlreadyHyperLinked=i_IsHyperLinked(aMessage)
    if contains(aMessage,'</a>')
        bIsAlreadyHyperLinked=true;
    else
        bIsAlreadyHyperLinked=false;
    end
end
