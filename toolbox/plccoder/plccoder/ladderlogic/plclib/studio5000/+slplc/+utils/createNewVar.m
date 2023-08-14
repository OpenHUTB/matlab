function var=createNewVar(varName,defaultScope,defaultPortIdx,defaultDataType,defaultInitialValue,isFBInstance,varAccess)




    var=struct(...
    'Name',varName,...
    'Scope',defaultScope,...
    'PortType','Hidden',...
    'PortIndex',defaultPortIdx,...
    'DataType',slplc.utils.getDefaultDataType(),...
    'Size','1',...
    'InitialValue','0',...
    'Retentive','Default',...
    'Constant','off',...
    'Address','<empty>',...
    'IsFBInstance',false,...
    'Access',varAccess,...
    'IsUsed',true,...
    'IsAutoImport',false...
    );

    if~strcmpi(defaultScope,'global')
        if strcmpi(varAccess,'read')
            var.Scope='Input';
            var.PortType='Inport';
        elseif strcmpi(varAccess,'write')
            var.Scope='Output';
            var.PortType='Outport';
        end
    else
        if strcmpi(varAccess,'read')
            var.PortType='Inport';
        elseif strcmpi(varAccess,'write')
            var.PortType='Outport';
        end
    end

    if ismember(varName,{'EnableIn','EnableOut'})
        var.PortIndex='1';
    end

    if~isempty(defaultDataType)
        var.DataType=defaultDataType;
    end

    if~isempty(defaultInitialValue)
        var.InitialValue=defaultInitialValue;
    end

    if~isempty(isFBInstance)
        var.IsFBInstance=isFBInstance;
    end

end
