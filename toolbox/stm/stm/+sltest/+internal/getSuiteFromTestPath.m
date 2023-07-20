function[suite,fileName,suiteNames]=getSuiteFromTestPath(testPath)




    if(slfeature('STMScriptedTest')>0)

        [status,msg]=simulinktest.munitutils.isSLTestMUnitFile(testPath);
        if~status&&~isempty(msg)
            error(msg);
        end
    end
    suite=matlab.unittest.TestSuite.fromFile(testPath);
    suiteNames=regexp({suite(:).Name},'^[^/]+','match');
    suiteNames=unique([suiteNames{:}]);
    fileName=regexprep(suiteNames{1},'\[[^\[]+\]','');
end
