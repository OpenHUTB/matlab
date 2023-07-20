
classdef GUIHelper<handle


    properties(Access='private')
        modelHandle;
        studioBlocker;
        releaseName;
        useGUI;
        DVStage;
    end

    methods(Access='public')

        function obj=GUIHelper(modelName,releaseName,useGUI)
            obj.modelHandle=get_param(modelName,'Handle');
            obj.releaseName=releaseName;
            obj.useGUI=useGUI;
        end

        function enable(obj)


            msg=DAStudio.message('Simulink:ExportPrevious:StatusBarProgress',...
            get_param(obj.modelHandle,'Name'),obj.releaseName);
            obj.studioBlocker=SLM3I.ScopedStudioBlocker(obj.modelHandle,msg,0,1);
            obj.setProgress(0);
        end

        function delete(obj)
            disable(obj);
        end

        function disable(obj)
            if ishandle(obj.modelHandle)

                set_param(obj.modelHandle,'StatusString','');
            end

            obj.studioBlocker=[];

            obj.DVStage=[];
        end


        function setProgress(obj,val)
            assert(val>=0,'setProgress value must be non-negative');
            assert(val<=1,'setProgress value must not exceed 1');
            obj.studioBlocker.setStatusBarProgress(val);
        end

        function setup(obj,sourceModelName)
            if obj.useGUI


                stageName=DAStudio.message('Simulink:ExportPrevious:StageName',obj.releaseName);
                obj.DVStage=Simulink.output.Stage(stageName,'ModelName',sourceModelName,'UIMode',true);
            end
        end


        function handleError(obj,E,sourceModelName)


            if obj.useGUI
                Simulink.output.error(E);
                m=MException('Simulink:ExportPrevious:AbortMessage','%s',...
                DAStudio.message('Simulink:ExportPrevious:AbortMessage',...
                sourceModelName,obj.releaseName));
                Simulink.output.error(m);
            else
                rethrow(E);
            end
        end

        function reportAsWarning(~,E)
            w=warning('backtrace','off');
            MSLDiagnostic(E).reportAsWarning;
            warning(w);
        end

        function reportCompletion(obj,targetFile,success)
            if success

                obj.printSuccessMessage(targetFile);
                if obj.useGUI

                    editor=GLUE2.Util.findAllEditors(get_param(obj.modelHandle,'Name'));
                    if~isempty(editor)
                        str=DAStudio.message('Simulink:ExportPrevious:CompletionNotification',...
                        targetFile,targetFile,obj.releaseName);
                        editor.deliverInfoNotification('export',str);
                    end
                end
            else


                w=warning('backtrace','off');
                msl=MSLException('Simulink:ExportPrevious:FailureMessage',...
                {['uiopen(''',char(targetFile),''', true)'],targetFile},obj.releaseName);
                Simulink.output.highPriorityWarning(msl);
                warning(w);
            end
        end

    end

    methods(Static,Access='public')
        function openExportedModel(filename)
            try
                open_system(filename);
            catch E
                d=DAStudio.DialogProvider;
                d.errordlg(E.message,DAStudio.message('Simulink:dialog:dlg_Error'),true);
            end
        end
    end

    methods(Access='protected')


        function printSuccessMessage(obj,targetFile)
            msl=MSLException('Simulink:ExportPrevious:SuccessMessage',...
            {['uiopen(''',char(targetFile),''', true)'],targetFile},obj.releaseName);
            Simulink.output.info(msl);
        end
    end
end
