function obj=current()

    if~isempty(systemcomposer.arch.BaseConnector.current())
        obj=systemcomposer.arch.BaseConnector.current();

    elseif~isempty(systemcomposer.arch.BasePort.current())
        obj=systemcomposer.arch.BasePort.current();

    elseif~isempty(systemcomposer.arch.BaseComponent.current())
        obj=systemcomposer.arch.BaseComponent.current();

    else
        obj=systemcomposer.arch.Architecture.current();

    end
