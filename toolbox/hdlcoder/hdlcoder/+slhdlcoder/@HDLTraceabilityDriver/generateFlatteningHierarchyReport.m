
function generateFlatteningHierarchyReport(this,flattening_pipe_file,title,model,p,JavaScriptBody)




    w=hdlhtml.reportingWizard(flattening_pipe_file,title);
    w.setHeader(title);
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end
    w.addBreak(3);
    w.addCollapsibleJS;
    hDrv=hdlcurrentdriver;
    modelMarkedForFlattening=false;
    ntks=p.Networks;
    flatenSetOffNtks=[];




    for i=length(ntks):-1:1
        if(strcmpi(ntks(i).getFlattenHierarchy(),'on')||ntks(i).hasUserFlattenedNics())
            modelMarkedForFlattening=true;
            break;
        end
    end

    if~modelMarkedForFlattening
        w.addText(DAStudio.message('hdlcoder:report:FHNoSubsystemFound'));
        w.addBreak(2);
    else
        section=w.createSectionTitle(DAStudio.message('hdlcoder:report:FHListOfSubsystems'));
        w.commitSection(section);
        w.addBreak(2);
        w.addFormattedText(['<li>',DAStudio.message('hdlcoder:report:FHTurnedOnTitle'),'</li>'],'b');
        if~isempty(p.userFlattenReqNetworks)

            listFHenabled=w.createList;
            flattenReqNtks=p.userFlattenReqNetworks;
            for i=1:numel(flattenReqNtks)
                if~isempty(flattenReqNtks{i})
                    listFHenabled.createEntry(hdlhtml.reportingWizard.generateSystemLink(flattenReqNtks{i}));
                end
            end
            addOnclickEvent(w,numel(flattenReqNtks),'onList',0);
            addCompLinks(w,listFHenabled,numel(flattenReqNtks),'onList');
            w.addBreak(2);

            for i=length(ntks):-1:1
                flattenSetOff=strcmpi(ntks(i).getFlattenHierarchy(),'off')&&~ntks(i).Synthetic;
                if flattenSetOff
                    flatenSetOffNtks=[flatenSetOffNtks,ntks(i)];%#ok<AGROW>
                end
            end

            if~isempty(flatenSetOffNtks)
                w.addFormattedText(['<li>',DAStudio.message('hdlcoder:report:FHTurnedOffTitle'),'</li>'],'b');
                listFHdisabled=w.createList;
                for i=1:length(flatenSetOffNtks)
                    listFHdisabled.createEntry(hdlhtml.reportingWizard.generateSystemLink(flatenSetOffNtks(i).FullPath));
                end
                addOnclickEvent(w,numel(flatenSetOffNtks),'offList',0);
                addCompLinks(w,listFHdisabled,numel(flatenSetOffNtks),'offList');
                w.addBreak(2);
            end
        end



        noOpportunities=false;
        if numel(p.userFlattenReqNetworks)==1
            topNtk=p.getTopNetwork();
            flattenReqNtks=p.userFlattenReqNetworks;
            isTopNetwork=isequal(topNtk.FullPath,flattenReqNtks{1});
            noOpportunities=isTopNetwork&&~topNtk.hasUserFlattenedNics();
        end

        section=w.createSectionTitle(DAStudio.message('hdlcoder:report:FHStatusTitle'));
        w.commitSection(section);
        w.addBreak(2);
        if noOpportunities

            w.addText(DAStudio.message('hdlcoder:report:FHOpportunities'));
            w.addBreak(2);
        else
            flatteningSucc=reportFlatteningHierarchyInfo(w,p);
            if flatteningSucc
                w.addText(DAStudio.message('hdlcoder:report:FHSuccessful'));
                w.addBreak(2);
            end
        end
    end

    if hdlgetparameter('generatevalidationmodel')
        this.publishValidationModelLink(w,model);
        w.addBreak;
    end

    if hDrv.mdlIdx==numel(hDrv.AllModels)

        if(isprop(hDrv.BackEnd,'OutModelFile'))
            this.publishGeneratedModelLink(w,hDrv.BackEnd.OutModelFile);
        end
    else

        genMdlName=getGeneratedModelName(hDrv.getParameter('generatedmodelnameprefix'),...
        p.ModelName,false);
        this.publishGeneratedModelLink(w,genMdlName);
    end

    w.addBreak;
    w.dumpHTML;
