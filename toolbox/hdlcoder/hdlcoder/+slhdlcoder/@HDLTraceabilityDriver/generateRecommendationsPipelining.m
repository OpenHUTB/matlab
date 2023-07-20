function generateRecommendationsPipelining(this,dist_pipe_file,title,model,p,JavaScriptBody)





    w=hdlhtml.reportingWizard(dist_pipe_file,title);
    w.setHeader(title);
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end
    w.addBreak(3);
    if hdlgetparameter('recommendations')

        topNtk=p.getTopNetwork;
        origrecommendedPipeline=hdlcoder.SimulinkData.getRecommendedPipeline(topNtk);
        recommendedPipeline=0;
        if(origrecommendedPipeline~=0)
            recommendedPipeline=topNtk.getOutputPipeline+origrecommendedPipeline;
        end
        recommendedStatus=hdlcoder.SimulinkData.getPipelineBlockingStatus(topNtk);
        section=w.createSectionTitle(DAStudio.message('hdlcoder:report:recommendations'));
        w.commitSection(section);
        w.addBreak(2);
        if recommendedPipeline>0
            if recommendedStatus==0

                table=w.createTable(1,3);
                table.setColHeading(1,DAStudio.message('hdlcoder:report:subsystemColumnHeading'));
                table.setColHeading(2,DAStudio.message('hdlcoder:report:outputpipelineColumnHeading'));
                table.setColHeading(3,DAStudio.message('hdlcoder:report:DistributedPipeliningColumnHeading'));

                if~isempty(topNtk.FullPath)
                    table.createEntry(1,1,hdlhtml.reportingWizard.generateSystemLink(topNtk.FullPath));
                else
                    table.createEntry(1,1,topNtk.Name);
                end

                table.createEntry(1,2,num2str(recommendedPipeline));

                table.createEntry(1,3,'on');
                w.commitTable(table);
                w.addBreak(2);

            end
        else
            w.addText(DAStudio.message('hdlcoder:report:noRecommendationOffered'));
            w.addBreak;
        end

        if recommendedStatus>0
            suggList=w.createList;
            if bitand(recommendedStatus,2)~=0
                suggList.createEntry(DAStudio.message('hdlcoder:report:distributedPipelineNotMoveRegistersIntoCycle'));
            end
            if bitand(recommendedStatus,4)~=0
                suggList.createEntry(DAStudio.message('hdlcoder:report:noInputToSubsystem'));
            end
            if bitand(recommendedStatus,1)~=0
                w.addText(DAStudio.message('hdlcoder:report:noRecommendationOffered'));
            else
                w.commitList(suggList);
            end
            w.addBreak;
        end
        w.addBreak;
    end


    generateConstrainedDistributedPipeliningReport(this,w,model,p);


    generateDistributedPipeliningReport(this,w,model,p);
end



function anyProblem=reportGlobalProblems(w,validNtks)
    anyProblem=false;
    if~hdlgetparameter('hierarchicalDistPipelining')
        return;
    end
    for i=1:length(validNtks)
        ntk=validNtks(i);
        if ntk.getDistributedPipeliningStatus==0
            w.addLine;
            w.addFormattedText(DAStudio.message('hdlcoder:report:status1',''),'b');
            w.addText(DAStudio.message('hdlcoder:report:multipleInstantiations'));
            w.addBreak(2);
            w.addText(DAStudio.message('hdlcoder:report:subsystemReuseOff'));
            w.addLine;
            anyProblem=true;
            return;
        end
    end
end


function anyProblem=reportIllegalSubsystemProblems(w,validNtks)
    anyProblem=false;
    if~hdlgetparameter('hierarchicalDistPipelining')
        return;
    end
    for i=1:length(validNtks)
        ntk=validNtks(i);
        if ntk.getDistributedPipeliningStatus==8
            w.addLine;
            w.addFormattedText(DAStudio.message('hdlcoder:report:status1',''),'b');
            w.addText(DAStudio.message('hdlcoder:report:enableOrtriggeredSubsystem'));
            w.addBreak(2);
            w.addText(DAStudio.message('hdlcoder:report:checkSubsystem',''));
            if~isempty(ntk.FullPath)
                w.addText(hdlhtml.reportingWizard.generateSystemLink(ntk.FullPath));
            else
                w.addText(ntk.Name);
            end
            w.addLine;
            anyProblem=true;
            return;
        end
    end
