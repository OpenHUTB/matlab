classdef Factory<handle






    properties(Access=private)
        packageName='starepository.repositorysignal';
        baseClassName='starepository.repositorysignal.RepositorySignal';
        PluginsFound={}
        repoUtil=starepository.RepositoryUtility();
    end


    methods


        function obj=Factory()


            obj.findPlugins();
        end


        function findPlugins(obj)

            obj.PluginsFound={
            starepository.repositorysignal.AoB();
            starepository.repositorysignal.BlockData();
            starepository.repositorysignal.Bus();
            starepository.repositorysignal.DataArray();
            starepository.repositorysignal.DataSet();
            starepository.repositorysignal.EmptyLoggedVariant();
            starepository.repositorysignal.ForEach();
            starepository.repositorysignal.FunctionCall();
            starepository.repositorysignal.GroundValue();
            starepository.repositorysignal.MultiDimensionalTimeSeries();
            starepository.repositorysignal.NDimensionalTimeSeries();
            starepository.repositorysignal.SLTimeTable();
            starepository.repositorysignal.StructWAndWoTime();
            starepository.repositorysignal.Timeseries();
            starepository.repositorysignal.VariantSink();
            };
        end


        function extractor=getSupportedExtractor(obj,dbId)

            extractor=[];


            format=obj.repoUtil.getMetaDataByName(dbId,'dataformat');


            for k=1:length(obj.PluginsFound)


                if obj.PluginsFound{k}.isSupported(dbId,format)

                    extractor=obj.PluginsFound{k};
                    return;
                end

            end
        end

    end

end

