classdef OptionsCreateSLBlocks_Checkbox<internal.CodeImporterUI.OptionBase




    methods
        function obj=OptionsCreateSLBlocks_Checkbox(env)
            id='OptionsCreateSLBlocks_Checkbox';
            obj@internal.CodeImporterUI.OptionBase(id,env);
            obj.Type='checkbox';
            obj.Value=env.State.CreateSLBlocks;
            obj.HasSummaryMessage=false;
        end

        function preShow(obj)
            obj.HideWidget=isa(obj.Env.CodeImporter,'sltest.CodeImporter');

            env=obj.Env;
            if(~isempty(char(env.CodeImporter.Options.LibraryBrowserName)))


                env.State.CreateSLBlocks=true;
            else
                env.State.CreateSLBlocks=false;
            end
            obj.Value=env.State.CreateSLBlocks;
        end

        function onChange(obj)
            env=obj.Env;
            lastAnswer=env.LastAnswer;
            values=lastAnswer.Value;
            for i=1:length(values)
                if strcmp(values(i).option,obj.Id)
                    if(values(i).value)
                        env.State.CreateSLBlocks=true;
                    else
                        env.State.CreateSLBlocks=false;
                    end
                end
            end
        end
    end
end
