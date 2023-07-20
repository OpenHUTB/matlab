classdef NodeResult < handle
%
% Class for result data for each node in the result tree
% The node can be any type of result set, test file result, test suite result or 
% test case result, and even more.

% Copyright 2014-2015 The MathWorks, Inc.
%
    
    properties
        ID = [];        
        resultType;
        resultTypeInt;  % integer version of result type, for convenience of comparison
        testDef = {};
        testRequirement = [];
        metaData = {};      % meta data for result 
        permData = [];      % permutation data        
        compData = {};      % comparison data
        baselineData = {};
        verifyData = {};
        errorStatus = 0;
    end
    
    % properties in tree structure
    properties
        depthInTree;
        parentIDInTree = 0;     % id of parent node        
        parentNameInTree = '';
        parentList = [];        % list of nodes in path from root. root first.
        pathFromRoot = '';        
        
    end
    
    properties (Constant)
        testCaseTypes = struct(...
            'SIMULATION',1, ...
            'BASELINE',2, ...
            'EQUIVALENCE', 3);
        
        resultOutcome = struct(...
            'OUTCOME_INCOMPLETE', 0, ...
            'OUTCOME_PASSED',2, ...
            'OUTCOME_FAILED',3, ...
            'OUTCOME_ERROR', 4, ...
            'OUTCOME_NOTSTARTED', 5, ...
            'OUTCOME_DISABLED', 6);
    end
    
    methods
        function getData(obj)
            dataType = 0;            
            obj.resultType = stm.internal.getResultType(obj.ID); 
            if(strcmp(obj.resultType,'ResultSet'))
                dataType = 1;
            elseif(strcmp(obj.resultType,'TestFileResult'))
                dataType = 2;
            elseif(strcmp(obj.resultType,'TestSuiteResult'))
                dataType = 3;
            elseif(strcmp(obj.resultType,'TestCaseResult'))
                dataType = 4;
            end
            if(dataType == 0)
                obj.updateStatus(false);
                return;
            end
            obj.resultTypeInt = dataType;
            
            % meta data            
            obj.metaData = stm.internal.getResultProperty(obj.ID,obj.resultType);
            obj.metaData.hasIterationResults = false;
            if(dataType == 4)         
                obj.metaData.hasIterationResults = stm.internal.hasIterationResults(obj.ID);
            end
            
            if(dataType == 4 && ~obj.metaData.hasIterationResults)
                obj.metaData.numOfPassed = 0;
                obj.metaData.numOfFailed = 0;
                obj.metaData.numOfDisabled = 0;
                obj.metaData.numOfIncomplete = 0;

                if(obj.metaData.outcome == obj.resultOutcome.OUTCOME_PASSED)
                    obj.metaData.numOfPassed = 1;
                elseif(obj.metaData.outcome == obj.resultOutcome.OUTCOME_FAILED)
                    obj.metaData.numOfFailed = 1; 
                elseif(obj.metaData.outcome == obj.resultOutcome.OUTCOME_INCOMPLETE)
                    obj.metaData.numOfIncomplete = 1;
                elseif(obj.metaData.outcome == obj.resultOutcome.OUTCOME_DISABLED)   
                    obj.metaData.numOfDisabled = 1;
                end
            else
                % set obj.metaData.outcome as outcome for ResultSet /
                % TestSuiteResult in database is not correct.
                if(obj.metaData.numOfFailed > 0)
                    obj.metaData.outcome = obj.resultOutcome.OUTCOME_FAILED;
                else
                    if(obj.metaData.numOfPassed == obj.metaData.numOfResults - obj.metaData.numOfDisabled)
                        if(obj.metaData.numOfPassed > 0)
                            obj.metaData.outcome = obj.resultOutcome.OUTCOME_PASSED;
                        else
                            obj.metaData.outcome = obj.resultOutcome.OUTCOME_DISABLED;
                        end 
                    else
                        obj.metaData.outcome = obj.resultOutcome.OUTCOME_INCOMPLETE;
                    end
                end                
                obj.metaData.numOfIncomplete = obj.metaData.numOfResults - ...
                    obj.metaData.numOfPassed - obj.metaData.numOfFailed - obj.metaData.numOfDisabled;                
            end
            
            % permutation data
            obj.permData = [];
            if(dataType == 4) 
                nullPerm = {};
                nullPerm.runID = [];
                nullPerm.isNull = true;
                
                permIDList = stm.internal.getPermutationResultIDList(obj.ID);
                if(~isempty(permIDList))
                    for k = 1 : length(permIDList)
                        permResult = stm.internal.getPermutationResult(permIDList(k));
                        permResult.isNull = false;                        
                        obj.permData = [obj.permData;permResult];
                    end
                else
                    obj.permData = nullPerm;
                end
            end 
            
            obj.compData = {};
            obj.testDef = {};
            if(dataType == 4)
                testCase = stm.internal.getTestCaseResultDetail(obj.ID);
                obj.testDef.testName = testCase.testCaseName;
                obj.testDef.testTags = testCase.testTags;
                obj.testDef.testDescription = testCase.testCaseDescription;
                obj.testDef.testDisablingReason = testCase.testCaseDisablingReason;
                obj.testDef.errorMSG = testCase.errorMSG;
                obj.testDef.logMSG = testCase.logMSG;
                
                obj.testDef.testCaseType = testCase.testCaseType; 
                
                if(strcmp(testCase.testCaseType, getString(message('stm:toolstrip:EquivalenceTest'))))
                    obj.testDef.testCaseTypeInt = obj.testCaseTypes.EQUIVALENCE;
                elseif(strcmp(testCase.testCaseType, getString(message('stm:toolstrip:BaselineTest'))))
                    obj.testDef.testCaseTypeInt = obj.testCaseTypes.BASELINE;
                    
                    % Baseline run data is applicable only in case of
                    % baseline test case ony.
                    obj.baselineData.runID = testCase.baselineRunID;
                    obj.baselineData.signalIDList = testCase.baselineSignalIDList;
                    obj.baselineData.name = testCase.baselineNodeName;
                    obj.baselineData.path = testCase.baselineFullPath;
                else
                    % Simulation Test
                    obj.testDef.testCaseTypeInt = obj.testCaseTypes.SIMULATION;
                end
                
                obj.verifyData = testCase.verifyResults;
                
                obj.testDef.testFile = testCase.testFileLocation;
                obj.testDef.uuid = testCase.testCaseUUID;
                obj.testDef.baselineName = testCase.baselineName;
                obj.testDef.baselineFile = testCase.baselineFile;   
                obj.testDef.isIterationResult = testCase.isIterationResult; 
                obj.testDef.iterationSettings = testCase.iterationSettings; 
                
                obj.testRequirement = stm.internal.getRequirementsFromTestResult(obj.ID);
                
                obj.compData.runID = testCase.runID;
                obj.compData.outcome = testCase.outcome;                
                obj.compData.signalOutcomeList = testCase.signalOutcomeList;
                obj.compData.signalIDList = testCase.signalIDList;
            elseif(dataType == 3 || dataType == 2)
                % test suite result or test file result.
                testSuiteResult = stm.internal.getTestSuiteResultDetails(obj.ID);
                obj.testDef.testName = testSuiteResult.testSuiteName;
                obj.testDef.testTags = testSuiteResult.testTags;                
                obj.testDef.testDescription = testSuiteResult.testSuiteDescription;
                obj.testDef.errorMSG = testSuiteResult.errorMSG;
                obj.testDef.testDisablingReason = testSuiteResult.testSuiteDisablingReason;
                obj.testRequirement = stm.internal.getRequirementsFromTestResult(obj.ID);
            end            
            obj.updateStatus(true);
        end
    end
    
    methods (Access = private)
        function updateStatus(obj,isGood)
            if(isGood)
                obj.errorStatus = obj.errorStatus + 1;
            else
                obj.errorStatus = obj.errorStatus - 1;
            end
        end
    end
end