end


function flatteningStatus=reportFlatteningHierarchyInfo(w,p)
    flatteningStatus=true;
    displayInlineNote=false;

    ntks=p.Networks;
    validNtks=[];

    for i=1:length(ntks)
        if~isempty(ntks(i).getFlattenHierarchyStatusList)&&~ntks(i).Synthetic
            ntk=ntks(i);
            validNtks=[validNtks,ntk];%#ok<AGROW>
            flatteningStatus=false;
        end
    end

    if~isempty(validNtks)
        w.addText(DAStudio.message('hdlcoder:report:FHUnSuccessful'));
        w.addBreak(2);

        table=w.createTable(length(validNtks),2);
        table.setAttribute('width','100%');
        table.setColHeading(1,DAStudio.message('hdlcoder:report:subsystemColumnHeading'));
        table.setColHeading(2,DAStudio.message('hdlcoder:report:reasonsColumnHeading'),'center');

        for i=1:length(validNtks)
            messageList=[];
            ntk=validNtks(i);
            isInlined=isNetworkInlined(ntk);


            if~isempty(ntk.FullPath)
                ntwkpath=hdlhtml.reportingWizard.generateSystemLink(ntk.FullPath);
            else
                ntwkpath=ntk.Name;
            end


            if isInlined
                ntwkpath=[ntwkpath,'<span style="color:Tomato;">*</span>'];%#ok<AGROW>
                table.createEntry(i,1,ntwkpath);
                displayInlineNote=true;
            else
                table.createEntry(i,1,ntwkpath);
            end

            msgList=ntk.getFlattenHierarchyStatusList;
            if~isempty(msgList)

                for jj=1:length(msgList)
                    messageList=[messageList,'<li>',msgList{jj},'</li>'];%#ok<AGROW>
                end
                table.createEntry(i,2,messageList);
            end
        end

        w.commitTable(table);

        if displayInlineNote
            inLineNote=['<h5 style = "white-space:nowrap;text-align:left;line-height:0px;">',DAStudio.message('hdlcoder:report:FHInLineNote'),'</h5>'];
            w.addFormattedText(inLineNote,'b');
        end
        w.addBreak(1);
    end
end


function inliningStatus=isNetworkInlined(ntwk)
    inliningStatus=true;

    if strcmpi(ntwk.getFlattenHierarchy(),'off')
        inliningStatus=false;
        return;
    end

    if(ntwk.isRAM||ntwk.isNfpNetwork||ntwk.dontTouch...
        ||(ntwk.NumberOfPirGenericPorts>0))
        inliningStatus=false;
    end
end


function jsCmd=addOnclickEvent(w,numElem,typeid,isUserDefined)
    jsCmd='';
    if numElem>0&&~isUserDefined
        jsCmd=['hdlTableShrink(this, ''',typeid,''')'];
        section=w.createSection('[+]','span');
        section.setAttribute('name','collapsible');
        section.setAttribute('id','collapsible');
        section.setAttribute('style','font-family:monospace');
        section.setAttribute('onclick',jsCmd);
        section.setAttribute('onmouseover','this.style.cursor = ''pointer''');
        w.commitSection(section);
    end
end


function addCompLinks(w,list,numElem,typeid)
    if(numElem)>0
        section=w.createSection('','span');
        section.setAttribute('name',typeid);
        section.setAttribute('id',typeid);
        section.setAttribute('style','display: none;');
        section.createEntry(list);
        w.commitSection(section);
    end
end


