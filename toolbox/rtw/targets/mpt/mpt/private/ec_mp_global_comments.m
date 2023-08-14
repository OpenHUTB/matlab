function[abstract,history,notes,otherSym,otherTxt]...
    =ec_mp_global_comments(modelName)
























    mpmResult=rtwprivate('rtwattic','AtticData','mpmResult');
    if isempty(mpmResult)|isfield(mpmResult,'warning')==0
        mpmResult.warning={};
    end

    ecac=rtwprivate('rtwattic','AtticData','ecac');
    if isfield(ecac,'globalComments')==0
        ecac.globalComments={};
    end
    allTsym='';
    allPcomment='';
    fileName='';





    sfb=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','SubSystem','MaskType','Stateflow');

    if isempty(sfb)==0
        for i=1:length(sfb)
            noteList=sf_get_note(sfb{i});
            for q=1:length(noteList)
                comment=noteList{q}.comment;
                [pcomment,tsym,csym]=parse_comment_string(comment);
                if isempty(tsym)==0
                    ecac.globalComments{end+1}=comment;
                    allTsym{end+1}=fliplr(deblank(fliplr(deblank(tsym))));
                    allPcomment{end+1}=pcomment;
                    object.name=pcomment;
                    status=register_object_with_sym(fileName,tsym,object);
                end
            end
        end
    end


    cr=sprintf('\n');


    anno=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FindAll','on','type','annotation');
    if isempty(anno)==0
        for i=1:length(anno)
            comment=get_param(anno(i),'Name');
            if isempty(comment)==1,continue;end;
            [pcomment,tsym,csym]=parse_comment_string(comment);
            if isempty(tsym)==0
                ecac.globalComments{end+1}=comment;
                allTsym{end+1}=fliplr(deblank(fliplr(deblank(tsym))));

                allPcomment{end+1}=pcomment;
                object.name=pcomment;
            end
        end
    end


    [temp,indx]=sort(allTsym);
    tempComment=allPcomment(indx);
    len=[];
    for j=1:length(temp)
        len=[len,length(temp{j})];
    end
    maxlen=max(len);

    if length(temp)>1

        rep='';
        msg='   The list of note or annotation name collision:';


        newList{1}='';
        newpcomment{1}='';

        tempc='';
        cc=0;
        for nn=1:length(temp)-1
            if isequal(temp{nn},temp{nn+1})==1
                cc=cc+1;
                rep{end+1}=temp{nn};



                tempc=[tempc,'      (',num2str(cc+1),'): ',tempComment{nn+1},cr];
            else
                if nn>1
                    newList{end+1}=temp{nn};
                    if cc==0
                        newpcomment{end+1}=tempComment{nn};
                    else
                        newpcomment{end+1}=[cr,'      (1): ',...
                        tempComment{nn-cc},cr,tempc];
                    end
                    cc=0;
                    tempc='';
                else
                    newList{1}=temp{nn};
                    newpcomment{1}=tempComment{nn};
                end
            end
        end

        nn=length(temp);
        newList{end+1}=temp{nn};
        if cc==0
            newpcomment{end+1}=tempComment{nn};
        else
            newpcomment{end+1}=[cr,'      (1): ',tempComment{nn-cc},cr,tempc];
        end
















    else
        newList=temp;
        newpcomment=tempComment;
    end
    rtwprivate('rtwattic','AtticData','mpmResult',mpmResult);



    noteSym={};
    noteTxt={};
    abstractSym={};
    abstractTxt={};
    historySym={};
    historyTxt={};
    otherSym={};
    otherTxt={};

    abstract='';
    history='';
    notes='';

    for k=1:length(newList)
        tsym=newList{k};
        pcomment=newpcomment{k};
        tsymC=upper(tsym);
        object.name=pcomment;
        if strcmp(tsymC,'ABSTRACT')==1

            abstractSym{end+1}='Abstract';
            abstractTxt{end+1}=pcomment;
        elseif strcmp(tsymC,'HISTORY')==1

            historySym{end+1}='History';
            historyTxt{end+1}=pcomment;
        elseif(isempty(regexp(tsymC,'^NOTE'))==0)
            noteSym{end+1}=tsym;
            noteTxt{end+1}=pcomment;
        else
            otherSym{end+1}=tsym;
            otherTxt{end+1}=pcomment;
        end
    end

    if~isempty(abstractSym)
        abstract=order_doc_text('Abstract',abstractSym,abstractTxt,fileName);
    end
    if~isempty(historySym)
        history=order_doc_text('History',historySym,historyTxt,fileName);
    end
    if~isempty(noteSym)
        notes=order_doc_text('Notes',noteSym,noteTxt,fileName);
    end


    docSym={};
    docTxt={};


    docList=find_system(modelName,'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','MaskType','DocBlock');

    for i=1:length(docList)
        try
            tagName=get_param(docList{i},'ECoderFlag');
            [tagText,textFormat]=docblock('getContent',docList{i});

            if isempty(tagText)
                rd=get_param(docList{i},'RTWdata');
                if~isempty(rd)

                    sFields=fieldnames(rd);
                    for j=1:length(sFields)
                        if strncmp(sFields{j},'document_text',13)
                            tagText=[tagText,getfield(rd,sFields{j})];
                        end
                    end
                else
                    tagText='';
                end
            else
                tagText=tagText(:)';
            end

            if~isempty(tagName)&&~strcmp(textFormat,'TXT')&&~strcmp(textFormat,'UNDEF')

                MSLDiagnostic('RTW:mpt:CommentsfromDocBlockIsNotText',docList{i},tagName).reportAsWarning;
            else
                if strcmp(textFormat,'TXT')||strcmp(textFormat,'UNDEF')
                    tagText=strrep(tagText,sprintf('\r'),'');
                end
                docSym{end+1}=fliplr(deblank(fliplr(deblank(tagName))));
                docTxt{end+1}=tagText;
                otherSym{end+1}=docSym{end};
                otherTxt{end+1}=docTxt{end};
                comment=[tagName,tagText];
                ecac.globalComments{end+1}=comment;
            end
        catch merr
            disp(merr.getReport);
        end
    end
    rtwprivate('rtwattic','AtticData','ecac',ecac);
    return


    function[resolvedSymbol]=order_doc_text(symbol,noteSym,noteTxt,fileName)

        cr=sprintf('\n');

        objTemp='';
        if length(noteSym)>1
            len=[];
            for j=1:length(noteSym)
                len=[len,length(noteSym{j})];
            end
            maxlen=max(len);
            for i=1:length(noteSym)

                objTemp=[objTemp,noteSym{i},': ',noteTxt{i},cr,'   '];

            end
            object.name=objTemp;
            status=register_object_with_sym(fileName,symbol,object);
            resolvedSymbol=objTemp;
        elseif length(noteSym)==1
            object.name=noteTxt{1};
            status=register_object_with_sym(fileName,symbol,object);
            resolvedSymbol=noteTxt{1};
        end

