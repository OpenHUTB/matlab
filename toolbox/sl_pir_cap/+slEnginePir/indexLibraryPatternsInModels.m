





classdef indexLibraryPatternsInModels<handle

    properties(Access='public')

    end

    properties(Hidden)

    end

    methods(Access='public')




        function this=indexLibraryPatternsInModels(libraryDirectory,modelDirectory)
            Simulink.SLPIR.CloneDetection.indexLibrary(libraryDirectory,modelDirectory);
        end

    end

end
