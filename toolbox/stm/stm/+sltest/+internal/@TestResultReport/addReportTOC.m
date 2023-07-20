function docPart=addReportTOC(obj)











    import mlreportgen.dom.*;

    docPart=Group();

    table=FormalTable(3);
    groups=sltest.testmanager.ReportUtility.genTableColSpecGroup([{'10cm'},{'3cm'},{'3cm'}]);
    table.ColSpecGroups=groups;
    table.Style={ResizeToFitContents(false),Width('17cm')};

    onerow=TableRow();
    if(strcmp(obj.reportType,'html'))
        onerow.Style={OuterMargin('0mm','0mm',obj.SectionSpacing,'0mm')};
    else
        onerow.Style={OuterMargin('0mm','0mm','0mm','0mm')};
    end
    if(obj.IncludeTestResults==1)
        str=getString(message('stm:ReportContent:Label_SummaryPassedOnly'));
    elseif(obj.IncludeTestResults==2)
        str=getString(message('stm:ReportContent:Label_SummaryFailedOnly'));
    else
        str=getString(message('stm:ReportContent:Label_Summary'));
    end
    text=Text(str);
    text.Style={FontSize(obj.HeadingFontSize),Color(obj.HeadingFontColor)};
    text.Bold=true;
    entry=TableEntry(Paragraph(text));
    entry.ColSpan=3;
    entry.Children(1).append(LinkTarget(obj.tocLinkTargetName));
    onerow.append(entry);
    table.append(onerow);

    headrow=TableRow();
    headrow.Style={OuterMargin('0mm','0mm',obj.SectionSpacing,'0mm')};
    fieldNames{1}=getString(message('stm:ReportContent:Label_Name'));
    fieldNames{2}=getString(message('stm:ReportContent:Label_Outcome'));
    fieldNames{3}=getString(message('stm:ReportContent:Label_Duration'));
    for k=1:length(fieldNames)
        text=Text(fieldNames{k});
        text.Style={FontSize(obj.BodyFontSize),Color(obj.BodyFontColor)};
        text.Bold=true;

        entry=TableEntry(text);
        if(k==1)
            entry.Style=[entry.Style,{HAlign('left'),VAlign('middle')}];
        elseif(k==2)
            entry.Style=[entry.Style,{HAlign('right'),VAlign('middle')}];
        elseif(k==3)
            entry.Style=[entry.Style,{HAlign('center'),VAlign('middle')}];
        end
        headrow.append(entry);
    end
    table.append(headrow);

    for treeid=1:length(obj.ResultObjList)
        theNodeList=obj.ResultObjList{treeid};
        for nodeIdx=1:length(theNodeList)
            node=theNodeList(nodeIdx);
            resultObj=node.Data;
            resultType=sltest.testmanager.ReportUtility.getTypeOfTestResult(resultObj);

            onerow=TableRow();

            sizeStr='15px';
            entryPara=Paragraph();
            entryPara.Style={OuterMargin('0mm','0mm','2mm','0mm'),WhiteSpace('pre')};
            if(resultType==sltest.testmanager.TestResultTypes.TestFileResult)
                resultDetails=stm.internal.getTestSuiteResultDetails(resultObj.getID());
                if endsWith(resultDetails.testFileLocation,'.m','IgnoreCase',true)
                    iconImage=Image(obj.IconFileScriptedTestFileResult);
                else
                    iconImage=Image(obj.IconFileTestFileResult);
                end
                img=iconImage;
                img.Width=sizeStr;
                img.Height=sizeStr;
                append(entryPara,img);
            elseif(resultType==sltest.testmanager.TestResultTypes.TestSuiteResult)
                resultDetails=stm.internal.getTestSuiteResultDetails(resultObj.getID());
                if endsWith(resultDetails.testFileLocation,'.m','IgnoreCase',true)
                    iconImage=Image(obj.IconFileScriptedTestSuiteResult);
                else
                    iconImage=Image(obj.IconFileTestSuiteResult);
                end
                img=iconImage;
                img.Width=sizeStr;
                img.Height=sizeStr;
                append(entryPara,img);
            elseif(resultType==sltest.testmanager.TestResultTypes.TestCaseResult)
                if endsWith(resultObj.TestFilePath,'.m','IgnoreCase',true)
                    iconImage=Image(obj.IconFileScriptedTestCaseResult);
                else
                    iconImage=Image(obj.IconFileTestCaseResult);
                end
                img=iconImage;
                img.Width=sizeStr;
                img.Height=sizeStr;
                append(entryPara,img);
            elseif(resultType==sltest.testmanager.TestResultTypes.TestIterationResult)
                img=Image(obj.IconFileTestIterationResult);
                img.Width=sizeStr;
                img.Height=sizeStr;
                append(entryPara,img);
            end
            tmpTxt1=Text(' ');
            sltest.testmanager.ReportUtility.setTextStyle(tmpTxt1,obj.BodyFontName,obj.BodyFontSize,'blue',false,false);
            append(entryPara,tmpTxt1);


            lnkTargetName=sprintf('%s',node.UID);
            inlnkObj=InternalLink(lnkTargetName,resultObj.Name);
            lnkTxt=inlnkObj.Children(1);
            sltest.testmanager.ReportUtility.setTextStyle(lnkTxt,obj.BodyFontName,obj.BodyFontSize,'blue',false,false);
            append(entryPara,inlnkObj);

            nodeDepth=node.IndentLevel;
            indentDelta=9;
            str=sprintf('%dpx',nodeDepth*indentDelta);
            if(nodeDepth>5)
                str=sprintf('%dpx',5*indentDelta);
            end
            entryPara.OuterLeftMargin=str;

            entry=TableEntry(entryPara);
            onerow.append(entry);


            entryPara=Paragraph();
            entryPara.Style={OuterMargin('0in')};

            cM=obj.getCountMetricsOfResult(node.Data);
            if(cM.numOfResults==1)
                outcome=resultObj.Outcome;
                if(outcome==sltest.testmanager.TestResultOutcomes.Passed)
                    append(entryPara,getPassedImage(obj));
                elseif(outcome==sltest.testmanager.TestResultOutcomes.Incomplete)
                    append(entryPara,getIncompleteImage(obj));
                elseif(outcome==sltest.testmanager.TestResultOutcomes.Disabled)
                    append(entryPara,getDisabledImage(obj));
                else
                    append(entryPara,getFailedImage(obj));
                end
            elseif(cM.numOfResults>1)
                prefixFlag=0;
                if(cM.numOfPassed>0)
                    str=sprintf('%d ',cM.numOfPassed);
                    tmpTxt=Text(str);
                    sltest.testmanager.ReportUtility.setTextStyle(tmpTxt,obj.BodyFontName,obj.BodyFontSize,'green',false,false);
                    append(entryPara,tmpTxt);
                    append(entryPara,getPassedImage(obj));
                    prefixFlag=1;
                end

                if(cM.numOfFailed>0)
                    if(prefixFlag)
                        tmpTxt1=Text(' ');
                        sltest.testmanager.ReportUtility.setTextStyle(tmpTxt1,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
                        append(entryPara,tmpTxt1);
                    end
                    str=sprintf('%d ',cM.numOfFailed);
                    tmpTxt2=Text(str);
                    sltest.testmanager.ReportUtility.setTextStyle(tmpTxt2,obj.BodyFontName,obj.BodyFontSize,'red',false,false);
                    append(entryPara,tmpTxt2);
                    append(entryPara,getFailedImage(obj));
                    prefixFlag=1;
                end

                if(cM.numOfDisabled>0)
                    if(prefixFlag)
                        tmpTxt1=Text(' ');
                        sltest.testmanager.ReportUtility.setTextStyle(tmpTxt1,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
                        append(entryPara,tmpTxt1);
                    end
                    str=sprintf('%d ',cM.numOfDisabled);
                    tmpTxt2=Text(str);
                    sltest.testmanager.ReportUtility.setTextStyle(tmpTxt2,obj.BodyFontName,obj.BodyFontSize,'grey',false,false);
                    append(entryPara,tmpTxt2);
                    append(entryPara,getDisabledImage(obj));
                    prefixFlag=1;
                end

                if(cM.numOfIncomplete>0)
                    if(prefixFlag)
                        tmpTxt1=Text(' ');
                        sltest.testmanager.ReportUtility.setTextStyle(tmpTxt1,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
                        append(entryPara,tmpTxt1);
                    end
                    str=sprintf('%d ',cM.numOfIncomplete);
                    tmpTxt2=Text(str);
                    sltest.testmanager.ReportUtility.setTextStyle(tmpTxt2,obj.BodyFontName,obj.BodyFontSize,'black',false,false);
                    append(entryPara,tmpTxt2);
                    append(entryPara,getIncompleteImage(obj));
                end
            end
            entry=TableEntry(entryPara);
            entry.Style=[entry.Style,{HAlign('right'),VAlign('middle')}];
            onerow.append(entry);


            entryPara=Paragraph();
            entryPara.Style={OuterMargin('0in')};
            txtStr=num2str(stm.internal.getResultObjectProp(resultObj.getID,'Duration'));
            txtObj=Text(txtStr);
            sltest.testmanager.ReportUtility.setTextStyle(txtObj,obj.BodyFontName,obj.BodyFontSize,obj.BodyFontColor,false,false);
            append(entryPara,txtObj);

            entry=TableEntry(entryPara);
            entry.Style=[entry.Style,{HAlign('center'),VAlign('middle')}];
            onerow.append(entry);

            table.append(onerow);
        end
    end
    append(docPart,table);

    append(obj.TOCPart,docPart);
end

function img=getPassedImage(obj)
    img=mlreportgen.dom.Image(obj.IconFileOutcomePassed);
    setImageStyle(img);
end

function img=getFailedImage(obj)
    img=mlreportgen.dom.Image(obj.IconFileOutcomeFailed);
    setImageStyle(img);
end

function img=getIncompleteImage(obj)
    img=mlreportgen.dom.Image(obj.IconFileOutcomeIncomplete);
    setImageStyle(img);
end

function img=getDisabledImage(obj)
    img=mlreportgen.dom.Image(obj.IconFileOutcomeDisabled);
    setImageStyle(img);
end

function setImageStyle(img)
    sizeStr='12px';
    img.Width=sizeStr;
    img.Height=sizeStr;
end
