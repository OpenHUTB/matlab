function addReportBody(reportObj)
    % Create report body here
    import mlreportgen.report.*;
    import mlreportgen.dom.*;
    
    earlyReturn = false;
    numTestObjsDone = 0;
    for i=1:length(reportObj.content)
        % break if reportObj.ReportGenStatus is set to stop report generation
        reportObj.ReportGenStatus = reportObj.getReportGenerationStatus();
        if(reportObj.ReportGenStatus >= 2)
            addIncompleteReportMsg(reportObj.Report);
            return;
        end
        testObj = reportObj.content{i};
        if(isa(testObj, 'sltest.testmanager.TestFile'))
            isValid = stm.internal.isValid(testObj.getID,'stm.TestSuite');
            if(~isValid)
                error('stm:general:InvalidTestObject', getString(message('stm:TestSpecReportContent:InvalidTestObject')));
            end
            earlyReturn = addTestFileBody(reportObj, testObj, reportObj.Report);
        elseif(isa(testObj, 'sltest.testmanager.TestSuite'))
            isValid = stm.internal.isValid(testObj.getID,'stm.TestSuite');
            if(~isValid)
                error('stm:general:InvalidTestObject', getString(message('stm:TestSpecReportContent:InvalidTestObject')));
            end
            earlyReturn = addTestSuiteBody(reportObj, testObj, reportObj.Report);
        elseif(isa(testObj, 'sltest.testmanager.TestCase'))
            isValid = stm.internal.isValid(testObj.getID,'stm.TestCase');
            if(~isValid)
                error('stm:general:InvalidTestObject', getString(message('stm:TestSpecReportContent:InvalidTestObject')));
            end
            earlyReturn = addTestCaseBody(reportObj, testObj, reportObj.Report);
        end
        if(earlyReturn)
           return; 
        end
        numTestObjsDone = numTestObjsDone + 1;
        percent = floor(numTestObjsDone*100 / length(reportObj.content));
        reportObj.updateReportGenerationStatus(percent);
    end
end

function earlyReturn = addTestFileBody(reportObj, testObj, parentSection)
   import mlreportgen.report.*;
   import mlreportgen.dom.*;
   
   earlyReturn = false;
   tfSection = Section;
   if(testObj.Enabled)
       tfSection.Title = Text(testObj.Name);
   else
       tfSection.Title = Text([testObj.Name, ' ', getString(message('stm:TestSpecReportContent:TestObjDisabled'))]);
       tfSection.Title.Italic = true;
   end
   tfSection.Title.FontSize = '24px';
   createTestFileReportBody(reportObj, testObj, tfSection);
   testSuites = testObj.getTestSuites;
   for j = 1 : length(testSuites)
      earlyReturn = addTestSuiteBody(reportObj, testSuites(j), tfSection);
      if(earlyReturn)
         return; 
      end
   end
   % break if reportObj.ReportGenStatus is set to stop report generation
   reportObj.ReportGenStatus = reportObj.getReportGenerationStatus();
   if(reportObj.ReportGenStatus >= 2)
       addIncompleteReportMsg(reportObj.Report);
       earlyReturn = true;
       return;
   end
   add(parentSection, tfSection); 
end

function earlyReturn = addTestSuiteBody(reportObj, testObj, parentSection)
   import mlreportgen.report.*;
   import mlreportgen.dom.*;
   
   earlyReturn = false;
   tsSection = Section;
   if(testObj.Enabled)
       tsSection.Title = Text(testObj.Name);
   else
       tsSection.Title = Text([testObj.Name, ' ', getString(message('stm:TestSpecReportContent:TestObjDisabled'))]);
       tsSection.Title.Italic = true;
   end
   tsSection.Title.FontSize = '24px';
   createTestSuiteReportBody(reportObj, testObj, tsSection);
   childTestSuites = testObj.getTestSuites;
   if(~isempty(childTestSuites))
       for i=1:length(childTestSuites)
           addTestSuiteBody(reportObj, childTestSuites(i), tsSection); 
       end
   end   
   testCases = testObj.getTestCases;
   for j = 1 : length(testCases)
      earlyReturn = addTestCaseBody(reportObj, testCases(j), tsSection);
      if(earlyReturn)
         return; 
      end
   end
   % break if reportObj.ReportGenStatus is set to stop report generation
   reportObj.ReportGenStatus = reportObj.getReportGenerationStatus();
   if(reportObj.ReportGenStatus >= 2)
       addIncompleteReportMsg(reportObj.Report);
       earlyReturn = true;
       return;
   end
   add(parentSection, tsSection); 

end

function earlyReturn = addTestCaseBody(reportObj, testObj, parentSection)
   import mlreportgen.report.*;
   import mlreportgen.dom.*;
   
   earlyReturn = false;
   tcSection = Section;
   if(testObj.Enabled)
       tcSection.Title = Text(testObj.Name);
   else
       tcSection.Title = Text([testObj.Name, ' ', getString(message('stm:TestSpecReportContent:TestObjDisabled'))]);
       tcSection.Title.Italic = true;
   end
   tcSection.Title.FontSize = '24px';
   createTestCaseReportBody(reportObj, testObj, tcSection);
   % break if reportObj.ReportGenStatus is set to stop report generation
   reportObj.ReportGenStatus = reportObj.getReportGenerationStatus();
   if(reportObj.ReportGenStatus >= 2)
       addIncompleteReportMsg(reportObj.Report);
       earlyReturn = true;
       return;
   end
   add(parentSection, tcSection);
end

function addIncompleteReportMsg(rpt)
    import mlreportgen.dom.*;
    str = getString(message('stm:ReportContent:WarningForIncompleteReport'));
    text = Text(str);
    styling = {Color('red'),FontFamily('Arial'),FontSize('18pt')};
    text.Style = styling;
    add(rpt, text);
end

