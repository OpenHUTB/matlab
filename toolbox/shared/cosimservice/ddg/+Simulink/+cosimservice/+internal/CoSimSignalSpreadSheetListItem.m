classdef(Hidden=true)CoSimSignalSpreadSheetListItem<handle&matlab.mixin.Heterogeneous
    properties
        dlgSource=[]
        spreadsheetSource=[]
portIdx
portHandle
portType
        portConfig=[]
        inputConfig=[]

        ColumnHeaders={DAStudio.message('CoSimService:PortConfig:ConfigDialogColumnPort'),...
        DAStudio.message('CoSimService:PortConfig:ConfigDialogColumnContinuousQuantity'),...
        DAStudio.message('CoSimService:PortConfig:ConfigDialogColumnRequestCompensation')};

    end

    methods

        function obj=CoSimSignalSpreadSheetListItem(dlgSource,spreadsheetSource,portIdx,portHandle,portType)
            obj.dlgSource=dlgSource;
            obj.spreadsheetSource=spreadsheetSource;
            obj.portIdx=portIdx;
            obj.portHandle=portHandle;
            obj.portType=portType;
            obj.portConfig=spreadsheetSource.getPortCoSimSignalConfiguration(portHandle);
            if strcmp(portType,'input')
                obj.inputConfig=spreadsheetSource.getInportCoSimSignalConfiguration(portHandle);
            end

        end


        function propValue=getPropValue(obj,propName)
            switch propName
            case obj.ColumnHeaders{1}
                propValue=num2str(obj.portIdx);
            case obj.ColumnHeaders{2}
                if strcmp(obj.portConfig.isContinuousQuantity,'on')
                    propValue=DAStudio.message('CoSimService:PortConfig:ConfigDialogYes');
                else
                    propValue=DAStudio.message('CoSimService:PortConfig:ConfigDialogNo');
                end
            case obj.ColumnHeaders{3}
                if isempty(obj.inputConfig)
                    propValue='--';
                else




                    switch(obj.inputConfig.requestCompensation)
                    case{'Auto'}
                        propValue=DAStudio.message('CoSimService:PortConfig:ConfigDialogAuto');
                    case{'Always'}
                        propValue=DAStudio.message('CoSimService:PortConfig:ConfigDialogAlways');
                    case{'Auto_Off','Always_Off'}
                        propValue=DAStudio.message('CoSimService:PortConfig:ConfigDialogOff');
                    end
                end
            otherwise
                warning('unexpected propName');
            end
        end


        function propType=getPropDataType(obj,propName)
            switch propName
            case obj.ColumnHeaders{3}
                propType='enum';
            otherwise
                propType='string';
            end
        end


        function getPropertyStyle(obj,propName,propertyStyle)
            switch propName

            case obj.ColumnHeaders{1}
                return;
            case obj.ColumnHeaders{2}
                if strcmp(obj.portConfig.isContinuousQuantity,'on')
                    propertyStyle.Tooltip=DAStudio.message('CoSimService:PortConfig:ConfigDialogTooltipIsContinuousQuantity');
                else
                    propertyStyle.Tooltip=DAStudio.message('CoSimService:PortConfig:ConfigDialogTooltipNotContinuousQuantity');
                end
            case obj.ColumnHeaders{3}
                if isempty(obj.inputConfig)
                    return;
                else
                    switch(obj.inputConfig.requestCompensation)
                    case{'Auto'}
                        propertyStyle.Tooltip=DAStudio.message('CoSimService:PortConfig:ConfigDialogTooltipCompensationAuto');
                    case{'Always'}
                        propertyStyle.Tooltip=DAStudio.message('CoSimService:PortConfig:ConfigDialogTooltipCompensationAlways');
                    case{'Auto_Off','Always_Off'}
                        if strcmp(obj.inputConfig.canInsertSignalCouplingElement,'on')
                            propertyStyle.Tooltip=DAStudio.message('CoSimService:PortConfig:ConfigDialogTooltipCompensationOffEligible');
                        else
                            propertyStyle.Tooltip=DAStudio.message('CoSimService:PortConfig:ConfigDialogTooltipCompensationOffNotEligible');
                        end
                    end
                end
            otherwise
                warning('unexpected propName');
            end
        end


        function propVal=getPropAllowedValues(obj,propName)
            switch propName
            case obj.ColumnHeaders{3}
                propVal={DAStudio.message('CoSimService:PortConfig:ConfigDialogAuto'),...
                DAStudio.message('CoSimService:PortConfig:ConfigDialogAlways'),...
                DAStudio.message('CoSimService:PortConfig:ConfigDialogOff')};
            otherwise
                warning('Unexpected propName for combobox');
            end
        end


        function isHier=isHierarchical(~)
            isHier=false;
        end


        function isReadOnly=isReadonlyProperty(obj,propName)
            switch propName
            case{obj.ColumnHeaders{1},obj.ColumnHeaders{2}}
                isReadOnly=true;
            otherwise
                isReadOnly=false;
            end
        end


        function isValid=isValidProperty(obj,propName)
            switch propName
            case{obj.ColumnHeaders{1},obj.ColumnHeaders{2},obj.ColumnHeaders{3}}
                isValid=true;
            otherwise
                isValid=true;
            end
        end



        function setPropValue(obj,propName,propValue)
            switch propName
            case obj.ColumnHeaders{3}





                if strcmp(propValue,DAStudio.message('CoSimService:PortConfig:ConfigDialogAuto'))
                    obj.inputConfig.requestCompensation='Auto';
                elseif strcmp(propValue,DAStudio.message('CoSimService:PortConfig:ConfigDialogAlways'))
                    obj.inputConfig.requestCompensation='Always';
                elseif strcmp(propValue,DAStudio.message('CoSimService:PortConfig:ConfigDialogOff'))
                    obj.inputConfig.requestCompensation='Always_Off';
                else
                    assert(false,'Unexpected value for compensation mode');
                end
                obj.spreadsheetSource.updateInputAdvanceButtonState(obj.dlgSource.dialog);
            otherwise
                assert(false,'Invalid propValue set');
            end
        end
    end
end

