




classdef MultiSignalLabelerAlgorithmRepository<vision.internal.labeler.AlgorithmRepository

    properties(Constant)



        PackageRoot={'vision.labeler','driving.automation'};
    end

    methods(Static)

        function repo=getInstance()
            persistent repository
            if isempty(repository)||~isvalid(repository)
                repository=vision.internal.videoLabeler.MultiSignalLabelerAlgorithmRepository();
            end
            repo=repository;
        end
    end

    methods(Access=protected)


        function TF=hasSupportedSignalType(~,~)


            TF=true;
        end

    end

end