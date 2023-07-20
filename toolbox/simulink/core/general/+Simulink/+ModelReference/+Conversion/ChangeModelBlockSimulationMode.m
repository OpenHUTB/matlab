classdef ChangeModelBlockSimulationMode<Simulink.ModelReference.Conversion.ModificationObject




    properties(SetAccess=private,GetAccess=public)
ModelBlocks
SimulationMode
    end

    methods(Access=public)
        function this=ChangeModelBlockSimulationMode(modelBlocks,simMode)
            this.ModelBlocks=modelBlocks;
            this.SimulationMode=simMode;
            this.Description=DAStudio.message('Simulink:modelReferenceAdvisor:ModifyModelBlockSimulationMode',simMode);
        end

        function exec(this)
            arrayfun(@(blk)set_param(blk,'SimulationMode',this.SimulationMode),this.ModelBlocks);
            arrayfun(@(blk)this.updateModelReferenceConfigset(blk),this.ModelBlocks);
        end
    end

    methods(Access=private)
        function updateModelReferenceConfigset(this,modelBlock)
            modelName=get_param(modelBlock,'ModelName');



            if strcmp(this.SimulationMode,'Software-in-the-loop (SIL)')
                this.updateSILModel(modelName);


                save_system(modelName);
            end
        end
    end

    methods(Static,Access=public)
        function updateSILModelForRCB(aModel)
            cs=getActiveConfigSet(aModel);
            if slfeature('RightClickBuild')
                if isa(cs,'Simulink.ConfigSetRef')
                    return;
                end

                if strcmpi(cs.get_param('SupportNonFinite'),'on')
                    cs.set_param('PurelyIntegerCode','off');
                end
            else
                if~strcmpi(cs.get_param('SupportNonFinite'),'on')
                    cs.set_param('SupportNonFinite','on');
                end


                if strcmp(cs.get_param('ProdEqTarget'),'on')&&strcmp(cs.get_param('PortableWordSizes'),'off')
                    cs.set_param('PortableWordSizes','on');
                end


                set_param(cs,'SupportContinuousTime','off');
            end
            save_system(aModel);
        end

        function updateSILModel(aModel)
            cs=getActiveConfigSet(aModel);
            cs.set_param('Solver','FixedStepDiscrete');

            if strcmpi(cs.get_param('CodeInterfacePackaging'),'Nonreusable function')
                cs.set_param('ModelReferenceNumInstancesAllowed','Single');
            end

            if~strcmpi(cs.get_param('SupportNonFinite'),'on')
                cs.set_param('SupportNonFinite','on');
                if slfeature('RightClickBuild')
                    cs.set_param('PurelyIntegerCode','off');
                end
            end

            if strcmp(cs.get_param('ProdEqTarget'),'on')&&strcmp(cs.get_param('PortableWordSizes'),'off')
                cs.set_param('PortableWordSizes','on');
            end


            set_param(cs,'SupportContinuousTime','off');

            save_system(aModel);
        end
    end
end


