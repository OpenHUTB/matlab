



classdef LidarLabelerAlgorithmRepository<vision.internal.labeler.AlgorithmRepository

    properties(Constant)


        PackageRoot={'lidar.labeler','vision.labeler'};
    end

    methods(Static)

        function repo=getInstance()
            persistent repository
            if isempty(repository)||~isvalid(repository)
                repository=lidar.internal.lidarLabeler.LidarLabelerAlgorithmRepository();
            end
            repo=repository;
        end
    end

    methods



        function refresh(this)
            refresh@vision.internal.labeler.AlgorithmRepository(this);

            algorithms=this.AlgorithmList;
            indices=cellfun(@(x)strcmp(x,'vision.labeler.PointCloudTemporalInterpolator'),algorithms);
            this.AlgorithmList(:,indices)=[];
            this.Names(:,indices)=[];
            this.Fullpath(:,indices)=[];

        end
    end

    methods(Access=protected)


        function TF=hasSupportedSignalType(~,metaClass)


            signalfun=str2func(['@(x)',metaClass.Name,'.checkSignalType(x)']);
            TF=signalfun(vision.labeler.loading.SignalType.PointCloud);
        end

    end

end
