function OnPortNameHoverExit(port)



    model=port.container.Name;
    portName=[model,'/',port.PortName];

    blks=find_system(model,'Tag',port.PortName);
    if isempty(blks)
        doBlock(portName);
    else
        for i=1:length(blks)
            doBlock(blks{i});
        end
    end


    function doBlock(portName)

        set_param(portName,'BackGroundColor','white');
        set_param(portName,'ForeGroundColor','black');
