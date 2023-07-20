classdef ConsistencyCheckReport


    properties(Access=private)
        ConsistencyCheckLog=[];
        strBuffer='';
        Verbose=0;
    end

    methods(Access=private)
        function strBufferOutput=createConsistencyReport(obj)
            strBufferOutput='';
            for i=1:numel(obj.ConsistencyCheckLog)
                errmsg=obj.getErrorMsgAsString(i,obj.Verbose);
                if isempty(strBufferOutput)
                    strBufferOutput=errmsg;
                else
                    strBufferOutput=sprintf('%s\n%s',strBufferOutput,errmsg);
                end
            end
        end

        function errorMsg=getErrorMsgAsString(obj,index,isVerbose)
            checkId=obj.ConsistencyCheckLog(index).checkId;
            errorMsg='';
            switch checkId
            case SLCC.TypeImporter.ConsistencyCheckLogger.NONIMPORTABLE_BUS_TYPE
                errorId='Simulink:CustomCode:TypeImporterNonImportableBusType';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            case SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_BUS_TYPE
                errorId='Simulink:CustomCode:TypeImporterBusTypeImported';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                if isVerbose
                    disp(errorMsg);
                end
            case SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_BUS_TYPE
                errorId='Simulink:CustomCode:TypeImporterExistingBusType';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                if isVerbose
                    disp(errorMsg);
                end
            case SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_BUS_TYPE_NOT_A_VALID_BUS_TYPE
                errorId='Simulink:CustomCode:TypeImporterInconsistentNotValidBusType';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            case SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_BUS_TYPE_BUSELEMENT_MISMATCH
                if~isempty(obj.ConsistencyCheckLog(index).InconsistencyInfo)
                    BusElementsCheckLog=obj.ConsistencyCheckLog(index).InconsistencyInfo;
                    for i=1:numel(BusElementsCheckLog)
                        if BusElementsCheckLog(i).isNew
                            errorId='Simulink:CustomCode:TypeImporterInconsistentBusTypeNewElement';
                            tempMsg=getString(message(errorId,...
                            obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath,BusElementsCheckLog(i).ElementIndex));
                            SLCC.TypeImporter.reportWarning(errorId,tempMsg);
                        else
                            errorId='Simulink:CustomCode:TypeImporterInconsistentBusTypeElementField';
                            tempMsg=getString(message(errorId,...
                            obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath,BusElementsCheckLog(i).ElementIndex,BusElementsCheckLog(i).FieldName));
                            SLCC.TypeImporter.reportWarning(errorId,tempMsg);
                        end
                        if isempty(errorMsg)
                            errorMsg=tempMsg;
                        else
                            errorMsg=sprintf('%s\n%s',errorMsg,tempMsg);
                        end
                    end
                    errorId='Simulink:CustomCode:TypeImporterInconsistentBusType';
                    tempMsg=getString(message(errorId,...
                    obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                    SLCC.TypeImporter.reportWarning(errorId,tempMsg);
                    errorMsg=sprintf('%s\n%s',errorMsg,tempMsg);
                end
            case SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ENUM_TYPE
                errorId='Simulink:CustomCode:TypeImporterEnumTypeImported';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                if isVerbose
                    disp(errorMsg);
                end
            case SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_ENUM_TYPE
                errorId='Simulink:CustomCode:TypeImporterExistingEnumType';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                if isVerbose
                    disp(errorMsg);
                end
            case SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_ENUM_TYPE_ENUM_NAME_MISMATCH
                errorId='Simulink:CustomCode:TypeImporterInconsistentEnumTypeEnumNames';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            case SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_ENUM_TYPE_ENUM_VALUE_MISMATCH
                errorId='Simulink:CustomCode:TypeImporterInconsistentEnumTypeEnumValues';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            case SLCC.TypeImporter.ConsistencyCheckLogger.FAILED_TO_PARSE_TYPE
                errorId='Simulink:CustomCode:TypeImporterNonImportableBusType';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            case SLCC.TypeImporter.ConsistencyCheckLogger.NEWLY_IMPORTED_ALIAS_TYPE
                errorId='Simulink:CustomCode:TypeImporterAliasTypeImported';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                if isVerbose
                    disp(errorMsg);
                end
            case SLCC.TypeImporter.ConsistencyCheckLogger.EXISTING_ALIAS_TYPE
                errorId='Simulink:CustomCode:TypeImporterExistingAliasType';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                if isVerbose
                    disp(errorMsg);
                end
            case SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_ALIAS_TYPE_NOT_A_VALID_ALIAS_TYPE
                errorId='Simulink:CustomCode:TypeImporterInconsistentNotValidAliasType';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            case SLCC.TypeImporter.ConsistencyCheckLogger.INCONSISTENT_ALIAS_TYPE_BASETYPE_MISMATCH
                errorId='Simulink:CustomCode:TypeImporterInconsistentAliasType';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            case SLCC.TypeImporter.ConsistencyCheckLogger.INVALID_MATLAB_VARIABLE_NAME
                errorId='Simulink:CustomCode:TypeImporterInvalidVariableName';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            case SLCC.TypeImporter.ConsistencyCheckLogger.INVALID_FIELD_NAME
                errorId='Simulink:CustomCode:TypeImporterInvalidFieldName';
                errorMsg=getString(message(errorId,...
                obj.ConsistencyCheckLog(index).Name,obj.ConsistencyCheckLog(index).headerFilePath));
                SLCC.TypeImporter.reportWarning(errorId,errorMsg);
            otherwise
                assert(false,'should never be here!')
            end
        end

    end

    methods

        function obj=ConsistencyCheckReport(consistencyCheckLogger,verbose)
            obj.ConsistencyCheckLog=consistencyCheckLogger.checkConsistencyInfo;
            obj.Verbose=verbose;
            obj.strBuffer=obj.createConsistencyReport();
        end

        function strBuffer=getReport(obj)
            strBuffer=obj.strBuffer;
        end
    end

end