end




function publishConstrainedDistributedPipeliningResults(w,blockGroups,numBlocks)

    numBlockGroups=length(blockGroups)-sum(cellfun(@isempty,blockGroups));
    table=w.createTable(numBlocks+numBlockGroups,4);
    table.setColHeading(1,DAStudio.message('hdlcoder:report:blockColumnHeading'),'center');
    table.setColHeading(2,DAStudio.message('hdlcoder:report:requiredConstrainedOutputPipelineHeading'),'center');
    table.setColHeading(3,DAStudio.message('hdlcoder:report:statusColumnHeading'),'center');
    table.setColHeading(4,DAStudio.message('hdlcoder:report:deficitColumnHeading'),'center');
    currEntry=1;
    for i=1:length(blockGroups)
        blocks=blockGroups{i};
        if~isempty(blocks)
            table.createEntry(currEntry,1,['Inside ',hdlhtml.reportingWizard.generateSystemLink(blocks{1}.Owner.FullPath)]);
            table.createEntry(currEntry,2,'  ');
            table.createEntry(currEntry,3,'  ');
            table.createEntry(currEntry,4,'  ');
            currEntry=currEntry+1;
        else
            continue;
        end
        for j=1:length(blocks)
            comp=blocks{j};
            path=[comp.Owner.FullPath,'/',comp.Name];
            if comp.isNetworkInstance
                childN=comp.ReferenceNetwork;
                path=childN.FullPath;
            end
            table.createEntry(currEntry,1,hdlhtml.reportingWizard.generateSystemLink(path),'right');
            if comp.isNetworkInstance
                childN=comp.ReferenceNetwork;
                table.createEntry(currEntry,2,num2str(childN.getConstrainedOutputPipeline),'center');
                status='Failed';
                if childN.getConstrainedOutputPipelineStatus
                    status='Passed';
                end
                table.createEntry(currEntry,3,status,'center');
                deficit=childN.getConstrainedOutputPipelineDeficit;
                if deficit==-1
                    table.createEntry(currEntry,4,'undefined','center');
                else
                    table.createEntry(currEntry,4,num2str(childN.getConstrainedOutputPipelineDeficit),'center');
                end
            else
                if comp.isCtxReference
                    childN=comp.ReferenceNetwork;
                    table.createEntry(currEntry,2,num2str(childN.getConstrainedOutputPipeline),'center');
                else
                    table.createEntry(currEntry,2,num2str(comp.getConstrainedOutputPipeline),'center');
                end
                status='Failed';
                if comp.getConstrainedOutputPipelineStatus
                    status='Passed';
                end
                table.createEntry(currEntry,3,status,'center');
                deficit=comp.getConstrainedOutputPipelineDeficit;
                if deficit==-1
                    table.createEntry(currEntry,4,'undefined','center');
                else
                    table.createEntry(currEntry,4,num2str(comp.getConstrainedOutputPipelineDeficit),'center');
                end
            end
            currEntry=currEntry+1;
        end
    end
    w.commitTable(table);
    w.addBreak(2);
end



