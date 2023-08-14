function generateTargetCodeGenerationReport(this,tcg_content_file,title,model,p,JavaScriptBody)





    w=hdlhtml.reportingWizard(tcg_content_file,title);


    w.setHeader([DAStudio.message('hdlcoder:report:targetCodeGenReport',model)]);
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end

    w.addBreak(3);

    alteraMegafunctions=targetcodegen.targetCodeGenerationUtils.isAlteraMode();
    xilinxCoreGen=targetcodegen.targetCodeGenerationUtils.isXilinxMode();
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();

    if~alteraMegafunctions&&~xilinxCoreGen&&~nfpMode
        w.addText(DAStudio.message('hdlcoder:report:reportStatusOfTargetCodeGen'));
        w.dumpHTML;
        return;
    end

    if alteraMegafunctions
        targetLibrary='Altera Megafunctions';
    elseif xilinxCoreGen
        targetLibrary='Xilinx LogiCORE';
    else
        targetLibrary='Native Floating Point';
    end

    deviceDetails=hdlgetdeviceinfo;
    numDetails=length(deviceDetails);

    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:targetSummary'));
    w.commitSection(section);
    w.addBreak(2);
    table=w.createTable(1,5);
    table.setColHeading(1,DAStudio.message('hdlcoder:report:targetLibraryHeading'));
    table.setColHeading(2,DAStudio.message('hdlcoder:report:familyColumnHeading'));
    table.setColHeading(3,DAStudio.message('hdlcoder:report:deviceColumnHeading'));
    table.setColHeading(4,DAStudio.message('hdlcoder:report:packageColumnHeading'));
    table.setColHeading(5,DAStudio.message('hdlcoder:report:speedColumnHeading'));
    table.createEntry(1,1,targetLibrary);
    table.createEntry(1,2,deviceDetails{1});
    if numDetails>=2&&~isempty(deviceDetails{2})
        table.createEntry(1,3,deviceDetails{2});
    end
    if numDetails>=3&&~isempty(deviceDetails{3})
        table.createEntry(1,4,deviceDetails{3});
    end
    if numDetails==4&&~isempty(deviceDetails{4})
        table.createEntry(1,5,deviceDetails{4});
    end
    w.commitTable(table);

    w.addBreak(2);


    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:targetMappingStatus'));
    w.commitSection(section);
    w.addBreak(2);


    gp=pir;
    if gp.getTargetCodeGenSuccess
        w.addText(DAStudio.message('hdlcoder:report:successful'));
        w.addBreak(2);


        reportOutputPortDelays(w,gp.getTopPirCtx);

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
    else
        w.addText('Failed.');
        w.addBreak(2);
        showOffendingComps(w,p);
    end


    w.dumpHTML;
end

function reportOutputPortDelays(w,p)


    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:pathDelaySummary'));
    w.commitSection(section);
    w.addBreak(2);
    w.addText(DAStudio.message('hdlcoder:report:delayBalancingDetailsOnPathDelays'));
    w.addBreak(2);
end

function offendingComps=parseOffendingCompsStr(offendingCompsStr)
    offendingComps={};
    [t,remain]=strtok(offendingCompsStr,';');
    while~isempty(t)
        offendingComps{end+1}=t;%#ok<AGROW>
        [t,remain]=strtok(remain,';');%#ok<STTOK>
    end
end

function showOffendingComps(w,p)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:detailed_report'));
    w.commitSection(section);
    w.addBreak(2);
    ntks=p.Networks;
    for i=length(ntks):-1:1
        n=ntks(i);
        path2Ntk=n.FullPath;
        if isempty(path2Ntk)
            continue;
        end
        w.addText(sprintf('%s: ',hdlhtml.reportingWizard.generateSystemLink(path2Ntk)));

        messageID=n.getTargetCodeGenMsgID;
        printErrorMessage(w,messageID);
        offendingCompsStr=n.getTargetCodeGenOffendingCompList;
        if messageID==targetcodegen.basedriver.DELAY_CONSTRAINT_NOT_MET
            w.addBreak(2);
            offendingComps=parseOffendingCompsStr(offendingCompsStr);
            table=w.createTable(length(offendingComps),2);
            table.setColHeading(1,DAStudio.message('hdlcoder:report:blockColumnHeading'));
            table.setColHeading(2,DAStudio.message('hdlcoder:report:requiredDelayOutputColumnHeading'),'center');
            for j=1:length(offendingComps)
                offCompDelayPair=offendingComps{j};
                [offComp,remain]=strtok(offCompDelayPair,'=');
                requiredDelay=strtok(remain,'=');
                linkToOffComp=hdlhtml.reportingWizard.generateSystemLink(offComp);
                if~isempty(linkToOffComp)
                    table.createEntry(j,1,linkToOffComp);
                else
                    table.createEntry(j,1,offComp);
                end
                table.createEntry(j,2,requiredDelay,'center');
            end
            w.commitTable(table);
        end

        if messageID==targetcodegen.basedriver.SUBSYSTEM_IN_LOOP||messageID==targetcodegen.basedriver.UNSUPPORTED_BLOCK
            w.addBreak;
            w.addText(hdlhtml.reportingWizard.generateSystemLink(offendingCompsStr));
            w.addBreak;
        end
        w.addBreak(2);
    end
end


function printErrorMessage(w,messageID)
    switch(messageID)
    case 1
        w.addText(DAStudio.message('hdlcoder:report:checkFailed'));
        w.addBreak(2);
        w.addFormattedText(DAStudio.message('hdlcoder:report:reasonWithoutParam'),'b');
        w.addText(DAStudio.message('hdlcoder:report:subsystemFoundInLoop'));
    case 2
        w.addText(DAStudio.message('hdlcoder:report:checkFailed'));
        w.addBreak(2);
        w.addFormattedText(DAStudio.message('hdlcoder:report:reasonWithoutParam'),'b');
        w.addText(DAStudio.message('hdlcoder:report:targetCodeGenNotReqOutDelays'));
    case 3
        w.addText(DAStudio.message('hdlcoder:report:checkFailed'));
        w.addBreak(2);
        w.addFormattedText(DAStudio.message('hdlcoder:report:reasonWithoutParam'),'b');
        w.addText(DAStudio.message('hdlcoder:report:foundContinousInfRate'));
    case 4
        w.addText(DAStudio.message('hdlcoder:report:checkFailed'));
        w.addBreak(2);
        w.addFormattedText(DAStudio.message('hdlcoder:report:reasonWithoutParam'),'b');
        w.addText(DAStudio.message('hdlcoder:report:unsupportedUserDefinedBlock'));
    case 5
        w.addText(DAStudio.message('hdlcoder:report:checkFailed'));
        w.addBreak(2);
        w.addFormattedText(DAStudio.message('hdlcoder:report:reasonWithoutParam'),'b');
        w.addText(DAStudio.message('hdlcoder:report:foundUnsupportedBlock'));
    otherwise
        w.addText(DAStudio.message('hdlcoder:report:checkSuccessful'))
    end
    w.addBreak;
end




