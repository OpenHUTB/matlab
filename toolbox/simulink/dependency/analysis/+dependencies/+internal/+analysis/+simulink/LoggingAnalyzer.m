classdef LoggingAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant,Hidden)
        DataParameters={...
        'ReturnWorkspaceOutputsName',...
        'StateSaveName','TimeSaveName','OutputSaveName',...
        'FinalStateName','SignalLoggingName','DSMLoggingName'};
        DataGuards={...
        'ReturnWorkspaceOutputs',...
        'SaveState','SaveTime','SaveOutput',...
        'SaveFinalState','SignalLogging','DSMLogging'};
    end

    methods

        function this=LoggingAnalyzer()

            workspaceQueries=[
            Simulink.loadsave.Query('//System/Block[BlockType="ToWorkspace"]')
            Simulink.loadsave.Query('//System/Block[BlockType="ToWorkspace"]/VariableName')
            Simulink.loadsave.Query('//System/Block[BlockType="SignalToWorkspace"]')
            Simulink.loadsave.Query('//System/Block[BlockType="SignalToWorkspace"]/VariableName')
            Simulink.loadsave.Query('//System/Block[BlockType="Scope" and SaveToWorkspace="on"]/SaveName')
            Simulink.loadsave.Query('//System/Block[BlockType="Scope"]/ScopeSpecificationString')
            ];
            this.addQueries(workspaceQueries);


            for n=1:length(this.DataParameters)
                configQueries=i_createGuardedConfigSetQueries('Simulink.DataIOCC',[this.DataGuards{n},'="on"'],this.DataParameters{n});
                this.addQueries(configQueries{:});
            end
        end

        function deps=analyze(~,handler,~,matches)
            deps=dependencies.internal.graph.Dependency.empty;


            handler.BaseWorkspace.addVariables({matches{2}.Value,matches{4}.Value,matches{5}.Value});



            if length(matches{1})>length(matches{2})
                defaultToWorkspaceVariable=get_param('built-in/ToWorkspace','VariableName');
                handler.BaseWorkspace.addVariables({defaultToWorkspaceVariable});
            end

            if length(matches{3})>length(matches{4})
                defaultSignalToWorkspaceVariable=get_param('built-in/SignalToWorkspace','VariableName');
                handler.BaseWorkspace.addVariables({defaultSignalToWorkspaceVariable});
            end


            for n=1:length(matches{6})
                expression=matches{6}(n).Value;
                try
                    if strncmp(expression,'C++SS(',6)
                        timescope=Simulink.scopes.TimeScopeBlockCfg;
                        converted=timescope.getScopeConfigurationParameters(expression);
                    else
                        [~,timescope]=evalc(expression);
                        converted=timescope.getScopeConfigurationParameters();
                    end

                    if converted.DataLogging
                        var=converted.DataLoggingVariableName;
                        handler.BaseWorkspace.addVariables({var});
                    end
                catch

                end
            end


            if~isempty(matches{7})
                handler.BaseWorkspace.addVariables({matches{7}.Value});
            else
                vars=vertcat(matches{8:end});
                handler.BaseWorkspace.addVariables({vars.Value});
            end
        end

    end

end


function queries=i_createGuardedConfigSetQueries(class,guard,parameter)
    slx=Simulink.loadsave.Query(['/ConfigSet/Object[ClassName="Simulink.ConfigSet"]/Array/Object[ClassName="',class,'" and ',guard,']/',parameter]);
    mdl=Simulink.loadsave.Query(['/Model/Array/Simulink.ConfigSet/Array/',class,'[',guard,']/',parameter]);
    queries={[slx;mdl],{'slx';'mdl'}};
end
