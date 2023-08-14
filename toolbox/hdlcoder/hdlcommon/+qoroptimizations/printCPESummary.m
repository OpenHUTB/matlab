

function printCPESummary(model,cpeDelaysMap,cpeHtmlFile,cpehighlight,offendinghighlight)



    ids=sort(cell2mat(cpeDelaysMap.keys()));
    numOfElements=numel(ids);

    updatedDelaysMap=containers.Map('KeyType','double','ValueType','any');
    numOfRows=0;
    for i=1:numOfElements


        isPathSubsystem=0;
        if i<numOfElements
            delimiter="/";
            currentBlockpath=cpeDelaysMap(ids(i)).blockPath;
            nextBlockpath=cpeDelaysMap(ids(i+1)).blockPath;
            pathTokens=split(nextBlockpath,delimiter);
            pathTokens(end)=[];
            nextBlockpath=join(pathTokens,delimiter);
            isPathSubsystem=strcmp(currentBlockpath,nextBlockpath);
        end


        if isPathSubsystem
            continue;
        end

        numOfRows=numOfRows+1;
        updatedDelaysMap(numOfRows)=cpeDelaysMap(ids(i));
    end



    w=hdlhtml.reportingWizard(cpeHtmlFile,'Critical Path Summary Report');
    w.addCollapsibleJS;
    w.setHeader(message('hdlcoder:optimization:CPEReportTitle',model).getString);
    w.addBreak(3);

    if(numOfRows==0)
        w.addText(DAStudio.message('hdlcoder:optimization:NoCriticalPathFound'));
        w.dumpHTML();
        return;
    end

    firstEntry=updatedDelaysMap(1);
    lastEntry=updatedDelaysMap(numOfRows);


    section=w.createSectionTitle(message('hdlcoder:optimization:SectionSummary').getString);
    w.commitSection(section);
    w.addText('<hr>');
    p=pir;
    longestDelay=p.getCriticalPathDelay;
    longestDelayStr=sprintf("%.3f",longestDelay);
    w.addText(sprintf([DAStudio.message('hdlcoder:optimization:CriticalPathDelay',longestDelayStr),'<br>']));

    if(~isempty(firstEntry)&&~isempty(firstEntry.blockPath))
        w.addText([DAStudio.message('hdlcoder:optimization:CriticalPathBegin',hdlhtml.reportingWizard.generateSystemLink(firstEntry.blockPath)),'<br>']);
    end

    if(~isempty(lastEntry)&&~isempty(lastEntry.blockPath))
        w.addText([DAStudio.message('hdlcoder:optimization:CriticalPathEnd',hdlhtml.reportingWizard.generateSystemLink(lastEntry.blockPath)),'<br>']);
    end

    cpelink=sprintf('<a href="matlab:run(''%s'')">%s.m</a>',cpehighlight,cpehighlight);
    w.addText([DAStudio.message('hdlcoder:optimization:HighCriticalPath',cpelink),'<br>']);
    if(~isempty(offendinghighlight))
        offlink=sprintf('<a href="matlab:run(''%s'')">%s.m</a>',offendinghighlight,offendinghighlight);
        w.addText([DAStudio.message('hdlcoder:optimization:HighlightUncharacterizedBlocks',offlink),'<br>']);
    end
    w.addBreak(2);



    section=w.createSectionTitle(message('hdlcoder:optimization:CPEPathDetails').getString);
    w.commitSection(section);
    w.addText('<hr>');



    smtable=w.createTable(numOfRows,4);
    smtable.getData.setColWidth(1,1);
    smtable.setColHeading(1,DAStudio.message('hdlcoder:optimization:Id'));
    smtable.setColHeading(2,DAStudio.message('hdlcoder:optimization:Propagation'));
    smtable.setColHeading(3,DAStudio.message('hdlcoder:optimization:Delay'));
    smtable.setColHeading(4,DAStudio.message('hdlcoder:optimization:BlockPath'));


    prevBlockDelayInfo={};
    for currentRow=1:numOfRows
        prevPropDelay=0;
        currentBlockDelayInfo=updatedDelaysMap(currentRow);
        propagationDelay=str2double(currentBlockDelayInfo.propagationDelay);
        if~isempty(prevBlockDelayInfo)
            prevPropDelay=str2double(prevBlockDelayInfo.propagationDelay);
        end
        unitDelay=propagationDelay-prevPropDelay;

        smtable.createEntry(currentRow,1,sprintf('%d',currentRow));
        smtable.createEntry(currentRow,2,sprintf('%.4f',propagationDelay));
        smtable.createEntry(currentRow,3,sprintf('%.4f',unitDelay));
        smtable.createEntry(currentRow,4,sprintf('%s',hdlhtml.reportingWizard.generateSystemLink(currentBlockDelayInfo.blockPath)));
        prevBlockDelayInfo=currentBlockDelayInfo;
    end
    w.commitTable(smtable);
    w.addBreak(2);


    w.dumpHTML;
end



