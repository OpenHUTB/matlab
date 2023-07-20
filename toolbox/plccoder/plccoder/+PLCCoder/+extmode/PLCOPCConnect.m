classdef PLCOPCConnect<handle


    properties
        fHostName='';
        fOPCServerID='';
        fOPC;
        fDataGroup;
        fDataPath;
        fDataNameList;
        fDataItemList;
    end

    methods
        function obj=PLCOPCConnect(host_name,server_id,data_path)
            import PLCCoder.extmode.*;
            obj.fHostName=host_name;
            obj.fOPCServerID=server_id;
            hostInfo=opcserverinfo(host_name);
            server_idlist=hostInfo.ServerID;
            if(~any(strcmp(server_idlist,server_id)))
                throwError(message('plccoder:extmode:InvalidOPCServerID',server_id));
            end
            obj.connect;
            obj.fDataPath=data_path;
        end

        function setupData(obj,data_name_list)
            obj.fDataNameList=data_name_list;
            obj.genDataItemList;
        end

        function data_value_list=readData(obj)
            sz=length(obj.fDataItemList);
            data_value_list=cell(sz);
            for i=1:sz
                data_value_list{i}=read(obj.fDataItemList{i});
            end
        end
    end

    methods(Access='private')
        function connect(obj)
            obj.fOPC=opcda(obj.fHostName,obj.fOPCServerID);
            connect(obj.fOPC);
            obj.fDataGroup=addgroup(obj.fOPC);
        end

        function genDataItemList(obj)
            obj.fDataItemList={};
            for i=1:length(obj.fDataNameList)
                full_name=sprintf('%s.%s',obj.fDataPath,obj.fDataNameList{i});
                obj.fDataItemList{end+1}=additem(obj.fDataGroup,full_name);
            end
        end
    end
end


