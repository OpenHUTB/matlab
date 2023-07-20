



function printSummaryHtml(model,gmModel,log,diagnostics,sanityCheckMessage,commandLog,diagnosticsFile,doSynthesis,offendingBlocksMessage)

    w=hdlhtml.reportingWizard(diagnosticsFile,'Optimization Summary Report');


    w.setHeader(message('hdlcoder:optimization:OptimizationReportTitle',model).getString);
    w.addBreak(3);



    section=w.createSectionTitle(message('hdlcoder:optimization:SectionSummary').getString);
    w.commitSection(section);
    w.addBreak(2);

    w.addText(preformatted(message('hdlcoder:optimization:SummaryLog',...
    sprintf('%.2f',log(end).iterCtrl.minAchievedLatency),sprintf('%.2f',sum([log.elapsedTime]))).getString));
    w.addBreak(1);
    if(~doSynthesis)
        w.addText(preformatted(message('hdlcoder:optimization:PerformSynthesisForAccurateResults').getString));
    end
    w.addBreak(1);

    smtable=w.createTable(length(log),4);
    smtable.getData.setColWidth(1,1);
    smtable.setColHeading(1,DAStudio.message('hdlcoder:optimization:IterationColumnHeading'));
    smtable.setColHeading(2,DAStudio.message('hdlcoder:optimization:CPColumnHeading'));
    smtable.setColHeading(3,DAStudio.message('hdlcoder:optimization:ConstraintColumnHeading'));
    smtable.setColHeading(4,DAStudio.message('hdlcoder:optimization:ElapsedColumnHeading'));
    for i=1:length(log)
        elapsed=[log.elapsedTime];
        smtable.createEntry(i,1,sprintf('%d',i-1));
        smtable.createEntry(i,2,sprintf('%.2f',log(i).iterCtrl.cplatency));
        smtable.createEntry(i,3,sprintf('%.2f',log(i).iterCtrl.constraint));
        smtable.createEntry(i,4,sprintf('%.2f',sum(elapsed(1:i))));
    end
    w.commitTable(smtable);
    w.addBreak(2);


    section=w.createSectionTitle(message('hdlcoder:optimization:SectionDiagnostic').getString);
    w.commitSection(section);
    w.addBreak(2);

    w.addText(preformatted(sprintf('%s\n%s',message('hdlcoder:optimization:FinishNote').getString,commandLog)));
    w.addBreak(2);
    if~isempty(offendingBlocksMessage)
        w.addText(preformatted(message('hdlcoder:optimization:OptimizationInaccurateNote','').getString));
        w.addText(offendingBlocksMessage);
        w.addBreak(3);
    end


    w.addFormattedText(message('hdlcoder:optimization:TimingAnalysis').getString,'b');
    w.addBreak(2);
    if(~isempty(sanityCheckMessage))
        w.addText(preformatted(sprintf('%s\n%s\n',message('hdlcoder:optimization:CPInaccurateNote').getString,sanityCheckMessage)));
    end

    w.addFormattedText(message('hdlcoder:optimization:CriticalPathData').getString,'bi');
    dgList=w.createList;
    for i=1:length(diagnostics)
        cp=diagnostics.path;
        assert(~isempty(cp));
        lastLatency=0;
        cpList=w.createList;
        for j=1:length(cp)
            node=cp(j);
            latency=node.latency;
            if(isempty(node.owner.exactPath))

                ownerPath=message('hdlcoder:optimization:CannotTraceToOriginalModel').getString;

                gmOwnerPath=message('hdlcoder:optimization:CannotTraceToGeneratedModel').getString;
                if(~isempty(node.owner.closestLocatableAncesterPath))

                    ownerPath=sprintf('%s\n%s',ownerPath,message('hdlcoder:optimization:LocateInAncester',hdlhtml.reportingWizard.generateSystemLink(node.owner.closestLocatableAncesterPath)).getString);
                    if isempty(gmModel)
                        gmOwnerPathTemp='';
                    else
                        gmOwnerPathTemp=traceToGeneratedModel(model,gmModel,node.owner.closestLocatableAncesterPath);
                    end
                    if(~isempty(gmOwnerPathTemp))

                        gmOwnerPath=sprintf('%s\n%s',gmOwnerPath,message('hdlcoder:optimization:LocateInAncester',hdlhtml.reportingWizard.generateSystemLink(gmOwnerPathTemp)).getString);
                    end
                end
            else
                ownerPath=node.owner.exactPath;
                if isempty(gmModel)
                    gmOwnerPath='';
                else
                    gmOwnerPath=traceToGeneratedModel(model,gmModel,node.owner.exactPath);
                    if(isempty(gmOwnerPath))
                        gmOwnerPath=message('hdlcoder:optimization:CannotTraceToGeneratedModel').getString;
                    end
                end
            end
            if(isempty(node.notes))
                notes='';
            else

                notes=preformatted(message('hdlcoder:optimization:CannotInsertDelayNote',node.notes).getString);
            end
            nodeList=w.createList;
            ltTable=w.createTable(1,2);
            ltTable.getData.setColWidth(1,1);
            ltTable.createEntry(1,1,sprintf('%.2f',latency-lastLatency));
            ltTable.createEntry(1,2,sprintf('%.2f (%s)',latency,message('hdlcoder:optimization:Cumulative').getString));
            nodeList.createEntry([ModelAdvisor.Text('Latency (ns):'),ltTable.getData]);
            ntTable=w.createTable(1,1);
            ntTable.createEntry(1,1,notes);
            nodeList.createEntry([ModelAdvisor.Text(message('hdlcoder:optimization:Notes').getString),ntTable.getData]);
            ssTable=w.createTable(1,2);
            ssTable.getData.setColWidth(1,1);

            ssTable.createEntry(1,1,message('hdlcoder:optimization:ObjInOriginalModel',hdlhtml.reportingWizard.generateSystemLink(ownerPath)).getString);

            if~isempty(gmModel)
                ssTable.createEntry(1,2,message('hdlcoder:optimization:ObjInGeneratedModel',hdlhtml.reportingWizard.generateSystemLink(gmOwnerPath)).getString);
            end

            nodeList.createEntry([ModelAdvisor.Text(message('hdlcoder:optimization:ParentSubsystemModel').getString),ssTable.getData]);
            drivers=node.drivers;
            drList=makeDriverReceiverList(w,drivers,model,gmModel,true);
            nodeList.createEntry([ModelAdvisor.Text('Driver:'),drList.getData]);
            receivers=node.receivers;
            rvList=makeDriverReceiverList(w,receivers,model,gmModel,false);
            nodeList.createEntry([ModelAdvisor.Text('Receivers:'),rvList.getData]);
            cpList.createEntry([ModelAdvisor.Text(sprintf('Signal %d',j)),nodeList.getData]);

            lastLatency=latency;
        end

        dgList.createEntry([ModelAdvisor.Text(message('hdlcoder:optimization:CriticalPathNote',sprintf('%d',i),sprintf('%.2f',cp(end).latency)).getString),cpList.getData]);
    end
    section=w.createSection('','span');
    section.createEntry(dgList);
    w.commitSection(section);


    w.dumpHTML;
