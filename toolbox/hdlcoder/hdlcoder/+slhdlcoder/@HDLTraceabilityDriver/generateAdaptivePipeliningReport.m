
function generateAdaptivePipeliningReport(this,adaptive_pipe_file,title,model,p,JavaScriptBody)




    w=hdlhtml.reportingWizard(adaptive_pipe_file,title);
    w.setHeader(title);
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end
    w.addBreak(3);

    hDrv=hdlcurrentdriver;

    adaptiveSucc=reportAdaptivePipeliningInfo(this,w,p);
    if~adaptiveSucc
        w.addText(DAStudio.message('hdlcoder:report:noPipelinesInserted'));
        w.addBreak;
    end

    w.addBreak;

    if hdlgetparameter('generatevalidationmodel')
        this.publishValidationModelLink(w,model);
        w.addBreak
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


function pipelineInfo=getPipelineInfo(hN)
    vComps=hN.Components;
    numComps=length(vComps);
    pipelineInfo={};
    for i=1:numComps
        hC=vComps(i);
        if(hC.getAdaptivePipelinesRequested()>0)
            pipeinfo.requested=num2str(hC.getAdaptivePipelinesRequested());
            pipeinfo.gmHandle=hC.getGMHandle;
            pipeinfo.origHandle=hC.OrigModelHandle;

            pipeinfo.inserted=num2str(hC.getAdaptivePipelinesInserted);
            pipeinfo.notes=num2str(hC.getAdaptivePipelineMessage);

            if pipeinfo.origHandle<=0||...
                ~strncmpi(get_param(pipeinfo.origHandle,'BlockType'),'Lookup',6)
                pipelineInfo{end+1}=pipeinfo;%#ok<AGROW> 
            end
        end
    end
end


function numOfEntries=reportAdaptivePipeliningInfo(this,w,p)
    vN=p.Networks;

    numOfEntries=0;
    for ii=1:length(vN)
        hN=vN(ii);
        pipelineInfo=getPipelineInfo(hN);
        if(~isempty(pipelineInfo))
            nwpath=hN.FullPath;
            if(length(hN.instances)>1)
                w.addFormattedText(DAStudio.message('hdlcoder:report:subsystems',this.getAtomicSubsystems(hN)),'b');
                w.addBreak;
                w.addText(DAStudio.message('hdlcoder:report:atomic_subsystems',hdlhtml.reportingWizard.generateSystemLink(nwpath)));
            else
                w.addFormattedText(DAStudio.message('hdlcoder:report:subsystem',hdlhtml.reportingWizard.generateSystemLink(nwpath)),'b');
            end
            w.addBreak(2);
            numOfEntries=length(pipelineInfo);
            table=w.createTable(numOfEntries,3);
            table.setColHeading(1,DAStudio.message('hdlcoder:report:blockname'));
            table.setColHeading(2,DAStudio.message('hdlcoder:report:NumberOfPipelinesInserted'));
            table.setColHeading(3,DAStudio.message('hdlcoder:report:Notes'));
            for entryId=1:numOfEntries
                pipeInfo=pipelineInfo{entryId};
                table.createEntry(entryId,1,getBlockLink(pipeInfo.origHandle,pipeInfo.gmHandle));
                table.createEntry(entryId,2,pipeInfo.inserted);
                table.createEntry(entryId,3,pipeInfo.notes);
            end
            w.commitTable(table);
            w.addBreak(2);
        end
    end
end


function linkstr=getBlockLink(origHandle,gmHandle)
    highlightstr='';
    blockName='';
    if gmHandle>0
        highlightstr=['hilite_system(''',getfullname(gmHandle),''');'];
        blockName=get_param(gmHandle,'Name');
    end
    if origHandle>0
        highlightstr=[highlightstr,'hilite_system(''',strrep(getfullname(origHandle),char(10),' '),''');'];
        blockName=get_param(origHandle,'Name');
    end
    linkstr=sprintf('<a href="matlab:%s">%s</a>',highlightstr,blockName);
end


