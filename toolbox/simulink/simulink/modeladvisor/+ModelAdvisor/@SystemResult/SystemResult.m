classdef(CaseInsensitiveProperties=true)SystemResult<handle
    properties(Hidden)
        uniqueCode='';
        Name='';
        value='';
    end

    properties(SetAccess=public)
        system='';
        Type='Library';
        numPass=-1;
        numFail=-1;
        numNotRun=-1;
        numWarn=-1;
        CheckResultObjs={};
    end

    properties(Hidden,SetAccess=public)
        ComponentId='';
    end

    properties(Hidden,SetAccess=private)
        htmlreport='';
        report='';
        mdladvinfo={};
        geninfo={};
        reportFileName='';
    end

    methods

        function SystemResult=SystemResult()
        end

        function set.uniqueCode(systemResultObj,value)
            systemResultObj.uniqueCode=value;
        end

        function setReportFileName(systemResultObj,value)
            systemResultObj.reportFileName=value;
        end

        function report=getReportFileName(this)
            report=this.reportFileName;
        end

    end
end