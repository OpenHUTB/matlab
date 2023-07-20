function createTestFileReportBody(reportObj, testObj, section)

import mlreportgen.report.*;
import mlreportgen.dom.*;

testFileRptr = sltest.testmanager.TestSuiteReporter('Object',testObj,...
                                                    'IncludeTestDetails', reportObj.IncludeTestDetails,...
                                                    'IncludeCoverageSettings', reportObj.IncludeCoverageSettings,...
                                                    'IncludeTestFileOptions',reportObj.IncludeTestFileOptions,...
                                                    'IncludeCallbackScripts', reportObj.IncludeCallbackScripts);

if(~isempty(reportObj.TestSuiteReporterTemplate))
   testFileRptr.TemplateSrc = reportObj.TestSuiteReporterTemplate;
end

add(section, testFileRptr);                              

end