function update(blockHandle,itemType,varargin)





    if numel(find(strcmp(varargin,'FieldToUpdate')))>1
        error('Simulink:SFunctionBuilder:TooManyFields',DAStudio.message('Simulink:SFunctionBuilder:TooManyFields'));
    end

    blockHandle=Simulink.SFunctionBuilder.internal.verifyBlockHandle(blockHandle);
    sfcnmodel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();

    cliView=struct('publishChannel','cli');
    sfcnmodel.registerView(blockHandle,cliView);

    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance;
    p=inputParser;
    switch(itemType)
    case{'Input','Output'}
        p.addParameter('Name','');
        p.addParameter('FieldToUpdate','');
        p.addParameter('NewValue','');
        p.parse(varargin{:});
        if isempty(p.Results.Name)
            error('Simulink:SFunctionBuilder:InvalidArgumentName',DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentName'));
        end
        if isempty(p.Results.FieldToUpdate)||...
            ~ismember(p.Results.FieldToUpdate,{'Name','DataType','Dimensions','Complexity'})
            error('Simulink:SFunctionBuilder:InvalidArgumentField',DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentField'));
        end
        if isempty(p.Results.NewValue)
            error('Simulink:SFunctionBuilder:InvalidArgumentNewValue',DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentNewValue'));
        end
        oldValue='';
        itemType=char(lower(itemType));
        switch p.Results.FieldToUpdate
        case 'Name'
            newPort={char(p.Results.NewValue),itemType};
            oldValue=char(p.Results.Name);
        case 'DataType'
            newDataType=char(p.Results.NewValue);
            if startsWith(newDataType,'fixdt(')




                try
                    ft=eval(newDataType);
                    isSigned=num2str(strcmp(ft.Signedness,'Signed'));
                    if strcmp(ft.DataTypeMode,'Fixed-point: binary point scaling')
                        newDataType=['Fixdt:binary(',isSigned,',',num2str(ft.WordLength),',',num2str(ft.FractionLength),')'];
                    elseif strcmp(ft.DataTypeMode,'Fixed-point: slope and bias scaling')
                        newDataType=['Fixdt:slope and bias(',isSigned,',',num2str(ft.WordLength),',',num2str(ft.Slope),',',num2str(ft.Bias),')'];
                    else
                        error('Simulink:SFunctionBuilder:InvalidDataType',DAStudio.message('Simulink:SFunctionBuilder:InvalidDataType'));
                    end
                catch
                    error('Simulink:SFunctionBuilder:InvalidDataType',DAStudio.message('Simulink:SFunctionBuilder:InvalidDataType'));
                end
            end
            newPort={char(p.Results.Name),itemType,newDataType};
        case 'Dimensions'
            dimension=p.Results.NewValue;
            if(~isstring(dimension)&&~ischar(dimension))||strlength(dimension)==0
                error('Simulink:SFunctionBuilder:InvalidArgumentDimension',DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentDimension'));
            end
            newPort={char(p.Results.Name),itemType,'',char(dimension)};
        case 'Complexity'
            newPort={char(p.Results.Name),itemType,'','',char(p.Results.NewValue)};
        otherwise
        end
        try
            sfbController.updateItemOfPortTable(blockHandle,newPort,lower(char(p.Results.FieldToUpdate)),oldValue);
        catch ME
            error(ME.identifier,ME.message);
        end
    case 'Parameter'
        p.addParameter('Name','');
        p.addParameter('FieldToUpdate','');
        p.addParameter('NewValue','');
        p.parse(varargin{:});
        if isempty(p.Results.Name)
            error('Simulink:SFunctionBuilder:InvalidArgumentName',DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentName'));
        end
        if isempty(p.Results.FieldToUpdate)||...
            ~ismember(p.Results.FieldToUpdate,{'Name','DataType','Value','Complexity'})
            error('Simulink:SFunctionBuilder:InvalidArgumentField',DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentField'));
        end
        if isempty(p.Results.NewValue)
            error('Simulink:SFunctionBuilder:InvalidArgumentNewValue',DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentNewValue'));
        end
        oldValue='';
        itemType=char(lower(itemType));
        switch p.Results.FieldToUpdate
        case 'Name'
            newPort={char(p.Results.NewValue),itemType};
            oldValue=char(p.Results.Name);
        case 'DataType'
            newPort={char(p.Results.Name),itemType,char(p.Results.NewValue)};
        case 'Complexity'
            newPort={char(p.Results.Name),itemType,'','',char(p.Results.NewValue)};
        case 'Value'
            value=p.Results.NewValue;
            if(~isstring(value)&&~ischar(value))||strlength(value)==0
                error('Simulink:SFunctionBuilder:InvalidArgumentParameterValue',DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentParameterValue'));
            end
            try
                sfbController.updateParameterValue(blockHandle,char(p.Results.Name),char(value));
            catch ME
                error(ME.identifier,ME.message);
            end
            return
        otherwise
        end
        try
            sfbController.updateItemOfPortTable(blockHandle,newPort,lower(char(p.Results.FieldToUpdate)),oldValue);
        catch ME
            error(ME.identifier,ME.message);
        end
    otherwise
        errorStruct.message=DAStudio.message('Simulink:SFunctionBuilder:InvalidField',itemType);
        errorStruct.identifier='Simulink:SFunctionBuilder:InvalidField';
        error(errorStruct);
    end


    sfcnmodel.unregisterView(blockHandle,cliView);
end

