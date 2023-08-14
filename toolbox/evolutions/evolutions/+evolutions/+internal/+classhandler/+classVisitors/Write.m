classdef Write<evolutions.internal.classhandler.classVisitors.Visitor




    methods(Access=?evolutions.internal.classhandler.classVisitors.Visitor)

        function visitBaseFileInfo(~,~)

        end

        function visitEvolutionInfo(this,evolution)

            this.generateDataFile(evolution);
        end

        function visitEdge(this,edge)

            this.generateDataFile(edge);
        end

        function visitEvolutionTreeInfo(this,evolutionTreeInfo)
            mfDataManager=evolutions.internal.session.SessionManager.getMf0Data;
            constellation=mfDataManager.getConstellation(evolutionTreeInfo);
            try
                constellation.saveModels(true);
            catch ME

                errorMessage=strrep(ME.message,getString(message('mf0:io:ModelConstellationSaveFailed','')),'');


                evolutionsErrorMessage=getString(message('evolutions:manage:TreeDataWriteFail',errorMessage));
                exception=MException('evolutions:manage:TreeDataWriteFail',evolutionsErrorMessage);
                throw(exception);
            end


            this.generateDataFile(evolutionTreeInfo);


            evolutionManager=evolutionTreeInfo.EvolutionManager;
            edgeManager=evolutionTreeInfo.EdgeManager;
            evolutions.internal.classhandler.ClassHandler.WriteObject(evolutionManager.Infos);
            evolutions.internal.classhandler.ClassHandler.WriteObject(edgeManager.Infos);
        end

        function generateDataFile(~,~)













        end
    end
end


