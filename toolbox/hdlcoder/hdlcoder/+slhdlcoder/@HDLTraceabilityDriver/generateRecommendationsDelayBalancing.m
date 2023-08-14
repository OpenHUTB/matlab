function generateRecommendationsDelayBalancing(this,delay_balance_file,title,model,p,JavaScriptBody)





    w=hdlhtml.reportingWizard(delay_balance_file,title);
    w.setHeader(title);
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end
    w.addBreak(3);

    hasUnbalancedNtwks=false;
    ntks=p.Networks;
    if~strcmpi(p.getParamValue('TreatBalanceDelaysOffAs'),'Error')



        for i=length(ntks):-1:1
            ntk=ntks(i);
            if strcmpi(ntk.getDelayBalancing(),'off')
                if~hasUnbalancedNtwks


                    w.addText(DAStudio.message('hdlcoder:report:DelayBalancingOff'));
                    w.addBreak(2);
                end
                hasUnbalancedNtwks=true;
                nwpath=ntk.FullPath;
                if(length(ntk.instances)>1)
                    w.addFormattedText(['Subsystems: ',this.getAtomicSubsystems(ntk)],'b');
                    w.addBreak;
                    w.addText(DAStudio.message('hdlcoder:report:atomic_subsystems',hdlhtml.reportingWizard.generateSystemLink(nwpath,[],true)));
                    w.addBreak;
                else
                    w.addFormattedText(['Subsystem: ',hdlhtml.reportingWizard.generateSystemLink(nwpath,[],true)],'b');
                    w.addBreak;
                end

            end
        end
    end

    if hasUnbalancedNtwks
        w.addBreak;
    end


    hDrv=hdlcurrentdriver;
    if hDrv.mdlIdx==numel(hDrv.AllModels)

        reportPathDelays(this,w,p);
        w.addBreak;
    end

    if hdlgetparameter('generatevalidationmodel')
        reportGeneratedModel(w,model);
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


function reportGeneratedModel(w,model)

    table=w.createTable(1,2);
    table.createEntry(1,1,DAStudio.message('hdlcoder:report:validationModel'));
    driver=hdlmodeldriver(model);
    genModel=driver.CoverifyModelName;
    alink=Simulink.report.ReportInfo.getMatlabCallHyperlink(sprintf('matlab:coder.internal.code2model(''%s'')',genModel));
    table.createEntry(1,2,[alink{1},genModel,alink{2}]);
    w.commitTable(table);
end


function reportPathDelays(this,w,p)
    if~p.isDelayBalancable&&p.needsDelayBalancing
        msg=p.getBalanceFailureReason;

        if p.getBalanceFailureId==p.srsDelayBalanceFeedbackId
            msg=getFeedbackHighlightMessage(this,'hdlcoder:report:feedbackloopmsg','hdlcoder:report:turnonhighlightfeedbackloops');
        end


        w.addText(DAStudio.message('hdlcoder:report:delayBalancingUnsuccessful'));
        w.addBreak(2);
        if isempty(msg)
            msg='none';
        end

        w.addText([DAStudio.message('hdlcoder:report:reason',''),msg]);
        w.addBreak;

        reportCulpritBlock(w,p.getBalanceFailureCulprit);
        return;
    end


    hN=p.getTopNetwork;
    outs=hN.NumberOfPirOutputPorts;
    if outs>0
        table=w.createTable(outs,3);
        table.setColHeading(1,DAStudio.message('hdlcoder:report:Port'));
        table.setColHeading(2,DAStudio.message('hdlcoder:report:PipelineLatency'));
        table.setColHeading(3,DAStudio.message('hdlcoder:report:PhaseDelay'));
        for ii=1:outs
            lat=p.getDutExtraLatency(ii-1);
            port=hN.PirOutputPorts(ii);
            phase=p.getOutputPortPhase(ii-1);
            table.createEntry(ii,1,[hN.Name,'/',port.Name]);
            table.createEntry(ii,2,num2str(lat));
            table.createEntry(ii,3,num2str(phase));
        end
        w.commitTable(table);
        w.addBreak;
        gp=pir();
        if gp.hasTestpointUnmatchedDelays


            w.addText(DAStudio.message('hdlcoder:hdldisp:DelayBalanceDiffLatency'));
        end
        w.addBreak(2);
    end
end


function reportCulpritBlock(w,blkname)
    if isempty(blkname)
        return;
    end
    try


        foundBlk=~isempty(find_system(blkname,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices));
    catch me %#ok<*NASGU>
        foundBlk=false;
    end
    w.addBreak;
    if foundBlk
        w.addFormattedText([DAStudio.message('hdlcoder:report:offendingBlock',''),hdlhtml.reportingWizard.generateSystemLink(blkname)],'b');
    else
        w.addFormattedText([DAStudio.message('hdlcoder:report:offendingBlock',''),blkname],'b');
    end
    w.addBreak;
end


function msg=getFeedbackHighlightMessage(this,feedbackmsg,turnonmsg)
    if hdlgetparameter('HighlightFeedbackLoops')
        filstr=hdlgetparameter('HighlightFeedbackLoopsFile');
        [~,v]=fileattrib(fullfile(hdlGetCodegendir(this),[filstr,'.m']));
        filename=v.Name;
        linkstr=sprintf('<a href="matlab:run(''%s'')">%s</a>',filename,filename);

        msg=DAStudio.message(feedbackmsg);
        msg=[msg,linkstr];
    else
        msg=DAStudio.message(turnonmsg);
    end

end


