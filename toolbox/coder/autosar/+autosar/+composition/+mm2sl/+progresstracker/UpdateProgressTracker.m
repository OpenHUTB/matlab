classdef UpdateProgressTracker<autosar.composition.mm2sl.progresstracker.ImportOrUpdateProgressTracker




    methods(Access=public)
        function this=UpdateProgressTracker(numComponents,compCounter)
            this=this@autosar.composition.mm2sl.progresstracker.ImportOrUpdateProgressTracker(numComponents,compCounter);
        end

        function displayAndIncrementProgress(this,modelName,compQName)
            msg=this.getDisplayMessage('autosarstandard:importer:CompositionImportProgressUpdate',modelName,compQName);
            autosar.mm.util.MessageReporter.print(msg);
            this.incrementCounter();
        end
    end

end


