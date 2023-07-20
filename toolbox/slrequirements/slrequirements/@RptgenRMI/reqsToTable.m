function nodeTable=reqsToTable(objReqs,dXML,addSeparators,...
    includeLabels,includeDoc,includeID,...
    list_keywords,details_level,use_id,refSource,reportedDocs)






    if~includeLabels&&~includeDoc&&~includeID
        nodeTable=[];
        return;
    elseif~includeLabels
        nodeTable=cell(0,2);
    elseif~includeDoc&&~includeID
        nodeTable=cell(0,2);
    else
        nodeTable=cell(0,3);
    end

    row=0;
    for i=1:length(objReqs)
        if objReqs(i).linked
            req=objReqs(i);








            linkType=rmi.linktype_mgr('resolveByRegName',req.reqsys);
            if isempty(linkType)
                [~,~,dExt]=fileparts(req.doc);
                linkType=rmi.linktype_mgr('resolve',req.reqsys,dExt);
            end


            row=row+1;
            nodeTable{row,1}=[' ',num2str(i),'. '];


            if includeLabels
                thisField=RptgenRMI.filterChars(req.description);
                if length(thisField)>60&&...
                    details_level>0&&...
                    ~isempty(linkType)&&~isempty(linkType.DetailsFcn)
                    thisField=[thisField(1:60),'..'];
                end
                if isDDLink(thisField)
                    nodeTable{row,2}=formatDDLink(dXML,thisField);
                else
                    nodeTable{row,2}=['"',thisField,'"'];
                end
                nextCol=3;
            else
                nextCol=2;
            end





            docUrl='';
            if includeDoc||includeID
                docUrl=rmi.reqToUrl(req,refSource,rmipref('ReportNavUseMatlab'),linkType);

                if use_id
                    display_string=RptgenRMI.rptToReqLabel(linkType,req,includeDoc,includeID,reportedDocs);
                else
                    display_string=RptgenRMI.rptToReqLabel(linkType,req,includeDoc,includeID);
                end
                if~isempty(docUrl)
                    thisField=dXML.makeLink(docUrl,display_string,'ulink');
                else
                    thisField=display_string;
                end
                nodeTable{row,nextCol}=thisField;
            end

            isSublist=false;

            if list_keywords
                keywords=strtrim(req.keywords);
                if~isempty(keywords)

                    nodeTable{row,2}=covnertToSublist(dXML,nodeTable{row,2},['Tags: ',keywords]);
                    isSublist=true;
                end
            end


            if details_level>0&&~isempty(linkType)&&~isempty(linkType.DetailsFcn)
                if linkType.isFile
                    if rmisl.isDocBlockPath(req.doc)
                        word_state=rmi.mdlAdvState('word');
                        if word_state==0
                            rmicom.wordRpt('init');
                        end
                        docPath=rmisl.docBlockTempPath(req.doc);
                    else
                        docPath=rmi.locateFile(req.doc,refSource);
                        if isempty(docPath)
                            continue;
                        else
                            docPath=rmiut.simplifypath(docPath,filesep);
                        end
                    end
                    content=RptgenRMI.reqDetailsToTable(dXML,linkType,docPath,req.id,details_level,docUrl);
                else
                    content=RptgenRMI.reqDetailsToTable(dXML,linkType,req.doc,req.id,details_level,docUrl);
                end
                if~isempty(content)
                    if isSublist
                        sublist=nodeTable{row,2};
                        sublist.setAttribute('rows','3');
                        sublist.appendChild(dXML.createElement('member',content));
                        nodeTable{row,2}=sublist;

                    else
                        nodeTable{row,2}=covnertToSublist(dXML,nodeTable{row,2},content);
                    end
                end
            end

            if addSeparators





            end

        end
    end
end

function sublist=covnertToSublist(dXML,origContent,newContent)
    sublist=dXML.createElement('simplelist');
    sublist.setAttribute('type','vert');
    sublist.setAttribute('rows','2');
    sublist.appendChild(dXML.createElement('member',origContent));
    sublist.appendChild(dXML.createElement('member',newContent));
end

function yesno=isDDLink(label)
    yesno=~isempty(regexp(label,'\[\S+\.sldd\:\S+\]','once'));
end

function result=formatDDLink(dXML,label)
    tokens=regexp(label,'^\[(\S+\.sldd)\:(\S+)\]\s(.+)','tokens');
    if isempty(tokens)
        result=['"',label,'"'];
    else
        dFile=tokens{1}{1};
        dVar=tokens{1}{2};
        reqLabel=tokens{1}{3};
        ddLabel=[dFile,':',dVar];
        if rmipref('ReportLinkToObjects')
            id=rmide.getGuid(dFile,'',dVar);
            navCmd=['rmiobjnavigate(''',dFile,''',''@',id,''');'];
            ddUrl=rmiut.cmdToUrl(navCmd);
            ddlink=dXML.makeLink(ddUrl,ddLabel,'ulink');
            result=dXML.createElement('simplelist');
            result.setAttribute('type','hor')
            result.setAttribute('columns','2');
            result.appendChild(dXML.createElement('member',['"',reqLabel,'" via ']));
            result.appendChild(dXML.createElement('member',ddlink));
        else
            result=['"',reqLabel,'" via [',ddLabel,']'];
        end
    end
end