function generateConstrainedDistributedPipeliningReport(this,w,model,p)

    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:constrainedOutputPipelineSummary'));
    w.commitSection(section);
    w.addBreak(2);

    ntks=p.Networks;
    anyBlock=false;
    blockGroups={};
    numBlocks=0;
    for i=length(ntks):-1:1
        ntk=ntks(i);
        comps=ntk.Components;
        blocks={};
        ntkWithConstrainedBlock=false;
        for j=1:length(comps)
            comp=comps(j);
            if comp.isNetworkInstance||comp.isCtxReference
                childN=comp.ReferenceNetwork;
                if childN.getConstrainedOutputPipeline>0
                    anyBlock=true;
                    ntkWithConstrainedBlock=true;
                    blocks{end+1}=comp;%#ok<AGROW>
                    numBlocks=numBlocks+1;
                end
            else
                if comp.getConstrainedOutputPipeline>0
                    anyBlock=true;
                    ntkWithConstrainedBlock=true;
                    blocks{end+1}=comp;%#ok<AGROW>
                    numBlocks=numBlocks+1;
                end
            end
        end
        if ntkWithConstrainedBlock

            publishStatus(this,w,ntk.getDistributedPipeliningStatus,false,ntk,model,{ntk},true);
        end
        blockGroups{end+1}=blocks;%#ok<AGROW>
    end

    if~anyBlock
        w.addText(DAStudio.message('hdlcoder:report:noBlockWithConstrainedOutputPipeline'));
    else

        publishConstrainedDistributedPipeliningResults(w,blockGroups,numBlocks);


        hDrv=hdlcurrentdriver;
        if hDrv.mdlIdx==numel(hDrv.AllModels)

            if(isprop(hDrv.BackEnd,'OutModelFile'))
                this.publishGeneratedModelLink(w,hDrv.BackEnd.OutModelFile);
            end
        else

            genMdlName=getGeneratedModelName(hDrv.getParameter('generatedmodelnameprefix'),...
            p.ModelName,false);
            this.publishGeneratedModelLink(w,genMdlName);
        end
    end
    w.addBreak(2);
end



function generateDistributedPipeliningReport(this,w,model,p)

    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:distributedPipeliningSummary'));
    w.commitSection(section);
    w.addBreak(2);

    ntks=p.Networks;
    validNtks=[];
    for i=length(ntks):-1:1
        ntk=ntks(i);
        if ntk.getDistributedPipelining||ntk.getDistributedPipeliningPerformed
            validNtks=[validNtks,ntk];%#ok<AGROW>
        end
    end

    if~isempty(validNtks)

        w.addFormattedText(DAStudio.message('hdlcoder:report:hdlCodeGenParam',''),'bi');
        if hdlgetparameter('hierarchicalDistPipelining')
            w.addFormattedText(DAStudio.message('hdlcoder:report:hierarchicalDistPipeliningOn'),'i');
            hierarchical=true;
        else
            w.addFormattedText(DAStudio.message('hdlcoder:report:hierarchicalDistPipeliningOff'),'i');
            hierarchical=false;
        end
        w.addBreak(2);


        generateSummaryReport(w,validNtks);


        if(reportIllegalSubsystemProblems(w,validNtks))
            w.dumpHTML;
            return;
        end


        if(reportGlobalProblems(w,validNtks))
            w.dumpHTML;
            return;
        end


        generateDetailedReport(this,w,validNtks,hierarchical,model);

    else
        w.addText(DAStudio.message('hdlcoder:report:noSubsystemFoundWithDistributedPipeliningOn'));
    end
    w.dumpHTML;
end


function newRegion=buildNewRegion(ntk,currRegion)
    newRegion=currRegion;
    if ntk.getDistributedPipelining
        newRegion{end+1}=ntk;
    else
        return;
    end
    comps=ntk.Components;
    for i=1:length(comps)
        c=comps(i);
        if c.isNetworkInstance
            childN=c.ReferenceNetwork;
            newRegion=buildNewRegion(childN,newRegion);
        end
    end
end


function regionSet=preprocessToBuildRegions(validNtks)
    regionSet={};
    for i=1:length(validNtks)
        ntk=validNtks(i);
        if ntk.getDistributedPipelining
            validParentN=getParentNetworkWithDistPipe(ntk);
            if isempty(validParentN)

                currRegion={};
                newRegion=buildNewRegion(ntk,currRegion);
                regionSet{end+1}=newRegion;%#ok<AGROW>
            end
        end
    end
end


function validGeneratedModel=generateNonhierarchicalReport(this,w,validNtks,model)
    validGeneratedModel=false;
    for i=1:length(validNtks)
        ntk=validNtks(i);

        distPipeStatus=ntk.getDistributedPipeliningStatus;

        publishResourceReportHeader(w,ntk);


        publishStatus(this,w,distPipeStatus,false,ntk,model,{ntk});

        if(distPipeStatus==-1)

            publishResourceReport(w,ntk);
            validGeneratedModel=true;
        end

    end
