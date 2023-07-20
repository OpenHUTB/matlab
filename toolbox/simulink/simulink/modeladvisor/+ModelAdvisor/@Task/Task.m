classdef(CaseInsensitiveProperties=true)Task<ModelAdvisor.Node

    properties(SetAccess=public,Hidden=true)
        Check=[];
        NextInProcedureCallGraph=[];
        PreviousInProcedureCallGraph=[];
        Severity='Optional';

        MAC='';
        MACIndex=0;
    end

    properties(SetAccess=public)

    end

    methods
        dlgStruct=getDialogSchema(this,name);

        function this=Task(varargin)
mlock
            if nargin==0
                this.ID='__blank__';
            else
                this.ID=convertStringsToChars(varargin{1});
            end
        end























    end

end