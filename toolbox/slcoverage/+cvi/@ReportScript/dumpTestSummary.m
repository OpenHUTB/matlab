function testLabels=dumpTestSummary(this,allTests,options)








    msgId='Slvnv:simcoverage:cvhtml:Tests';
    htmlTag=cvi.ReportScript.convertNameToHtmlTag(msgId);
    printIt(this,'<a name="%s"></a><h2>%s</h2>\n',htmlTag,getString(message(msgId)));
    [testInfo,colInfo]=collectTestInfo(this,allTests,options);

    [tableInfo,tableTemplate]=getTemplate(options,colInfo,any([testInfo.hasLinkedName]));
    tableStr=cvprivate('html_table',testInfo,tableTemplate,tableInfo);
    printIt(this,'%s',tableStr);
    printIt(this,'<br/>\n');
    testLabels={testInfo(:).testIdxLabel};

    function[testInfo,colInfo]=collectTestInfo(~,allTests,options)
        colInfo.hasSetupCmd=false;
        colInfo.hasLabel=false;
        colInfo.hasTimeInterval=false;
        colInfo.hasDescription=false;
        testNum=numel(allTests);
        testInfo=[];
        for idx=1:testNum
            cvd=allTests{idx};
            testId=cvd.id;
            if idx==testNum&&...
                numel(allTests)>1&&~options.cumulativeReport
                ts.testIdxLabel=getString(message('Slvnv:simcoverage:cvhtml:Total'));
            else
                testCaseName=cvi.ReportScript.getTestCaseName(cvd.testRunInfo,options);
                if~isempty(testCaseName)
                    ts.testIdxLabel=testCaseName;
                    ts.hasLinkedName=true;
                else
                    ts.testIdxLabel=getString(message('Slvnv:simcoverage:cvhtml:Test',num2str(idx)));
                    ts.hasLinkedName=false;
                end

            end

            ts.description=cvd.description;
            if(testId>0)
                cvt=cvtest(testId);
                ts.mlSetupCmd=cvt.setupCmd;
                ts.label=cvt.label;
            else
                ts.mlSetupCmd='';
                ts.label='';
            end
            if~isempty(ts.mlSetupCmd)
                colInfo.hasSetupCmd=true;
            end

            if~isempty(ts.label)
                colInfo.hasLabel=true;
            end
            if~isempty(ts.description)
                colInfo.hasDescription=true;
            end

            ts.startTime=cvd.startTime;
            ts.stopTime=cvd.stopTime;
            ts.timeInterval='';
            if(testId>0)
                cvt=cvtest(testId);
                if cvt.options.useTimeInterval&&(cvd.intervalStopTime>=cvd.intervalStartTime)
                    ts.timeInterval=sprintf('[%d, %d]',cvd.intervalStartTime,cvd.intervalStopTime);
                    colInfo.hasTimeInterval=true;
                end
            end
            if isempty(testInfo)
                testInfo=ts;
            else
                testInfo(end+1)=ts;%#ok<AGROW>
            end
        end
        if~colInfo.hasLabel
            testInfo=rmfield(testInfo,'label');
        end
        if~colInfo.hasTimeInterval
            testInfo=rmfield(testInfo,'timeInterval');
        end
        if~colInfo.hasSetupCmd
            testInfo=rmfield(testInfo,'mlSetupCmd');
        end


        function[tableInfo,tableTemplate]=getTemplate(options,colInfo,hasLinkedName)

            tableInfo.table='border="0" cellpadding="5" ';
            tableInfo.cols=struct('align','"left"');
            tableInfo.imageDir=options.imageSubDirectory;
            if hasLinkedName
                tableTemplate={['$<b> ','Test',' </b>']};
            else
                tableTemplate={['$<b> ','Test#',' </b>']};
            end
            tableRows={{'Cat','#testIdxLabel'}};
            if colInfo.hasLabel
                tableTemplate=[tableTemplate,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:Description')),' </b>']}];
                tableRows=[tableRows,{{'Cat','#label'}}];
            end

            tableTemplate=[tableTemplate,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:StartedExecution')),' </b>']}];
            tableTemplate=[tableTemplate,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:EndedExecution')),' </b>']}];

            tableRows=[tableRows,{{'Cat','#startTime'}}];
            tableRows=[tableRows,{{'Cat','#stopTime'}}];

            if colInfo.hasTimeInterval
                tableTemplate=[tableTemplate,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:TimeWindow')),' </b>']}];
                tableRows=[tableRows,{{'Cat','#timeInterval'}}];
            end
            if colInfo.hasSetupCmd
                tableTemplate=[tableTemplate,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:SetupCommand')),' </b>']}];
                tableRows=[tableRows,{{'Cat','#mlSetupCmd'}}];
            end
            descriptionRow={};
            if colInfo.hasDescription
                tableTemplate=[tableTemplate,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:Description')),' </b>']}];
                tableRows=[tableRows,{{'Cat','#description'}}];
            end

            tableTemplate=[tableTemplate,{'\n'}];

            tableTemplate=[tableTemplate...
            ,{{'ForEach','#.',...
            tableRows{:},...
            descriptionRow{:},...
            '\n',...
            }}];

            function label=report_test(this,testObj,idx,lastLabel)


                mlSetupCmd='';
                testId=testObj.id;
                if isempty(lastLabel)
                    label=getString(message('Slvnv:simcoverage:cvhtml:Test',num2str(idx)));
                    if(testId>0)
                        [lab,mlSetupCmd]=cv('get',testId,'testdata.label','testdata.mlSetupCmd');
                        if~isempty(lab)
                            label=[label,', ',lab];
                        end
                    end
                else
                    label=lastLabel;
                end

                hasLabel=~isempty(label);
                hasTimeInterval=false;

                if(testId>0)
                    cvt=cvtest(testId);
                    if cvt.options.useTimeInterval&&(testObj.intervalStopTime>=testObj.intervalStartTime)
                        hasTimeInterval=true;
                    end
                end
                printIt(this,'<h3> %s </h3>\n');
                printIt(this,'<table>\n');
                printIt(this,'<thead> <tr>\n');
                if hasLabel
                    printIt(this,'<th>Description</th>')
                end
                printIt(this,'<th>%s</th>',getString(message('Slvnv:simcoverage:cvhtml:StartedExecution')));
                printIt(this,'<th>%s</th>',getString(message('Slvnv:simcoverage:cvhtml:EndedExecution')));
                if hasTimeInterval
                    printIt(this,'<th>Description</th>')
                end

                printIt(this,'</tr> </thead>\n');
                printIt(this,'<tr>\n');
                printIt(this,'<td> %s </td> \n',testObj.startTime);
                printIt(this,'<td> %s </td> \n',testObj.stopTime);
                if~isempty(label)
                    printIt(this,'<td> %s </td> \n',label);
                end
                printIt(this,'</tr>\n');
                if(testId>0)
                    cvt=cvtest(testId);
                    if cvt.options.useTimeInterval&&(testObj.intervalStopTime>=testObj.intervalStartTime)
                        printIt(this,'<tr> <td> %s </td> <td> [%d, %d] </td> </tr>\n',getString(message('Slvnv:simcoverage:cvhtml:TimeWindow')),testObj.intervalStartTime,testObj.intervalStopTime);
                    end
                end
                if~isempty(mlSetupCmd)
                    printIt(this,'<tr> <td> %s: </td> <td> %s </td> </tr>\n',getString(message('Slvnv:simcoverage:cvhtml:SetupCommand')),mlSetupCmd);
                end
                printIt(this,'</table>\n');
