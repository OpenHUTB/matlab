function openDomainPropertyInspector(model)

    assert(bdIsLoaded(model)&&...
    strcmp(get_param(model,'Type'),'block_diagram'));

























    set_param(model,'SetExecutionDomain','on');
    set_param(model,'ExecutionDomainType','ExportFunction');
end
