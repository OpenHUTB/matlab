classdef ModelCompileHandler<handle






    properties(SetAccess=private)
        ObjectPath(1,:)char
    end

    properties(Hidden)
        SimType=Simulink.CMI.CompiledSimType.Sim;
        LicenseType=Simulink.EngineInterfaceVal.fixedPoint;
        MaskCompileError logical=true;
    end

    properties(Access=private)
        Session=[];
        SystemSession=[];
    end

    methods
        function this=ModelCompileHandler(objectPath)
            objectPath=convertStringsToChars(objectPath);
            this.ObjectPath=objectPath;
        end

        function start(this)
            modelPath=bdroot(this.ObjectPath);
            if strcmp(get_param(modelPath,'SimulationStatus'),'stopped')
                warningStruct=warning('off','all');
                try

                    this.Session=Simulink.CMI.EIAdapter(this.LicenseType);
                    this.SystemSession=Simulink.CMI.CompiledBlockDiagram(this.Session,modelPath);
                    this.Session.init(this.SystemSession,int32(this.SimType));
                catch err
                    warning(warningStruct);
                    if this.MaskCompileError
                        FunctionApproximation.internal.DisplayUtils.throwError(MException(message('SimulinkFixedPoint:functionApproximation:updateDiagramError',modelPath)));
                    else
                        throwAsCaller(err);
                    end
                end
                warning(warningStruct);
            end
        end

        function stop(this)
            modelPath=bdroot(this.ObjectPath);
            if strcmp(get_param(modelPath,'SimulationStatus'),'paused')

                if~isempty(this.Session)

                    this.Session.term(this.SystemSession);
                else



                    feval(modelPath,[],[],[],'term');
                end
            end
            clearSessions(this);
        end

        function setLicenseType(this,licenseType)
            this.LicenseType=licenseType;
        end

        function setSimType(this,simType)
            this.SimType=simType;
        end

        function setMaskCompileError(this,flag)
            this.MaskCompileError=flag;
        end
    end

    methods(Access=private)
        function clearSessions(this)
            this.Session=[];
            this.SystemSession=[];
        end
    end
end
