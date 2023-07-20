function createTestSuiteReportBody(reportObj, testObj,  section)

import mlreportgen.report.*;
import mlreportgen.dom.*;

testSuiteRptr = sltest.testmanager.TestSuiteReporter('Object',testObj,...
                                                     'IncludeTestDetails', reportObj.IncludeTestDetails,...
                                                     'IncludeCoverageSettings', reportObj.IncludeCoverageSettings,...
                                                     'IncludeTestFileOptions', false,...
                                                     'IncludeCallbackScripts', reportObj.IncludeCallbackScripts);

if(~isempty(reportObj.TestSuiteReporterTemplate))
   testSuiteRptr.TemplateSrc = reportObj.TestSuiteReporterTemplate;
end

add(section, testSuiteRptr);

end