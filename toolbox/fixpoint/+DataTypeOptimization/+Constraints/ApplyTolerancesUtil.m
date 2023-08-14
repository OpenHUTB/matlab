classdef ApplyTolerancesUtil<handle









    methods
        function applyTol(this,models,opt)



            opt=this.getExistingAssertionChecks(models,opt);


            this.verifyConstraints(opt)

        end
    end

    methods(Hidden)

        function opt=getExistingAssertionChecks(this,models,opt)




            blkNames=this.getModelVerificationBlockNames(models);

            for bIndex=1:numel(blkNames)
                normalizedBlkName=Simulink.BlockPath(blkNames{bIndex}).convertToCell{1};

                opt.addTolerance(normalizedBlkName,0,'Assertion',0);
            end
        end

        function blkName=getModelVerificationBlockNames(~,models)



            blkName={};
            for mIndex=1:numel(models)




                blkName=[blkName;find_system(models{mIndex},...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'Regexp','on','MaskType','Checks_*','Enabled','on','StopWhenAssertionFail','on')];%#ok<*AGROW>











                blkName=[blkName;find_system(models{mIndex},...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','Assertion','Enabled','on','StopWhenAssertionFail','on')];

            end
        end

        function verifyConstraints(~,opt)
            if isempty(opt.Constraints)

                DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:noConstraints');
            end



            constraintsCell=opt.Constraints.values;
            for cIndex=1:numel(constraintsCell)
                try
                    if~isequal(constraintsCell{cIndex}.getMode,'Assertion')
                        ph=get_param(constraintsCell{cIndex}.path,'PortHandles');
                        assert(numel(ph.Outport)>=constraintsCell{cIndex}.portIndex);
                    end
                catch errDiag
                    DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:invalidConstraint',constraintsCell{cIndex}.path,constraintsCell{cIndex}.portIndex);
                end
            end

        end
    end
end


