classdef(Hidden=true,Sealed=true)FastRestart





    methods(Static=true,Hidden=true)
        function enable(model)
            try
                set_param(model,'InitializeInteractiveRuns','on');
            catch e
                throwAsCaller(e);
            end

        end
        function isOn=isEnabled(model)

            try
                str=get_param(model,'InitializeInteractiveRuns');
                isOn=~isempty(str)&&strcmpi(str,'on');
            catch e
                throwAsCaller(e);
            end
        end
        function val=isBetweenSimulations(model)
            val=strcmp(get_param(model,'SimulationStatus'),'compiled');
        end
        function val=isStopped(model)
            status=get_param(model,'SimulationStatus');
            val=(strcmp(status,'stopped')||strcmp(status,'compiled'));
        end
        function val=isCompiledAndStopped(model)
            status=get_param(model,'SimulationStatus');
            val=strcmp(status,'compiled');
        end
        function val=isInitialized(model)


            simStatus=get_param(model,'SimulationStatus');
            val=~isempty(simStatus)&&...
            (strcmpi(simStatus,'paused')||strcmpi(simStatus,'running')||...
            strcmpi(simStatus,'paused-in-debugger')||...
            strcmpi(simStatus,'compiled'));
        end

        function val=isReady(model)
            simStatus=get_param(model,'SimulationStatus');
            val=~isempty(simStatus)&&...
            (strcmpi(simStatus,'stopped')||strcmpi(simStatus,'compiled'));
        end
        function run(model,varargin)
            narginchk(1,5);
            useDV=false;
            option=[];

            if nargin>1
                if mod(nargin,2)==0
                    me=MException('Simulink:util:NotNameValArguments',...
                    DAStudio.message('Simulink:util:NotNameValArguments'));
                    throw(me);
                end
                for idx=1:2:nargin-1
                    name=varargin{idx};
                    value=varargin{idx+1};
                    switch lower(name)
                    case 'diagnosticviewer'
                        if islogical(value)
                            useDV=value;
                        else
                            warning('Simulink:FastRestart:InvalidParameterValue',...
                            'Invalid value for the parameter DiagnosticViewer. Expected a logical.');
                        end
                    case 'skipparameterupdate'
                        if islogical(value)
                            if value
                                option=12;
                            end
                        else
                            warning('Simulink:FastRestart:InvalidParameterValue',...
                            'Invalid value for the parameter SkipParameterUpdate. Expected a logical.');
                        end
                    otherwise
                        warning('Simulink:FastRestart:InvalidParameter',...
                        'Invalid parameter %s',name);
                    end
                end
            end

            try


                if(strcmpi(get_param(model,'InitializeInteractiveRuns'),'on'))
                    pause(6);
                    st=Simulink.SimulationStepper(model);
                    if~useDV
                        if isempty(option)
                            st.runBlockingNonUIModeWithErrorsThrown();
                        else
                            st.runBlockingNonUIModeWithErrorsThrown(option);
                        end
                    else
                        if isempty(option)
                            st.runBlocking();
                        else
                            st.runBlocking(option);
                        end
                    end
                else
                    me=MException('Simulink:Stepper:FastRestartDisabled',...
                    DAStudio.message('Simulink:Stepper:FastRestartDisabled'));
                    throw(me);
                end
            catch exception

                throwAsCaller(exception);
            end
        end
        function disable(model)
            try
                set_param(model,'InitializeInteractiveRuns','off');
            catch e
                throwAsCaller(e);
            end
        end
    end
end

