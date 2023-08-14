function[simOut]=simulateSystem(this,varargin)




















    this.assertDEValid();


    this.loadSystems();

    stopTime=slResolve(get_param(this.TopModel,'StopTime'),this.TopModel);
    if isinf(stopTime)
        throw(MException(message('SimulinkFixedPoint:dataTypeOptimization:infSimulationTime',this.TopModel)));
    end

    if isempty(varargin)||(isa(varargin{1},'Simulink.SimulationInput')&&isempty(varargin{1}))






        varargin={'ReturnWorkspaceOutputs','on'};
    end


    firstArg=varargin{1};
    if isa(firstArg,'Simulink.SimulationInput')

        p=inputParser;



        addRequired(p,'simIn');



        addParameter(p,'ShowSimulationManager','off');


        addParameter(p,'ShowProgress','off');


        parse(p,varargin{:});


        [simOut,simIn,mergedRunName]=performMultiSimulation(this,p.Results);
        this.registerMultiSimulation(p.Results,simIn,mergedRunName);

    else



        if(any(strcmp(varargin,'current')))
            varargin{strcmp(varargin,'current')}='parent';
        end

        simOut=performSimpleSimulation(this,varargin);
        this.registerSimpleSimulation();

    end

end
