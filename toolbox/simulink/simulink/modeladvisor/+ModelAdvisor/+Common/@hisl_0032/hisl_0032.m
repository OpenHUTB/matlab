






classdef hisl_0032<handle

    properties(Access=private)
        system;
        prefix;
        status;
        result;
        violations;

        conventionBlockNames;
        conventionSignalNames;
        conventionParameterNames;
        conventionBusNames;
        conventionStateflowNames;

        regexpBlockNames;
        regexpSignalNames;
        regexpParameterNames;
        regexpBusNames;
        regexpStateflowNames;

        reservedNames;
    end

    methods(Static,Access=public)

        registerCheck(checkId,group,license);
        executeCheck(system,checkId);


    end

    methods(Access=public)

        function this=hisl_0032(system,prefix)

            this.system=system;
            this.prefix=prefix;

            this.status=false;
            this.result={};
            this.violations=[];

            this.conventionBlockNames='MAAB';
            this.conventionSignalNames='MAAB';
            this.conventionParameterNames='MAAB';
            this.conventionBusNames='MAAB';
            this.conventionStateflowNames='MAAB';

            this.regexpBlockNames=Advisor.Utils.Naming.getRegExp('MAAB');
            this.regexpSignalNames=Advisor.Utils.Naming.getRegExp('MAAB');
            this.regexpParameterNames=Advisor.Utils.Naming.getRegExp('MAAB');
            this.regexpBusNames=Advisor.Utils.Naming.getRegExp('MAAB');
            this.regexpStateflowNames=Advisor.Utils.Naming.getRegExp('MAAB');
            this.reservedNames=Advisor.Utils.Naming.getReservedNames();

        end

        text=getText(this,id,varargin);

        function status=getStatus(this)
            status=this.status;
        end

        function result=getResult(this)
            result=this.result;
        end

        execute(this,system);

        function violations=getViolations(this)
            violations=this.violations;
        end
    end


end


