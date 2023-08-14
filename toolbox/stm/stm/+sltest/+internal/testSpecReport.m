function testSpecReport(testObj,filePath,varargin)

    stm.internal.util.checkLicense();
    stm.internal.apiDetail.checkAPIRunningPermission('sltest.testmanager.TestSpecReport');
    stm.internal.apiDetail.testSpecReportWrapper(testObj,filePath,varargin);

end