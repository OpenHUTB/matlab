


classdef SpreadsheetRow<handle
    properties(SetAccess=private,GetAccess=public)
        m_SSParent;
        m_DialogSource;
        m_ArgName;
        m_PortName;
        m_Scope;
        m_Index;
        m_Type;
        m_Size;
        m_IsGlobal=false;
        m_ScopeEditable;
        m_TypeEditable;
        m_SizeEditable;
        m_ValidTypeValues;
        m_ValidScopeValues;
    end

    properties(Access=private,Constant=true)
        argNameColumn=DAStudio.message('Simulink:CustomCode:PortSpec_ArgName');
        portNameColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Label');
        scopeColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Scope');
        indexColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Index');
        typeColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Type');
        sizeColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Size');
        refreshTypeMessage=DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace');
    end

    methods(Static)
        function obj=constructFromPortStruct(ssParent,portStruct,portHeuristicStruct)
            import SLCC.blocks.ui.PortSpec.*;
            portIdxStr=num2str(portStruct.Index);
            portSizeStr=portStruct.Size;

            try
                obj=SpreadsheetRow(ssParent,portStruct.ArgName,...
                portStruct.PortName,...
                portStruct.Scope,...
                portIdxStr,...
                portStruct.Type,...
                portSizeStr,...
                portStruct.IsGlobal,...
                portHeuristicStruct.isScopeEditable,...
                portHeuristicStruct.isTypeEditable,...
                portHeuristicStruct.isSizeEditable,...
                portHeuristicStruct.validTypeValues,...
                portHeuristicStruct.validScopeValues);
            catch
                obj=[];
            end
        end
    end

    methods(Access=private)
        function this=SpreadsheetRow(ssParent,argName,portName,...
            portScope,portIdx,inType,inSize,isGlobal,scopeEditable,...
            typeEditable,sizeEditable,validTypeValues,validScopeValues)
            this.m_SSParent=ssParent;
            this.m_DialogSource=ssParent.m_DialogSource;
            this.m_ArgName=argName;
            this.m_PortName=portName;
            this.m_Scope=portScope;
            this.m_Index=portIdx;
            this.m_Type=inType;
            this.m_Size=inSize;
            this.m_IsGlobal=isGlobal;

            this.m_ScopeEditable=scopeEditable;
            this.m_TypeEditable=typeEditable;
            this.m_SizeEditable=sizeEditable;
            this.m_ValidTypeValues=validTypeValues;
            this.m_ValidScopeValues=validScopeValues;
        end
    end


    methods
        function[bIsValid]=isValidProperty(this,aPropName)
            switch(aPropName)
            case{this.argNameColumn,this.portNameColumn,...
                this.scopeColumn,this.indexColumn,...
                this.typeColumn,this.sizeColumn}
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function[bIsReadOnly]=isReadonlyProperty(this,aPropName)
            switch(aPropName)
            case{this.argNameColumn}
                bIsReadOnly=true;
            case{this.scopeColumn}
                bIsReadOnly=~this.m_ScopeEditable;
            case{this.indexColumn}
                bIsReadOnly=true;
            case{this.typeColumn}
                bIsReadOnly=~this.m_TypeEditable;
            case{this.sizeColumn}
                bIsReadOnly=~this.m_SizeEditable;
            otherwise
                bIsReadOnly=false;
            end
        end

        function[bIsEditable]=isEditableProperty(this,aPropName)
            bIsEditable=~this.isReadonlyProperty(aPropName);
        end

        function[aPropValue]=getPropValue(this,aPropName)
            switch(aPropName)
            case this.argNameColumn
                aPropValue=this.m_ArgName;
            case this.portNameColumn
                aPropValue=this.m_PortName;
            case this.scopeColumn
                aPropValue=this.m_Scope;
            case this.indexColumn
                aPropValue=this.m_Index;
            case this.typeColumn
                aPropValue=this.m_Type;
            case this.sizeColumn
                aPropValue=this.m_Size;
            otherwise
                aPropValue='';
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            shouldNotifyParent=true;
            switch(aPropName)
            case this.argNameColumn
                this.m_ArgName=aPropValue;
            case this.portNameColumn
                this.m_PortName=aPropValue;
            case this.scopeColumn
                this.m_Scope=aPropValue;
            case this.indexColumn
                this.m_Index=aPropValue;
            case this.typeColumn
                shouldNotifyParent=this.setArgType(aPropValue);
            case this.sizeColumn
                this.m_Size=aPropValue;
            otherwise
                shouldNotifyParent=false;
            end

            if shouldNotifyParent
                this.m_SSParent.notifyRowChange(this);
            end
        end

        function[aPropType]=getPropDataType(this,aPropName)
            switch(aPropName)
            case{this.scopeColumn}
                aPropType='enum';
            otherwise
                aPropType='string';
            end
        end

        function[allowValues]=getPropAllowedValues(this,aPropName)
            switch(aPropName)
            case{this.scopeColumn}
                allowValues=this.m_ValidScopeValues;
            case{this.typeColumn}
                allowValues=this.getTypeSelections();
            otherwise
                allowValues={};
            end
        end

        function getPropertyStyle(this,aPropName,aStyle)
            switch(aPropName)
            case this.argNameColumn
                if(this.m_IsGlobal)



                    aStyle.Bold=true;
                    if isequal(this.m_Scope,'Input')
                        aStyle.Tooltip=DAStudio.message('Simulink:CustomCode:GlobalInputTooltip');
                    elseif isequal(this.m_Scope,'Output')
                        aStyle.Tooltip=DAStudio.message('Simulink:CustomCode:GlobalOutputTooltip');
                    elseif isequal(this.m_Scope,'InputOutput')
                        aStyle.Tooltip=DAStudio.message('Simulink:CustomCode:GlobalInputOutputTooltip');
                    else

                        aStyle.Tooltip=DAStudio.message('Simulink:CustomCode:GlobalNonInterfaceTooltip');
                    end

                end
            end
        end
    end


    methods
        function dataStruct=getDataStruct(this)
            dataStruct=...
            struct('ArgName',this.m_ArgName,'PortName',this.m_PortName,...
            'Scope',this.m_Scope,'Index',this.m_Index,...
            'Type',this.m_Type,'Size',this.m_Size,...
            'IsGlobal',this.m_IsGlobal);
        end

        function typeSelections=getTypeSelections(this)
            typeSelections=this.m_ValidTypeValues;
        end

        function refreshFromPortStruct(this,portStruct,portHeuristicStruct)
            this.m_ArgName=portStruct.ArgName;
            this.m_PortName=portStruct.PortName;
            this.m_Scope=portStruct.Scope;
            this.m_Index=num2str(portStruct.Index);
            this.m_Type=portStruct.Type;
            this.m_Size=portStruct.Size;
            this.m_IsGlobal=portStruct.IsGlobal;
            this.m_ScopeEditable=portHeuristicStruct.isScopeEditable;
            this.m_TypeEditable=portHeuristicStruct.isTypeEditable;
            this.m_SizeEditable=portHeuristicStruct.isSizeEditable;
            this.m_ValidTypeValues=portHeuristicStruct.validTypeValues;
            this.m_ValidScopeValues=portHeuristicStruct.validScopeValues;
        end

        function dataStr=getAsString(this)
            delimiter=char(9);
            dataStr=strjoin({this.m_ArgName,this.m_PortName,this.m_Scope,...
            this.m_Index,this.m_Type,this.m_Size},...
            delimiter);
        end

        function result=setArgType(this,typeStr)
            isValidType=SLCC.blocks.PortSpecification.isValidTypeString(typeStr,this.m_ValidTypeValues);
            if~isValidType
                errorId='Simulink:CustomCode:CCallerInvalidArgumentType';
                errorMsg=DAStudio.message(errorId,typeStr,this.m_ArgName);
                dlgTitle='Error';
                hf=errordlg(errorMsg,dlgTitle);
                set(hf,'tag','C Caller Type Error Dialog');
                result=false;
                return;
            end
            this.m_Type=typeStr;
            result=true;
        end

    end
end


