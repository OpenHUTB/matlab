

classdef DebugRuntimeManager<handle


    properties(SetAccess=private)
SFScriptId
instancePath
blockHandle
    end

    methods
        function obj=DebugRuntimeManager(instancePath)
            obj.instancePath=instancePath;
            obj.blockHandle=get_param(instancePath,'handle');





        end

        function addBreakpointsToMap(obj)
            if CGXE.Debug.DebugRuntimeManager.isDebuggerOn()



            end
        end

        function[brkDebugLoop,isDebugCommand]=evaluateCommand(obj,command)

            brkDebugLoop=0;
            isDebugCommand=0;

            if isempty(command)
                return;
            end

            tokens=textscan(command,'%s');
            tokens=tokens{1};
            cmd=regexprep(tokens{1},'^(.*?)[,;]*$','$1');

            switch cmd
            case 'dbstep'
                if(length(tokens)==1)

                    CGXE.internal.Debugger.stepOver(obj.instancePath,true);
                else
                    cmdModifier=tokens{2};
                    switch(cmdModifier)
                    case 'in'

                        CGXE.internal.Debugger.stepIn(obj.instancePath,true);
                    case 'out'

                        CGXE.internal.Debugger.stepOut(obj.instancePath,true);
                    end
                end
                brkDebugLoop=1;
                isDebugCommand=1;

            case 'dbcont'
                brkDebugLoop=1;
                isDebugCommand=1;

            case{'dbquit','exit','quit'}
                obj.stopSimulation();
                brkDebugLoop=1;
                isDebugCommand=1;
            case 'clear'

                disp(DAStudio.message('Stateflow:sfprivate:WarningclearCommandIsDisabledAtStateflowMATLABFunctio'));
            case 'help'
                disp(CGXE.Debug.get_help_str);
            otherwise
                brkDebugLoop=0;
                isDebugCommand=0;
            end
        end

        function debuggerAnimate(obj,scriptName,~)
            objectId=sfprivate('eml_script_cache_get_wrapper_for_breakpoints',scriptName);
            obj.SFScriptId=objectId;
            sfprivate('eml_man','create_ui',objectId,1,obj.blockHandle);
        end


        function removeAnimation(~)

        end

        function refreshAnimation(~)

        end

        function stopSimulation(~)

        end
    end

    methods(Static)
        function retVal=hasValueChanged(newVal,oldVal)
            try
                retVal=~isequal(newVal,oldVal);
            catch ME
                topStack=ME.stack.name;
                if strcmp(topStack,'nested_function.isequal')
                    retVal=false;
                else
                    retVal=true;
                end
            end
        end

        function dbcont()



        end

        function dbquit()



        end

        function exitDebugLoop()



        end

        function result=isDebuggerOn()
            result=cgxe('Feature','Debugger');
        end

        function result=isDebuggerEnabledForCurrentBlock()
            blockPath=CGXE.internal.Debugger.getCurrentInstancePath();
            result=~isempty(blockPath)&&CGXE.Debug.DebugRuntimeManager.isDebuggerOn();
        end
    end
end
