function Data=CollectMathBlockPortDataTypes(blk,~)


    portDataTypes=get_param(blk,'CompiledPortDataTypes');


    Data=any(strcmp(portDataTypes.Inport,{'double','single'}))...
    ||any(strcmp(portDataTypes.Outport,{'double','single'}));

end
