classdef VMgrDiagInterceptor<handle







    methods

        function obj=VMgrDiagInterceptor(aModelName)
            obj.ModelName=aModelName;
        end

        function diagMdlName=get.DiagnosticViewerName(obj)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            diagMdlName=[VMgrConstants.DiagMdlNamePrefix,obj.ModelName];
        end

        function result=process(obj,aMsgRecord)
            aMsgRecord.ModelName=obj.DiagnosticViewerName;
            result=aMsgRecord;
        end

    end

    properties

        ModelName(1,:)char;

    end

    properties(Dependent)

        DiagnosticViewerName(1,:)char;

    end

end
