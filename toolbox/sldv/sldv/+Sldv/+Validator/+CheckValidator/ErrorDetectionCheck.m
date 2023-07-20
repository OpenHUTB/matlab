classdef ErrorDetectionCheck




    properties
        modelObject;
        expectedDiagnostics;
    end
    methods
        function obj=ErrorDetectionCheck(varargin)

            if nargin~=1
                error('Incorrect arguments passed to create the check');
            else
                blockData=varargin{1};
                obj.modelObject=Sldv.ModelObject(blockData);
                obj.expectedDiagnostics={};
            end
        end


        function success=Validate(obj,executionInfo)



            success=obj.scanAndMatchDiagnostics(executionInfo.ErrorDiagnostic)||...
            obj.scanAndMatchDiagnostics(executionInfo.WarningDiagnostics);
        end
        function success=scanAndMatchDiagnostics(obj,diagnosticsArray)


            success=false;

            for idx=1:length(diagnosticsArray)
                currentDiagnostic=diagnosticsArray(idx);


                diagnosticStruct=jsondecode(currentDiagnostic.Diagnostic.json);

                if obj.matchDiagnostic(diagnosticStruct)&&...
                    obj.matchPath(diagnosticStruct,obj.modelObject.designSID)
                    success=true;
                    return;
                end
            end
        end

        function isDiagnosticMatched=matchDiagnostic(obj,diagnosticStruct)


            isDiagnosticMatched=false;
            if iscell(diagnosticStruct)


                for idx=1:length(diagnosticStruct)
                    isDiagnosticMatched=obj.matchDiagnostic(diagnosticStruct{idx});
                    if isDiagnosticMatched
                        return;
                    end
                end
            end
            if isa(diagnosticStruct,'MSLDiagnostic')



                diagnosticStruct=jsondecode(currentDiagnostic.Diagnostic.json);
            end
            for idx=1:length(diagnosticStruct)
                currentDiagnosticStruct=diagnosticStruct(idx);
                if isstruct(currentDiagnosticStruct)&&isfield(currentDiagnosticStruct,'identifier')
                    isDiagnosticMatched=any(strcmp(strtrim(obj.expectedDiagnostics),strtrim({currentDiagnosticStruct.identifier})));
                    if isDiagnosticMatched
                        return;
                    elseif isfield(currentDiagnosticStruct,'causes')&&~isempty(currentDiagnosticStruct.causes)
                        isDiagnosticMatched=obj.matchDiagnostic(currentDiagnosticStruct.causes);
                    end
                end
            end
        end
        function isPathMatched=matchPath(obj,diagnosticStruct,blockSID)




            isPathMatched=false;
            if isempty(diagnosticStruct)

                return;
            elseif~isempty(diagnosticStruct.paths)&&...
                any(strcmp(Simulink.ID.getSID(strtrim(diagnosticStruct.paths)),...
                strtrim(blockSID)))


                isPathMatched=true;
                return;
            elseif isa(diagnosticStruct,'MSLDiagnostic')
                for idx=1:length(diagnosticStruct.cause)


                    isPathMatched=matchPath(obj,diagnosticStruct.cause{idx},blockSID);
                    if isPathMatched
                        return;
                    end
                end
            else

                for idx=1:length(diagnosticStruct.causes)


                    isPathMatched=matchPath(obj,diagnosticStruct.causes(idx),blockSID);
                    if isPathMatched
                        return;
                    end
                end
            end
        end


    end
end
