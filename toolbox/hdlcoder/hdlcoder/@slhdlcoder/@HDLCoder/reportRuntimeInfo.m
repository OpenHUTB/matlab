function reportRuntimeInfo(this)




    if isempty(this)
        return;
    end

    codeGenDir=this.hdlGetCodegendir;
    fileName=[this.ModelName,'_performance_rpt.html'];
    if~isempty(dir(fullfile(pwd,codeGenDir)))
        codeGenDir=fullfile(pwd,codeGenDir);
    elseif isempty(dir(codeGenDir))
        assert(false,message('hdlcoder:engine:fullfilenamenotfound'));
    end

    fullFileName=fullfile(codeGenDir,fileName);


    w=hdlhtml.reportingWizard(fullFileName,this.ModelName);


    w.setHeader(getBoldFormat(MSG('hdlcoder:report:PerformanceRptTitle',this.getStartNodeName),getStyleInfo('Navy')));


    w.addBreak(2);


    generateRunTimeSummaryReport(w,this.getStartNodeName,this.ModelName,codeGenDir);


    generateModelDiagnosticsReport(w,this.getStartNodeName);


    w.dumpHTML;


    filePath=coder.report.internal.fileURL(fullFileName,'');
    if feature('hotlinks')
        WebLink=hdlcoder.report.getHDLCoderHyperLink(filePath,fileName);
    else
        WebLink=filePath;
    end


    hdldisp(message('hdlcoder:hdldisp:HTMLPerformanceReportGenerated',WebLink));
end



function generateRunTimeSummaryReport(w,DUT,modelName,codegenDir)


    w.addText(getBoldFormat(MSG('hdlcoder:report:PerformanceRptCodeGenStatistics',DUT),getStyleInfo('Navy')));
    w.addBreak(1);
    w.addText(getParagraphFormat(MSG('hdlcoder:report:PerformanceRptCodeGenSummary'),getStyleInfo('Black')));
    w.addBreak(1);

    runtimeObj=jsondecode(fileread(fullfile(codegenDir,...
    [modelName,'_runtime_info.json'])));
    phaseNames=fieldnames(runtimeObj);
    phaseCount=numel(phaseNames);

    styleInfo1=getStyleInfo('Maroon');
    styleInfo2=getStyleInfo('Black');
    styleInfo3=getStyleInfo('Green');
    table=w.createTable(phaseCount+1,2);
    table.createEntry(1,1,getBoldFormat('Code Generation state',styleInfo1));
    table.createEntry(1,2,getBoldFormat('Execution time in sec',styleInfo1));

    for ii=1:phaseCount-1
        phaseKey=phaseNames{ii};
        phaseInfo=runtimeObj.(phaseKey);
        table.createEntry(ii+1,1,getSmallFormat(phaseInfo{1},styleInfo2));
        table.createEntry(ii+1,2,getSmallFormat(num2str(round(phaseInfo{2},4)),styleInfo2));
    end

    phaseKey=phaseNames{ii+1};
    phaseInfo=runtimeObj.(phaseKey);
    table.createEntry(ii+2,1,getBoldFormat(phaseInfo{1},styleInfo3));
    table.createEntry(ii+2,2,getBoldFormat(num2str(round(phaseInfo{2},4)),styleInfo3));
    w.commitTable(table);
end


function generateModelDiagnosticsReport(w,DUT)


    [~,sRpt]=sldiagnostics(DUT,'CountBlocks','CountSF','Libs');


    reportSimulinkBlockInfo(w,DUT,sRpt);


    reportStateflowBlockInfo(w,DUT,sRpt);


    reportLibraryBlockInfo(w,DUT,sRpt);
end

