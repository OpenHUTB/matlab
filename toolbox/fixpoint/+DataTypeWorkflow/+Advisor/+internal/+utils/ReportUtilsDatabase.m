classdef ReportUtilsDatabase<handle





    properties(SetAccess=private,GetAccess=public)
        CheckList={}
        Tables={}
        CauseRationale={}
    end

    properties(Constant)
        NumDiagnosticChecks=3;
        TableStrConstant="Table";
        HeaderStrConstant="Header";
        GenerateStrConstant="generate";
        CauseRationaleKeys=["WarnWithoutChange","FailWithoutChange"];
    end

    methods


        function setCheckList(obj,input)
            obj.CheckList=input;
        end

        function setCauseRationale(obj,check,status,value)
            obj.CauseRationale.(check).(status)=value;
        end


        function parseReport(obj,report,type)

            obj.populateCheckListWithRestore(type);


            obj.initializeTables(obj.CheckList);


            obj.initializeCauseRationale(obj.CheckList);


            obj.populateTableData(report,obj.CheckList);
        end

        function populateCheckListWithRestore(obj,type)

            if(type)

                obj.setCheckList({'RestorePoint','HardwareSetting','DiagnosticSetting','UnsupportedConstruct','DesignRange','SUDBoundary'});
            else

                obj.setCheckList({'RestorePoint','HardwareSetting','DiagnosticSetting','UnsupportedConstruct','SUDBoundary'});
            end
        end

        function initializeTables(obj,checkList)

            for idx=1:length(checkList)
                tableName=checkList{idx}+obj.TableStrConstant;
                obj.Tables.(tableName)=table();
            end
        end

        function initializeCauseRationale(obj,checkList)

            for idx=1:length(checkList)
                for k=1:length(obj.CauseRationaleKeys)
                    obj.CauseRationale.(checkList{idx}).(obj.CauseRationaleKeys{k})='';
                end
            end
        end

        function populateTableData(obj,report,checkList)
            for idx=1:length(checkList)

                checkResults=report.(checkList{idx});


                generateStr=obj.GenerateStrConstant+checkList{idx}+obj.TableStrConstant;


                obj.(generateStr)(checkResults,checkList{idx});
            end
        end

        function addCauseRationale(obj,checkStr,statusStr,checkResult)

            if(~isempty(checkResult.Causes)&&isempty(obj.CauseRationale.(checkStr).(statusStr)))
                obj.CauseRationale.(checkStr).(statusStr)=checkResult.Causes.getRationale();
            end
        end



        function generateUnsupportedConstructTable(obj,checkResults,checkStr)

            obj.Tables.UnsupportedConstructTable=table();



            for idx=1:length(checkResults)
                status=checkResults{idx}.Status;






                if(status==DataTypeWorkflow.Advisor.CheckStatus.PassWithChange)
                    blockNameStr=string(checkResults{idx}.AfterValue);
                else
                    blockNameStr=string(checkResults{idx}.BeforeValue);
                end

                statusStr=string(status);



                obj.addCauseRationale(checkStr,statusStr,checkResults{idx});

                [uniqueIDStr,objectClass]=fxptds.Utils.getIDClass(blockNameStr);
                obj.Tables.UnsupportedConstructTable=[obj.Tables.UnsupportedConstructTable;{blockNameStr,statusStr,uniqueIDStr,objectClass}];
            end


            obj.Tables.UnsupportedConstructTable.Properties.VariableNames={'Name';'Status';'UniqueID';'ObjectClass'};
        end

        function generateHardwareSettingTable(obj,checkResults,checkStr)

            obj.Tables.HardwareSettingTable=table();



            for idx=1:length(checkResults)
                modelNameStr=string(checkResults{idx}.entry);
                status=checkResults{idx}.Status;
                statusStr=string(status);



                obj.addCauseRationale(checkStr,statusStr,checkResults{idx});

                [uniqueIDStr,objectClass]=fxptds.Utils.getIDClass(modelNameStr);
                obj.Tables.HardwareSettingTable=[obj.Tables.HardwareSettingTable;{modelNameStr,statusStr,uniqueIDStr,objectClass}];
                if(~strcmp(checkResults{idx}.BeforeValue,''))
                    obj.Tables.HardwareSettingParams=checkResults{idx}.BeforeValue;
                end

            end


            obj.Tables.HardwareSettingTable.Properties.VariableNames={'Name';'Status';'UniqueID';'ObjectClass'};
        end

        function generateDiagnosticSettingTable(obj,checkResults,checkStr)

            obj.Tables.DiagnosticSettingTable=table();



            for idx=1:obj.NumDiagnosticChecks:length(checkResults)
                modelNameStr=string(checkResults{idx}.entry);
                status=checkResults{idx}.Status;
                statusStr=string(status);



                obj.addCauseRationale(checkStr,statusStr,checkResults{idx});

                [uniqueIDStr,objectClass]=fxptds.Utils.getIDClass(modelNameStr);
                obj.Tables.DiagnosticSettingTable=[obj.Tables.DiagnosticSettingTable;{modelNameStr,statusStr,uniqueIDStr,objectClass}];
            end


            obj.Tables.DiagnosticSettingTable.Properties.VariableNames={'Name';'Status';'UniqueID';'ObjectClass'};
        end

        function generateSUDBoundaryTable(obj,checkResults,checkStr)

            obj.Tables.SUDBoundaryTable=table();




            if(isempty(checkResults))
                return;
            end



            for idx=1:length(checkResults)
                blockNameStr=string(checkResults{idx}.BeforeValue);
                status=checkResults{idx}.Status;
                statusStr=string(status);



                obj.addCauseRationale(checkStr,statusStr,checkResults{idx});

                [uniqueIDStr,objectClass]=fxptds.Utils.getIDClass(blockNameStr);
                obj.Tables.SUDBoundaryTable=[obj.Tables.SUDBoundaryTable;{blockNameStr,statusStr,uniqueIDStr,objectClass}];
            end


            obj.Tables.SUDBoundaryTable.Properties.VariableNames={'Name';'Status';'UniqueID';'ObjectClass'};
        end

        function generateDesignRangeTable(obj,checkResults,checkStr)

            obj.Tables.DesignRangeTable=table();




            if(isempty(checkResults))
                return;
            end



            for idx=1:length(checkResults)
                blockNameStr=checkResults{idx}.entry;
                status=checkResults{idx}.Status;
                statusStr=string(status);



                obj.addCauseRationale(checkStr,statusStr,checkResults{idx});

                [uniqueIDStr,objectClass]=fxptds.Utils.getIDClass(blockNameStr);
                obj.Tables.DesignRangeTable=[obj.Tables.DesignRangeTable;{blockNameStr,statusStr,uniqueIDStr,objectClass}];
            end


            obj.Tables.DesignRangeTable.Properties.VariableNames={'Name';'Status';'UniqueID';'ObjectClass'};
        end
        function generateRestorePointTable(obj,checkResults,checkStr)

            obj.Tables.RestorePointTable=table();




            if(isempty(checkResults))
                return;
            end




            for idx=1:numel(checkResults)
                modelNameStr=checkResults{idx}.entry;
                status=checkResults{idx}.Status;
                statusStr=string(status);

                fileNameStr=string(checkResults{idx}.BeforeValue);



                obj.addCauseRationale(checkStr,statusStr,checkResults{idx});

                [uniqueIDStr,objectClass]=fxptds.Utils.getIDClass(modelNameStr);
                obj.Tables.RestorePointTable=[obj.Tables.RestorePointTable;{fileNameStr,statusStr,uniqueIDStr,objectClass}];
            end

            obj.Tables.RestorePointTable.Properties.VariableNames={'Name';'Status';'UniqueID';'ObjectClass'};
        end
    end
end


