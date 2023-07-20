




classdef CallbackManager<handle


    properties
Callbacks
    end
    methods
        function obj=CallbackManager(callbacks)
            obj.setCallbacks(callbacks);
        end

        function setCallbacks(obj,callbacks)

            obj.preValidate(callbacks);


            expandedCallbacks=obj.expandCallbacks(callbacks);


            obj.validateCallbacks(expandedCallbacks);


            obj.Callbacks=expandedCallbacks;
        end

        function out=expandCallbacks(obj,callbacks)




            out={};
            for i=1:length(callbacks)
                currentCallback=callbacks{i};
                if strcmpi(callbacks{i}.AppliesTo,'AUTO')&&...
                    strcmpi(callbacks{i}.Event,'PreAccess')



                    out{end+1}=Simulink.ProtectedModel.Callback(currentCallback.Event,...
                    'SIM',currentCallback.getCallback());%#ok<AGROW>                    
                    out{end}.markAsExpanded();
                    out{end+1}=Simulink.ProtectedModel.Callback(currentCallback.Event,...
                    'VIEW',currentCallback.getCallback());%#ok<AGROW>
                    out{end}.markAsExpanded();






                    out{end+1}=obj.expandCodegenCallback(currentCallback);%#ok<AGROW>

                elseif strcmpi(callbacks{i}.AppliesTo,'AUTO')&&...
                    strcmpi(callbacks{i}.Event,'Build')


                    out{end+1}=obj.expandCodegenCallback(currentCallback);%#ok<AGROW>
                    out{end}.markAsExpanded();
                else
                    out{end+1}=currentCallback;%#ok<AGROW>
                end
            end
        end

        function preValidate(~,callbacks)
            for i=1:length(callbacks)

                if~isa(callbacks{i},'Simulink.ProtectedModel.Callback')
                    error(message('Simulink:protectedModel:protectedModelInvalidCallbackType'));
                end
            end
        end

        function validateCallbacks(~,callbacks)
            cbMap=containers.Map;
            for i=1:length(callbacks)


                strId=[callbacks{i}.Event,callbacks{i}.AppliesTo];
                if~isKey(cbMap,strId)
                    cbMap(strId)=strId;
                else
                    error(message('Simulink:protectedModel:protectedModelDuplicateCallback',callbacks{i}.Event,callbacks{i}.AppliesTo));
                end
            end
        end

        function out=hasCallback(obj,event,appliesTo)
            out=~isempty(obj.getCallback(event,appliesTo));
        end

        function out=getCallback(obj,event,appliesTo)
            out=[];
            for i=1:length(obj.Callbacks)
                if strcmpi(obj.Callbacks{i}.Event,event)&&...
                    strcmpi(obj.Callbacks{i}.AppliesTo,appliesTo)
                    out=obj.Callbacks{i};
                end
            end
        end

        function out=getCallbackFileListForFunctionality(obj,appliesTo)
            out={};
            for i=1:length(obj.Callbacks)
                callback=obj.Callbacks{i};
                if strcmpi(callback.AppliesTo,appliesTo)
                    out{end+1}=callback.getCallbackFileName();%#ok<AGROW>
                end
            end
        end




        function update(obj,protectedModelCreator)
            if~protectedModelCreator.hasCallbacks()
                return;
            end

            switch(protectedModelCreator.Modes)
            case{'Normal','Accelerator'}

                obj.removeCallbacksForFunctionality('CODEGEN');
            case 'ViewOnly'

                obj.removeCallbacksForFunctionality('CODEGEN');
                obj.removeCallbacksForFunctionality('SIM');
            end
            if~protectedModelCreator.Webview

                obj.removeCallbacksForFunctionality('VIEW');
            end




            if obj.hasCallback('build','CODEGEN')&&...
                ~(protectedModelCreator.packageSourceCode()&&protectedModelCreator.supportsCodeGen())
                error(message('Simulink:protectedModel:protectedModelCallbackUnsupportedConfigurationForBuildCodeGen',protectedModelCreator.ModelName));
            end
        end

        function removeCallbacksForFunctionality(obj,appliesTo)
            assert(strcmpi(appliesTo,'SIM')||strcmpi(appliesTo,'VIEW')||strcmpi(appliesTo,'CODEGEN')||strcmpi(appliesTo,'AUTO'));


            callbacks={};
            for i=1:length(obj.Callbacks)
                currentCB=obj.Callbacks{i};
                if~strcmpi(currentCB.AppliesTo,appliesTo)
                    callbacks{end+1}=currentCB;%#ok<AGROW>
                else


                    if~currentCB.Expanded
                        errID='Simulink:protectedModel:protectedModelFunctionalityNotPresent';
                        msg=message(errID,appliesTo);
                        ME=MException(errID,'%s',msg.getString);
                        MSLDiagnostic(ME).reportAsWarning;
                    end
                end
            end
            obj.Callbacks=callbacks;
        end
    end
    methods(Access=protected)
        function out=expandCodegenCallback(~,currentCallback)
            cb=Simulink.ProtectedModel.Callback(currentCallback.Event,...
            'CODEGEN',currentCallback.getCallback());
            cb.setOverrideBuild(currentCallback.getOverrideBuild());
            cb.markAsExpanded();
            out=cb;
        end
    end
end


