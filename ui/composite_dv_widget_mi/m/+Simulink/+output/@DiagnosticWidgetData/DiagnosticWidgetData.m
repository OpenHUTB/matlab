classdef DiagnosticWidgetData












    properties
        Diagnostic='';
        Severity=Simulink.output.utils.Severity.Error;
        Component='';
        Category='';
        HelpFcn='';
        SuppressFcn='';
        RestoreFcn='';
    end

    methods
        function obj=DiagnosticWidgetData(diagnostic,varargin)
            if~(isa(diagnostic,'MException')||isa(diagnostic,'MSLException')||isa(diagnostic,'MSLDiagnostic'))
                error(message('sl_diagnostic:SLMsgVieweri18N:CompositeDVWidgetInvalidType',class(diagnostic)).getString());
            end


            if(isa(diagnostic,'MException'))
                diagnostic=MSLException(diagnostic);
            end

            p=inputParser;
            addParameter(p,'Severity',obj.Severity,@isValidSeverity);
            addParameter(p,'Component',obj.Component,@ischar);
            addParameter(p,'Category',obj.Category,@ischar);
            addParameter(p,'HelpFcn',obj.HelpFcn,@isFcnHandle);
            addParameter(p,'SuppressFcn',obj.SuppressFcn,@isFcnHandle);
            addParameter(p,'RestoreFcn',obj.RestoreFcn,@isFcnHandle);
            parse(p,varargin{:});




            obj.Diagnostic=diagnostic.json;
            obj.Severity=p.Results.Severity;
            obj.Component=p.Results.Component;
            obj.Category=p.Results.Category;
            obj.HelpFcn=p.Results.HelpFcn;
            obj.SuppressFcn=p.Results.SuppressFcn;
            obj.RestoreFcn=p.Results.RestoreFcn;

            function output=isFcnHandle(input)
                output=isa(input,'function_handle');
            end

            function output=isValidSeverity(input)
                output=isa(input,'Simulink.output.utils.Severity');
            end
        end
    end
end
