classdef PLCExtModeMgr<handle





































    properties
        fHost;
        fTargetIDE;
        fMdlName;
        fLogFile;
        fLogData;
        fOPC;
        fDisplayList;
    end

    methods
        function obj=PLCExtModeMgr(opc_host,target_ide,mdl_name,log_file)
            import PLCCoder.extmode.*;
            obj.fHost=opc_host;
            obj.fTargetIDE=target_ide;
            obj.fMdlName=mdl_name;
            obj.fLogFile=log_file;
            obj.fLogData=PLCLogData(obj.fLogFile);
        end

        function printLogData(obj)
            obj.fLogData.printLogData;
        end

        function printSelectData(obj)
            obj.fLogData.printSelectData;
        end

        function selectDataByIdx(obj,idx_list)
            obj.fLogData.selectDataByIdx(idx_list);
        end

        function selectDataByName(obj,name_list)
            obj.fLogData.selectDataByName(name_list);
        end

        function run(obj)
            import PLCCoder.extmode.*;
            obj.fLogData.convertTypeList(obj.fTargetIDE);
            obj.fOPC=PLCOPCConnect(obj.fHost,obj.getOPCServerID,obj.getOPCPath);
            obj.fOPC.setupData(obj.fLogData.fSelectDataList);
            obj.setupDisplay;
            obj.streamData;
        end
    end

    methods(Access='private')
        function server_id=getOPCServerID(obj)
            import PLCCoder.extmode.*;
            switch obj.fTargetIDE
            case{'rslogix5000','studio5000'}
                server_id='RSLinx OPC Server';
            otherwise
                throwError(message('plccoder:extmode:UnsupportedTarget',obj.fTargetIDE));
            end
        end

        function path=getOPCPath(obj)
            import PLCCoder.extmode.*;
            switch obj.fTargetIDE
            case{'rslogix5000','studio5000'}
                path=sprintf('[%s]Program:MainProgram.%s',obj.fMdlName,obj.fLogData.fLogVar);
            otherwise
                throwError(message('plccoder:extmode:UnsupportedTarget',obj.fTargetIDE));
            end
        end

        function setupDisplay(obj)
            import PLCCoder.extmode.*;
            PLCDataDisplay.clear;
            PLCDataDisplay.show;
            data_list=obj.fLogData.fSelectDataList;
            type_list=obj.fLogData.fSelectTypeList;
            assert(length(data_list)==length(type_list));
            sz=length(data_list);
            obj.fDisplayList=cell(sz);
            for i=1:sz
                data_name=data_list{i};
                obj.fDisplayList{i}=PLCDataDisplay(type_list{i},data_name,obj.fTargetIDE,[data_name,'_id'],i,i);
            end
            PLCDataDisplay.refresh;
            PLCDataDisplay.setupSDI(sz);
        end

        function streamData(obj)
            tm_count=0;
            while(true)
                data_value_list=obj.fOPC.readData;
                obj.showDataGUI(tm_count,data_value_list);
                pause(0.2);
                tm_count=tm_count+1;
            end
        end

        function showDataCmdline(obj,tm_count,data_value_list)
            data_list=obj.fLogData.fSelectDataList;
            assert(length(data_list)==length(data_value_list));
            clc;
            sz=length(data_list);
            for i=1:sz
                fprintf(1,'%s\n',data_list{i});
                disp(data_value_list{i}.Value);
            end
            fprintf(1,'-------------------------------\n');
            fprintf(1,'TIME: %d\n',tm_count);
        end

        function showDataGUI(obj,tm_count,data_value_list)
            data_list=obj.fLogData.fSelectDataList;
            assert(length(data_list)==length(data_value_list));
            sz=length(data_list);
            for i=1:sz
                obj.fDisplayList{i}.addData(tm_count,data_value_list{i}.Value);
            end
        end
    end
end