end



function validGeneratedModel=generateHierarchicalReport(this,w,regionSet,model)
    validGeneratedModel=false;
    for i=1:length(regionSet)
        region=regionSet{i};
        for j=1:length(region)
            ntk=region{j};

            if j==1
                w.addFormattedText(sprintf(DAStudio.message('hdlcoder:report:hierarchicalDistPipeliningRegion',i,' ')),'b');
                w.startColoredSection('#FDEEF4');
                distPipeStatus=ntk.getDistributedPipeliningStatus;
                publishStatus(this,w,distPipeStatus,true,ntk,model,region);
                if(distPipeStatus~=-1)
                    break;
                else


                    validGeneratedModel=true;
                    w.addFormattedText(DAStudio.message('hdlcoder:report:detailsWithinHierarchicalDistributedPipelingRegion'),'b');
                end
                w.addBreak(2);
            end
            publishResourceReportHeader(w,ntk);

            publishResourceReport(w,ntk);
        end
        if w.isInsideRunningSection
            w.endColoredSection;
            w.addBreak(2);

            w.addBreak;
        end
    end
end


function generateDetailedReport(this,w,validNtks,hierarchical,model)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:detailed_report'));
    w.commitSection(section);
    w.addBreak(2);
    if hierarchical
        regionSet=preprocessToBuildRegions(validNtks);
        publishGeneratedModel=generateHierarchicalReport(this,w,regionSet,model);
    else
        publishGeneratedModel=generateNonhierarchicalReport(this,w,validNtks,model);
    end

    if publishGeneratedModel
        hDrv=hdlcurrentdriver;
        if hDrv.mdlIdx==numel(hDrv.AllModels)

            if(isprop(hDrv.BackEnd,'OutModelFile'))
                this.publishGeneratedModelLink(w,hDrv.BackEnd.OutModelFile);
            end
        else

            genMdlName=getGeneratedModelName(hDrv.getParameter('generatedmodelnameprefix'),...
            model,false);
            this.publishGeneratedModelLink(w,genMdlName);
        end
    end
end


function name=getCompName(h)
    cname=get_param(h,'Name');
    if isempty(cname)
        name='unnamed';
    else
        name=hdlfixblockname(cname);
    end
end


function link=getLinkFromHandle(h)
    name=getCompName(h);
    link=hdlhtml.reportingWizard.generateSystemLinkFromHandle(name,h);
end


function newPath=getGenModelPath(path,genModel)
    [~,postPath]=strtok(path,'/');
    newPath=[genModel,postPath];
end


function h=getValidHandle(path)
    try
        h=get_param(path,'Handle');
    catch %#ok<CTCH>
        h=-1;
    end
end


function emitIllegalList(this,w,model,region)


    ntk=region{1};
    path=ntk.FullPath;
    if isempty(path)
        return;
    end
    h=getValidHandle(path);
    if h==-1

        genModel=getGeneratedModel(model);
        path=getGenModelPath(path,genModel);
    end
    if isempty(path)
        return;
    end
    blocks=this.getNonzeroResetBlocks(path,true);

    illegalList=w.createList;
    for i=1:length(blocks)
        illegalBlockPath=blocks{i};
        hB=get_param(illegalBlockPath,'Handle');
        illegalList.createEntry(getLinkFromHandle(hB));
    end
    w.commitList(illegalList);
end


