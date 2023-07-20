classdef ImportProgressTracker<autosar.composition.mm2sl.progresstracker.ImportOrUpdateProgressTracker




    methods(Access=public)
        function this=ImportProgressTracker(numComponents,compCounter)
            this=this@autosar.composition.mm2sl.progresstracker.ImportOrUpdateProgressTracker(numComponents,compCounter);
        end

        function displayAndIncrementProgress(this,modelName,compQName)
            msg=this.getDisplayMessage('autosarstandard:importer:CompositionImportProgress',modelName,compQName);
            Simulink.output.info(msg);
            this.incrementCounter();
        end
    end

end


