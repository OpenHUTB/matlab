function generateTargetResourceUsageReport(~,ru_content_file,title,model,tcgInventory,JavaScriptBody)





    w=hdlhtml.reportingWizard(ru_content_file,title);


    w.setHeader(DAStudio.message('hdlcoder:report:deviceSpecificResourceReportFor',model));
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end

    w.addBreak(3);

    alteraMegafunctions=targetcodegen.targetCodeGenerationUtils.isAlteraMode();
    xilinxCoreGen=targetcodegen.targetCodeGenerationUtils.isXilinxMode();

    if alteraMegafunctions
        targetPlatform='Altera';
    elseif xilinxCoreGen
        targetPlatform='Xilinx';
    else
        targetPlatform='Unknown';
    end

    if strcmp(targetPlatform,'Unknown')
        w.addText(DAStudio.message('hdlcoder:report:reportDeviceSpecific'));
        w.dumpHTML;
        return;
    end

    deviceDetails=hdlgetdeviceinfo;
    numDetails=length(deviceDetails);

    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:targetSummary'));
    w.commitSection(section);
    w.addBreak(2);
    table=w.createTable(1,5);
    table.setColHeading(1,DAStudio.message('hdlcoder:report:platformColumnHeading'));
    table.setColHeading(2,DAStudio.message('hdlcoder:report:familyColumnHeading'));
    table.setColHeading(3,DAStudio.message('hdlcoder:report:deviceColumnHeading'));
    table.setColHeading(4,DAStudio.message('hdlcoder:report:packageColumnHeading'));
    table.setColHeading(5,DAStudio.message('hdlcoder:report:speedColumnHeading'));
    table.createEntry(1,1,targetPlatform);
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

    if alteraMegafunctions
        printAlteraResourceUsage(w,tcgInventory);
    elseif xilinxCoreGen
        printXilinxResourceUsage(w,tcgInventory);
    end


    w.dumpHTML;
end


function printAlteraResourceUsage(w,tcgInventory)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:altraMegafunctionResourceUsage'));
    w.commitSection(section);
    w.addBreak(2);
    cumUsage=containers.Map('KeyType','char','ValueType','int32');
    if~isempty(tcgInventory)
        targetComps=tcgInventory.getComps;
    end
    if isempty(tcgInventory)||isempty(targetComps)
        w.addText(DAStudio.message('hdlcoder:report:targetMappingUnsuccessfulNoSpecificIP'));
        w.addBreak(2);
        return;
    end

    rtable=w.createTable(length(targetComps),7);

    rtable.setColHeading(1,DAStudio.message('hdlcoder:report:megaFunBlockColumnHeading'));
    rtable.setColHeading(2,DAStudio.message('hdlcoder:report:megaFunModuleColumnHeading'));
    rtable.setColHeading(3,DAStudio.message('hdlcoder:report:resourceUsagePerBlockColumnHeading'));
    rtable.setColHeading(4,DAStudio.message('hdlcoder:report:frequencyColumnHeading'));
    rtable.setColHeading(5,DAStudio.message('hdlcoder:report:latencyCyclesColumnHeading'));
    rtable.setColHeading(6,DAStudio.message('hdlcoder:report:numOfBlockColumnHeading'));
    rtable.setColHeading(7,DAStudio.message('hdlcoder:report:totalResouceUsageColumnHeading'));
    for j=1:length(targetComps)
        comp=targetComps{j};
        rtable.createEntry(j,1,comp);
        rtable.createEntry(j,2,tcgInventory.getModule(comp));

        resourceUsage=tcgInventory.getResourceUsage(comp);
        achievedFreq=tcgInventory.getAchievedFreq(comp);
        achievedLatency=tcgInventory.getAchievedLatency(comp);

        if~isempty(resourceUsage)
            rtable.createEntry(j,3,resourceUsage);
        else
            rtable.createEntry(j,3,'unavailable');
        end

        if achievedFreq~=-1
            freqStr=sprintf('%d',achievedFreq);
        else
            freqStr='N/A';
        end
        rtable.createEntry(j,4,freqStr);

        if achievedLatency~=-1
            latStr=sprintf('%d',achievedLatency);
        else
            latStr='N/A';
        end
        rtable.createEntry(j,5,latStr);

        rtable.createEntry(j,6,num2str(tcgInventory.getCount(comp)));


        totalResourceUsage=getTotalResourceUsage(resourceUsage,tcgInventory,comp);

        if~isempty(totalResourceUsage)
            rtable.createEntry(j,7,totalResourceUsage);

            totalResUsageParts=regexp(totalResourceUsage,'(?<numres>\d+)\s(?<res>\w+);','names');
            for i=1:length(totalResUsageParts)
                currTotalResUsage=totalResUsageParts(i);
                res=currTotalResUsage.res;
                numRes=str2double(currTotalResUsage.numres);
                if cumUsage.isKey(res)
                    lastCumUsage=cumUsage(res);
                    cumUsage(res)=lastCumUsage+numRes;
                else
                    cumUsage(res)=numRes;
                end
            end
        else
            rtable.createEntry(j,7,'unavailable');
        end
    end
    w.commitTable(rtable);
    w.addBreak(2);

    printCumResourceTable(w,cumUsage);