end

function drTable=makeDriverReceiverList(w,drs,model,gmModel,isDriver)
    if(isDriver)
        direction='out';
    else
        direction='in';
    end
    drTable=w.createTable(max(1,length(drs)),2);
    drTable.getData.setColWidth(1,1);
    if(~isempty(drs))
        for k=1:length(drs)
            dr=drs(k);

            drTable.createEntry(k,1,message('hdlcoder:optimization:ObjInOriginalModel',sprintf('%s/%d',generateSystemLink(dr.original,direction,dr.portIdx),dr.portIdx+1)).getString);
            if~isempty(gmModel)
                gmPath=traceToGeneratedModel(model,gmModel,dr.original);
                if(isempty(gmPath))

                    drTable.createEntry(k,2,message('hdlcoder:optimization:CannotTraceToGeneratedModel').getString);
                else

                    drTable.createEntry(k,2,message('hdlcoder:optimization:ObjInGeneratedModel',sprintf('%s/%d',generateSystemLink(gmPath,direction,dr.portIdx),dr.portIdx+1)).getString);
                end
            end
        end
    else


        omPath=message('hdlcoder:optimization:CannotTraceToOriginalModel').getString;
        drTable.createEntry(1,1,omPath);
        if~isempty(gmModel)
            gmPath=message('hdlcoder:optimization:CannotTraceToGeneratedModel').getString;
            drTable.createEntry(1,2,gmPath);
        end
    end
end

function gmBlkPath=traceToGeneratedModel(~,gmModel,blkPath)
    gmBlkPath=[gmModel,blkPath(length(bdroot(blkPath))+1:end)];
    gmBlkPath=strrep(gmBlkPath,char(10),' ');
    try


        gmBlk=find_system(gmBlkPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    catch me
        if(strcmpi(me.identifier,'Simulink:Commands:FindSystemInvalidPVPair')||...
            strcmpi(me.identifier,'Simulink:Commands:FindSystemNoBlock'))
            gmBlk='';
        else
            rethrow(me);
        end
    end
    candidateIdx=find(strcmp(gmBlk,gmBlkPath));
    if(length(candidateIdx)~=1)
        gmBlkPath='';
    end
end

function linkedPath=generateSystemLinkFromHandle(name,h,portDirection,portIdx)
    sid=Simulink.ID.getSID(h);
    link=sprintf('matlab:Simulink.ID.hilite(''%s'')',sid);
    if(portIdx>=0)
        blkPath=[get_param(h,'parent'),'/',get_param(h,'name')];
        if(strcmpi(portDirection,'in'))
            link=sprintf('%s; ph = get_param(''%s'', ''portHandles''); ph1 = ph.Inport(%d); hilite_system(ph1, ''different'');',link,blkPath,portIdx+1);
        else
            assert(strcmpi(portDirection,'out'));
            link=sprintf('%s; ph = get_param(''%s'', ''portHandles''); ph1 = ph.Outport(%d); hilite_system(ph1, ''different'');',link,blkPath,portIdx+1);
        end
    end
    section=hdlhtml.section(name,'a');
    section.setAttribute('href',link);
    section.setAttribute('name','code2model');
    section.setAttribute('class','code2model');
    linkedPath=section.getHTML;
end

function linkedPath=generateSystemLink(path,portDirection,portIdx)
    h=[];
    if isempty(path)
        linkedPath='';
        return;
    end
    if isempty(h)
        try
            h=get_param(path,'Handle');
        catch
            h=[];
        end
    end
    [~,nameVisible]=fileparts(path);
    if isempty(h)
        linkedPath=path;
    else
        linkedPath=generateSystemLinkFromHandle(nameVisible,h,portDirection,portIdx);
    end
end

function outStr=preformatted(inStr)
    outStr=strrep(inStr,sprintf('\n'),'<br>');
    outStr=strrep(outStr,' ','&nbsp;');
    outStr=strrep(outStr,sprintf('\t'),'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
end

