




classdef VideoLabelerAlgorithmRepository<vision.internal.labeler.AlgorithmRepository

    properties(Constant)



        PackageRoot={'vision.labeler','driving.automation'};
    end

    methods(Static)

        function repo=getInstance()
            persistent repository
            if isempty(repository)||~isvalid(repository)
                repository=vision.internal.labeler.VideoLabelerAlgorithmRepository();
            end
            repo=repository;
        end
    end

end