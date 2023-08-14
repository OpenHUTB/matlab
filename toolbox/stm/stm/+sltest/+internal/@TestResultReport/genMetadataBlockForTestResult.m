function groupObj=genMetadataBlockForTestResult(obj,result,isTestSuiteResult)
















    p=inputParser;
    addRequired(p,'obj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{}));
    addRequired(p,'result',...
    @(x)validateattributes(x,{'sltest.testmanager.ReportUtility.ReportResultData'},{}));
    addRequired(p,'isTestSuiteResult',...
    @(x)validateattributes(x,{'logical'},{'scalar'}));
    p.parse(obj,result,isTestSuiteResult);

    import mlreportgen.dom.*;

    groupObj=Group();
    resultObj=result.Data;
    description=resultObj.Description;
    hasResultDescription=strlength(description)>0;


    table=FormalTable(1);
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup({'10cm'});
    table.ColSpecGroups=groups;
    table.TableEntriesStyle={OuterMargin('0mm')};
    table.Style=[table.Style,{ResizeToFitContents(false)}];
    onerow=TableRow();
    text=Text(resultObj.Name);
    sltest.testmanager.ReportUtility.setTextStyle(text,obj.HeadingFontName,...
    obj.HeadingFontSize,obj.HeadingFontColor,true,false);

    entryPara=Paragraph();
    entryPara.Style=[entryPara.Style,{OuterMargin('0mm','0mm','0mm','0mm')}];

    lnkTargetName=sprintf('%s',result.UID);
    entryPara.append(LinkTarget(lnkTargetName));

    entryPara.append(text);

    entry=TableEntry(entryPara);
    onerow.append(entry);

    append(table,onerow);
    append(groupObj,table);
    append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));


    table=FormalTable(2);
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'4cm'},{'10cm'}]);
    table.ColSpecGroups=groups;
    table.TableEntriesStyle={OuterMargin('0mm')};
    table.Style=[table.Style,{ResizeToFitContents(false),Width('15cm'),...
    OuterMargin(obj.ChapterIndent,'0mm','0mm',obj.SectionSpacing)}];

    onerow=TableRow();
    str=getString(message('stm:ReportContent:Label_TestResultInformation'));
    text=Text(str);
    sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,true,false);
    entryPara=Paragraph(text);
    entryPara.Style=[entryPara.Style,{OuterMargin('0mm','0mm','0mm','2mm')}];
    entry=TableEntry(entryPara);
    entry.ColSpan=2;

    onerow.append(entry);
    append(table,onerow);

    rowList=obj.genTableRowsForResultMetaInfo(result);
    for k=1:length(rowList)
        append(table,rowList(k));
    end


    if hasResultDescription
        onerow=TableRow();
        text1=text.clone();
        text1.Content=getString(message('stm:ReportContent:Field_Description'));
        sltest.testmanager.ReportUtility.setTextStyle(text1,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
        onerow.append(TableEntry(text1));

        text1=text.clone();
        text1.Content='';
        onerow.append(TableEntry(text1));
        append(table,onerow);
    end
    append(groupObj,table);
    append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));

    if hasResultDescription
        htmlBlock=sltest.testmanager.ReportUtility.genHTMLBlock(obj,description,obj.ChapterIndentL2);
        append(groupObj,htmlBlock);
        append(groupObj,sltest.testmanager.ReportUtility.vspace(obj.SectionSpacing));
    end



    table=FormalTable(2);
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'4cm'},{'10cm'}]);
    table.ColSpecGroups=groups;
    table.TableEntriesStyle={OuterMargin('0mm')};
    table.Style=[table.Style,{ResizeToFitContents(false),Width('15cm'),...
    OuterMargin(obj.ChapterIndent,'0mm','0mm',obj.SectionSpacing)}];

    onerow=TableRow();
    if(isTestSuiteResult)
        str=getString(message('stm:ReportContent:Label_TestSuiteInformation'));
    else
        str=getString(message('stm:ReportContent:Label_TestCaseInformation'));
    end
    text=Text(str);
    sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,true,false);
    entryPara=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
    entryPara.Style=[entryPara.Style,{OuterMargin('0mm','0mm','0mm','2mm')}];
    entry=TableEntry(entryPara);
    entry.ColSpan=2;
    entry.Style={HAlign('left'),VAlign('middle')};
    onerow.append(entry);
    append(table,onerow);


    onerow=TableRow();
    str=getString(message('stm:ReportContent:Field_Name'));
    text=Text(str);
    text.Style=[text.Style,{FontSize(obj.BodyFontSize),Color(obj.BodyFontColor)}];
    onerow.append(TableEntry(text));

    str=char(resultObj.Name);
    entry=sltest.testmanager.ReportUtility.genDefaultTableEntry(obj,str);
    onerow.append(entry);
    append(table,onerow);



    if(~strcmp(class(resultObj),'sltest.testmanager.TestIterationResult'))%#ok<STISA> inheritance
        tagList=resultObj.Tags;
        if(~isempty(tagList))
            str=getString(message('stm:ReportContent:Field_Tags'));

            onerow=TableRow();
            text=Text(str);
            text.Style=[text.Style,{FontSize(obj.BodyFontSize),Color(obj.BodyFontColor)}];
            onerow.append(TableEntry(text));

            str=tagList.join(',').char;
            entry=sltest.testmanager.ReportUtility.genDefaultTableEntry(obj,str);
            onerow.append(entry);
            append(table,onerow);
        end
    end



    if(~isTestSuiteResult)
        onerow=TableRow();
        str=getString(message('stm:ReportContent:Field_Type'));
        text=Text(str);
        text.Style=[text.Style,{FontSize(obj.BodyFontSize),Color(obj.BodyFontColor)}];
        onerow.append(TableEntry(text));

        str=char(resultObj.TestCaseType);
        if(any(resultObj.RunOnTarget))
            str=[getString(message('stm:toolstrip:RealTimeTest')),' (',str,' )'];
        end
        text=Text(str);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
        entry=TableEntry(text);
        entry.Style={HAlign('left'),VAlign('middle')};
        onerow.append(entry);
        append(table,onerow);


        testCaseType=sltest.testmanager.ReportUtility.getTestTypeOfResult(resultObj);
        if(testCaseType==sltest.testmanager.TestCaseTypes.Baseline)
            if(~isempty(resultObj.Baseline.BaselineName))
                onerow=TableRow();
                str=getString(message('stm:ReportContent:Field_BaselineName'));
                entry=sltest.testmanager.ReportUtility.genDefaultTableEntry(obj,str);
                onerow.append(entry);

                str=resultObj.Baseline.BaselineName;
                entry=sltest.testmanager.ReportUtility.genDefaultTableEntry(obj,str);
                onerow.append(entry);
                append(table,onerow);

                if(~isempty(resultObj.Baseline.BaselineFile))
                    onerow=TableRow();

                    str=getString(message('stm:ReportContent:Field_BaselineFile'));
                    entry=sltest.testmanager.ReportUtility.genDefaultTableEntry(obj,str);
                    onerow.append(entry);

                    str=resultObj.Baseline.BaselineFile;
                    entry=sltest.testmanager.ReportUtility.genDefaultTableEntry(obj,str);
                    onerow.append(entry);

                    append(table,onerow);
                end
            end
        end
    end

    if(isa(resultObj,'sltest.testmanager.TestCaseResult'))
        adapterName='';
        try
            adapterName=resultObj.Adapter;
        catch
        end

        if(~isempty(adapterName))
            sltest.internal.Helper.addAdapterInfoToTable(obj,resultObj,table);
        end
    end
    append(groupObj,table);


    if(resultObj.Outcome==sltest.testmanager.TestResultOutcomes.Disabled&&~isempty(resultObj.DisablingReason))
        str=getString(message('stm:ReportContent:Field_DisableReason'));
        text=Text(str);
        sltest.testmanager.ReportUtility.setTextStyle(text,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
        para=Paragraph(text);
        para.Style=[para.Style,{OuterMargin(obj.ChapterIndent,'0in','0in','0in')}];
        append(groupObj,para);

        htmlBlock=sltest.testmanager.ReportUtility.genHTMLBlock(obj,resultObj.DisablingReason,obj.ChapterIndentL2);
        append(groupObj,htmlBlock);
    end

    resultType=sltest.testmanager.ReportUtility.getTypeOfTestResult(result.Data);
    if(resultType==sltest.testmanager.TestResultTypes.TestIterationResult)
        itrDoc=obj.genIterationSettingTable(result);
        groupObj.append(itrDoc);
    end


    if(~isempty(resultObj.Requirements)&&obj.IncludeTestRequirement==1)
        reqTable=obj.genRequirementLinksTable(resultObj,isTestSuiteResult);
        append(groupObj,reqTable);
        append(groupObj,sltest.testmanager.ReportUtility.vspace('0mm'));
    end

end
