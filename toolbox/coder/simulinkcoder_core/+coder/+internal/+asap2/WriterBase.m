classdef WriterBase<handle









    properties(Access=private)
        Data;
    end

    properties(Access=protected)
        FormatContentsObj;
        CustomizeASAP2;
    end

    methods(Abstract,Access=public)
        getByteOrder(this);
        writeDimension(this);
        writeLayoutForMultiDimArray(this);
        writeByteOrderMark(this);
        writeCoeffsInCompuMethods(this);
        writeCalibrationAccess(this);
    end

    methods(Access=public)



        function this=WriterBase(data)
            this.Data=data;
        end




        function write(this,Version,fullFilePath,varargin)
            systemTargetFile='';
            modelVersion='';
            includeComments=true;
            toggleArrayLayout=char.empty;


            maxEcuAddressExtension=intmax('int16');
            minEcuAddressExtension=intmin('int16');
            ecuAddressExtension=32768;

            argCount=length(varargin);
            if argCount>=1
                systemTargetFile=varargin{1};
            end
            if argCount>=2
                modelVersion=varargin{2};
            end
            if argCount>=4
                includeComments=varargin{3};
                includeCustomization=varargin{4};
            end
            if argCount>=5
                includeAllRecordLayouts=varargin{5};
            end

            if argCount>=6
                ecuAddressExtension=varargin{6};
            end

            if argCount>=7
                toggleArrayLayout=varargin{7};
            end

            if toggleArrayLayout
                if strcmp(this.Data.ArrayLayout,'ROW_DIR')
                    arrayLayout='COLUMN_DIR';
                else
                    arrayLayout='ROW_DIR';
                end
            else
                arrayLayout=this.Data.ArrayLayout;
            end
            if~strcmp(this.Data.ArrayLayout,arrayLayout)
                swap=true;
            else
                swap=false;
            end
            if includeComments
                this.FormatContentsObj=coder.internal.asap2.FormatContentsWithComments(fullFilePath);
            else
                this.FormatContentsObj=coder.internal.asap2.FormatContentsWithoutComments(fullFilePath);
            end
            this.writeByteOrderMark();
            slVersionObj=simulink_version;
            slVersion=string(slVersionObj.version);
            timeFormat=datestr(now,'ddd mmm dd HH:MM:SS yyyy');
            if this.Data.IsCppInterface
                sourceCodeLanguage=[' * C++ source code generated on : ',timeFormat];
            else
                sourceCodeLanguage=[' * C source code generated on : ',timeFormat];
            end
            if~isempty(coder.internal.watermark)
                watermark=emit(coder.internal.watermark,' * ');
            end
            this.CustomizeASAP2.ASAP2FileName=[this.Data.ModelName,'.a2l'];
            if isempty(includeCustomization)
                this.CustomizeASAP2=coder.asap2.UserCustomizeBase;

            else
                this.CustomizeASAP2=includeCustomization;
            end
            this.CustomizeASAP2.Header=sprintf([' *\n',...
            '',watermark,newline,...
            ' *',newline,...
            ' * Code generation for model "',this.Data.ModelName,'".',newline,...
            ' *',newline,...
            ' * Model version              : ',modelVersion,newline,...
            ' * Simulink Coder version : ',char(slVersion),' ',slVersionObj.release,newline,...
            sourceCodeLanguage,newline,...
            ' *',newline,...
            ' * Target selection: ',systemTargetFile,newline,...
            ' * Embedded hardware selection: ',this.Data.HWDeviceType,newline,...
            ' * Code generation objectives: Unspecified',newline,...
            ' * Validation result: Not run',newline,...
            ' *',newline,...
            ' * (add additional file header information here)\n',...
            ' *',newline]);
            if isempty(this.CustomizeASAP2.ByteOrder)
                if(strcmp(this.Data.Endianess,'LittleEndian'))
                    this.CustomizeASAP2.ByteOrder='BYTE_ORDER     MSB_LAST';
                elseif(strcmp(this.Data.Endianess,'BigEndian'))
                    this.CustomizeASAP2.ByteOrder='BYTE_ORDER     MSB_FIRST';
                else
                    this.CustomizeASAP2.ByteOrder=this.getByteOrder();
                end
            end
            if isempty(this.CustomizeASAP2.ASAP2FileName)
                this.CustomizeASAP2.ASAP2FileName=[this.Data.ModelName,'.a2l'];
            end
            this.CustomizeASAP2.Alignment=this.getAlignment();

            ASAP2NumberFormat='%0.6';

            this.FormatContentsObj.wLine(this.CustomizeASAP2.writeFileHead);
            version=strsplit(Version,'.');
            this.FormatContentsObj.writeAppend(['ASAP2_VERSION  ',version{1},' ',version{2}],['     /* Version ',version{1},'.',version{2},' */']);
            this.FormatContentsObj.wLine('');
            this.FormatContentsObj.wLine(['/begin PROJECT ',this.CustomizeASAP2.ProjectName,' "',this.CustomizeASAP2.ProjectComment,'"']);
            if~isempty(this.CustomizeASAP2.AfterBeginProjectContents)
                this.FormatContentsObj.wLine(coder.asap2.UserCustomizeBase.readjustText(this.CustomizeASAP2.AfterBeginProjectContents,'  '));
            end
            this.FormatContentsObj.wLine('');

            this.FormatContentsObj.wLine(this.CustomizeASAP2.writeHeader);
            this.FormatContentsObj.wLine('');
            this.FormatContentsObj.wLine(['  /begin MODULE ',this.CustomizeASAP2.ModuleName,'  "',this.CustomizeASAP2.ModuleComment,'"']);
            if~isempty(this.CustomizeASAP2.AfterBeginModuleContents)
                this.FormatContentsObj.wLine(coder.asap2.UserCustomizeBase.readjustText(this.CustomizeASAP2.AfterBeginModuleContents,'    '));
            end
            if~isempty(this.CustomizeASAP2.AddA2MLSection)
                this.FormatContentsObj.wLine(coder.asap2.UserCustomizeBase.readjustText(this.CustomizeASAP2.AddA2MLSection,'    '));
            end
            if~isempty(this.CustomizeASAP2.AddIFDataSection)
                this.FormatContentsObj.wLine(coder.asap2.UserCustomizeBase.readjustText(this.CustomizeASAP2.AddIFDataSection,'    '));
            end
            this.FormatContentsObj.wLine('');

            this.FormatContentsObj.wLine(this.CustomizeASAP2.writeHardwareInterface);
            paramKeys=this.Data.ParametersMap.keys;
            removeFromGroup={};

            for ii=1:length(paramKeys)
                maxDiff='0';
                optionalParams=containers.Map;
                comparisonQuantity=string();
                transpose=false;


                paramValue=this.Data.ParametersMap(paramKeys{ii});
                if paramValue.Export

                    calibrationAccessValue=paramValue.CalibrationAccess;

                    if~isempty(calibrationAccessValue)...
                        &&strcmp(calibrationAccessValue,'NoCalibration')
                        optionalParams('CALIBRATION_ACCESS')='NO_CALIBRATION';
                    end
                    if~strcmp(paramValue.DisplayIdentifier,"")
                        optionalParams('DISPLAY_IDENTIFIER')=['',paramValue.DisplayIdentifier,''];
                    end
                    if~strcmp(paramValue.Format,"")
                        optionalParams('FORMAT')=['"',paramValue.Format,'"'];
                    end
                    if~isempty(paramValue.BitMask)
                        optionalParams('BIT_MASK')=['',paramValue.BitMask,''];
                    end


                    isLookup=isfield(paramValue,'AxisInfo')...
                    ||(isa(paramValue,'coder.asap2.Characteristic')&&...
                    numel(paramValue.AxisInfo)>0);
                    if isa(paramValue,'coder.asap2.Characteristic')
                        if isLookup
                            comparisonQuantity=paramValue.ComparisonQuantity;
                            transpose=paramValue.Transpose&&~paramValue.IsTransposed;
                            axisInfoForStdAxis=paramValue.AxisInfo;
                            if paramValue.ForceShared&&all(strcmp({axisInfoForStdAxis.AxisType},'STD_AXIS'))


                                valuesForRecLayout=this.Data.LookUpTableRecordLayoutMap(paramValue.RecordLayout);

                                [axisInfoForStdAxis.AxisType]=deal('COM_AXIS');
                                axisPtsForCom=coder.asap2.AxisInfo;
                                paramValue.AxisInfo=coder.asap2.AxisInfo;


                                recordLayoutForTable=['Record_',valuesForRecLayout.tDataType];
                                if~this.Data.RecordLayoutsMap.isKey(recordLayoutForTable)
                                    this.Data.RecordLayoutsMap(recordLayoutForTable)=valuesForRecLayout.tDataType;
                                end


                                paramValue.RecordLayout=recordLayoutForTable;

                                for i=1:numel(axisInfoForStdAxis)



                                    for fn=fieldnames(axisInfoForStdAxis)'
                                        axisPtsForCom(i).(fn{1})=axisInfoForStdAxis(i).(fn{1});
                                    end

                                    if strcmp(axisPtsForCom(i).EcuAddressComment,"")
                                        axisPtsForCom(i).EcuAddress=paramValue.EcuAddress;
                                    else
                                        ecuAddress=['0x0000 /* ',axisPtsForCom(i).EcuAddressComment,' */'];
                                        axisPtsForCom(i).EcuAddress=ecuAddress;
                                    end



                                    axisName=[paramKeys{ii},'_BP',num2str(i)];
                                    axisPtsForCom(i).AxisPointsRef=axisName;



                                    temp=extract(axisPtsForCom(i).Name,digitsPattern);
                                    if numel(axisInfoForStdAxis)==1
                                        axisDataType=valuesForRecLayout.axisPtsDataType;
                                    else
                                        axisDataType=valuesForRecLayout.axisPtsDataType(i);

                                    end
                                    if numel(axisInfoForStdAxis)==1
                                        recordLayoutKey="Axis_"+valuesForRecLayout.axisPtsDataType;
                                    elseif Simulink.CodeMapping.isAutosarCompliant(this.Data.ModelName)||isempty(temp)
                                        recordLayoutKey="Axis_"+valuesForRecLayout.axisPtsDataType(i);
                                    else
                                        recordLayoutKey="Axis_"+valuesForRecLayout.axisPtsDataType(str2num(temp{1}));
                                    end
                                    axisPtsForCom(i).RecordLayout=recordLayoutKey;

                                    this.Data.CommonAxesMap(axisName)=axisPtsForCom(i);


                                    paramValue.AxisInfo(i)=axisPtsForCom(i);
                                    if(valuesForRecLayout.SupportTunableSize)
                                        dataType=valuesForRecLayout.NumOfAxisPtsDataType(i);
                                    else
                                        dataType='UBYTE';
                                    end
                                    valuesForRecLayoutForAxis=struct('AxisType','COM_AXIS','xDataType',axisDataType,'Layout',arrayLayout,...
                                    'nxDataType',dataType,'SupportTunableSize',valuesForRecLayout.SupportTunableSize);


                                    if~this.Data.LookUpTableRecordLayoutMap.isKey(recordLayoutKey)
                                        this.Data.LookUpTableRecordLayoutMap(recordLayoutKey)=valuesForRecLayoutForAxis;
                                    end
                                end

                            end

                            if transpose&&swap||transpose&&~swap


                                recordLayout=paramValue.RecordLayout;
                                recordLayoutKey=[recordLayout,'_TRANSPOSED'];

                                if this.Data.LookUpTableRecordLayoutMap.isKey(recordLayout)

                                    values=this.Data.LookUpTableRecordLayoutMap(recordLayout);
                                    if(transpose&&swap)||(transpose&&~swap)
                                        values.ToggleArrayLayout=true;
                                    else
                                        values.ToggleArrayLayout=false;
                                    end

                                else




                                    dataType=this.Data.RecordLayoutsMap(recordLayout);
                                    if(transpose||swap)&&~(transpose&&swap)
                                        layout=coder.internal.asap2.WriterBase.getToggledLayout(this);
                                    else
                                        layout=this.Data.ArrayLayout;
                                    end
                                    values=struct('AxisType','Custom','DataType',dataType,'Layout',layout);
                                end
                                this.Data.LookUpTableRecordLayoutMap(recordLayoutKey)=values;
                                paramValue.RecordLayout=recordLayoutKey;
                            end
                        end
                        if paramValue.ExportArrayAsFixAxis&&strcmp(paramValue.Type,'VAL_BLK')

                            isLookup=true;
                            numOfBreakPoints=2;
                            bpIndex=2;
                            paramValue.Type='MAP';
                            for i=1:numOfBreakPoints
                                dist='1';
                                offset='0';
                                cmName='NO_COMPU_METHOD';
                                lowerLimit=paramValue.LowerLimit;
                                upperLimit=paramValue.UpperLimit;
                                referenceToInput='NO_INPUT_QUANTITY';
                                fixAxisType='FIX_AXIS_PAR_DIST';
                                if~isempty(paramValue.AxisInfo)&&i<=numel(paramValue.AxisInfo)
                                    if~strcmp(paramValue.AxisInfo(i).CompuMethodName,"")
                                        cmName=paramValue.AxisInfo(i).CompuMethodName;
                                    end
                                    if~isempty(paramValue.AxisInfo(i).LowerLimit)
                                        lowerLimit=paramValue.AxisInfo(i).LowerLimit;
                                    end
                                    if~isempty(paramValue.AxisInfo(i).UpperLimit)
                                        upperLimit=paramValue.AxisInfo(i).UpperLimit;
                                    end
                                    if~strcmp(paramValue.AxisInfo(i).InputQuantity,"")
                                        referenceToInput=paramValue.AxisInfo(i).InputQuantity;
                                    end
                                    if~strcmp(paramValue.AxisInfo(i).FixAxisType,"")
                                        fixAxisType=paramValue.AxisInfo(i).FixAxisType;
                                    end
                                    if~isempty(paramValue.AxisInfo(i).Distance)
                                        dist=paramValue.AxisInfo(i).Distance;
                                    end
                                    if~isempty(paramValue.AxisInfo(i).Offset)
                                        offset=paramValue.AxisInfo(i).Offset;
                                    end

                                end
                                name=['Bp',num2str(bpIndex)];
                                axisInfo(i)=struct('Name',name,'AxisType','FIX_AXIS',...
                                'InputQuantity',referenceToInput,'CompuMethodName',cmName,'MaxAxisPoints',num2str(paramValue.Dimensions(i)),...
                                'LowerLimit',lowerLimit,'UpperLimit',upperLimit,'FixAxisType',fixAxisType,'Distance',num2str(dist),'Offset',offset,'Format','','EvenSpacingLutObjWithExplicitBPSpec',true);
                                bpIndex=bpIndex-1;
                            end

                            paramValue.AxisInfo=axisInfo;
                        end

                    end
                    this.FormatContentsObj.wLine('');
                    this.FormatContentsObj.write('','  /begin CHARACTERISTIC ');
                    this.FormatContentsObj.write('    /* Name                   */      ',paramKeys{ii});
                    this.FormatContentsObj.write('    /* Long Identifier        */      ',['"',paramValue.LongIdentifier,'"']);
                    if~includeComments
                        this.FormatContentsObj.wLine('');
                        this.FormatContentsObj.write('','   ');
                    end


                    if~isLookup
                        this.FormatContentsObj.write('    /* Type                   */      ',paramValue.Type);
                    else
                        this.FormatContentsObj.write('    /* Characteristic Type    */      ',paramValue.Type);
                    end


                    if strcmp(paramValue.EcuAddressComment,"")
                        this.FormatContentsObj.write('    /* ECU Address            */      ',paramValue.EcuAddress);
                    else
                        ecuAddress=['0x0000 /* ',paramValue.EcuAddressComment,' */'];
                        this.FormatContentsObj.write('    /* ECU Address            */      ',ecuAddress);
                    end
                    this.FormatContentsObj.write('    /* Record Layout          */      ',paramValue.RecordLayout);

                    if~isLookup
                        this.FormatContentsObj.write('    /* Maximum Difference     */      ',maxDiff);
                    else
                        this.FormatContentsObj.write('    /* Maxdiff                */      ',maxDiff);
                    end


                    this.FormatContentsObj.write('    /* Conversion Method      */      ',paramValue.CompuMethodName);

                    this.FormatContentsObj.write('    /* Lower Limit            */      ',num2str(paramValue.LowerLimit));

                    this.FormatContentsObj.write('    /* Upper Limit            */      ',num2str(paramValue.UpperLimit));
                    if~includeComments
                        this.FormatContentsObj.wLine('');
                    end
                    if strcmp(paramValue.Type,'VAL_BLK')
                        this.writeDimension(paramValue,true,swap);
                    end

                    if isLookup
                        axisInfo=paramValue.AxisInfo;
                        if isa(axisInfo,'coder.asap2.AxisInfo')
                            for i=1:numel(axisInfo)
                                name=['Bp',num2str(i)];
                                axisInfo(i).Name=name;
                            end
                        end
                        if(transpose||swap)&&~(transpose&&swap)



                            if length(paramValue.AxisInfo)>1
                                paramValue.AxisInfo=flip(paramValue.AxisInfo);
                                name=paramValue.AxisInfo(2).Name;
                                paramValue.AxisInfo(2).Name=paramValue.AxisInfo(1).Name;
                                paramValue.AxisInfo(1).Name=name;
                            end
                            paramValue.IsTransposed=true;
                        end
                        for x=1:length(paramValue.AxisInfo)

                            axisInfo=paramValue.AxisInfo(x);
                            this.FormatContentsObj.wLine('    /begin AXIS_DESCR');
                            axis='';
                            if x==1
                                axis='X-Axis';
                            elseif x==2
                                axis='Y-Axis';
                            elseif x==3
                                axis='Z-Axis';
                            else
                                axis=['Z',num2str(x),'-Axis'];
                            end
                            this.FormatContentsObj.write(['      /* Description of ',axis,' Points */'],'');
                            this.FormatContentsObj.write('      /* Axis Type            */ ',['     ',axisInfo.AxisType]);
                            this.FormatContentsObj.write('      /* Reference to Input   */      ',axisInfo.InputQuantity);
                            this.FormatContentsObj.write('      /* Conversion Method    */      ',axisInfo.CompuMethodName);
                            this.FormatContentsObj.write('      /* Number of Axis Pts   */      ',num2str(axisInfo.MaxAxisPoints));
                            this.FormatContentsObj.write('      /* Lower Limit          */      ',num2str(axisInfo.LowerLimit));
                            this.FormatContentsObj.write('      /* Upper Limit          */      ',num2str(axisInfo.UpperLimit));
                            if~includeComments
                                this.FormatContentsObj.wLine('')
                            end
                            if strcmp(axisInfo.AxisType,'COM_AXIS')
                                this.FormatContentsObj.wLine(['      AXIS_PTS_REF                    ',axisInfo.AxisPointsRef]);
                            end
                            if strcmp(axisInfo.AxisType,'FIX_AXIS')
                                if~isempty(axisInfo.Format)
                                    this.FormatContentsObj.wLine(['      FORMAT      ','                    "',(axisInfo.Format),'"']);
                                end
                                if strcmp(axisInfo.FixAxisType,'FIX_AXIS_PAR_DIST')||strcmp(axisInfo.FixAxisType,'FIX_AXIS_PAR')
                                    this.FormatContentsObj.wLine(['      ',axisInfo.FixAxisType,'               ',num2str(axisInfo.Offset(1)),' ',num2str(axisInfo.Distance),' ',num2str(axisInfo.MaxAxisPoints)]);
                                else
                                    this.FormatContentsObj.wLine('    /begin FIX_AXIS_PAR_LIST')
                                    this.FormatContentsObj.wLine(['      ',num2str(axisInfo.Offset)]);
                                    this.FormatContentsObj.wLine('    /end FIX_AXIS_PAR_LIST');
                                end
                            end
                            this.FormatContentsObj.wLine('    /end AXIS_DESCR');
                        end
                    end

                    if optionalParams.Count>0
                        optionalParamKeys=optionalParams.keys;
                        optionalParamValues=optionalParams.values;
                        for jj=1:numel(optionalParamKeys)
                            if isempty(optionalParamValues{jj})
                                this.FormatContentsObj.wLine(['    ',optionalParamKeys{jj}]);
                            else
                                if strcmp(optionalParamKeys{jj},'CALIBRATION_ACCESS')
                                    this.writeCalibrationAccess(optionalParamValues{jj});
                                else
                                    this.FormatContentsObj.wLine(['    ',optionalParamKeys{jj},' ',optionalParamValues{jj}]);
                                end
                            end
                        end
                    end
                    if~this.FormatContentsObj.isFreshLine()
                        this.FormatContentsObj.wLine('');
                    end



                    if isscalar(paramValue.EcuAddressExtension)...
                        &&(paramValue.EcuAddressExtension>=minEcuAddressExtension)...
                        &&(paramValue.EcuAddressExtension<=maxEcuAddressExtension)
                        this.FormatContentsObj.wLine(['    /* ECU Extension          */      ECU_ADDRESS_EXTENSION ',num2str(paramValue.EcuAddressExtension)]);

                    elseif ecuAddressExtension>=minEcuAddressExtension&&ecuAddressExtension<=maxEcuAddressExtension
                        this.FormatContentsObj.wLine(['    /* ECU Extension          */      ECU_ADDRESS_EXTENSION ',num2str(ecuAddressExtension)]);
                    else

                    end


                    if isLookup&&~strcmp(comparisonQuantity,"")
                        this.FormatContentsObj.wLine(['    COMPARISON_QUANTITY  ',comparisonQuantity]);
                    end



                    if isa(paramValue,'coder.asap2.Characteristic')

                        if isprop(paramValue,'SymbolLink')
                            writeSymbolLink(this,paramValue)
                        end
                    end

                    this.FormatContentsObj.wLine('  /end CHARACTERISTIC ');
                    if~this.Data.CompuMethodsMap.isKey(paramValue.CompuMethodName)



                        coder.internal.asap2.WriterBase.addCompuMethodToMap(this,...
                        paramValue.GraphicalName,paramValue.CompuMethodName);
                    end
                else
                    removeFromGroup{end+1}=paramKeys{ii};
                end
            end


            signalKeys=this.Data.SignalsMap.keys;

            for ii=1:length(signalKeys)
                signalValue=this.Data.SignalsMap(signalKeys{ii});
                sigName=signalValue.GraphicalName;
                optionalSignals=containers.Map;
                if signalValue.Export

                    calibrationAccessValue=signalValue.CalibrationAccess;

                    if~strcmp(signalValue.DisplayIdentifier,"")
                        optionalSignals('DISPLAY_IDENTIFIER')=['',signalValue.DisplayIdentifier,''];
                    end
                    if~strcmp(signalValue.Format,"")
                        optionalSignals('FORMAT')=['"',signalValue.Format,'"'];
                    end
                    if~isempty(calibrationAccessValue)...
                        &&strcmp(calibrationAccessValue,'Calibration')
                        optionalSignals('READ_WRITE')=true;
                    else
                        optionalSignals('READ_WRITE')=false;
                    end

                    if~isempty(signalValue.BitMask)
                        optionalSignals('BIT_MASK')=['',signalValue.BitMask,''];
                    end


                    this.FormatContentsObj.wLine('');
                    this.FormatContentsObj.write('','  /begin MEASUREMENT ');
                    this.FormatContentsObj.write('    /* Name                   */      ',signalKeys{ii});
                    this.FormatContentsObj.write('    /* Long identifier        */      ',['"',signalValue.LongIdentifier,'"']);
                    if~includeComments
                        this.FormatContentsObj.wLine('');
                        this.FormatContentsObj.write('','   ');
                    end
                    this.FormatContentsObj.write('    /* Data type              */      ',signalValue.DataType);
                    this.FormatContentsObj.write('    /* Conversion method      */      ',signalValue.CompuMethodName);
                    this.FormatContentsObj.write('    /* Resolution (Not used)  */','      0      ');
                    this.FormatContentsObj.write('    /* Accuracy (Not used)    */','      0      ');
                    this.FormatContentsObj.write('    /* Lower limit            */      ',num2str(signalValue.LowerLimit));
                    this.FormatContentsObj.write('    /* Upper limit            */      ',num2str(signalValue.UpperLimit));
                    if~includeComments
                        this.FormatContentsObj.wLine('');
                    end
                    if isa(signalValue,'coder.asap2.Measurement')&&~isempty(signalValue.Dimensions)
                        [signalValue.Width,~]=coder.internal.asap2.Utils.getWidthFromDimension(signalValue.Dimensions);
                    end
                    if~isempty(signalValue.Width)
                        this.writeLayoutForMultiDimArray(signalValue.Width,arrayLayout);
                        this.writeDimension(signalValue,false,swap);
                    end
                    if strcmp(signalValue.EcuAddressComment,"")
                        this.FormatContentsObj.wLine(['    ECU_ADDRESS                       ',signalValue.EcuAddress]);
                    else
                        ecuAddress=['0x0000 /* ',signalValue.EcuAddressComment,' */'];
                        this.FormatContentsObj.write('    /* ECU Address            */      ',ecuAddress);
                    end
                    if optionalSignals.Count>0
                        optionalSignalKeys=optionalSignals.keys;
                        optionalSignalValues=optionalSignals.values;
                        for jj=1:numel(optionalSignalKeys)
                            if isempty(optionalSignalValues{jj})
                                this.FormatContentsObj.wLine(['    ',optionalSignalKeys{jj}]);
                            else
                                if strcmp(optionalSignalKeys{jj},'READ_WRITE')
                                    if optionalSignalValues{jj}
                                        this.FormatContentsObj.wLine(['    ',optionalSignalKeys{jj}]);
                                    end
                                else
                                    this.FormatContentsObj.wLine(['    ',optionalSignalKeys{jj},' ',optionalSignalValues{jj}]);
                                end
                            end
                            if~this.FormatContentsObj.isFreshLine()
                                this.FormatContentsObj.wLine('');
                            end
                        end
                    end
                    rasterInfo=signalValue.Raster;
                    if~isempty(rasterInfo)
                        if isa(signalValue,"coder.asap2.Measurement")
                            if isfield(rasterInfo,'FixedEventName')&&~isempty(rasterInfo.FixedEventName)
                                rasterInfo.FixedEventID={};
                                for i=1:numel(rasterInfo.FixedEventName)
                                    rate=rasterInfo.FixedEventName(i);
                                    rasterInfo.FixedEventID{end+1}=coder.internal.asap2.Utils.getRateID(rate,this.Data.PeriodicEventList);
                                end

                            elseif isfield(rasterInfo,'AvailableEventName')&&~isempty(rasterInfo.AvailableEventName)||...
                                isfield(rasterInfo,'DefaultEventName')&&~isempty(rasterInfo.DefaultEventName)

                                if isfield(rasterInfo,'AvailableEventName')&&~isempty(rasterInfo.AvailableEventName)
                                    rasterInfo.AvailableEventID={};
                                    for i=1:numel(rasterInfo.AvailableEventName)
                                        rate=rasterInfo.AvailableEventName(i);
                                        rasterInfo.AvailableEventID{end+1}=coder.internal.asap2.Utils.getRateID(rate,this.Data.PeriodicEventList);
                                    end

                                end

                                if isfield(rasterInfo,'DefaultEventName')&&~isempty(rasterInfo.DefaultEventName)
                                    rasterInfo.DefaultEventID={};
                                    for i=1:numel(rasterInfo.DefaultEventName)
                                        rate=rasterInfo.DefaultEventName(i);
                                        rasterInfo.DefaultEventID{end+1}=coder.internal.asap2.Utils.getRateID(rate,this.Data.PeriodicEventList);
                                    end
                                end
                            end

                        end
                        if~isempty(rasterInfo.FixedEventID)

                            this.FormatContentsObj.wLine('    /begin IF_DATA XCP');
                            this.FormatContentsObj.wLine('      /begin DAQ_EVENT');
                            this.FormatContentsObj.wLine('          /begin FIXED_EVENT_LIST');
                            for k=1:numel(rasterInfo.FixedEventID)
                                coder.internal.asap2.WriterBase.writeEventData(this,rasterInfo.FixedEventID(k));
                            end
                            this.FormatContentsObj.wLine('          /end FIXED_EVENT_LIST');
                            this.FormatContentsObj.wLine('      /end DAQ_EVENT');
                            this.FormatContentsObj.wLine('    /end IF_DATA');
                        elseif~isempty(rasterInfo.DefaultEventID)||...
                            ~isempty(rasterInfo.AvailableEventID)

                            this.FormatContentsObj.wLine('    /begin IF_DATA XCP');
                            this.FormatContentsObj.wLine('      /begin DAQ_EVENT VARIABLE');
                            if~isempty(rasterInfo.DefaultEventID)
                                this.FormatContentsObj.wLine('          /begin DEFAULT_EVENT_LIST');
                                coder.internal.asap2.WriterBase.writeEventData(this,rasterInfo.DefaultEventID);
                                this.FormatContentsObj.wLine('          /end DEFAULT_EVENT_LIST');
                            end
                            if~isempty(rasterInfo.AvailableEventID)
                                this.FormatContentsObj.wLine('          /begin AVAILABLE_EVENT_LIST');
                                for k=1:numel(rasterInfo.AvailableEventID)
                                    coder.internal.asap2.WriterBase.writeEventData(this,rasterInfo.AvailableEventID(k));
                                end
                                this.FormatContentsObj.wLine('          /end AVAILABLE_EVENT_LIST');
                            end
                            this.FormatContentsObj.wLine('      /end DAQ_EVENT');
                            this.FormatContentsObj.wLine('    /end IF_DATA');
                        end
                    end



                    if isscalar(signalValue.EcuAddressExtension)...
                        &&(signalValue.EcuAddressExtension>=minEcuAddressExtension)...
                        &&(signalValue.EcuAddressExtension<=maxEcuAddressExtension)
                        this.FormatContentsObj.wLine(['    /* ECU Extension          */      ECU_ADDRESS_EXTENSION ',num2str(signalValue.EcuAddressExtension)]);

                    elseif ecuAddressExtension>=minEcuAddressExtension&&ecuAddressExtension<=maxEcuAddressExtension
                        this.FormatContentsObj.wLine(['    /* ECU Extension          */      ECU_ADDRESS_EXTENSION ',num2str(ecuAddressExtension)]);
                    else

                    end


                    if~this.Data.CompuMethodsMap.isKey(signalValue.CompuMethodName)



                        coder.internal.asap2.WriterBase.addCompuMethodToMap(this,...
                        paramValue.GraphicalName,paramValue.CompuMethodName);
                    end


                    if isa(signalValue,'coder.asap2.Measurement')

                        if isprop(signalValue,'SymbolLink')
                            writeSymbolLink(this,signalValue);
                        end

                    end

                    this.FormatContentsObj.wLine('  /end MEASUREMENT ');
                else
                    removeFromGroup{end+1}=signalKeys{ii};
                end
            end

            if~isempty(this.Data.CommonAxesMap)
                axisNames=this.Data.CommonAxesMap.keys;

                for i=1:length(axisNames)
                    optionalAxisParams=containers.Map;
                    axisValue=this.Data.CommonAxesMap(axisNames{i});
                    calibrationAccessValue=axisValue.CalibrationAccess;
                    if~isempty(calibrationAccessValue)...
                        &&strcmp(calibrationAccessValue,'NoCalibration')
                        optionalAxisParams('CALIBRATION_ACCESS')='NO_CALIBRATION';
                    end
                    if~strcmp(axisValue.DisplayIdentifier,"")
                        optionalAxisParams('DISPLAY_IDENTIFIER')=['',axisValue.DisplayIdentifier,''];
                    end
                    if~strcmp(axisValue.Format,"")
                        optionalAxisParams('FORMAT')=['"',axisValue.Format,'"'];
                    end

                    this.FormatContentsObj.wLine('');
                    this.FormatContentsObj.write('','  /begin AXIS_PTS ');
                    if~isempty(axisValue.SharedAxis)
                        this.FormatContentsObj.write('    /* Name                   */      ',axisValue.SharedAxis);
                    else
                        this.FormatContentsObj.write('    /* Name                   */      ',axisNames{i});
                    end
                    this.FormatContentsObj.write('    /* Long Identifier        */      ',['"',axisValue.LongIdentifier,'"']);
                    if~includeComments
                        this.FormatContentsObj.wLine('');
                        this.FormatContentsObj.write('','   ');
                    end
                    this.FormatContentsObj.write('    /* ECU Address            */      ',axisValue.EcuAddress);
                    this.FormatContentsObj.write('    /* Input Quantity         */      ',axisValue.InputQuantity);
                    this.FormatContentsObj.write('    /* Record Layout          */      ',axisValue.RecordLayout);
                    this.FormatContentsObj.write('    /* Maximum Difference     */      ','0');
                    this.FormatContentsObj.write('    /* Conversion Method      */      ',axisValue.CompuMethodName);
                    this.FormatContentsObj.write('    /* Number of Axis Pts     */      ',num2str(axisValue.MaxAxisPoints));
                    this.FormatContentsObj.write('    /* Lower Limit            */      ',num2str(axisValue.LowerLimit));
                    this.FormatContentsObj.write('    /* Upper Limit            */      ',num2str(axisValue.UpperLimit));
                    if~includeComments
                        this.FormatContentsObj.wLine('');
                    end
                    if optionalAxisParams.Count>0
                        optionalAxisParamKeys=optionalAxisParams.keys;
                        optionalAxisParamsValues=optionalAxisParams.values;
                        for jj=1:numel(optionalAxisParamKeys)
                            if isempty(optionalAxisParamsValues{jj})
                                this.FormatContentsObj.wLine(['    ',optionalAxisParamKeys{jj}]);
                            else
                                if strcmp(optionalAxisParamKeys{jj},'CALIBRATION_ACCESS')
                                    this.writeCalibrationAccess(optionalAxisParamsValues{jj});
                                else
                                    this.FormatContentsObj.wLine(['    ',optionalAxisParamKeys{jj},' ',optionalAxisParamsValues{jj}]);
                                end
                            end
                        end
                    end


                    if isscalar(axisValue.EcuAddressExtension)...
                        &&(axisValue.EcuAddressExtension>=minEcuAddressExtension)...
                        &&(axisValue.EcuAddressExtension<=maxEcuAddressExtension)
                        this.FormatContentsObj.wLine(['    /* ECU Extension          */      ECU_ADDRESS_EXTENSION ',num2str(axisValue.EcuAddressExtension)]);

                    elseif ecuAddressExtension>=minEcuAddressExtension&&ecuAddressExtension<=maxEcuAddressExtension
                        this.FormatContentsObj.wLine(['    /* ECU Extension          */      ECU_ADDRESS_EXTENSION ',num2str(ecuAddressExtension)]);
                    else

                    end




                    if isa(axisValue,'coder.asap2.AxisInfo')

                        if isprop(axisValue,'SymbolLink')
                            writeSymbolLink(this,axisValue);
                        end
                    end
                    this.FormatContentsObj.wLine('  /end AXIS_PTS ');
                end
            end




            if slfeature('FunctionDescriptionInCalibration')==1
                arrFunctions=this.Data.FunctionMap.values;


                for index=1:length(arrFunctions)
                    functionInfo=arrFunctions{index};

                    if~this.FormatContentsObj.isFreshLine()
                        this.FormatContentsObj.wLine('');
                    end
                    this.FormatContentsObj.write('','  /begin FUNCTION');
                    this.FormatContentsObj.write('',['    /* Name              */      ',char(functionInfo.Name)]);
                    this.FormatContentsObj.write('',['    /* Long identifier   */      "',char(functionInfo.LongIdentifier),'"']);


                    if~isempty(functionInfo.FunctionVersion)&&functionInfo.FunctionVersion~=""
                        this.FormatContentsObj.write('',['    /* Function version  */      "',char(functionInfo.FunctionVersion),'"']);
                    end


                    if~isempty(functionInfo.Annotation)&&functionInfo.Annotation~=""
                        this.FormatContentsObj.write('',['    /* Annotation        */      "',char(functionInfo.Annotation),'"']);
                    end

                    if~this.FormatContentsObj.isFreshLine()
                        this.FormatContentsObj.wLine('');
                    end

                    writeFunctionInfoCollection(this,functionInfo.InMeasurements,'IN_MEASUREMENT');
                    writeFunctionInfoCollection(this,functionInfo.OutMeasurements,'OUT_MEASUREMENT');
                    writeFunctionInfoCollection(this,functionInfo.LocMeasurements,'LOC_MEASUREMENT');
                    writeFunctionInfoCollection(this,functionInfo.DefCharacteristics,'DEF_CHARACTERISTIC');
                    writeFunctionInfoCollection(this,functionInfo.RefCharacteristics,'REF_CHARACTERISTIC');
                    writeFunctionInfoCollection(this,functionInfo.SubFunctions,'SUB_FUNCTION');

                    if~this.FormatContentsObj.isFreshLine()
                        this.FormatContentsObj.wLine('');
                    end
                    this.FormatContentsObj.write('','  /end FUNCTION');
                end
            end

            function this=writeFunctionInfoCollection(this,arrValues,token)

                faultyIndexes=cellfun(@isempty,arrValues);
                arrValues=arrValues(~faultyIndexes);

                if~isempty(arrValues)
                    this.FormatContentsObj.write('',['    /begin ',token]);
                    if~this.FormatContentsObj.isFreshLine()
                        this.FormatContentsObj.wLine('');
                    end
                    this.FormatContentsObj.write('',['      ',char(join(arrValues,' '))]);
                    if~this.FormatContentsObj.isFreshLine()
                        this.FormatContentsObj.wLine('');
                    end
                    this.FormatContentsObj.wLine(['    /end ',token]);
                end
            end


            compuMethodsNames=this.Data.CompuMethodsMap.keys;

            for kk=1:length(compuMethodsNames)
                compuMethod=this.Data.CompuMethodsMap(compuMethodsNames{kk});
                this.FormatContentsObj.wLine('');
                this.FormatContentsObj.write('','  /begin COMPU_METHOD');
                this.FormatContentsObj.write('    /* Name of CompuMethod    */      ',compuMethodsNames{kk});
                if~includeComments
                    this.FormatContentsObj.write('    /* Long identifier        */      ','""');
                    this.FormatContentsObj.wLine('');
                    this.FormatContentsObj.write('','   ');
                else
                    if any(regexp(compuMethod.LongIdentifier,'"'))
                        this.FormatContentsObj.write('    /* Long identifier        */      ',compuMethod.LongIdentifier);
                    else


                        this.FormatContentsObj.write('    /* Long identifier        */      ',['"',compuMethod.LongIdentifier,'"']);
                    end
                end
                this.FormatContentsObj.write('    /* Conversion Type        */      ',compuMethod.ConversionType);
                this.FormatContentsObj.write('    /* Format                 */      ',['"',compuMethod.Format,'"']);
                if(isempty(compuMethod.Units))
                    this.FormatContentsObj.write('    /* Units                  */      ','""');
                else
                    this.FormatContentsObj.write('    /* Units                  */      ',['"',compuMethod.Units,'"']);
                end
                if~this.FormatContentsObj.isFreshLine()
                    this.FormatContentsObj.wLine('');
                end
                if~strcmp(compuMethod.ConversionType,'TAB_VERB')
                    this.writeCoeffsInCompuMethods(ASAP2NumberFormat,compuMethod);
                end
                if strcmp(compuMethod.ConversionType,'TAB_VERB')
                    this.FormatContentsObj.write('    /* Conversion Table       */  ',['    COMPU_TAB_REF VTAB_FOR_',compuMethodsNames{kk}]);
                end
                if~this.FormatContentsObj.isFreshLine()
                    this.FormatContentsObj.wLine('');
                end
                this.FormatContentsObj.wLine('  /end COMPU_METHOD');
                if strcmp(compuMethod.ConversionType,'TAB_VERB')
                    this.FormatContentsObj.wLine('');

                    this.FormatContentsObj.write('','  /begin COMPU_VTAB');
                    cvTabName=['VTAB_FOR_',compuMethodsNames{kk}];
                    this.FormatContentsObj.write('    /* Name of Table          */      ',cvTabName);
                    if this.Data.CompuVtabsMap.isKey(cvTabName)
                        cvTabMapValues=this.Data.CompuVtabsMap(cvTabName);
                        longID=cvTabMapValues(1).LongIdentifier;
                    else


                        cvTabMapValues=compuMethod.CompuVTabValues;
                        for i=1:numel(compuMethod.CompuVTabValues.Literals)
                            cvTabMapValues(i).Literals=compuMethod.CompuVTabValues.Literals(i);
                            cvTabMapValues(i).Values=compuMethod.CompuVTabValues.Values(i);

                        end
                        longID=['"Enumerated data type: ',compuMethodsNames{kk},'"'];
                    end
                    this.FormatContentsObj.write('    /* Long identifier        */      ',longID);
                    if~includeComments
                        this.FormatContentsObj.wLine('');
                        this.FormatContentsObj.write('','   ');
                    end
                    this.FormatContentsObj.write('    /* Conversion Type        */      ','TAB_VERB');
                    this.FormatContentsObj.write('    /* Number of Elements     */      ',num2str(numel(cvTabMapValues)));
                    for ii=1:numel(cvTabMapValues)
                        if~this.FormatContentsObj.isFreshLine()
                            this.FormatContentsObj.wLine('');
                        end
                        this.FormatContentsObj.write('    /* Table Element          */  ',['    ',cvTabMapValues(ii).Values,' "',cvTabMapValues(ii).Literals,'"']);
                    end
                    if~this.FormatContentsObj.isFreshLine()
                        this.FormatContentsObj.wLine('');
                    end
                    this.FormatContentsObj.wLine('  /end COMPU_VTAB');
                end
            end

            recordLayoutKeys=this.Data.RecordLayoutsMap.keys;


            if includeAllRecordLayouts
                try
                    buildDir=RTW.getBuildDir(this.Data.ModelName);
                    destinationFile=fullfile(buildDir.BuildDirectory,'RecordLayouts.a2l');
                    sourceFile=this.getSourceFile(arrayLayout);
                    fid=fopen(destinationFile,'w');
                    fileHeader=sprintf(['/******************************************************************************\n',...
                    ' *',newline,...
                    ' * ASAP2 file:     ','RecordLayouts.a2l',newline,...
                    ' *',newline,...
                    '',watermark,newline,...
                    ' *',newline,...
                    ' * Record Layouts for Characteristics.',newline,...
                    ' *',newline,...
                    ' * ASAP2(a2l) Generated on ',timeFormat,...
                    newline,...
' ******************************************************************************/'
                    ]);
                    fprintf(fid,fileHeader);
                    fprintf(fid,'\n');
                    fprintf(fid,fileread(sourceFile));
                    fclose(fid);
                    this.FormatContentsObj.wLine('');
                    this.FormatContentsObj.wLine('/include "RecordLayouts.a2l"');
                catch exp
                    DAStudio.warning('RTW:asap2:CannotIncludeAllRecordLayouts',exp.message);
                    includeAllRecordLayouts=false;
                end
            end
            if~includeAllRecordLayouts
                for i=1:length(recordLayoutKeys)
                    this.FormatContentsObj.wLine('');
                    this.FormatContentsObj.wLine(['  /begin  RECORD_LAYOUT ',recordLayoutKeys{i}]);
                    if startsWith(recordLayoutKeys{i},'Lookup1D_X')||startsWith(recordLayoutKeys{i},'Lookup2D_X')
                        this.FormatContentsObj.wLine(['    FNC_VALUES 1 ',this.Data.RecordLayoutsMap(recordLayoutKeys{i}),' INDEX_INCR DIRECT']);
                    else
                        this.FormatContentsObj.wLine(['    FNC_VALUES 1 ',this.Data.RecordLayoutsMap(recordLayoutKeys{i}),' ',arrayLayout,' DIRECT']);
                    end
                    this.FormatContentsObj.wLine('  /end  RECORD_LAYOUT ');

                end
            end


            if~isempty(this.Data.LookUpTableRecordLayoutMap)
                this.FormatContentsObj.wLine('');
                this.FormatContentsObj.write('  /* Record Layouts for Lookup Tables in Standard Axis format */','');
                this.FormatContentsObj.wLine('');
                LutRLNames=this.Data.LookUpTableRecordLayoutMap.keys;

                for i=1:length(LutRLNames)
                    this.FormatContentsObj.wLine(['  /begin RECORD_LAYOUT ',LutRLNames{i}]');
                    values=this.Data.LookUpTableRecordLayoutMap(LutRLNames{i});

                    if strcmp(values.AxisType,'STD_AXIS')
                        numOfBreakPoints=values.noOfAxis;
                        if values.SupportTunableSize
                            if strcmp(values.StructOrder,'SizeTableBreakpoints')
                                index=[(numOfBreakPoints)+2,(numOfBreakPoints)+1];
                            else
                                index=[numOfBreakPoints+1,(2*(numOfBreakPoints))+1];
                            end
                        else
                            if strcmp(values.StructOrder,'SizeTableBreakpoints')
                                index=[2,1];
                            else
                                index=[1,numOfBreakPoints+1];
                            end
                        end
                        if values.ToggleArrayLayout&&~swap
                            if strcmp(this.Data.ArrayLayout,'ROW_DIR')
                                arrayLayout='COLUMN_DIR';
                            else
                                arrayLayout='ROW_DIR';
                            end
                        elseif values.ToggleArrayLayout&&swap
                            arrayLayout=this.Data.ArrayLayout;
                        end
                        toChange=(swap||values.ToggleArrayLayout)&&~(swap&&values.ToggleArrayLayout);
                        if numOfBreakPoints>1
                            if(toChange)&&this.Data.IsAutosarCompliant...
                                ||~(toChange)&&~this.Data.IsAutosarCompliant
                                indexOfX=num2str(index(1)+1);
                                dataTypeOfX=convertStringsToChars(values.axisPtsDataType(2));
                                indexOfY=num2str(index(1));
                                dataTypeOfY=convertStringsToChars(values.axisPtsDataType(1));
                                posOfNumOfXaxisPts='2';
                                posOfNumOfYaxisPts='1';
                                if~isempty(values.NumOfAxisPtsDataType)
                                    numOfXaxisPtsDataType=convertStringsToChars(values.NumOfAxisPtsDataType(2));
                                    numOfYaxisPtsDataType=convertStringsToChars(values.NumOfAxisPtsDataType(1));
                                end
                            else
                                indexOfX=num2str(index(1));
                                dataTypeOfX=convertStringsToChars(values.axisPtsDataType(1));
                                indexOfY=num2str(index(1)+1);
                                dataTypeOfY=convertStringsToChars(values.axisPtsDataType(2));
                                posOfNumOfXaxisPts='1';
                                posOfNumOfYaxisPts='2';
                                if~isempty(values.NumOfAxisPtsDataType)
                                    numOfXaxisPtsDataType=convertStringsToChars(values.NumOfAxisPtsDataType(1));
                                    numOfYaxisPtsDataType=convertStringsToChars(values.NumOfAxisPtsDataType(2));
                                end
                            end
                        end
                        if numOfBreakPoints==2

                            if values.SupportTunableSize
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_X ',posOfNumOfXaxisPts,' ',numOfXaxisPtsDataType]);
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_Y ',posOfNumOfYaxisPts,' ',numOfYaxisPtsDataType]);
                            end
                            this.FormatContentsObj.wLine(['    AXIS_PTS_X ',indexOfX,' ',dataTypeOfX,' INDEX_INCR DIRECT']);
                            this.FormatContentsObj.wLine(['    AXIS_PTS_Y ',indexOfY,' ',dataTypeOfY,' INDEX_INCR DIRECT']);
                            this.FormatContentsObj.wLine(['    FNC_VALUES ',num2str(index(2)),' ',values.tDataType,' ',arrayLayout,' DIRECT']);

                        elseif numOfBreakPoints==1

                            if values.SupportTunableSize
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_X 1 ',convertStringsToChars(values.NumOfAxisPtsDataType)]);
                            end
                            this.FormatContentsObj.wLine(['    AXIS_PTS_X ',num2str(index(1)),' ',convertStringsToChars(values.axisPtsDataType),' INDEX_INCR DIRECT']);
                            this.FormatContentsObj.wLine(['    FNC_VALUES ',num2str(index(2)),' ',values.tDataType,' ',arrayLayout,' DIRECT']);

                        elseif numOfBreakPoints==3

                            if values.SupportTunableSize
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_X ',posOfNumOfXaxisPts,' ',numOfXaxisPtsDataType]);
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_Y ',posOfNumOfYaxisPts,' ',numOfYaxisPtsDataType]);
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_Z 3 ',convertStringsToChars(values.NumOfAxisPtsDataType(3))]);
                            end
                            this.FormatContentsObj.wLine(['    AXIS_PTS_X ',indexOfX,' ',dataTypeOfX,' INDEX_INCR DIRECT']);
                            this.FormatContentsObj.wLine(['    AXIS_PTS_Y ',indexOfY,' ',dataTypeOfY,' INDEX_INCR DIRECT']);
                            this.FormatContentsObj.wLine(['    AXIS_PTS_Z ',num2str(index(1)+2),' ',convertStringsToChars(values.axisPtsDataType(3)),' INDEX_INCR DIRECT']);
                            this.FormatContentsObj.wLine(['    FNC_VALUES ',num2str(index(2)),' ',values.tDataType,' ',arrayLayout,' DIRECT']);
                        else

                            if values.SupportTunableSize
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_X ',posOfNumOfXaxisPts,' ',numOfXaxisPtsDataType]);
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_Y ',posOfNumOfYaxisPts,' ',numOfYaxisPtsDataType]);
                                this.FormatContentsObj.wLine(['    NO_AXIS_PTS_Z 3 ',convertStringsToChars(values.NumOfAxisPtsDataType(3))]);
                                for yy=4:numOfBreakPoints
                                    this.FormatContentsObj.wLine(['    NO_AXIS_PTS_',num2str(yy),' ',num2str(yy),' ',convertStringsToChars(values.NumOfAxisPtsDataType(yy))]);
                                end
                            end
                            this.FormatContentsObj.wLine(['    AXIS_PTS_X ',indexOfX,' ',dataTypeOfX,' INDEX_INCR DIRECT']);
                            this.FormatContentsObj.wLine(['    AXIS_PTS_Y ',indexOfY,' ',dataTypeOfY,' INDEX_INCR DIRECT']);
                            this.FormatContentsObj.wLine(['    AXIS_PTS_Z ',num2str(index(1)+2),' ',convertStringsToChars(values.axisPtsDataType(3)),' INDEX_INCR DIRECT']);
                            for yy=1:numOfBreakPoints-3
                                this.FormatContentsObj.wLine(['    AXIS_PTS_',num2str(yy+3),' ',num2str(index(1)+yy+2),' ',convertStringsToChars(values.axisPtsDataType(yy+3)),' INDEX_INCR DIRECT']);
                            end
                            this.FormatContentsObj.wLine(['    FNC_VALUES ',num2str(index(2)),' ',values.tDataType,' ',arrayLayout,' DIRECT']);
                        end

                    elseif strcmp(values.AxisType,'COM_AXIS')
                        if values.SupportTunableSize
                            this.FormatContentsObj.wLine(['    NO_AXIS_PTS_X 1 ',values.nxDataType]);
                            this.FormatContentsObj.wLine(['    AXIS_PTS_X 2 ',values.xDataType,' INDEX_INCR DIRECT']);
                        else
                            this.FormatContentsObj.wLine(['    AXIS_PTS_X 1 ',values.xDataType,' INDEX_INCR DIRECT']);
                        end
                    elseif strcmp(values.AxisType,'Custom')
                        this.FormatContentsObj.wLine(['    FNC_VALUES 1 ',dataType,' ',layout,' DIRECT']);
                    end
                    this.FormatContentsObj.wLine('  /end RECORD_LAYOUT ');
                    this.FormatContentsObj.wLine('');
                end
            end

            groupNames=this.Data.GroupsMap.keys;

            for i=1:length(groupNames)
                groupInfoVal=this.Data.GroupsMap(groupNames{i});
                subGroups=this.Data.SubGroupsMap(groupNames{i});
                subGroupsWithExistingGrps=[];
                if isfield(subGroups,'Names')&&~isempty(subGroups.Names)
                    for nS=1:length(subGroups)
                        for nSubgrpsNames=1:length(subGroups.Names)
                            if this.Data.GroupsMap.isKey([groupNames{i},'.',subGroups.Names{nSubgrpsNames}])
                                subGroupsWithExistingGrps{end+1}=subGroups.Names{nSubgrpsNames};
                            end
                        end
                    end

                    if~isempty(subGroups.Names)&&isempty(subGroupsWithExistingGrps)
                        continue;
                    end
                    subGroups=struct('Names',{subGroupsWithExistingGrps});
                end

                this.FormatContentsObj.wLine('');
                this.FormatContentsObj.write('','  /begin GROUP');
                this.FormatContentsObj.write('    /* Name                   */      ',groupNames{i});
                if strcmp(groupNames{i},this.Data.ModelName)
                    this.FormatContentsObj.write('    /* Long identifier        */      ',['"',this.Data.ModelName,'"']);
                    this.FormatContentsObj.write('    /* Root                   */      ','ROOT');
                elseif~(isempty(groupInfoVal))
                    this.FormatContentsObj.write('    /* Long identifier        */      ',['"',groupInfoVal(1).LongIdentifier,'"']);
                else
                    this.FormatContentsObj.write('    /* Long identifier        */      ','""');
                end
                if~includeComments
                    this.FormatContentsObj.wLine('');
                end

                if strcmp(groupNames{i},this.Data.ModelName)&&...
                    (isfield(subGroups,'ParamBuses')&&~isempty(subGroups.ParamBuses)...
                    ||isfield(subGroups,'SignalsBuses')&&~isempty(subGroups.SignalsBuses)...
                    ||isfield(subGroups,'Instances')&&~isempty(subGroups.Instances))...
                    ||(isfield(subGroups,'SubSystems')&&~isempty(subGroups.SubSystems))
                    this.FormatContentsObj.wLine('    /begin SUB_GROUP');
                    if isfield(subGroups,'ParamBuses')&&~isempty(subGroups.ParamBuses)
                        for kk=1:length(subGroups.ParamBuses)
                            this.FormatContentsObj.wLine(['      ',subGroups.ParamBuses{kk}]);
                        end
                    end
                    if isfield(subGroups,'SignalsBuses')&&~isempty(subGroups.SignalsBuses)
                        for kk=1:length(subGroups.SignalsBuses)
                            this.FormatContentsObj.wLine(['      ',subGroups.SignalsBuses{kk}]);
                        end
                    end
                    if isfield(subGroups,'SubSystems')&&~isempty(subGroups.SubSystems)
                        for kk=1:length(subGroups.SubSystems)
                            this.FormatContentsObj.wLine(['      ',subGroups.SubSystems{kk}]);
                        end
                    end
                    if isfield(subGroups,'Instances')&&~isempty(subGroups.Instances)
                        for kk=1:length(subGroups.Instances)
                            this.FormatContentsObj.wLine(['      ',subGroups.Instances{kk}]);
                        end
                    end
                    this.FormatContentsObj.wLine('    /end SUB_GROUP');
                elseif(isfield(subGroups,'Names')&&~isempty(subGroups.Names))...
                    ||(isfield(subGroups,'Instances')&&~isempty(subGroups.Instances))...
                    ||(isfield(subGroups,'SubSystems')&&~isempty(subGroups.SubSystems))
                    this.FormatContentsObj.wLine('    /begin SUB_GROUP');
                    if isfield(subGroups,'Names')
                        for j=1:length(subGroups)
                            for kk=1:length(subGroups.Names)
                                this.FormatContentsObj.wLine(['      ',groupNames{i},'.',subGroups.Names{kk}]);
                            end
                        end
                    end
                    if isfield(subGroups,'SubSystems')
                        for j=1:length(subGroups)
                            for kk=1:length(subGroups.SubSystems)
                                this.FormatContentsObj.wLine(['      ',subGroups.SubSystems{kk}]);
                            end
                        end
                    end
                    if isfield(subGroups,'Instances')
                        for j=1:length(subGroups)
                            for kk=1:length(subGroups.Instances)
                                this.FormatContentsObj.wLine(['      ',subGroups.Instances{kk}]);
                            end
                        end
                    end
                    this.FormatContentsObj.wLine('    /end SUB_GROUP');
                end

                if~(isempty(groupInfoVal))
                    if(isfield(groupInfoVal,'Params')&&~isempty(groupInfoVal.Params))...
                        ||(isfield(groupInfoVal,'SubSysParams')&&~isempty(groupInfoVal.SubSysParams))
                        this.FormatContentsObj.wLine('    /begin REF_CHARACTERISTIC');
                        if strcmp(groupNames{i},this.Data.ModelName)
                            for kk=1:length(groupInfoVal.Params)
                                if~any(contains(removeFromGroup,groupInfoVal.Params{kk}))
                                    this.FormatContentsObj.wLine(['      ',groupInfoVal.Params{kk}]);
                                end
                            end
                        else
                            if isfield(groupInfoVal,'Params')
                                for kk=1:length(groupInfoVal.Params)
                                    if~any(contains(removeFromGroup,groupInfoVal.Params{kk}))
                                        this.FormatContentsObj.wLine(['      ',groupNames{i},'.',groupInfoVal.Params{kk}]);
                                    end
                                end
                            end
                            if isfield(groupInfoVal,'SubSysParams')
                                for kk=1:length(groupInfoVal.SubSysParams)
                                    this.FormatContentsObj.wLine(['      ',groupInfoVal.SubSysParams{kk}]);
                                end
                            end
                        end
                        this.FormatContentsObj.wLine('    /end REF_CHARACTERISTIC');
                    end
                    if isfield(groupInfoVal,'Signals')&&~isempty(groupInfoVal.Signals)&&~isempty(signalKeys)...
                        ||(isfield(groupInfoVal,'SubSysSignals')&&~isempty(groupInfoVal.SubSysSignals))
                        this.FormatContentsObj.wLine('    /begin REF_MEASUREMENT');
                        if strcmp(groupNames{i},this.Data.ModelName)
                            for kk=1:length(groupInfoVal.Signals)
                                if~any(contains(removeFromGroup,groupInfoVal.Signals{kk}))
                                    this.FormatContentsObj.wLine(['      ',groupInfoVal.Signals{kk}]);
                                end
                            end
                        else
                            if isfield(groupInfoVal,'SubSysSignals')
                                for kk=1:length(groupInfoVal.SubSysSignals)
                                    this.FormatContentsObj.wLine(['      ',groupInfoVal.SubSysSignals{kk}]);
                                end
                            end
                            if isfield(groupInfoVal,'Signals')
                                for kk=1:length(groupInfoVal.Signals)
                                    if~any(contains(removeFromGroup,groupInfoVal.Signals{kk}))
                                        this.FormatContentsObj.wLine(['      ',groupNames{i},'.',groupInfoVal.Signals{kk}]);
                                    end
                                end
                            end
                        end
                        this.FormatContentsObj.wLine('    /end REF_MEASUREMENT');
                    end
                end
                this.FormatContentsObj.wLine('  /end GROUP');
            end
            categoryToObjectsMapKeys=this.Data.CategoryToObjectsMap.keys;
            for ii=1:numel(categoryToObjectsMapKeys)
                categoryToObjectsMapValues=this.Data.CategoryToObjectsMap(categoryToObjectsMapKeys{ii});
                groupName='';
                groupComment='';
                if strcmp(categoryToObjectsMapKeys{ii},'SCALAR')
                    groupName='Group_Type_Scalar';
                    groupComment="Contains all scalar parameters and signals";
                elseif strcmp(categoryToObjectsMapKeys{ii},'ARRAY')
                    groupName='Group_Type_Array';
                    groupComment="Contains all array parameters and signals";
                elseif strcmp(categoryToObjectsMapKeys{ii},'CURVE')
                    groupName='Group_Type_Curve';
                    groupComment="Contains all curve parameters";
                elseif strcmp(categoryToObjectsMapKeys{ii},'MAP')
                    groupName='Group_Type_Map';
                    groupComment="Contains all map parameters";
                elseif strcmp(categoryToObjectsMapKeys{ii},'CUBOID')
                    groupName='Group_Type_Cuboid';
                    groupComment="Contains all cuboid parameters";
                elseif strcmp(categoryToObjectsMapKeys{ii},'CUBE_4')
                    groupName='Group_Type_Cube_4';
                    groupComment="Contains all cube_4 parameters";
                elseif strcmp(categoryToObjectsMapKeys{ii},'CUBE_5')
                    groupName='Group_Type_Cube_5';
                    groupComment="Contains all cube_5 parameters";
                end
                if(str2double(Version)<double(1.6))&&any(strcmp(groupName,{'Group_Type_CUBE_4','Group_Type_CUBE_5'}))
                    continue;
                else
                    if iscell(categoryToObjectsMapValues)&&~isempty(categoryToObjectsMapValues)||...
                        (isfield(categoryToObjectsMapValues,'Characteristics')&&~isempty(categoryToObjectsMapValues.Characteristics))||...
                        (isfield(categoryToObjectsMapValues,'Measurements')&&~isempty(categoryToObjectsMapValues.Measurements))
                        this.FormatContentsObj.wLine('');
                        this.FormatContentsObj.write('','  /begin GROUP');
                        this.FormatContentsObj.write('    /* Name                   */      ',groupName);
                        this.FormatContentsObj.write('    /* Long identifier        */      ',['"',groupComment,'"']);
                        if~includeComments
                            this.FormatContentsObj.wLine('');
                        end
                        if~isempty(categoryToObjectsMapValues)
                            if isfield(categoryToObjectsMapValues,'Characteristics')&&~isempty(categoryToObjectsMapValues.Characteristics)
                                this.FormatContentsObj.wLine('    /begin REF_CHARACTERISTIC');
                                categoryToObjectsMapValues.Characteristics=unique(categoryToObjectsMapValues.Characteristics);
                                for kk=1:length(categoryToObjectsMapValues.Characteristics)
                                    this.FormatContentsObj.wLine(['      ',categoryToObjectsMapValues.Characteristics{kk}]);
                                end
                                this.FormatContentsObj.wLine('    /end REF_CHARACTERISTIC');
                            end

                            if~isfield(categoryToObjectsMapValues,'Characteristics')&&~isfield(categoryToObjectsMapValues,'Measurements')
                                this.FormatContentsObj.wLine('    /begin REF_CHARACTERISTIC');
                                for kk=1:length(categoryToObjectsMapValues)
                                    this.FormatContentsObj.wLine(['      ',categoryToObjectsMapValues{kk}]);
                                end
                                this.FormatContentsObj.wLine('    /end REF_CHARACTERISTIC');
                            end

                            if isfield(categoryToObjectsMapValues,'Measurements')&&~isempty(categoryToObjectsMapValues.Measurements)
                                this.FormatContentsObj.wLine('    /begin REF_MEASUREMENT');
                                categoryToObjectsMapValues.Measurements=unique(categoryToObjectsMapValues.Measurements);
                                for kk=1:length(categoryToObjectsMapValues.Measurements)
                                    this.FormatContentsObj.wLine(['      ',categoryToObjectsMapValues.Measurements{kk}]);
                                end
                                this.FormatContentsObj.wLine('    /end REF_MEASUREMENT');
                            end
                            this.FormatContentsObj.wLine('  /end GROUP');
                        end
                    end
                end
            end
            this.FormatContentsObj.wLine('');
            if~isempty(this.CustomizeASAP2.BeforeEndModuleContents)
                this.FormatContentsObj.wLine(coder.asap2.UserCustomizeBase.readjustText(this.CustomizeASAP2.BeforeEndModuleContents,'  '));
            end
            this.FormatContentsObj.wLine('  /end MODULE');
            this.FormatContentsObj.wLine('');
            if~isempty(this.CustomizeASAP2.BeforeEndProjectContents)
                this.FormatContentsObj.wLine(coder.asap2.UserCustomizeBase.readjustText(this.CustomizeASAP2.BeforeEndProjectContents,'  '));
            end
            this.FormatContentsObj.wLine('/end PROJECT');
            if includeComments

                this.FormatContentsObj.wLine(this.CustomizeASAP2.writeFileTail);
            end
            this.FormatContentsObj.close();
        end
    end



    methods(Access=private)

        function writeSymbolLink(this,value)
            symbolLink=value.SymbolLink;
            symbolName=symbolLink.SymbolName;
            offset=symbolLink.Offset;
            if~isempty(symbolName)&&~isempty(offset)
                this.FormatContentsObj.wLine(['    SYMBOL_LINK    "',string(symbolName)+'"  '+num2str(offset)]);
            end
        end
    end


    methods(Static,Access=private)
        function ishex=ishex(propertyValue)
            ishex=false;
            expression='^0[xX][0-9a-fA-F]+$';
            if~isempty(regexp(char(propertyValue),expression,'ONCE'))
                ishex=true;
            end
        end
        function addCompuMethodToMap(this,variableOfInterest,compuMethodName)
            compuValues=this.Data.CompuMethodsMap.values;
            compuNames=this.Data.CompuMethodsMap.keys;
            for i=1:this.Data.CompuMethodsMap.size()
                compvalue=compuValues{i};
                compkey=compuNames{i};

                if any(strcmp(variableOfInterest,compvalue.Elements))
                    if numel(compvalue.Elements)==1



                        remove(this.Data.CompuMethodsMap,compkey);
                    end
                    this.Data.CompuMethodsMap(compuMethodName)=compvalue;
                end
            end
        end
        function writeEventData(this,eventIDForRaster)
            if iscell(eventIDForRaster)
                eventID=char(eventIDForRaster);
            else
                eventID=eventIDForRaster;
            end
            if coder.internal.asap2.WriterBase.ishex(eventID)
                this.FormatContentsObj.wLine(['            EVENT  ',eventID]);
            else
                this.FormatContentsObj.wLine(['            EVENT  ',['0x',dec2hex(eventID,4)]]);
            end
        end

        function layout=getToggledLayout(this)
            if strcmp(this.Data.ArrayLayout,'ROW_DIR')
                layout='COLUMN_DIR';
            else
                layout='ROW_DIR';
            end
        end
    end

end