end


function totalResourceUsage=getTotalResourceUsage(resourceUsage,tcgInventory,comp)
    totalResourceUsage='';
    if isempty(resourceUsage)
        return;
    end
    resUsageParts=regexp(resourceUsage,'(?<numres>\d+)\s(?<res>\w+)','names');
    count=tcgInventory.getCount(comp);
    for i=1:length(resUsageParts)
        currResUsage=resUsageParts(i);
        res=currResUsage.res;
        numRes=str2double(currResUsage.numres);
        totalResourceUsage=sprintf('%s%d %s;',totalResourceUsage,numRes*count,res);
    end
end


function printCumResourceTable(w,cumUsage)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:reportAlteraMegaFunctionBlocks'));
    w.commitSection(section);
    w.addBreak(2);
    resources=cumUsage.keys;
    if isempty(resources)
        w.addText(DAStudio.message('hdlcoder:report:unavailable'));
        return;
    end
    table=w.createTable(length(resources),2);

    table.setColHeading(1,DAStudio.message('hdlcoder:report:resourceColumnHeading'));
    table.setColHeading(2,DAStudio.message('hdlcoder:report:totalColumnHeading'));
    for j=1:length(resources)
        resource=resources{j};
        table.createEntry(j,1,resource);
        numResources=cumUsage(resource);
        table.createEntry(j,2,sprintf('%g',numResources));
    end
    w.commitTable(table);
end


function printXilinxResourceUsage(w,tcgInventory)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:xilinxCoregenResourceUsage'));
    w.commitSection(section);
    w.addBreak(2);
    cumUsage=containers.Map('KeyType','char','ValueType','int32');
    if~isempty(tcgInventory)
        targetComps=tcgInventory.getComps;
    end
    if isempty(tcgInventory)||isempty(targetComps)
        w.addText(DAStudio.message('hdlcoder:report:targetMappingUnsuccessful'));
        w.addBreak(2);
        return;
    end

    rtable=w.createTable(length(targetComps),5);

    rtable.setColHeading(1,DAStudio.message('hdlcoder:report:coregenBlockColumnHeading'));
    rtable.setColHeading(2,DAStudio.message('hdlcoder:report:CoregenModuleColumnHeading'));
    rtable.setColHeading(3,DAStudio.message('hdlcoder:report:resourceUsagePerBlockColumnHeading'));
    rtable.setColHeading(4,DAStudio.message('hdlcoder:report:numOfBlockColumnHeading'));
    rtable.setColHeading(5,DAStudio.message('hdlcoder:report:totalResouceUsageColumnHeading'));
    for j=1:length(targetComps)
        comp=targetComps{j};
        rtable.createEntry(j,1,comp);
        rtable.createEntry(j,2,tcgInventory.getModule(comp));

        resourceUsage=tcgInventory.getResourceUsage(comp);

        if~isempty(resourceUsage)
            rtable.createEntry(j,3,tcgInventory.getResourceUsage(comp));
        else
            rtable.createEntry(j,3,'unavailable');
        end

        rtable.createEntry(j,4,num2str(tcgInventory.getCount(comp)));


        totalResourceUsage=getTotalResourceUsage(resourceUsage,tcgInventory,comp);

        if~isempty(totalResourceUsage)
            rtable.createEntry(j,5,totalResourceUsage);

            totalResUsageParts=regexp(totalResourceUsage,'(?<numres>\d+)\s(?<res>\w+);','names');
            for i=1:length(totalResUsageParts)
                currTotalResUsage=totalResUsageParts(i);
                res=currTotalResUsage.res;
                numRes=str2double(currTotalResUsage.numres);
                if cumUsage.isKey(res)
                    lastCumUsage=cumUsage(res);
                    cumUsage(res)=lastCumUsage+numRes;
                else
                    cumUsage(res)=numRes;
                end
            end
        else
            rtable.createEntry(j,5,'unavailable');
        end
    end
    w.commitTable(rtable);
    w.addBreak(2);

end




