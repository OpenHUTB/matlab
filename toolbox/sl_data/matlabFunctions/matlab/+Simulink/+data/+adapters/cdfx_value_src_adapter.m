classdef cdfx_value_src_adapter<Simulink.data.adapters.BaseMatlabFileAdapter




    properties
    end

    methods
        function name=getAdapterName(~)
            name='CDFX Value Source Adapter';
        end

        function sections=getSectionNames(~,source)
            sections={'ValueSrc'};
        end

        function extensions=getSupportedExtensions(~)
            extensions={'.cdfx'};
        end

        function retVal=supportsReading(this,Source)
            retVal=false;
            if this.isSourceValid(Source)
                retVal=true;
            end
        end

        function retVal=supportsWriting(this,Source)
            retVal=false;
        end

        function diagnostic=getData(this,sourceWorkspace,prevChecksum,diagnostic)
            clearAllVariables(sourceWorkspace);
            wkps=matlab.internal.lang.Workspace();
            try
                cdfxObj=cdfx(this.source);
                dataTable=cdfxObj.instanceList;
                [rows,~]=size(dataTable);

                for iter=1:rows
                    idExpression=char(dataTable.ShortName(iter));
                    if strcmp(dataTable.Category(iter),"MAP")
                        value=dataTable.Value{iter}.PhysicalValue;
                    else
                        value=dataTable.Value{iter};
                    end
                    if~contains(idExpression,'.')
                        setVariable(sourceWorkspace,idExpression,value);
                    else



                        assignVariable(wkps,'value',value);
                        evaluateIn(wkps,[idExpression,'= value;']);
                        evaluateIn(wkps,'clear value;');
                    end
                end

                vars=listVariables(wkps);
                for iter=1:length(vars)
                    name=vars{iter};
                    value=getValue(wkps,name);
                    setVariable(sourceWorkspace,name,value);
                end
            catch ME
                clearAllVariables(sourceWorkspace);
                diagnostic.AdapterDiagnostic=Simulink.data.adapters.AdapterDiagnostic.UnrecognizedFormat;
                diagnostic.DiagnosticMessage=[this.getAdapterName(),': reports ',ME.message];
            end
        end

        function diagnostic=writeData(this,sourceWorkspace,changeReport,diagnostic)
            assert(false,'Writing CDFX files is not currently supported')
        end

    end
end
