classdef DecoupledSubsystemCollector<handle





    properties(SetAccess=private)
        IDs=[]
        BlockPaths={}
        Table=table.empty
    end

    methods
        function collect(this,sud)




            this.validateInput(sud);
            unsupportedConstructsCell=this.getUnsupportedConstructs(sud);
            registerTable(this,unsupportedConstructsCell);
        end

        function registerTable(this,unsupportedConstructsCell)


            nBlocks=numel(unsupportedConstructsCell);
            this.IDs=1:nBlocks;
            this.BlockPaths=unsupportedConstructsCell;
            this.Table=table(this.IDs',this.BlockPaths','VariableNames',{'ID','BlockPath'});
        end
    end

    methods(Static,Hidden)
        function validateInput(sud)


            sud=convertStringsToChars(sud);
            designEnvironment=DataTypeWorkflow.DesignEnvironment();
            try
                designEnvironment.setup(sud);
            catch validationErr
                validationErr.throwAsCaller();
            end
        end

        function unsupportedConstructsCell=getUnsupportedConstructs(sud)



            ssBlocks=Simulink.findBlocksOfType(sud,'SubSystem');
            if Simulink.internal.useFindSystemVariantsMatchFilter()

                allModels=find_mdlrefs(sud,'MatchFilter',@Simulink.match.codeCompileVariants);
            else
                allModels=find_mdlrefs(sud);
            end
            allModels=allModels(1:end-1);
            for iModel=1:numel(allModels)
                ssBlocks=[ssBlocks;Simulink.findBlocksOfType(allModels{iModel},'SubSystem')];%#ok<AGROW>
            end


            nBlocks=numel(ssBlocks);
            madeByAnalyzer=false(nBlocks,1);
            for k=1:nBlocks
                blockName=Simulink.ID.getFullName(ssBlocks(k));
                madeByAnalyzer(k)=DataTypeWorkflow.Advisor.Utils.isConstructedDecouplingSubsystem(blockName);
            end
            unsupportedConstructs=ssBlocks(madeByAnalyzer);


            unsupportedConstructsCell=cell(1,numel(unsupportedConstructs));
            for k=1:numel(unsupportedConstructsCell)
                unsupportedConstructsCell{k}=Simulink.BlockPath(Simulink.ID.getFullName(unsupportedConstructs(k))).convertToCell{1};
            end
        end
    end
end
