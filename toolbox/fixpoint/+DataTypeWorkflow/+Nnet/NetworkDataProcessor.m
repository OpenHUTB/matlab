classdef NetworkDataProcessor<handle






    properties(SetAccess=private)
        SimulinkData=DataTypeWorkflow.Nnet.SimulinkContext
NetworkData
    end

    properties(Access=private)
        ModelPreLoaded=false
        ProcessingPassed=false
    end

    properties(Constant)
        DLTlibrary='neural'
    end

    methods
        function this=NetworkDataProcessor(networkToPrep,trainingInput,trainingTarget,varargin)


            narginchk(3,9);
            this.NetworkData=DataTypeWorkflow.Nnet.NetworkContext(...
            networkToPrep,trainingInput,trainingTarget);
            this.SimulinkData=DataTypeWorkflow.Nnet.SimulinkContext(varargin{:});
            this.openSystemUnderDesign(networkToPrep);


            this.ProcessingPassed=true;
        end

        function delete(this)
            if~this.ProcessingPassed&&~this.ModelPreLoaded


                close_system(this.SimulinkData.SystemUnderDesign,0);
            elseif this.ProcessingPassed&&this.ModelPreLoaded



                open_system(this.SimulinkData.SystemUnderDesign);
            end
        end
    end

    methods(Access={?NnetTestCase})
        function openSystemUnderDesign(this,networkToPrep)
            sud=this.SimulinkData.SystemUnderDesign;
            if isempty(sud)


                this.createNewModel(networkToPrep);
            else


                if bdIsLoaded(sud)
                    this.ModelPreLoaded=true;
                else
                    open_system(sud);
                end
                this.checkInputModel();
            end
        end

        function createNewModel(this,networkToPrep)
            simData=this.SimulinkData;
            [sud,netName]=gensim(networkToPrep);
            simData.SystemUnderDesign=sud;
            simData.NetworkBlock=[sud,'/',netName];
            simData.LibraryInfo=libinfo(sud);
            simData.setTopModelFromSUD();
        end

        function checkInputModel(this)
            simData=this.SimulinkData;
            libdata=libinfo(simData.SystemUnderDesign);
            if isempty(libdata)||~contains([libdata.Library],this.DLTlibrary)
                error(message('FixedPointTool:fixedPointTool:InvalidNNETModel'));
            else
                opts=Simulink.FindOptions('SearchDepth',1);
                simData.NetworkBlock=getfullname(Simulink.findBlocksOfType...
                (simData.SystemUnderDesign,'SubSystem',opts));
                simData.LibraryInfo=libdata;
                simData.setTopModelFromSUD();
            end
        end
    end
end


