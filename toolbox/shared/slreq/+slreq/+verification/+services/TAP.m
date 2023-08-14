classdef TAP<slreq.verification.services.ServiceInterface




    properties(Constant,Hidden)
        TAP_STATUS_PASS="ok";
        TAP_STATUS_FAIL="not ok";
    end
    properties(Access=private,Constant)
        TAP_VERSION_LINE_REGEX_="TAP version .*";
        TAP_PLAN_LINE_REGEX_="1\.\.(?<numtests>\d+)";
        TAP_TEST_LINE_REGEX_="(?<status>ok|not ok)(?<testid>[\d ]+)?-? ?(?<description>(?=\S)[^#\n]+)?#? ?(?<command>skip|TODO)?(?<comment>[\w ]*)?";

        TAP_BAIL_OUT_REGEX_="Bail out!.*";


        FIELD_STATUS="status";
        FIELD_TESTID="testid";
        FIELD_DESCRIPTION="description";
        FIELD_COMMAND="command";
        FIELD_COMMENT="comment";

        FIELD_TIMESTAMP="timestamp";
        FIELD_INFO="info";
        FIELD_ERROR="error";
    end
    methods
        function result=getResult(this,testId,tapFilePath)
            result.(this.FIELD_STATUS)=slreq.verification.Status.Unknown;
            results=this.getAllResults(tapFilePath);
            for i=1:length(results)
                if strcmp(strtrim(results(i).testid),testId)||contains(results(i).description,testId)
                    if results(i).(this.FIELD_STATUS)==this.TAP_STATUS_PASS
                        result.(this.FIELD_STATUS)=slreq.verification.Status.Pass;

                        result.(this.FIELD_INFO)=results(i).(this.FIELD_DESCRIPTION);
                    else
                        result.(this.FIELD_STATUS)=slreq.verification.Status.Fail;

                        result.(this.FIELD_ERROR)=results(i).(this.FIELD_DESCRIPTION);
                    end
                    break;
                end
            end
            result.(this.FIELD_TIMESTAMP)=this.getTimestampForTAPFile(tapFilePath);
        end

        function testResults=getAllResults(this,filepath)
            filetext=strsplit(string(fileread(filepath)),newline);
            numTotalTests=this.getTAPNumTests(filetext);
            testResults=repmat(this.getDefaultTAPResultStruct(),1,numTotalTests);

            numTests=1;
            for i=1:length(filetext)
                line=filetext(i);
                if this.isTAPTestLine(line)
                    testResults(numTests)=this.getTAPInfo(line);
                    testResults(numTests).(this.FIELD_TIMESTAMP)=this.getTimestampForTAPFile(filepath);
                    numTests=numTests+1;
                end
            end
        end
    end

    methods(Access=private)

        function resultStruct=getDefaultTAPResultStruct(this)
            resultStruct=struct(this.FIELD_STATUS,"",...
            this.FIELD_TESTID,"",...
            this.FIELD_DESCRIPTION,"",...
            this.FIELD_COMMAND,"",...
            this.FIELD_COMMENT,"",...
            this.FIELD_TIMESTAMP,"");
        end

        function tf=isTAPVersionLine(this,line)
            tf=regexp(line,this.TAP_VERSION_LINE_REGEX_,"match");
        end

        function tf=isTAPTestLine(this,line)
            tf=~isempty(regexp(line,this.TAP_TEST_LINE_REGEX_,"match"));
        end

        function isPassed=getTAPStatus(this,line)
            tapInfo=this.getTAPInfo(line);
            isPassed=(tapInfo.status==this.TAP_STATUS_PASS);
        end

        function numTests=getTAPNumTests(this,fileText)

            regOut=regexp(fileText(1),this.TAP_PLAN_LINE_REGEX_,"names");

            if isempty(regOut)&&length(fileText)>1

                regOut=regexp(fileText(2),this.TAP_PLAN_LINE_REGEX_,"names");
            end
            if isempty(regOut)&&length(fileText)>1

                regOut=regexp(fileText(end),this.TAP_PLAN_LINE_REGEX_,"names");
            end

            if~isempty(regOut)
                numTests=str2double(regOut.numtests);
            else
                error(message('Slvnv:slreq:ExtVerifInvalidTAPFile'))
            end
        end

        function tapInfo=getTAPInfo(this,line)
            tapInfo=regexp(line,this.TAP_TEST_LINE_REGEX_,"names","once");




            if~isfield(tapInfo,this.FIELD_STATUS)
                return;
            end


            if~isfield(tapInfo,this.FIELD_TESTID)
                tapInfo.(this.FIELD_TESTID)="";
            end
            if~isfield(tapInfo,this.FIELD_DESCRIPTION)
                tapInfo.(this.FIELD_DESCRIPTION)="";
            end
            if~isfield(tapInfo,this.FIELD_COMMAND)
                tapInfo.(this.FIELD_COMMAND)="";
            end
            if~isfield(tapInfo,this.FIELD_COMMENT)
                tapInfo.(this.FIELD_COMMENT)="";
            end

            tapInfo.(this.FIELD_TIMESTAMP)=NaT;
        end

        function timestamp=getTimestampForTAPFile(this,filepath)
            timestamp=this.getTimestampFromFile(filepath);
        end
    end
end


