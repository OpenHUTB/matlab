classdef DSMExporter<Simulink.sdi.internal.export.ElementExporter




    methods

        function ret=getDomainType(~)
            ret='dsm';
        end


        function ret=exportElement(~,ret,dataStruct)
            if~dataStruct.SharedMemoryRootSigID
                ret=locLegacyExport(ret,dataStruct);
                return
            end




            writers=dataStruct.repo.getSignalSharedMemoryWriters(dataStruct.SharedMemoryRootSigID);
            if isempty(writers)&&~isempty(dataStruct.Values.Time)
                ret=locLegacyExport(ret,dataStruct);
                return
            end


            ret=Simulink.SimulationData.DataStoreMemory;
            ret.Name=dataStruct.LoggedName;
            if~isempty(dataStruct.BlockPath)
                ret.BlockPath=dataStruct.BlockPath;
            end


            ret=ret.utSetWriters(writers);
            if dataStruct.SharedMemoryType==1


                ret=ret.utSetScope('global');
            end


            if~isempty(writers)
                writerIdx=dataStruct.repo.getSignalTemporalMetaData(dataStruct.SharedMemoryRootSigID,'DSMWriters');
                ret=ret.utSetWriterIndices(uint32(writerIdx));

                ret.Values=dataStruct.Values;
                if isa(ret.Values,'timeseries')
                    ret.Values.Name=dataStruct.SignalName;
                end
            end
        end

    end

end


function ret=locLegacyExport(ret,dataStruct)
    exporter=Simulink.sdi.internal.export.SignalExporter;
    ret=exporter.exportElement(ret,dataStruct);
end