function newMsg=reprint3WithLink(msg,model)
    newMsg=msg;
    if isempty(msg)
        return;
    end
    comps=regexp(msg,'Unconstrained Path found from <(?<from>.*)> to <(?<to>.*)>[a-zA-Z .]+','names','ONCE');
    format=0;
    if isempty(comps)
        comps=regexp(msg,'Unconstrained Path found from input <(?<from>.*)> to <(?<to>.*)>[a-zA-Z .]+','names','ONCE');
        format=1;
    end
    if isempty(comps)
        comps=regexp(msg,'Unconstrained Path found from <(?<from>.*)> to input <(?<to>.*)>[a-zA-Z .]+','names','ONCE');
        format=2;
    end
    if isempty(comps)
        comps=regexp(msg,'Unconstrained Path found from input <(?<from>.*)> to input <(?<to>.*)>[a-zA-Z .]+','names','ONCE');
        format=3;
    end

    fromPath=comps.from;
    h1=getValidHandle(fromPath);

    toPath=comps.to;
    h2=getValidHandle(toPath);

    displayOnGenModel=false;
    if h1==-1||h2==-1

        genModel=getGeneratedModel(model);
        fromPath=getGenModelPath(fromPath,genModel);
        toPath=getGenModelPath(toPath,genModel);
        h1=getValidHandle(fromPath);
        h2=getValidHandle(toPath);
        if h1==-1||h2==-1
            newMsg=msg;

            return;
        end
        displayOnGenModel=true;
    end
    switch(format)
    case{0,1}
        newMsg=sprintf(DAStudio.message('hdlcoder:report:unConstrainedPathFoundFromInputToOutput',...
        hdlhtml.reportingWizard.generateSystemLink(fromPath),...
        hdlhtml.reportingWizard.generateSystemLink(toPath)));

    case{2,3}
        newMsg=sprintf(DAStudio.message('hdlcoder:report:unConstrainedPathFoundFromInputToOutput',...
        hdlhtml.reportingWizard.generateSystemLink(fromPath),...
        hdlhtml.reportingWizard.generateSystemLink(toPath)));

    end
    if(displayOnGenModel)
        newMsg=sprintf(DAStudio.message('hdlcoder:report:nodesNotLocatedInOriginalModel',newMsg));
    end
end


function publishStatus(this,w,distPipeStatus,hierarchical,ntk,model,region,constrained)
    if nargin<8
        constrained=false;
    end
    addedLine=false;
    if constrained
        if distPipeStatus~=-1

            w.addFormattedText([DAStudio.message('hdlcoder:report:status',...
            hdlhtml.reportingWizard.generateSystemLink(ntk.FullPath)),...
            ':   '],'b');
        end
        transform='Constrained Distributed Pipelining';
    else
        w.addLine;
        addedLine=true;
        if hierarchical
            w.addFormattedText([DAStudio.message('hdlcoder:report:statusOfHierarchicalDistPipelining',''),...
            hdlhtml.reportingWizard.generateSystemLink(ntk.FullPath),':   '],'b');
        else
            w.addFormattedText(DAStudio.message('hdlcoder:report:status1',''),'b');
        end
        transform='Distributed Pipelining';
    end

    if distPipeStatus<0
        if~constrained
            w.addText(sprintf(DAStudio.message('hdlcoder:report:distributePipelineSuccessful',transform)));
        end
        if distPipeStatus<-1
            distPipeStatus=-distPipeStatus;
            w.addText(sprintf(DAStudio.message('hdlcoder:report:furtherDistributedPipelineIsNotPossible',transform)));
        end
    end


    switch distPipeStatus
    case-1


    case 1

        if ntk.getHasRetimingBarrier
            w.addText(sprintf(DAStudio.message('hdlcoder:report:noChangeNoOptunityToApplyInSubsystemWBlocker',transform)));
        else

            w.addText(sprintf(DAStudio.message('hdlcoder:report:noChangeNoOptunityToApplyInSubsystem',transform)));
        end

    case 2
        w.addText(sprintf(DAStudio.message('hdlcoder:report:foundNonZeroInitialValue',transform)));
        emitIllegalList(this,w,model,region);
    case 3
        c1h=ntk.getRetimingOffendingComp1Handle;
        c2h=ntk.getRetimingOffendingComp2Handle;
        if c1h==-1||c2h==-1
            failedMsg=reprint3WithLink(ntk.getRetimingFailedMessage,model);
            w.addText(sprintf(DAStudio.message('hdlcoder:report:exited',failedMsg,transform)));
        else
            w.addText(sprintf(DAStudio.message('hdlcoder:report:unConstrainedPathFound',...
            getLinkFromHandle(c1h),getLinkFromHandle(c2h),transform)));

        end
        w.addBreak(2);
        if hierarchical
            w.addText(DAStudio.message('hdlcoder:report:checkDistributedPipeliningTurnedOff'));
            w.addText(DAStudio.message('hdlcoder:report:blockBlackBoxDistributedPipelining'));
        else
            w.addText(DAStudio.message('hdlcoder:report:blockOrSubsystemBlackBoxDistributedPipelining'));
        end
        w.addBreak(2);
        w.addText(DAStudio.message('hdlcoder:report:addPipelineReg'));
    case 5
        w.addText(sprintf(DAStudio.message('hdlcoder:report:foundContinuousRateExit',transform)));
    case 7
        w.addText(sprintf(DAStudio.message('hdlcoder:report:foundUnsupportedBlockExited',transform)));
    case 9
        w.addText(sprintf(DAStudio.message('hdlcoder:report:exited',...
        ntk.getRetimingFailedMessage(),transform)));
    otherwise
        w.addText(sprintf(DAStudio.message('hdlcoder:report:unsuccessful',transform)));
    end

    if ntk.getHasRetimingBarrier

        if ntk.getHasRetimingNumericMismatchBarrier


            w.addBreak(2);
            w.addText(message('hdlcoder:report:DistPipelineNumericMismatchWorkaround',model).getString);
        end


        w.addBreak(2);
        hDrv=hdlcurrentdriver;
        baseCodeGenDir=hDrv.hdlGetBaseCodegendir();
        linkstr=sprintf('matlab:run(''%s'')',fullfile(baseCodeGenDir,'highlightDistributedPipeliningBarriers.m'));
        w.addLink(DAStudio.message('hdlcoder:report:HighlightDistributedPipeliningBarriers'),linkstr);
        w.addBreak(2);
    end

    if addedLine
        w.addLine;
    elseif distPipeStatus~=-1
        w.addBreak(2);
    end
