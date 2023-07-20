classdef json_value_src_adapter<Simulink.data.adapters.BaseMatlabFileAdapter





    methods
        function name=getAdapterName(~)
            name='JSON Value Source Adapter';
        end

        function extensions=getSupportedExtensions(~)
            extensions={'.json','.jsn'};
        end

        function sections=getSectionNames(~,~)
            sections={'ValueSrc'};
        end

        function diagnostic=getData(this,sourceWorkspace,~,diagnostic)
            clearAllVariables(sourceWorkspace);
            try
                filetext=fileread(this.source);
                json=jsondecode(filetext);

                if isfield(json,'variables')
                    for iter=numel(json.variables):-1:1
                        if iscell(json.variables(iter))


                            name=json.variables{iter}.name;
                            value=eval(json.variables{iter}.value);
                        else


                            name=json.variables(iter).name;
                            value=eval(json.variables(iter).value);
                        end
                        if~isvarname(name)
                            clearAllVariables(sourceWorkspace);
                            diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.UnrecognizedFormat;
                            diagnostic.DiagnosticMessage=['Invalid variable name ',name];
                            return;
                        end
                        setVariable(sourceWorkspace,name,value);
                    end
                end

            catch ME
                clearAllVariables(sourceWorkspace);
                diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.UnrecognizedFormat;
                diagnostic.DiagnosticMessage=[this.getAdapterName(),': reports ',ME.message];
            end
        end

        function diagnostic=writeData(this,sourceWorkspace,~,diagnostic)
            if exist(this.source,'file')==2
                try
                    filetext=fileread(this.source);
                    json=jsondecode(filetext);
                    if~isfield(json,'variables')
                        json.variables=[];
                    end
                catch ME
                    diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.UnrecognizedFormat;
                    diagnostic.DiagnosticMessage=[this.getAdapterName(),': reports ',ME.message];
                    return
                end
            else

                json.variables=[];
            end

            adapterData=listVariables(sourceWorkspace);

            removedRowCounter=0;
            celled=false;
            for idx=1:numel(json.variables)
                if iscell(json.variables(idx-removedRowCounter))
                    name=json.variables{idx-removedRowCounter}.name;
                    celled=true;
                else
                    name=json.variables(idx-removedRowCounter).name;
                end
                found=false;



                for iter=1:numel(adapterData)
                    if strcmp(adapterData(iter),name)
                        found=true;
                        if iscell(json.variables(idx-removedRowCounter))
                            json.variables{idx-removedRowCounter}.value=mat2str(getVariable(sourceWorkspace,name));
                        else
                            json.variables(idx-removedRowCounter).value=mat2str(getVariable(sourceWorkspace,name));
                        end
                        adapterData(iter)=[];
                        break;
                    end
                end
                if~found
                    json.variables(idx-removedRowCounter)=[];
                    removedRowCounter=removedRowCounter+1;
                end
            end

            r=numel(json.variables);

            for iter=1:numel(adapterData)
                name=adapterData(iter);
                if celled
                    json.variables{r+iter}.name=name;
                    json.variables{r+iter}.value=mat2str(getVariable(sourceWorkspace,name));
                else
                    json.variables(r+iter).name=name;
                    json.variables(r+iter).value=mat2str(getVariable(sourceWorkspace,name));
                end
            end

            filetext=jsonencode(json,'PrettyPrint',true);
            fid=fopen(this.source,'w');
            fwrite(fid,filetext);
            fclose(fid);
        end

    end
end

