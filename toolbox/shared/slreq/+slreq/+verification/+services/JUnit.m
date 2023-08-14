classdef JUnit<slreq.verification.services.ServiceInterface





    properties(Access=private,Hidden)
parser
evaluator
    end

    properties(Access=private,Constant)
        TAG_ROOT="testsuites";
        TAG_TESTSUITE="testsuite";
        TAG_TESTCASE="testcase";

        ATTRIB_TESTNAME="name";
        ATTRIB_TESTSTATUS="status";

        TAG_TEST_SKIPPED="skipped";
        TAG_TEST_ERROR="error";
        TAG_TEST_FAILURE="failure";



        FIELD_STATUS="status";
        FIELD_TIMESTAMP="timestamp";
        FIELD_TESTID="testid";
        FIELD_DESCRIPTION="description";
        FIELD_COMMENT="comment";

        FIELD_INFO="info";
        FIELD_ERROR="error";


        TESTCASE_SELECT_BY_NAME_XPATH="//testsuite/testcase[@name='%s']";
        TESTCASE_SELECT_ALL_XPATH="//testcase";
        TIMESTAMP_ATTRIBUTE_XPATH="string(../@timestamp)";
        TESTCASE_GET_FAILURE_STRING="./failure/text()";
        TESTCASE_GET_ERROR_STRING="./error/text()";

        JUNIT_TIMESTAMP_FORMAT='yyyy-MM-dd''T''HH:mm:ss';
    end

    methods
        function result=getResult(this,testId,filepath)
            result.status=slreq.verification.Status.Unknown;
            result.timestamp=datetime(NaT);

            xmlDoc=this.readFile(filepath);
            testCaseNode=this.getTestCaseNode(xmlDoc,testId);
            if~isempty(testCaseNode)
                result.status=this.getTestCaseStatus(testCaseNode);
            end
            result.timestamp=this.getTimestampForJUnitTestCase(testCaseNode,filepath);
        end

        function results=getAllResults(this,filepath)
            xmlDoc=this.readFile(filepath);
            testCases=this.evaluateXpath(xmlDoc,this.TESTCASE_SELECT_ALL_XPATH,"nodeset");
            results=repmat(this.getDefaultJUnitResultStruct(),1,numel(testCases));
            for i=1:numel(testCases)
                testCase=testCases(i);
                results(i).(this.FIELD_TESTID)=string(testCase.getAttribute(this.ATTRIB_TESTNAME));
                results(i).(this.FIELD_STATUS)=this.getTestCaseStatus(testCase);
                results(i).(this.FIELD_TIMESTAMP)=this.getTimestampForJUnitTestCase(testCase,filepath);
                if this.isTestCaseErrored(testCase)


                    results(i).(this.FIELD_ERROR)=this.getTestCaseErrorStr(testCase);
                else


                    results(i).(this.FIELD_INFO)=this.getTestCaseInfoStr(testCase);
                end
            end
        end
    end

    methods
        function this=JUnit()
            import matlab.io.xml.dom.*
            import matlab.io.xml.xpath.*;

            this.parser=Parser();
            this.evaluator=Evaluator();
        end

        function rootNode=readFile(this,filepath)
            docNode=this.parseJUnitXMLFile(filepath);
            rootNode=docNode.getFirstChild();
        end
    end

    methods(Hidden)
        function root=parseJUnitXMLFile(this,filepath)
            import matlab.io.xml.dom.*
            try
                root=this.parser.parseFile(filepath);
            catch mex
                error(message('Slvnv:slreq:ExtVerifInvalidJUnitFile'));
            end
        end
    end
    methods
        function resultStruct=getDefaultJUnitResultStruct(this)
            resultStruct=struct(this.FIELD_STATUS,"",...
            this.FIELD_TIMESTAMP,"",...
            this.FIELD_TESTID,"");
        end

        function testCaseNode=getTestCaseNode(this,xmlDoc,testCaseName)
            xpath=sprintf(this.TESTCASE_SELECT_BY_NAME_XPATH,testCaseName);
            testCaseNode=this.evaluateXpath(xmlDoc,xpath,"node");
        end

        function status=getTestCaseStatus(this,testCaseNode)

            if this.isTestCaseSkipped(testCaseNode)

                status=slreq.verification.Status.Unknown;
            elseif this.isTestCaseFail(testCaseNode)||this.isTestCaseErrored(testCaseNode)


                status=slreq.verification.Status.Fail;
            else

                status=slreq.verification.Status.Pass;
            end
        end

        function isFail=isTestCaseFail(this,testCaseNode)

            xpath=sprintf("./%s",this.TAG_TEST_FAILURE);
            failureNode=this.evaluateXpath(testCaseNode,xpath,"node");
            isFail=~isempty(failureNode);
        end

        function isSkipped=isTestCaseSkipped(this,testCaseNode)

            xpath=sprintf("./%s",this.TAG_TEST_SKIPPED);
            failureNode=this.evaluateXpath(testCaseNode,xpath,"node");
            isSkipped=~isempty(failureNode);
        end

        function isErrored=isTestCaseErrored(this,testCaseNode)

            xpath=sprintf("./%s",this.TAG_TEST_ERROR);
            failureNode=this.evaluateXpath(testCaseNode,xpath,"node");
            isErrored=~isempty(failureNode);
        end

        function timestamp=getTimestampForJUnitTestCase(this,testCaseNode,filepath)
            timestamp=NaT;
            if isempty(testCaseNode)
                return;
            end



            timestampString=this.evaluateXpath(testCaseNode,this.TIMESTAMP_ATTRIBUTE_XPATH,"string");
            if~isempty(timestampString)&&strlength(timestampString)>0
                try
                    timestamp=datetime(timestampString,'InputFormat',this.JUNIT_TIMESTAMP_FORMAT,'TimeZone','Local');
                catch

                end
            else

                timestamp=this.getTimestampFromFile(filepath);
            end
        end

        function infoStr=getTestCaseInfoStr(this,testCaseNode)

            if this.isTestCaseFail(testCaseNode)
                infoStr=this.evaluateXpath(testCaseNode,this.TESTCASE_GET_FAILURE_STRING,"string");
            elseif this.isTestCaseSkipped(testCaseNode)
                infoStr="Skipped";
            else


                infoStr="";
            end
        end

        function errorStr=getTestCaseErrorStr(this,testCaseNode)

            errorStr=this.evaluateXpath(testCaseNode,this.TESTCASE_GET_ERROR_STRING,"string");
        end
    end

    methods(Access=private)
        function result=evaluateXpath(this,node,xpathExpression,type)
            import matlab.io.xml.xpath.*;

            switch type
            case "nodeset"
                outType=EvalResultType.NodeSet;
            case "node"
                outType=EvalResultType.Node;
            case "boolean"
                outType=EvalResultType.Boolean;
            case "number"
                outType=EvalResultType.Number;
            case "string"
                outType=EvalResultType.String;
            end

            result=this.evaluator.evaluate(xpathExpression,node,outType);
        end
    end
end
