classdef ReportUtils<handle




    properties
HardwareSettingMap
OtherSettingMap
ReportDB
    end

    properties(Constant)
        BackendStatuskeys=["PassWithoutChange","PassWithChange","WarnWithoutChange","FailWithoutChange"];
        HarwareSettingUIStatusValues=["Pass","Pass","Warning","Error"];
        OtherSettingUIStatusValues=["Pass","Pass","Warning","Error"];
        PassStatus="PassWithoutChange";
        TableStrConstant="Table";
        HeaderStrConstant="Header";
        HarwareSettingStrConstant="HardwareSetting";
    end

    methods

        function register(obj)
            obj.HardwareSettingMap=containers.Map(obj.BackendStatuskeys,obj.HarwareSettingUIStatusValues);
            obj.OtherSettingMap=containers.Map(obj.BackendStatuskeys,obj.OtherSettingUIStatusValues);
        end


        function checkList=getCheckList(obj)
            checkList=obj.ReportDB.CheckList;
        end

        function checkNameStr=getCheckEnumStr(~,reportCheckCategory)

            enumValue=DataTypeWorkflow.Advisor.internal.utils.ReportCheckCategory.convertCheckCategoryToEnum(reportCheckCategory);


            checkNameStr=string(enumValue);
        end

        function statusArr=getUniqueStatusArr(obj,reportCheckCategory)

            checkNameStr=obj.getCheckEnumStr(reportCheckCategory);

            tableNameStr=checkNameStr+obj.TableStrConstant;

            statusArr=obj.PassStatus;
            if(~isempty(obj.ReportDB.Tables.(tableNameStr)))
                statusArr=obj.ReportDB.Tables.(tableNameStr).Status;


                statusArr=unique(statusArr);
            end


            if(length(statusArr)==1)
                statusArr={statusArr};
            end
        end

        function uiStatusArr=convertToUIStatus(obj,statusArr,reportCheckCategory)

            checkNameStr=obj.getCheckEnumStr(reportCheckCategory);


            statusMap=obj.OtherSettingMap;




            if(strcmp(checkNameStr,obj.HarwareSettingStrConstant))
                statusMap=obj.HardwareSettingMap;
            end

            uiStatusArr=[];

            for idx=1:length(statusArr)

                uiStatusArr=[uiStatusArr;DataTypeWorkflow.Advisor.internal.utils.ReportCheckStatus(statusMap(statusArr{idx}))];%#ok<*AGROW>
            end
        end

        function[summary,header,info]=getDetailedInfo(obj,reportCheckCategory,statusArr)



            header={};
            info={};


            checkNameStr=obj.getCheckEnumStr(reportCheckCategory);


            summaryStr=checkNameStr+"DetailedHeader";


            summary=fxptui.message(summaryStr);


            if(length(statusArr)==1)

                [hdr,msg]=obj.getDetailsFromDB(checkNameStr,statusArr{1});
                header{end+1}=hdr;
                info{end+1}=msg;
            else


                for idx=1:length(statusArr)
                    if(~strcmp(statusArr{idx},obj.PassStatus))
                        [hdr,msg]=obj.getDetailsFromDB(checkNameStr,statusArr{idx});
                        header{end+1}=hdr;
                        info{end+1}=msg;
                    end
                end
            end
            if(strcmp(checkNameStr,obj.HarwareSettingStrConstant))
                info{end+1}=obj.ReportDB.Tables.HardwareSettingParams;
            end
        end

        function[header,info]=getDetailsFromDB(obj,checkNameStr,statusStr)

            headerStr=checkNameStr+statusStr+obj.HeaderStrConstant;





            if(ismember(statusStr,obj.ReportDB.CauseRationaleKeys))

                header=obj.ReportDB.CauseRationale.(checkNameStr).(statusStr);
            else

                header=fxptui.message(headerStr);
            end


            info=obj.getDetailedDBInfo(checkNameStr,statusStr);
        end


        function results=getDetailedDBInfo(obj,checkNameStr,statusStr)



            results=table();


            tableName=checkNameStr+obj.TableStrConstant;



            if(~strcmp(statusStr,obj.PassStatus))
                results=obj.ReportDB.Tables.(tableName)(obj.ReportDB.Tables.(tableName).Status==statusStr,{'Name','UniqueID','ObjectClass'});
            end

            results=table2struct(results);
        end
    end

end