end

function publishResourceReportHeader(w,ntk)
    if~isempty(ntk.FullPath)
        w.addFormattedText(DAStudio.message('hdlcoder:report:subsystem',hdlhtml.reportingWizard.generateSystemLink(ntk.FullPath)),'b');
    else
        w.addFormattedText(ntk.Name,'b');
    end
    w.addBreak(2);
    w.addFormattedText(DAStudio.message('hdlcoder:report:impParam',' '),'bi');
    w.addFormattedText(DAStudio.message('hdlcoder:report:distributedPipelineOn',' '),'i');

    w.addFormattedText([DAStudio.message('hdlcoder:report:inputPipeline',num2str(ntk.getInputPipeline)),'; '],'i');
    w.addFormattedText([DAStudio.message('hdlcoder:report:outputPipeline',num2str(ntk.getOutputPipeline))],'i');
    w.addBreak(2);
end


function publishResourceReport(w,ntk)

    prebill=ntk.getBillOfMaterialsBeforeRetiming;
    postbill=ntk.getBillOfMaterialsAfterRetiming;

    if~isempty(prebill)
        w.addFormattedText(DAStudio.message('hdlcoder:report:beforeDistributedPipelining'),'bu');
        w.addFormattedText([': ',num2str(prebill.getTotalFrequency('reg_comp')),DAStudio.message('hdlcoder:report:registers','   ')],'b');
        w.addFormattedText(['   (',num2str(prebill.getTotalFlipflops),DAStudio.message('hdlcoder:report:flipflops'),')'],'bi');
        w.addBreak(2);
        createRegisterTable(w,prebill);
    elseif~isempty(postbill)
        w.addFormattedText(DAStudio.message('hdlcoder:report:beforeDistributedPipelining'),'bu');
        w.addFormattedText([': ',num2str(prebill.getTotalFrequency('reg_comp')),DAStudio.message('hdlcoder:report:registers','   ')],'b');
        w.addFormattedText(['   (',num2str(prebill.getTotalFlipflops),DAStudio.message('hdlcoder:report:flipflops'),')'],'bi');
        w.addBreak(2);
    end

    if~isempty(postbill)
        w.addFormattedText(DAStudio.message('hdlcoder:report:afterDistributedPipelining'),'bu');
        w.addFormattedText([': ',num2str(prebill.getTotalFrequency('reg_comp')),DAStudio.message('hdlcoder:report:registers','   ')],'b');
        w.addFormattedText(['   (',num2str(prebill.getTotalFlipflops),DAStudio.message('hdlcoder:report:flipflops'),')'],'bi');
        w.addBreak(2);
        createRegisterTable(w,postbill);
        w.addBreak;
    elseif~isempty(prebill)
        w.addFormattedText(DAStudio.message('hdlcoder:report:afterDistributedPipelining'),'bu');
        w.addFormattedText([': ',num2str(prebill.getTotalFrequency('reg_comp')),DAStudio.message('hdlcoder:report:registers','   ')],'b');
        w.addFormattedText(['   (',num2str(prebill.getTotalFlipflops),DAStudio.message('hdlcoder:report:flipflops'),')'],'bi');
        w.addBreak(2);
    end
