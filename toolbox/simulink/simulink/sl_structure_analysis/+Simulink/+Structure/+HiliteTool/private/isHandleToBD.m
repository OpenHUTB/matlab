function bool=isHandleToBD(element)

    bool=~isempty(element)&&...
    isa(element,'double')&&...
    strcmpi(get_param(element,'type'),'block_diagram');

end