function reportSimulinkBlockInfo(w,DUT,sRpt)

    w.addBreak(3);
    w.addText(getBoldFormat(MSG('hdlcoder:report:PerformanceRptSimulinkBlkStatistics',DUT),getStyleInfo('Navy')));
    w.addBreak(1);
    w.addText(getParagraphFormat(MSG('hdlcoder:report:PerformanceRptSimulinkBlkSummary'),getStyleInfo('Black')));
    w.addText(getParagraphFormat(MSG('hdlcoder:report:PerformanceRptSimulinkBlkNote'),getStyleInfo('Black')));
    w.addBreak(1);

    row=1;
    blkList=sRpt.blocks;
    numOfBlks=length(blkList);
    styleInfo1=getStyleInfo('Maroon');
    styleInfo2=getStyleInfo('Black');
    styleInfo3=getStyleInfo('Green');
    table=w.createTable(numOfBlks+1,2);
    table.createEntry(row,1,getBoldFormat('Type',styleInfo1));
    table.createEntry(row,2,getBoldFormat('Count',styleInfo1));

    row=row+1;
    for i=2:numOfBlks
        blkType=blkList(i).type;
        if blkList(i).isMask
            blkType=[blkType,' ','''','M',''''];
        end
        blkCount=num2str(blkList(i).count);
        table.createEntry(row,1,getSmallFormat(blkType,styleInfo2));
        table.createEntry(row,2,getSmallFormat(blkCount,styleInfo2));

        row=row+1;
    end

    blkCount=num2str(blkList(1).count);
    table.createEntry(row,1,getBoldFormat('Total Count',styleInfo3));
    table.createEntry(row,2,getBoldFormat(blkCount,styleInfo3));

    w.commitTable(table);
end

function reportStateflowBlockInfo(w,DUT,sRpt)

    blkList=sRpt.stateflow;


    proonedBlkList={};
    for ii=1:length(blkList)
        if blkList(ii).count
            proonedBlkList{end+1}=blkList(ii);
        end
    end

    numOfBlks=length(proonedBlkList);
    if numOfBlks
        w.addBreak(3);
        w.addText(getBoldFormat(MSG('hdlcoder:report:PerformanceRptStateflowBlkStatistics',DUT),getStyleInfo('Navy')));
        w.addBreak(1);
        w.addText(getParagraphFormat(MSG('hdlcoder:report:PerformanceRptStateflowBlkSummary'),getStyleInfo('Black')));
        w.addBreak(1);

        styleInfo1=getStyleInfo('Maroon');
        styleInfo2=getStyleInfo('Black');
        table=w.createTable(numOfBlks+1,2);
        table.createEntry(1,1,getBoldFormat('Type',styleInfo1));
        table.createEntry(1,2,getBoldFormat('Count',styleInfo1));

        for ii=1:numOfBlks
            blkType=proonedBlkList{ii}.class;
            blkCount=num2str(proonedBlkList{ii}.count);
            table.createEntry(ii+1,1,getSmallFormat(blkType,styleInfo2));
            table.createEntry(ii+1,2,getSmallFormat(blkCount,styleInfo2));
        end
        w.commitTable(table);
    end
end

function reportLibraryBlockInfo(w,DUT,sRpt)

    libList=sRpt.links;
    numOfLibs=length(libList);

    if numOfLibs
        w.addBreak(3);
        w.addText(getBoldFormat(MSG('hdlcoder:report:PerformanceRptLibStatistics',DUT),getStyleInfo('Navy')));
        w.addBreak(1);
        w.addText(getParagraphFormat(MSG('hdlcoder:report:PerformanceRptLibSummary'),getStyleInfo('Black')));
        w.addBreak(1);

        styleInfo1=getStyleInfo('Maroon');
        styleInfo2=getStyleInfo('Black');
        styleInfo3=getStyleInfo('Green');
        for ii=1:numOfLibs
            libName=libList(ii).libName;
            libLinkCount=num2str(libList(ii).numLinksToLib);
            w.addText(getBoldFormat(['Library name : ',libName{1}],styleInfo3));
            w.addBreak(1);
            w.addText(getBoldFormat(['Number of links to library : ',libLinkCount],styleInfo3));
            w.addBreak(2);
            refBlks=libList(ii).refBlocks;
            refBlkCount=length(refBlks);
            table=w.createTable(refBlkCount+1,2);
            table.createEntry(1,1,getBoldFormat('Block Name',styleInfo1));
            table.createEntry(1,2,getBoldFormat('Number of Instances',styleInfo1));
            for jj=1:refBlkCount
                blkName=refBlks(jj).blockName;
                blkCount=num2str(refBlks(jj).numInstances);
                table.createEntry(jj+1,1,getSmallFormat(blkName,styleInfo2));
                table.createEntry(jj+1,2,getSmallFormat(blkCount,styleInfo2));
            end
            w.commitTable(table);
            w.addBreak(2);
        end
    end
end

function boldStr=getSmallFormat(str,styleInfo)
    boldStr=['<small ',styleInfo,'>',str,'</small>'];
end

function boldStr=getBoldFormat(str,styleInfo)
    boldStr=['<b',styleInfo,'>',str,'</b>'];
end

function paraStr=getParagraphFormat(str,styleInfo)
    paraStr=['<p',styleInfo,'>',str,'</p>'];
end

function styleInfo=getStyleInfo(color)
    styleInfo=[' style="'...
    ,'color:',color,';'...
    ,'" '];
end


function str=MSG(varargin)
    obj=message(varargin{:});
    str=obj.getString();
end
