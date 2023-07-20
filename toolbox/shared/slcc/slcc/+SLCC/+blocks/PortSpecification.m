classdef PortSpecification<handle




    properties(Access=private)
        m_BlockHandle;
        m_SSHandle;
        m_PortStruct;
        m_PortHeuristicStruct;
    end

    properties(Access=private,Constant=true)
        refreshTypeMessage=DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace');
    end

    methods(Hidden)
        function this=PortSpecification(hBlk)
            import SLCC.blocks.ui.PortSpec.*;
            this.m_BlockHandle=hBlk;
            this.m_SSHandle=Spreadsheet(this);
        end

        function updatePortStruct(this,portStruct,portHeuristicStruct)
            this.m_PortStruct=portStruct;
            this.m_PortHeuristicStruct=portHeuristicStruct;
            if~isempty(this.m_SSHandle)&&isvalid(this.m_SSHandle)
                this.m_SSHandle.updateSpreadsheet(portStruct,portHeuristicStruct);
            end
        end

        function updateStruct=getUnappliedPortUpdates(this)
            if~isempty(this.m_SSHandle)&&isvalid(this.m_SSHandle)&&...
                this.m_SSHandle.m_hasUnappliedChanges
                updateStruct=this.m_SSHandle.getUnappliedChanges();
                this.m_SSHandle.clearUnappliedChanges();
            else
                updateStruct=struct.empty;
            end
        end

        function hSS=getSSSource(this)
            import SLCC.blocks.ui.PortSpec.*;
            if isempty(this.m_SSHandle)||~isvalid(this.m_SSHandle)
                this.m_SSHandle=Spreadsheet(this);
            end
            hSS=this.m_SSHandle;
        end

        function portStruct=getPortStruct(this)
            portStruct=this.m_PortStruct;
        end
    end

    methods(Hidden,Static)
        function dtaItems=getDefaultDtaItems()
            dtaItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('NumBool');
            dtaItems.scalingModes={'UDTBinaryPointMode','UDTSlopeBiasMode'};
            dtaItems.signModes={'UDTSignedSign','UDTUnsignedSign'};

            dtaItems.allowsExpression=true;
            dtaItems.supportsBusType=true;
            dtaItems.supportsEnumType=true;
        end

        function result=parseTypeString(typeStr)
            dtaItems=SLCC.blocks.PortSpecification.getDefaultDtaItems();
            dt=Simulink.DataTypePrmWidget.parseDataTypeString(typeStr,...
            dtaItems);



            typeStrNoSpaces=strrep(typeStr,' ','');
            if strcmp(typeStrNoSpaces,'int64')
                dt=Simulink.DataTypePrmWidget.parseDataTypeString('fixdt(1,64,0)',dtaItems);
            elseif strcmp(typeStrNoSpaces,'uint64')
                dt=Simulink.DataTypePrmWidget.parseDataTypeString('fixdt(0,64,0)',dtaItems);
            end



            if dt.isBuiltin
                result.mode='built-in';
                result.type=dtaItems.builtinTypes{dt.indexBuiltin+1};
                if strcmpi(dt.fixptProps.datatypeoverride,'Inherit')
                    result.dtoMode='Inherit';
                elseif strcmpi(dt.fixptProps.datatypeoverride,'''Off''')
                    result.dtoMode='Off';
                else
                    result.dtoMode='Inherit';
                end
                result.normalizedType=result.type;
            elseif dt.isFixPt
                result.mode='fixed point';
                result.isSigned=(dt.fixptProps.signed==0);
                result.wordLength=eval(dt.fixptProps.wordLength);
                result.slope=eval(dt.fixptProps.slope);
                result.bias=eval(dt.fixptProps.bias);
                result.fractionLength=eval(dt.fixptProps.fractionLength);
                scalingModeNames={'binary point','slope and bias'};
                result.scalingMode=scalingModeNames{dt.fixptProps.scalingMode+1};
                if strcmpi(dt.fixptProps.datatypeoverride,'Inherit')
                    result.dtoMode='Inherit';
                elseif strcmpi(dt.fixptProps.datatypeoverride,'''Off''')
                    result.dtoMode='Off';
                else
                    result.dtoMode='Inherit';
                end
                if strcmp(result.scalingMode,'binary point')
                    result.normalizedType=['fixdt(',num2str(result.isSigned),','...
                    ,num2str(result.wordLength),',',num2str(result.fractionLength),')'];
                elseif strcmp(result.scalingMode,'slope and bias')
                    result.normalizedType=['fixdt(',num2str(result.isSigned),','...
                    ,num2str(result.wordLength),',',num2str(result.slope),',',num2str(result.bias),')'];
                end
            elseif dt.isEnumType
                result.mode='enum';
                result.type=dt.enumClassName;
                result.normalizedType=['Enum: ',result.type];
            elseif dt.isBusType
                result.mode='bus';
                result.type=dt.busObjectName;
                result.normalizedType=['Bus: ',result.type];
            elseif dt.isExpress
                classname=regexp(dt.str,'^[Cc]lass:\s*(.*)','tokens');
                if~isempty(classname)&&~isempty(classname{1}{1})
                    result.mode='class';
                    result.type=classname{1}{1};
                    result.normalizedType=['Class: ',result.type];
                elseif~strcmp(dt.errMsg.id,'UDTNoError')
                    result.mode='unknown';
                    result.type=dt.str;
                    result.errMsg=dt.errMsg;
                else


                    result.mode='expression';
                    result.type=dt.str;
                    result.normalizedType=result.type;
                end
            else
                result.mode='unknown';
                result.errMsg=dt.errMsg;
            end
        end

        function result=isValidTypeString(typeStr,validTypeValues)

            result=true;
            try
                typeInfo=SLCC.blocks.PortSpecification.parseTypeString(typeStr);
            catch

                result=false;
                return;
            end

            if strcmp(typeInfo.mode,"unknown")||strcmp(typeInfo.mode,"class")

                result=false;
                return;
            end


            if ismember(typeInfo.normalizedType,validTypeValues)||strcmp(typeInfo.mode,"expression")
                result=true;
                return;
            end


            TF=startsWith(validTypeValues,'fixdt(');
            if~strcmp(typeInfo.mode,"fixed point")||~any(TF)
                result=false;
                return;
            end
            fixdtType=validTypeValues(TF);
            fixdtTypeInfo=SLCC.blocks.PortSpecification.parseTypeString(fixdtType{1});
            if(fixdtTypeInfo.wordLength<typeInfo.wordLength)

                result=false;
            elseif(fixdtTypeInfo.isSigned~=typeInfo.isSigned)

                result=false;
            else
                result=true;
            end

        end
    end
end


