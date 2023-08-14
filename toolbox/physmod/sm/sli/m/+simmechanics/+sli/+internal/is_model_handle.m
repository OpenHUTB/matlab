function isMdlH=is_model_handle(hdl)

    isMdlH=false;
    if isnumeric(hdl)&&is_simulink_handle(hdl)
        type=get_param(hdl,'Type');
        if strcmpi(type,'block_diagram')
            bdType=get_param(hdl,'BlockDiagramType');
            if strcmpi(bdType,'model')
                isMdlH=true;
            end
        end
    end