end


function genModel=getGeneratedModel(model)
    driver=hdlmodeldriver(model);
    genModel=driver.BackEnd.OutModelFile;
end


function generateSummaryReport(w,validNtks)

    w.addFormattedText(DAStudio.message('hdlcoder:report:subsystemDistributedPipeliningOn',' '),'bi');
    w.addBreak(2);

    table=w.createTable(length(validNtks),3);
    table.setColHeading(1,DAStudio.message('hdlcoder:report:subsystemColumnHeading'));
    table.setColHeading(2,DAStudio.message('hdlcoder:report:inputPipelineColumnHeading'));
    table.setColHeading(3,DAStudio.message('hdlcoder:report:outputpipelineColumnHeading'));
    for i=1:length(validNtks)
        ntk=validNtks(i);
        if~isempty(ntk.FullPath)
            table.createEntry(i,1,hdlhtml.reportingWizard.generateSystemLink(ntk.FullPath));
        else
            table.createEntry(i,1,ntk.Name);
        end
        if(ntk.isSFHolder)
            inPipe=num2str(hdlget_param(ntk.FullPath,'InputPipeline'));
            outPipe=num2str(hdlget_param(ntk.FullPath,'OutputPipeline'));
        else
            inPipe=num2str(ntk.getInputPipeline);
            outPipe=num2str(ntk.getOutputPipeline);
        end
        table.createEntry(i,2,inPipe);
        table.createEntry(i,3,outPipe);
    end
    w.commitTable(table);
    w.addBreak(2);
end


function ntkInstance=getSingletonInstance(ntk)
    ntkInstances=ntk.instances;
    if isempty(ntkInstances)||length(ntkInstances)>1

        ntkInstance=[];
    else
        ntkInstance=ntkInstances(1);
    end
end


function parent=getParentNetworkWithDistPipe(ntk)
    parent=[];
    ntkInstance=getSingletonInstance(ntk);
    if isempty(ntkInstance)
        return;
    end
    parentNtk=ntkInstance.Owner;
    if parentNtk.getDistributedPipelining
        parent=parentNtk;
    end
end


function createRegisterTable(w,bill)
    regSet=bill.getCompInfoSet('reg_comp');
    numRegTypes=length(regSet);
    if(numRegTypes==0)
        return;
    end
    table=w.createTable(numRegTypes,2);
    table.setColHeading(1,DAStudio.message('hdlcoder:report:Registers'));
    table.setColHeading(2,DAStudio.message('hdlcoder:report:count'));
    for j=1:numRegTypes
        currReg=regSet(j);
        numBits=currReg.getInputBitwidth(1);
        if numBits>0
            table.createEntry(j,1,[num2str(numBits),'-bit']);
        else
            table.createEntry(j,1,'real');
        end
        table.createEntry(j,2,num2str(currReg.getFrequency));
    end
    w.commitTable(table);
    w.addBreak;
end




