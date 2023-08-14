classdef PLCLogData<handle

    properties
        fLogFile;
        fDataList;
        fTypeList;
        fLogData;
        fModel;
        fSubsystemID;
        fLogVar;
        fSelectDataList;
        fSelectTypeList;
    end

    methods
        function obj=PLCLogData(log_file_path)
            import PLCCoder.extmode.*;
            if~exist(log_file_path,'file')
                throwError(message('plccoder:extmode:InvalidLogFilePath',log_file_path));
            end
            obj.fLogFile=log_file_path;
            obj.getLogData;
            obj.fSelectDataList=obj.fDataList;
            obj.fSelectTypeList=obj.fTypeList;
        end

        function disp(obj)
            fprintf('log file: %s\n',obj.fLogFile);
            fprintf('log var: %s\n',obj.fLogVar);
            arrayfun(@(c)fprintf('#%d: %s: %s\n',c,obj.fDataList{c},obj.fTypeList{c}),1:length(obj.fDataList),'UniformOutput',false);
            fprintf(1,'Selected data:\n');
            arrayfun(@(c)fprintf('#%d: %s: %s\n',c,obj.fSelectDataList{c},obj.fSelectTypeList{c}),1:length(obj.fSelectDataList),'UniformOutput',false);
        end

        function printLogData(obj)
            fprintf(1,'Log data:\n');
            arrayfun(@(c)fprintf('#%d: %s: %s\n',c,obj.fDataList{c},obj.fTypeList{c}),1:length(obj.fDataList),'UniformOutput',false);
        end

        function printSelectData(obj)
            fprintf(1,'Selected data:\n');
            arrayfun(@(c)fprintf('#%d: %s: %s\n',c,obj.fSelectDataList{c},obj.fSelectTypeList{c}),1:length(obj.fSelectDataList),'UniformOutput',false);
        end

        function validateIdx(obj,idx)
            import PLCCoder.extmode.*;
            if~(idx>=1&&idx<=length(obj.fDataList))
                throwError(message('plccoder:extmode:SelectDataIndexInvalid',idx));
            end
        end

        function selectIdx(obj,idx)
            obj.fSelectDataList{end+1}=obj.fDataList{idx};
            obj.fSelectTypeList{end+1}=obj.fTypeList{idx};
        end

        function selectDataByIdx(obj,idx_list)
            idx_list=unique(idx_list,'stable');
            if isempty(idx_list)
                return;
            end
            arrayfun(@(idx)obj.validateIdx(idx),idx_list,'UniformOutput',false);
            obj.fSelectDataList={};
            obj.fSelectTypeList={};
            arrayfun(@(idx)obj.selectIdx(idx),idx_list,'UniformOutput',false);
        end

        function validateName(obj,name)
            import PLCCoder.extmode.*;
            if~ismember(name,obj.fDataList)
                throwError(message('plccoder:extmode:LogDataNameInvalid',name));
            end
        end

        function selectName(obj,name)
            idx=find(ismember(obj.fDataList,name));
            obj.fSelectDataList{end+1}=obj.fDataList{idx};
            obj.fSelectTypeList{end+1}=obj.fTypeList{idx};
        end

        function selectDataByName(obj,name_list)
            name_list=unique(name_list);
            if isempty(name_list)
                return;
            end
            cellfun(@(name)obj.validateName(name),name_list,'UniformOutput',false);
            obj.fSelectDataList={};
            obj.fSelectTypeList={};
            cellfun(@(name)obj.selectName(name),name_list,'UniformOutput',false);
        end

        function convertTypeList(obj,target)
            import PLCCoder.extmode.PLCTypeConverter;
            obj.fSelectTypeList=PLCCoder.extmode.PLCTypeConverter.convertTypeList(target,obj.fSelectTypeList);
        end
    end

    methods(Access='private')
        function getLogData(obj)
            log_data=load(obj.fLogFile);
            log_data_fields=fieldnames(log_data);
            assert(length(log_data_fields)==1);
            assert(strcmp(log_data_fields{1},'plc_log_data'));
            obj.fLogData=log_data.plc_log_data;
            obj.fModel=obj.fLogData.model;
            obj.fSubsystemID=obj.fLogData.subsystem_id;
            log_var=obj.fLogData.logdata_var;
            obj.fLogVar=log_var.name;
            base_name='';
            obj.fDataList={};
            obj.fTypeList={};
            obj.genData(base_name,log_var.type);
        end

        function genData(obj,base_name,type)
            import PLCCoder.extmode.*;
            switch(type.kind)
            case 'element'
                obj.fDataList{end+1}=sprintf('%s',base_name);
                obj.fTypeList{end+1}=sprintf('%s',type.name);
            case 'struct'
                obj.genStructData(base_name,type);
            case 'enum'
                return;
            case 'array'
                return;
            otherwise
                throwError(message('plccoder:extmode:GeneralTypeUnsupported',type.kind));
            end
        end

        function genStructData(obj,base_name,type)
            if isempty(base_name)
                for i=1:length(type.desc)
                    obj.genData(sprintf('%s',type.desc(i).field_name),type.desc(i).field_type);
                end
            else
                for i=1:length(type.desc)
                    obj.genData(sprintf('%s.%s',base_name,type.desc(i).field_name),type.desc(i).field_type);
                end
            end
        end
    end

end


