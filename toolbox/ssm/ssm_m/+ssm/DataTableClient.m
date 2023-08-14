classdef DataTableClient<handle





    properties(Hidden,Access=private)
        modelHandle;
        allReaderIDs;
        allWriterIDs;
    end

    methods
        function obj=DataTableClient(varargin)
            obj.modelHandle=get_param(gcs,'handle');
            obj.allReaderIDs=[];
            obj.allWriterIDs=[];
        end
    end

    methods(Access=protected,Sealed)

        function readerID=registerDataTableReader(obj,tableName,BusName)
            readerID=ssm.SSMService.registerDataTableReader(obj.modelHandle,tableName,BusName);
            obj.allReaderIDs(end+1)=readerID;
        end


        function writerID=registerDataTableWriter(obj,tableName,BusName,varargin)
            nVarargs=length(varargin);
            IC=struct();
            if nVarargs==0
                IC=struct();
            elseif nVarargs==1
                IC=varargin{1};
            else
                matlab.system.internal.error(...
                'ssm:mcosMessages:IncorrectArgumentNum',...
                'registerDataTableWriter');
            end
            writerID=ssm.SSMService.registerDataTableWriter(obj.modelHandle,tableName,BusName,IC);
            obj.allWriterIDs(end+1)=writerID;
        end


        function response=readFromDataTable(obj,readerID,query)
            response=ssm.SSMService.readFromDataTable(obj.modelHandle,readerID,query);
        end


        function writeToDataTable(obj,writerID,data)
            ssm.SSMService.writeToDataTable(obj.modelHandle,writerID,data);
        end

        function unregisterDataTableClient(obj,clientID)
            if max(ismember(obj.allReaderIDs,clientID))
                ssm.SSMService.unregisterDataTableReader(...
                obj.modelHandle,clientID);
            elseif max(ismember(obj.allWriterIDs,clientID))
                ssm.SSMService.unregisterDataTableWriter(...
                obj.modelHandle,clientID);
            else
                error(message('ssm:mcosMessages:IdNotRegistered',...
                clientID).getString)
            end
        end
    end
end
