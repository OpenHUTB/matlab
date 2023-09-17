classdef JSEditorService<handle

    methods

        function editorEditFunction(this,functionName)
            import matlab.internal.lang.capability.Capability
            filePath=which(strcat(functionName));

            if(isfile(filePath))


                [setupFnPath,~,setupFnExt]=fileparts(filePath);
                if~strcmp(setupFnExt,'.m')&&~strcmp(setupFnExt,'.mlx')
                    error(message('experiments:editor:FunctionFileNotMOrMLX',functionName));
                end

                if~startsWith(setupFnPath,this.getCurrentProjectPath())
                    error(message('experiments:editor:CannotEditFunctionNotInsideProject',functionName));
                end



                if ismac
                    commandwindow();
                end
                if~Capability.isSupported(Capability.LocalClient)
                    this.editorMinimizeCef();
                end
                edit(filePath);
            else
                error(message('experiments:editor:CannotEditFunctionNotInsideProject',functionName));
            end

        end

        function editorMinimizeCef(this)
            this.cef.minimize();
        end

    end
end
