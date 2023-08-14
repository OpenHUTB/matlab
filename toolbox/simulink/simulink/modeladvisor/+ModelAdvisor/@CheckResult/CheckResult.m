classdef(CaseInsensitiveProperties=true)CheckResult<handle

    properties(Hidden)
        html='';
        index=0;
        paramName={};
        paramValue={};
        resultDetails=[];
    end

    properties(SetAccess=public)
        system='';
        status='';
        checkID='';
        checkName='';
        taskID='';
    end

    methods

        function CheckResult=CheckResult(varargin)
            if nargin==1
                CheckResult.system=varargin{1};
            end
        end




        function resultDetails=getResultDetails(this)
            resultDetails=this.resultDetails;
        end


    end
end