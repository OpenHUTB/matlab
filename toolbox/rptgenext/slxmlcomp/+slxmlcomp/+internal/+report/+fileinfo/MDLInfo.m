


classdef MDLInfo<slxmlcomp.internal.report.fileinfo.FileInfoRetriever

    properties(Access=public)
        Names={i_GetSLXResourceString('report.info.modelversion'),...
        i_GetSLXResourceString('report.info.savedinversion'),...
        i_GetSLXResourceString('report.info.modeldescription')...
        };
    end

    properties(Access=private)
        MDLInfoFields={'ModelVersion',...
        'ReleaseName',...
'Description'...
        };
    end

    methods(Access=public)
        function values=getValuesForFile(obj,file)
            mdlInfo=Simulink.MDLInfo(file);

            values=cell(size(obj.MDLInfoFields));

            for fieldIndex=1:numel(values)
                values{fieldIndex}=getfield(mdlInfo,obj.MDLInfoFields{fieldIndex});%#ok<GFLD>
            end
        end
    end

end

function string=i_GetSLXResourceString(id)
    import slxmlcomp.internal.report.getResourceString;
    string=getResourceString(id);
end

