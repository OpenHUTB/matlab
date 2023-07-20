


classdef CScriptPortSSRow<handle
    properties(SetAccess=private,GetAccess=public)
        m_SSParent;
        m_ArgName;
        m_Scope;
        m_Label;
        m_Index;
        m_Type;
        m_Size;
        m_NameEditable;
        m_ScopeEditable;
        m_LabelEditable;
        m_TypeEditable;
        m_SizeEditable;
        m_IndexEditable;
        m_ValidTypeValues;
        m_ValidScopeValues;
        m_ValidIndexValues;
    end

    properties(Access=private,Constant=true)
        argNameColumn=DAStudio.message('Simulink:CustomCode:PortSpec_ArgName');
        labelColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Label');
        scopeColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Scope');
        indexColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Index');
        typeColumn=DAStudio.message('Simulink:CustomCode:PortSpec_Type');
        sizeColumn=DAStudio.message('Simulink:CustomCode:CSPortSpec_Size');
        refreshTypeMessage=DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace');
    end

    methods(Static)
        function obj=constructFromPortStruct(ssParent,portStruct,portHeuristicStruct)
            import SLCC.blocks.ui.PortSpec.*;
            portIdxStr=num2str(portStruct.PortNumber);
            portSizeStr=portStruct.Size;

            try
                obj=CScriptPortSSRow(ssParent,portStruct.Name,...
                portStruct.Scope,...
                portStruct.Label,...
                portIdxStr,...
                portStruct.Type,...
                portSizeStr,...
                portHeuristicStruct.isNameEditable,...
                portHeuristicStruct.isScopeEditable,...
                portHeuristicStruct.isLabelEditable,...
                portHeuristicStruct.isTypeEditable,...
                portHeuristicStruct.isSizeEditable,...
                portHeuristicStruct.isIndexEditable,...
                portHeuristicStruct.validTypeValues,...
                portHeuristicStruct.validScopeValues,...
                portHeuristicStruct.validIndexValues);
            catch
                obj=[];
            end
        end
    end

    methods(Access=private)
        function this=CScriptPortSSRow(ssParent,argName,...
            portScope,label,portIdx,inType,inSize,nameEditable,...
            scopeEditable,labelEditable,typeEditable,sizeEditable,indexEditable,...
            validTypeValues,validScopeValues,validIndexValues)
            this.m_SSParent=ssParent;
            this.m_ArgName=argName;
            this.m_Scope=portScope;
            this.m_Label=this.updateLabelOnUI(portScope,label);
            this.m_Index=this.updatePortValueOnUI(portScope,portIdx);
            this.m_Type=inType;
            this.m_Size=inSize;

            this.m_NameEditable=nameEditable;
            this.m_ScopeEditable=scopeEditable;
            this.m_LabelEditable=labelEditable;
            this.m_TypeEditable=typeEditable;
            this.m_SizeEditable=sizeEditable;
            this.m_IndexEditable=indexEditable;
            this.m_ValidTypeValues=validTypeValues;
            this.m_ValidScopeValues=validScopeValues;
            this.m_ValidIndexValues=validIndexValues;
        end
    end


    methods
        function[bIsValid]=isValidProperty(this,aPropName)
            switch(aPropName)
            case{this.argNameColumn,this.labelColumn,...
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
                bIsReadOnly=~this.m_NameEditable;
            case{this.scopeColumn}
                bIsReadOnly=~this.m_ScopeEditable;
            case{this.labelColumn}
                bIsReadOnly=~this.m_LabelEditable;
            case{this.indexColumn}
                bIsReadOnly=~this.m_IndexEditable;
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
            case this.scopeColumn
                aPropValue=this.m_Scope;
            case this.labelColumn
                aPropValue=this.m_Label;
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
            block=this.m_SSParent.m_DialogSource.getBlock();
            obj=get_param(block.Handle,'SymbolSpec');
            try
                switch(aPropName)
                case this.argNameColumn
                    obj.getSymbol(this.m_ArgName).Name=aPropValue;
                case this.scopeColumn
                    obj.getSymbol(this.m_ArgName).Scope=aPropValue;
                case this.labelColumn
                    obj.getSymbol(this.m_ArgName).Label=aPropValue;
                case this.indexColumn
                    obj.getSymbol(this.m_ArgName).PortNumber=str2num(aPropValue);
                case this.typeColumn
                    obj.getSymbol(this.m_ArgName).Type=aPropValue;
                case this.sizeColumn
                    obj.getSymbol(this.m_ArgName).Size=aPropValue;
                otherwise
                    error(['Internal error: ',aPropName,' is not a valid field name of the port specification table.']);
                end
            catch ME
                dlgTitle='Error';

                hf=errordlg(regexprep(ME.message,'<a\s+href=".*">(.*)</a>','$1'),dlgTitle);
                set(hf,'tag','C Function Error Dialog');
                setappdata(hf,'MException',ME);
            end
        end

        function[aPropType]=getPropDataType(this,aPropName)
            switch(aPropName)
            case{this.scopeColumn}
                aPropType='enum';
            case{this.indexColumn}
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
            case{this.indexColumn}
                allowValues=this.m_ValidIndexValues;
            otherwise
                allowValues={};
            end
        end
    end


    methods
        function dataStruct=getDataStruct(this)
            dataStruct=...
            struct('ArgName',this.m_ArgName,...
            'Scope',this.m_Scope,...
            'Label',this.m_Label,...
            'Index',this.m_Index,...
            'Type',this.m_Type,...
            'Size',this.m_Size);
        end

        function typeSelections=getTypeSelections(this)
            typeSelections=this.m_ValidTypeValues;
        end

        function refreshFromPortStruct(this,portStruct,portHeuristicStruct)
            this.m_ArgName=portStruct.Name;
            this.m_Scope=portStruct.Scope;
            this.m_Label=this.updateLabelOnUI(portStruct.Scope,portStruct.Label);
            this.m_Index=this.updatePortValueOnUI(portStruct.Scope,num2str(portStruct.PortNumber));
            this.m_Type=portStruct.Type;
            this.m_Size=portStruct.Size;
            this.m_NameEditable=portHeuristicStruct.isNameEditable;
            this.m_ScopeEditable=portHeuristicStruct.isScopeEditable;
            this.m_LabelEditable=portHeuristicStruct.isLabelEditable;
            this.m_TypeEditable=portHeuristicStruct.isTypeEditable;
            this.m_SizeEditable=portHeuristicStruct.isSizeEditable;
            this.m_IndexEditable=portHeuristicStruct.isIndexEditable;
            this.m_ValidTypeValues=portHeuristicStruct.validTypeValues;
            this.m_ValidScopeValues=portHeuristicStruct.validScopeValues;
            this.m_ValidIndexValues=portHeuristicStruct.validIndexValues;
        end

        function refreshCellOnPortStruct(this,aChangeValue,method)
            switch(method)
            case{'SetSymbolName'}
                this.m_ArgName=aChangeValue;
            case{'SetSymbolSize'}
                this.m_Size=aChangeValue;
            case{'SetSymbolLabel'}
                this.m_Label=aChangeValue;
            case{'SetSymbolType'}
                this.m_Type=aChangeValue;
            case{'AddSymbol'}
                this.m_ValidIndexValues=aChangeValue;
            case{'SetSizeEditable'}
                this.m_SizeEditable=aChangeValue;
            otherwise
                error([method,' is not supported for cell refresh.']);
            end
        end

        function portIdxStr=updatePortValueOnUI(this,portScope,portIdx)
            switch(portScope)
            case{'Persistent','Constant'}
                portIdxStr='-';
            case{'Input','Output','InputOutput','Parameter'}
                portIdxStr=portIdx;
            otherwise
                error([portScope,' is not a valid scope name.']);
            end
        end

        function portLabelStr=updateLabelOnUI(this,portScope,portLabel)%#ok<*INUSL>
            switch(portScope)
            case{'Persistent'}
                portLabelStr='-';
            case{'Input','Output','InputOutput','Parameter','Constant'}
                portLabelStr=portLabel;
            otherwise
                error([portScope,' is not a valid scope name.']);
            end
        end
    end
end


