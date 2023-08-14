function changeDocItem(dlgSrc,dialogH)



    doc=strtrim(dialogH.getWidgetValue('docEdit'));
    currentIdx=dialogH.getWidgetValue('lb')+1;
    allTypes=rmi.linktype_mgr('all');


    is_url=false;
    page='';
    anchor='';

    if~isempty(doc)

        if dlgSrc.typeItems(dlgSrc.reqIdx)==0||...
            (isFileType(dlgSrc.typeItems(dlgSrc.reqIdx))&&~isSameType(doc,dlgSrc.reqItems(dlgSrc.reqIdx).doc))
            reqTarget=resolveRegTarget();

            if~isempty(reqTarget)
                for i=1:length(allTypes)
                    if(allTypes(i)==reqTarget)
                        dlgSrc.typeItems(dlgSrc.reqIdx)=i;
                        break;
                    end
                end
            end
        end
    end

    function tf=isFileType(typeIdx)
        chosenType=allTypes(typeIdx);
        tf=chosenType.isFile;
    end

    function tf=isSameType(first,second)
        [~,~,firstExt]=fileparts(first);
        [~,~,secondExt]=fileparts(second);
        tf=strcmp(firstExt,secondExt);
    end


    if~isempty(dlgSrc.reqItems)
        if~isempty(doc)&&dlgSrc.typeItems(dlgSrc.reqIdx)>0


            docTypeItem=allTypes(dlgSrc.typeItems(dlgSrc.reqIdx));


            if strcmp(docTypeItem.Registration,'linktype_rmi_url')
                if~is_url
                    [is_url,page,anchor]=rmiut.is_url(doc);
                end
                if is_url
                    doc=page;

                    if~isempty(anchor)
                        dlgSrc.reqItems(dlgSrc.reqIdx).id=['@',anchor];

                        if strcmp(dlgSrc.reqItems(dlgSrc.reqIdx).description,getString(message('Slvnv:reqmgt:NoDescriptionEntered')))
                            dlgSrc.reqItems(dlgSrc.reqIdx).description=anchor;
                        end
                    end
                end
            elseif any(strcmp(docTypeItem.Registration,{'linktype_rmi_simulink'}))



                [~,docName,ext]=fileparts(doc);
                if any(strcmp(ext,docTypeItem.Extensions))
                    doc=docName;
                end
            end

            rmi.history('add',doc,docTypeItem.Registration);
        end


        dlgSrc.reqItems(dlgSrc.reqIdx).doc=doc;
    end

    if dlgSrc.reqIdx==currentIdx
        dialogH.refresh();
    end

    function reqTarget=resolveRegTarget()

        docHistory=[];
        if~isempty(dlgSrc.docHistory)
            docHistory=dlgSrc.docHistory(:,1);
        end
        loc=strcmp(doc,docHistory);
        loc=find(loc);
        if~isempty(loc)&&~strcmp(dlgSrc.docHistory{loc(1),2},'other')
            reqTarget=rmi.linktype_mgr('resolve',...
            dlgSrc.docHistory{loc(1),2},'');


        else


            if exist(doc,'file')==4
                reqTarget=rmi.linktype_mgr('resolveByRegName','linktype_rmi_simulink');

            else

                [is_url,page,anchor]=rmiut.is_url(doc);
                if is_url
                    reqTarget=rmi.linktype_mgr('resolveByRegName','linktype_rmi_url');


                else
                    [~,~,fileExt]=fileparts(doc);
                    switch fileExt
                    case '.slx'
                        reqTarget=rmi.linktype_mgr('resolveByRegName','linktype_rmi_simulink');
                    case '.m'
                        reqTarget=rmi.linktype_mgr('resolveByRegName','linktype_rmi_matlab');
                    case '.sldd'
                        reqTarget=rmi.linktype_mgr('resolveByRegName','linktype_rmi_data');
                    case '.mldatx'
                        reqTarget=rmi.linktype_mgr('resolveByRegName','linktype_rmi_testmgr');
                    otherwise
                        reqTarget=rmi.linktype_mgr('resolve','other',fileExt);
                    end
                end
            end
        end
    end

end

