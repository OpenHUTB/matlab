function selectContent(dlgSrc,dialogH)




    if(~isempty(dlgSrc.docContents))
        contentIdx=dialogH.getWidgetValue('contentlb')+1;
        locStr=dlgSrc.docContents{2}{contentIdx};



        if isempty(locStr)
            return;
        end




        if strcmp(dlgSrc.reqItems(dlgSrc.reqIdx).reqsys,'linktype_rmi_oslc')
            if oslc.isCollectionItem(dlgSrc.docContents{1}{contentIdx})
                if ReqMgr.rmidlg_hasChanges()



                else


                    [~,nameInfo]=strtok(dlgSrc.reqItems(dlgSrc.reqIdx).doc);
                    projectName=nameInfo(3:end-1);
                    oslc.updateContentsList(projectName,locStr);
                    dlgSrc.updateContents(dialogH,true);
                    return;
                end
            end
        end


        if strcmp(dlgSrc.reqItems(dlgSrc.reqIdx).id,locStr)
            return;
        end

        dlgSrc.reqItems(dlgSrc.reqIdx).id=locStr;



        linkType=rmi.linktype_mgr('resolveByRegName',dlgSrc.reqItems(dlgSrc.reqIdx).reqsys);
        if~isempty(linkType)&&strcmp(linkType.Registration,'linktype_rmi_oslc')&&~contains(locStr,'https://')
            reqItem=oslc.getReqItem(locStr);
            if~isempty(reqItem)
                dlgSrc.reqItems(dlgSrc.reqIdx).id=sprintf('%s (%s)',reqItem.resource,reqItem.identifier);
            end
        end




        if(strcmp(dlgSrc.reqItems(dlgSrc.reqIdx).description,getString(message('Slvnv:reqmgt:NoDescriptionEntered'))))
            update_description=true;
        else
            reply=questdlg([...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:ModifyingExistingLabelWarning')),' ',...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:ModifyingExistingLabelQuestion'))],...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:ModifyingExistingLabelTitle')),...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:Keep')),...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:Update')),...
            getString(message('Slvnv:reqmgt:LinkSet:updateContents:Keep')));
            if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:reqmgt:LinkSet:updateContents:Update')))
                update_description=true;
            else
                update_description=false;
            end
        end
        if update_description
            labelStr=dlgSrc.docContents{1}{contentIdx};

            while strncmp(labelStr,'. ',2)
                labelStr=strrep(labelStr,'. . ','');
            end

            reqDoc=dlgSrc.reqItems(dlgSrc.reqIdx).doc;
            if isempty(linkType)
                linkType=rmi.linktype_mgr('resolveByFileExt',reqDoc);
            end
            if isempty(linkType)


                dlgSrc.reqItems(dlgSrc.reqIdx).description=labelStr;
            else
                switch linkType.Registration
                case 'linktype_rmi_slreq'



                case 'linktype_rmi_simulink'

                    if rmisl.isHarnessIdString(reqDoc)
                        doc=rmisl.harnessIdToEditorName(reqDoc);
                    else
                        [~,doc]=fileparts(reqDoc);
                    end
                    labelStr=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',labelStr,doc));
                case 'linktype_rmi_matlab'



                    if rmisl.isHarnessIdString(reqDoc)
                        doc=rmisl.harnessIdToEditorName(reqDoc);
                        labelStr=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',labelStr,doc));
                    else
                        [~,doc,ext]=fileparts(reqDoc);
                        labelStr=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',labelStr,[doc,ext]));
                    end

                case 'linktype_rmi_oslc'
                    labelStr=oslc.contentLineToLabel(reqDoc,locStr,labelStr);

                otherwise
                    [~,doc,ext]=fileparts(reqDoc);
                    labelStr=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',labelStr,[doc,ext]));
                end
            end
            dlgSrc.reqItems(dlgSrc.reqIdx).description=labelStr;
        end
    end

    currentIdx=dialogH.getWidgetValue('lb')+1;
    if(dlgSrc.reqIdx==currentIdx)
        dlgSrc.tabIndex=0;
        dlgSrc.switchTab=0;
        dialogH.refresh();
    end
end
