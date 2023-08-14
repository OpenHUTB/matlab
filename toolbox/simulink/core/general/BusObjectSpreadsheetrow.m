classdef BusObjectSpreadsheetrow<handle






    properties
        m_dialogSource;
        m_SelectedRow;
        m_rowNumber;
        m_busElement;

        m_CachedDataSource;
        m_busObjectName;
        m_isSlidStructureType;
        m_parentSS;
        m_busObjectMode;
    end

    properties(Access=private,Constant=true)
        m_Name=DAStudio.message('Simulink:busEditor:PropElementName');
        m_DataType=DAStudio.message('Simulink:busEditor:PropDataType');
        m_Type=DAStudio.message('Simulink:busEditor:PropType');
        m_Complexity=DAStudio.message('Simulink:busEditor:PropComplexity');
        m_Dimension=DAStudio.message('Simulink:busEditor:PropDimensions');
        m_Min=DAStudio.message('Simulink:busEditor:PropMin');
        m_Max=DAStudio.message('Simulink:busEditor:PropMax');
        m_DimensionsMode=DAStudio.message('Simulink:busEditor:PropDimensionsMode');
        m_SampleTime=DAStudio.message('Simulink:busEditor:PropSampleTime');
        m_Unit=DAStudio.message('Simulink:busEditor:PropUnits');
        m_Description=DAStudio.message('Simulink:busEditor:PropDescription');
    end

    methods
        function this=BusObjectSpreadsheetrow(parent,dialogSource,row,selectedRow,cachedDataSource,busObjectName,isSlidStructureType)
            this.m_parentSS=parent;
            this.m_dialogSource=dialogSource;
            this.m_SelectedRow=selectedRow;
            this.m_CachedDataSource=cachedDataSource;
            this.m_rowNumber=row;
            this.m_busElement=this.m_dialogSource.Elements(this.m_rowNumber);
            this.m_busObjectName=busObjectName;
            this.m_isSlidStructureType=isSlidStructureType;
            this.m_busObjectMode=false;

            if slfeature('CUSTOM_BUSES')==1
                this.m_busObjectMode=isa(this.m_parentSS.m_BusObject,'Simulink.ConnectionBus');
            end
            if slfeature('ClientServerInterfaceEditor')==1
                this.m_busObjectMode=this.m_busObjectMode||isa(this.m_parentSS.m_BusObject,'Simulink.ServiceBus');
            end
        end

        function bIsValid=isValidProperty(this,aPropName)
            if this.m_busObjectMode
                bIsValid=any(strcmp({this.m_Name,this.m_Type,this.m_Description},aPropName));
            else
                bIsValid=any(strcmp({this.m_Name,this.m_DataType,this.m_Complexity,...
                this.m_Dimension,this.m_Min,this.m_Max,this.m_DimensionsMode,...
                this.m_SampleTime,...
                this.m_Unit,this.m_Description},aPropName));
            end
        end

        function[bIsReadOnly]=isReadOnlyProperty(this,~)
            if this.m_isSlidStructureType
                bIsReadOnly=true;
            else
                bIsReadOnly=false;
            end
        end

        function[bIsEditable]=isEditableProperty(this,~)
            dlg=getDialog(this);
            selData=dlg.getUserData('DeleteElementBtn');
            if numel(selData.keys)>1
                areMultipleRowsSelected=true;
            else
                areMultipleRowsSelected=false;
            end
            if this.m_isSlidStructureType||areMultipleRowsSelected
                bIsEditable=false;
            else
                bIsEditable=true;
            end
        end

        function propValues=getPropAllowedValues(this,aPropName)
            propValues={};
            try
                if this.m_busObjectMode
                    if strcmpi(aPropName,this.m_Type)
                        if slfeature('CUSTOM_BUSES')==1
                            busTypes=getListOfBusTypes(this);



                            physmodDoms=[];
                            if Simulink.internal.isSimscapeInstalledAndLicensed
                                physmodDoms=cellfun(@(elem)['Connection: ',elem],simscape.internal.availableDomains(),...
                                'UniformOutput',false);
                            end
                            propValues=vertcat(busTypes,physmodDoms(:));
                        end
                    else
                        propValues={};
                    end
                else
                    switch(aPropName)
                    case this.m_DimensionsMode
                        propValues={'Fixed','Variable'};
                    case this.m_DataType
                        busTypes=getListOfBusTypes(this);
                        propValues=[getListOfNonBusBuiltinDataTypes(this);busTypes;getListOfAliasAndNumericTypes(this)];
                    case this.m_Complexity
                        propValues={'real','complex'};
                    otherwise
                        propValues={};
                    end
                end
            catch me
                this.reportError(this,me);
            end
        end

        function aPropValue=getPropValue(this,aPropName)




            longPrecision=16;

            try
                if this.m_busObjectMode
                    switch(aPropName)
                    case this.m_Name
                        aPropValue=this.m_busElement.Name;
                    case this.m_Description
                        aPropValue=this.m_busElement.Description;
                    case this.m_Type
                        aPropValue=this.m_busElement.Type;
                    end
                else
                    if startsWith(this.m_busElement.DataType,'ValueType:')
                        switch(aPropName)
                        case this.m_Name
                            aPropValue=this.m_busElement.Name;
                        case this.m_DataType
                            aPropValue=this.m_busElement.DataType;
                        otherwise
                            aPropValue='';
                        end
                    else
                        switch(aPropName)
                        case this.m_Name
                            aPropValue=this.m_busElement.Name;
                        case this.m_Dimension
                            dims=this.m_busElement.Dimensions;
                            if isnumeric(dims)
                                aPropValue=mat2str(dims);
                            else
                                assert(ischar(dims)||isstring(dims));
                                aPropValue=dims;
                            end
                        case this.m_DimensionsMode
                            aPropValue=this.m_busElement.DimensionsMode;
                        case this.m_Min
                            aPropValue=num2str(this.m_busElement.Min,longPrecision);
                            if isempty(aPropValue)
                                aPropValue='[]';
                            end
                        case this.m_Max
                            aPropValue=num2str(this.m_busElement.Max,longPrecision);
                            if isempty(aPropValue)
                                aPropValue='[]';
                            end
                        case this.m_SampleTime
                            aPropValue=num2str(this.m_busElement.SampleTime,longPrecision);
                        case this.m_Unit
                            aPropValue=this.m_busElement.Unit;
                        case this.m_Description
                            aPropValue=this.m_busElement.Description;
                        case this.m_DataType
                            aPropValue=this.m_busElement.DataType;
                        case this.m_Complexity
                            aPropValue=this.m_busElement.Complexity;
                        end
                    end
                end
            catch me
                this.reportError(this,me);
            end
        end

        function aPropValue=getPropDataType(this,aPropName)
            try
                if this.m_busObjectMode
                    switch(aPropName)
                    case this.m_Name
                        aPropValue='edit';
                    case this.m_Description
                        aPropValue='edit';
                    case this.m_Type
                        aPropValue='';
                    end
                else
                    switch(aPropName)
                    case this.m_Name
                        aPropValue='edit';
                    case this.m_Dimension
                        aPropValue='edit';
                    case this.m_DimensionsMode
                        aPropValue='enum';
                    case this.m_Min
                        aPropValue='edit';
                    case this.m_Max
                        aPropValue='edit';
                    case this.m_SampleTime
                        aPropValue='edit';
                    case this.m_Unit
                        aPropValue='edit';
                    case this.m_Description
                        aPropValue='edit';
                    case this.m_DataType
                        aPropValue='';
                    case this.m_Complexity
                        aPropValue='enum';
                    end
                end
            catch me
                this.reportError(this,me);
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            dlg=getDialog(this);




            DialogState=dlg.getUserData('MoveElementUpBtn');
            tempBusObject=DialogState.tempBusObject;



            selectedRowsMap=dlg.getUserData('DeleteElementBtn');

            if~isempty(selectedRowsMap)
                this.m_SelectedRow=str2double(selectedRowsMap.keys);
            end
            this.m_busElement=tempBusObject.Elements(this.m_SelectedRow);



            busElementTemp=this.m_busElement;

            try
                if this.m_busObjectMode
                    switch aPropName
                    case this.m_Name
                        this.m_busElement.Name=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).Name=aPropValue;

                    case this.m_Description
                        this.m_busElement.Description=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).Description=aPropValue;

                    case this.m_Type
                        this.m_busElement.Type=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).Type=aPropValue;
                    end
                else
                    switch aPropName
                    case this.m_Name
                        this.m_busElement.Name=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).Name=aPropValue;

                    case this.m_DataType
                        this.m_busElement.DataType=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).DataType=aPropValue;

                    case this.m_Complexity
                        this.m_busElement.Complexity=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).Complexity=aPropValue;

                    case this.m_Dimension
                        dimsInNumeric=str2num(aPropValue);%#ok<ST2NM>
                        if(isnumeric(dimsInNumeric)&&~isempty(dimsInNumeric))
                            aPropValue=dimsInNumeric;
                        end
                        this.m_busElement.Dimensions=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).Dimensions=aPropValue;

                    case this.m_Min
                        this.m_busElement.Min=str2double(aPropValue);
                        tempBusObject.Elements(this.m_rowNumber).Min=str2double(aPropValue);

                    case this.m_Max
                        this.m_busElement.Max=str2double(aPropValue);
                        tempBusObject.Elements(this.m_rowNumber).Max=str2double(aPropValue);

                    case this.m_DimensionsMode
                        this.m_busElement.DimensionsMode=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).DimensionsMode=aPropValue;

                    case this.m_SampleTime
                        this.m_busElement.SampleTime=str2double(aPropValue);
                        tempBusObject.Elements(this.m_rowNumber).SampleTime=str2double(aPropValue);

                    case this.m_Unit
                        this.m_busElement.Unit=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).Unit=aPropValue;

                    case this.m_Description
                        this.m_busElement.Description=aPropValue;
                        tempBusObject.Elements(this.m_rowNumber).Description=aPropValue;
                    end
                end



                DialogState.tempBusObject=tempBusObject;
                dlg.setUserData('MoveElementUpBtn',DialogState);
            catch ex
                dp=DAStudio.DialogProvider;
                d=dp.errordlg(ex.message,'Error',true);


                tempBusObject.Elements(this.m_SelectedRow)=busElementTemp;
            end
            selectionData.selectedRows=this.m_rowNumber;
            selectionData.selData=[];
            dlg.setUserData('MoveElementDownBtn',selectionData);

            isSpreadsheetUpdating=true;
            dlg.setUserData('BusObjectSpreadsheet',isSpreadsheetUpdating);
            busobjectSpreadsheetWidget=dlg.getWidgetInterface('BusObjectSpreadsheet');
            busobjectSpreadsheetWidget.update();
        end
    end

    methods(Access=private)
        function reportError(~,me)
            dp=DAStudio.DialogProvider;
            title=DAStudio.message('Simulink:utility:ErrorDialogSeverityError');
            dp.errordlg(me.message,title,true);
        end

        function numericAndAliasTypes=getListOfAliasAndNumericTypes(h)
            cachedDataSource=h.m_CachedDataSource;
            numericAndAliasTypes={};

            if isempty(cachedDataSource)
                wksVariables=evalin('base','whos');
                for i=1:numel(wksVariables)
                    if strcmp(wksVariables(i).class,'Simulink.NumericType')||strcmp(wksVariables(i).class,'Simulink.AliasType')
                        aliasOrNumericTypeName=wksVariables(i).name;
                        numericAndAliasTypes=vertcat(numericAndAliasTypes,aliasOrNumericTypeName);%#ok<AGROW>
                    end
                end
            else

                ddAliasTypes=cachedDataSource.getEntriesWithClass('Global','Simulink.NumericType');
                ddNumericTypes=cachedDataSource.getEntriesWithClass('Global','Simulink.AliasType');
                ddAliasAndNumericTypes=vertcat(ddAliasTypes,ddNumericTypes);
                for i=1:numel(ddAliasAndNumericTypes)
                    typeName=ddAliasAndNumericTypes{i,1};
                    numericAndAliasTypes=vertcat(numericAndAliasTypes,typeName);%#ok<AGROW>
                end
            end
        end

        function busTypes=getListOfBusTypes(h)
            cachedDataSource=h.m_CachedDataSource;
            busTypes={};
            if h.m_busObjectMode
                className='Simulink.ConnectionBus';
            else
                className='Simulink.Bus';
            end

            if isempty(cachedDataSource)
                wksVariables=evalin('base','whos');
                for i=1:numel(wksVariables)
                    if strcmp(wksVariables(i).class,className)&&~strcmp(wksVariables(i).name,h.m_busObjectName)
                        busName=append('Bus:',' ',wksVariables(i).name);
                        busTypes=vertcat(busTypes,busName);
                    end
                end
            else
                ddBusObjects=cachedDataSource.getEntriesWithClass('Global',className);

                for i=1:numel(ddBusObjects)
                    if~strcmp(ddBusObjects{i},h.m_busObjectName)
                        busName=append('Bus:',' ',ddBusObjects{i});
                        busTypes=vertcat(busTypes,busName);
                    end
                end
            end
        end

        function builtins=getListOfNonBusBuiltinDataTypes(~)
            builtins=[Simulink.DataTypePrmWidget.getBuiltinList('NumHalfBool');...
            'fixdt(1,16)';'fixdt(1,16,0)';'fixdt(1,16,2^0,0)';'string';'Enum:<class name>';'<data type expression>'];
        end

        function dlg=getDialog(this)
            dlgs=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag','BusObjectDialog');
            dlg={};


            for i=numel(dlgs):-1:1
                if isequal(this.m_parentSS,dlgs(i).getWidgetSource('BusObjectSpreadsheet'))
                    dlg=dlgs(i);
                    break;
                end
            end
        end
    end
end
