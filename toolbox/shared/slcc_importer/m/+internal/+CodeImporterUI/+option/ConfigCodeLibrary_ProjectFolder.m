
classdef ConfigCodeLibrary_ProjectFolder<internal.CodeImporterUI.OptionBase
    methods
        function obj=ConfigCodeLibrary_ProjectFolder(env)
            id='ConfigCodeLibrary_ProjectFolder';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='path';
            obj.Property='OutputFolder';
            obj.HasMessage=true;
            obj.HasHintMessage=true;
            obj.HasSummaryMessage=false;
            obj.initValue();
        end

        function applyOnNext(obj)
            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    if isempty(strip(values(i).value))
                        err=MException(message('Simulink:CodeImporterUI:OutputFolderUnspecified'));
                        throw(err);
                    end
                    if strcmp(strip(values(i).value),'.')
                        env.CodeImporter.OutputFolder="";
                    else
                        env.CodeImporter.OutputFolder=values(i).value;
                    end
                end
            end
        end
    end
end
