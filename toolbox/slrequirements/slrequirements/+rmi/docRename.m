function[total_objects,modified_links,total_links]=docRename(modelH,old_doc,new_doc)







    slreq.uri.getPreferredPath(false);
    clp=onCleanup(@()slreq.uri.getPreferredPath(true));




    if rmisl.isComponentHarness(modelH)
        [slReq,sfReq,otherItems]=rmisl.getHarnessObjectsWithReqs(modelH);
        objects=[slReq;sfReq];
    else
        [objects,otherItems]=rmisl.getObjWithReqs(modelH);
    end
    total_objects=length(objects)+length(otherItems);
    total_links=0;
    modified_links=0;
    if total_objects==0
        return;
    else
        for obj=objects'

            reqs=rmi.getReqs(obj);
            [modified,reqs,total_links,modified_links]=updateReqs(reqs,old_doc,new_doc,total_links,modified_links);
            if modified
                if rmisl.is_signal_builder_block(obj)
                    rmi.setReqs(obj,reqs,1,length(reqs));
                else
                    rmi.setReqs(obj,reqs);
                end
            end
        end
        for i=1:length(otherItems)
            myItem=otherItems{i};
            if ischar(myItem)

                [total_links,modified_links]=processMFunctionLinks(myItem,old_doc,new_doc,total_links,modified_links);
            end
        end
    end
end

function[total_links,modified_links]=processMFunctionLinks(myItem,old_doc,new_doc,total_links,modified_links)
    bookmarkData=slreq.utils.getRangesAndLabels(myItem);
    bookmarkIds=bookmarkData(:,1);
    for j=1:length(bookmarkIds)
        myBookmark=bookmarkIds{j};
        reqs=rmiml.getReqs(myItem,myBookmark);
        [modified,reqs,total_links,modified_links]=updateReqs(reqs,old_doc,new_doc,total_links,modified_links);
        if modified
            rmiml.setReqs(reqs,myItem,myBookmark);
        end
    end
end

function[modified,reqs,total_links,modified_links]=updateReqs(reqs,old_doc,new_doc,total_links,modified_links)
    total_links=total_links+length(reqs);
    modified=false;
    for i=1:length(reqs)
        if~isempty(strfind(reqs(i).doc,old_doc))
            if strcmp(old_doc,new_doc)

                if isempty(reqs(i).id)||isempty(reqs(i).description)
                    continue;
                else
                    id=reqs(i).id;
                    if id(1)=='@'
                        reqs(i).id=['?',strtrim(reqs(i).description)];
                        if isempty(strfind(reqs(i).description,id(2:end)))
                            reqs(i).description=[reqs(i).description,' (',id(2:end),')'];
                        end
                    else
                        continue;
                    end
                end
            else
                reqs(i).doc=strrep(reqs(i).doc,old_doc,new_doc);
            end
            modified_links=modified_links+1;
            modified=true;
        end
    end
end
