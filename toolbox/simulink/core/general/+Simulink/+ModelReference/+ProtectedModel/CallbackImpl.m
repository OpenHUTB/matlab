




classdef CallbackImpl<handle

    properties(SetAccess=protected)
Event
AppliesTo
OverrideBuild
CallbackFileName
    end
    properties(Transient,SetAccess=protected)
CallbackString
Expanded
    end
    methods
        function obj=CallbackImpl(event,appliesTo,callback)
            obj.setEvent(event);
            obj.setAppliesTo(appliesTo);
            obj.setCallback(callback);
            obj.postValidation();
            obj.Expanded=false;
        end

        function markAsExpanded(obj)
            obj.Expanded=true;
        end

        function setOverrideBuild(obj,value)
            if~islogical(value)
                error(message('Simulink:modelReference:nameValuePairNeedsLogicalValue','OverrideBuild'));
            elseif~strcmpi(obj.Event,'Build')&&value
                error(message('Simulink:protectedModel:protectedModelInvalidEventForOverrideBuild'));
            end
            obj.OverrideBuild=value;
        end

    end
    methods(Hidden)

        function setEvent(obj,event)

            event=Simulink.ModelReference.ProtectedModel.getCharArray(event);
            if strcmpi(event,'PreAccess')
                obj.Event='PreAccess';
            elseif strcmpi(event,'Build')
                obj.Event='Build';
            else
                error(message('Simulink:protectedModel:protectedModelInvalidCallbackEvent'));
            end
        end

        function setAppliesTo(obj,appliesTo)

            appliesTo=Simulink.ModelReference.ProtectedModel.getCharArray(appliesTo);
            if strcmpi(appliesTo,'SIM')||...
                strcmpi(appliesTo,'CODEGEN')||...
                strcmpi(appliesTo,'VIEW')||...
                strcmpi(appliesTo,'AUTO')
                obj.AppliesTo=upper(appliesTo);
            elseif isempty(appliesTo)
                obj.AppliesTo='AUTO';
            else
                error(message('Simulink:protectedModel:protectedModelInvalidCallbackAppliesTo'));
            end
        end

        function out=isMATLABFileName(~,callback)
            callback=Simulink.ModelReference.ProtectedModel.getCharArray(callback);
            [~,~,fExt]=fileparts(callback);
            fExt=lower(fExt);
            if exist(callback,'file')==2&&strcmp(fExt,'.m')

                out=true;
            elseif exist(callback,'file')==6&&strcmp(fExt,'.p')

                out=true;
            elseif exist(callback,'file')==2&&strcmp(fExt,'.mlx')
                error(message('Simulink:protectedModel:protectedModelCallbackMLXNotSupported'));
            else
                out=false;
            end
        end

        function setCallback(obj,callback)

            if~ischar(callback)&&~Simulink.ModelReference.ProtectedModel.isValidSingleString(callback)
                error(message('Simulink:protectedModel:protectedModelInvalidCallback',obj.Event,obj.AppliesTo));
            elseif obj.isMATLABFileName(callback)
                callback=Simulink.ModelReference.ProtectedModel.getCharArray(callback);
                obj.CallbackFileName=callback;
            else
                callback=Simulink.ModelReference.ProtectedModel.getCharArray(callback);
                obj.CallbackString=callback;
            end
        end

        function out=getCallback(obj)
            if exist(obj.CallbackFileName,'file')
                out=obj.CallbackFileName;
            else
                out=obj.CallbackString;
            end
        end

        function out=getCallbackFileName(obj)
            fname='';
            if~isempty(obj.CallbackFileName)
                if exist(obj.CallbackFileName,'file')
                    fname=obj.CallbackFileName;
                else


                    [cbDir,cbfname,cbext]=fileparts(obj.CallbackFileName);
                    dirInfo=what(cbDir);
                    fname=fullfile(dirInfo.path,[cbfname,cbext]);
                    if~exist(fname,'file')
                        fname='';
                    end
                end
            end




            if isempty(fname)


                fname=[obj.Event,'_',obj.AppliesTo,'.m'];
                if~exist(fname,'file')
                    fid=fopen(fname,'w+');
                    fprintf(fid,'%s',obj.CallbackString);
                    fclose(fid);
                end
            end


            [~,stem,~]=fileparts(fname);
            out=which([stem,'.p']);



            if~exist(out,'file')
                pcode(fname);
                out=which([stem,'.p']);
            end

            obj.CallbackFileName=[stem,'.p'];
        end

        function out=getOverrideBuild(obj)
            if isempty(obj.OverrideBuild)
                out=false;
            else
                out=obj.OverrideBuild;
            end
        end

        function out=supportsCodeGen(obj)
            out=(strcmpi(obj.AppliesTo,'CODEGEN')||strcmpi(obj.AppliesTo,'AUTO'));
        end

        function postValidation(obj)
            if strcmpi(obj.Event,'Build')&&~obj.supportsCodeGen()
                error(message('Simulink:protectedModel:protectedModelInvalidCallbackIncompatibleEventAppliesTo',...
                obj.Event,...
                obj.AppliesTo));
            end
        end
    end
end


