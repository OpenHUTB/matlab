classdef ForEach<starepository.repositorysignal.RepositorySignal




    properties
        SUPPORTED_FORMATS={'foreachsubsys','loggedsignal:foreachsubsys'};
    end


    methods

        function bool=isSupported(obj,dbId,dataFormat)




            bool=any(strcmpi(dataFormat,obj.SUPPORTED_FORMATS))||...
            ~isempty(strfind(dataFormat,'foreachsubsys'));
        end


        function[varValue,varName]=extractValue(obj,dbId)

            varValue=createSimulinkSimulationDataSignal(obj,dbId);

            if isempty(dbId)
                varValue=[];
                varName=[];
                return;
            end


            varName=obj.repoUtil.getVariableName(dbId);

            kidDbId=obj.repoUtil.getChildrenIDsInSiblingOrder(dbId);

            N_KIDS=length(kidDbId);
            cellOfTimeTables=cell(1,N_KIDS);
            vectorOfTimeSeries=timeseries.empty(0,N_KIDS);

            IS_TIME_TABLE=false;


            aFactory=starepository.repositorysignal.Factory;

            for k=1:length(kidDbId)


                concreteExtractor=aFactory.getSupportedExtractor(kidDbId(k));


                [varValLeaf,varNameLeaf]=concreteExtractor.extractValue(kidDbId(k));

                if isa(concreteExtractor,'starepository.repositorysignal.SLTimeTable')
                    cellOfTimeTables{k}=varValLeaf;
                    IS_TIME_TABLE=true;
                else
                    vectorOfTimeSeries(k)=varValLeaf;
                end

            end

            if IS_TIME_TABLE
                varValue.Values=cellOfTimeTables;
            else
                varValue.Values=vectorOfTimeSeries;
            end

        end

    end
end