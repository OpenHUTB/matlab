classdef SignatureImport<handle


    properties(Constant,Hidden)
        Instance=fusion.internal.scenarioApp.component.SignatureImport;
    end

    properties(SetAccess=protected,Hidden)
        ImportDialog;
    end

    methods(Access=protected)
        function this=SignatureImport
        end
    end

    methods
        function dlgName=getImportDialogName(~)
            dlgName=getString(message('fusion:trackingScenarioApp:Component:SignatureImport'));
        end

        function labels=getImportDialogLabels(~)
            labels={getString(message('fusion:trackingScenarioApp:Component:SignatureLabel'))};
        end

        function validVariables=validateImportVariables(~,~,variables,~)
            dataTypes={variables.class};
            validTypes={'rcsSignature'};
            variables(~cellfun(@(c)any(strcmp(c,validTypes)),dataTypes))=[];

            if isempty(variables)
                validVariables={};
            else
                validVariables={variables.name};
            end
        end
    end

    methods(Static)

        function signature=import(varargin)
            r=fusion.internal.scenarioApp.component.SignatureImport.Instance;
            iDialog=r.ImportDialog;
            if isempty(iDialog)||~isvalid(iDialog)
                iDialog=matlabshared.application.ImportDialog(r);
                r.ImportDialog=iDialog;
            end
            signature=open(iDialog,varargin{:});
        end
    end
end
