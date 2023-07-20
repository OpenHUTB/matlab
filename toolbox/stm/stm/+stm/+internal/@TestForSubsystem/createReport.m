function rpt=createReport(topModel,testfileLocation,result,subsys,status)




    import mlreportgen.report.*
    import mlreportgen.dom.*


    rpt=sltest.testmanager.ReportUtility.TestSpecReport(helperCreateUniqueFileName(pwd,['sltest_',topModel.char,'_TestGenReport'],'.html'),'html-file');

    tp=TitlePage;
    tp.Title=message("stm:TestFromModelComponents:ReportTitle",topModel).getString;
    tp.Subtitle=message("stm:general:Title").getString+" - "+message("stm:TestFromModelComponents:TestForModelComponentsTitle").getString;
    tp.Author=getenv('USERNAME');
    append(rpt,tp);
    append(rpt,TableOfContents);
    ch1=Chapter;
    ch1.Title=message("stm:TestFromModelComponents:ChapterTitle").getString;
    sec1=Section;
    sec1.Title=message("stm:TestFromModelComponents:Section1Title").getString;
    append(sec1,Paragraph([message("stm:TestFromModelComponents:DataFileOptionsStep_TestFileLabel").getString,' ',testfileLocation]));
    append(ch1,sec1);
    sec2=Section;
    sec2.Title=message("stm:TestFromModelComponents:Section2Title").getString;
    td=cell(numel(result),4);
    for row=1:numel(result)

        td{row,1}=row;

        td{row,2}=subsys(row);

        if status(row)
            td{row,3}=Image(fullfile(matlabroot,'toolbox/stm/stm/+stm/+internal/+report/Icons/ResultsStatusIconPassed.png'));
        else
            td{row,3}=Image(fullfile(matlabroot,'toolbox/stm/stm/+stm/+internal/+report/Icons/ResultsStatusIconFailed.png'));
        end
        td{row,3}.Height='15px';
        td{row,3}.Width='15px';

        if status(row)
            td{row,4}=result{row}.TestPath;
        else
            td{row,4}=Text(result{row}.message);
            td{row,4}.Color='red';
            td{row,4}.WhiteSpace='preserve';
        end
    end

    td0=[{Text(message("stm:TestFromModelComponents:SerialColumn").getString)},...
    {Text(message("stm:TestFromModelComponents:ComponentColumn").getString)},...
    {Text(message("stm:TestFromModelComponents:StatusColumn").getString)},...
    {Text(message("stm:TestFromModelComponents:OutcomeColumn").getString)}];
    td0{1,1}.Bold=true;
    td0{1,2}.Bold=true;
    td0{1,3}.Bold=true;
    td0{1,4}.Bold=true;
    td=[td0;td];
    tbl=Table(td);
    tbl.Style={...
    RowSep('solid','black','1px'),...
    ColSep('solid','black','1px'),};
    tbl.Border='double';
    append(sec2,tbl);
    append(ch1,sec2);
    append(rpt,ch1);
    close(rpt);
    rptview(rpt);
end

function uniqueFilePath=helperCreateUniqueFileName(parentPath,fileName,ext)
    idx=1;
    tmpFileName=fileName;
    while(1)
        uniqueFilePath=fullfile(parentPath,[tmpFileName,ext]);
        if(exist(uniqueFilePath,'file')>0)
            tmpFileName=[fileName,num2str(idx)];
            idx=idx+1;
        else
            break;
        end
    end
end
