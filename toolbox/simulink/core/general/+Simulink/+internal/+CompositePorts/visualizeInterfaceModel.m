function visualizeInterfaceModel(mode,h)
    persistent g;
    persistent intf;
    persistent model;
    persistent listener;
    persistent fig;
    persistent text

    if strcmpi(mode,'start')
        narginchk(2,2);
        try
            if isnumeric(h)&&ishandle(h)
                g=h;
            else
                g=get_param(h,'Handle');
            end
        catch
            error('Expecting a graph path or handle');
        end

        stopListening();


        fig=figure('Name',sprintf('Interface Model of %s',getfullname(g)),...
        'NumberTitle','off',...
        'MenuBar','None',...
        'Color',[239,235,231]/255,...
        'Position',[1000,200,550,690],...
        'CloseRequestFcn',@(a,b)Simulink.internal.CompositePorts.visualizeInterfaceModel('stop'));
        text=uicontrol(fig,'Style','edit',...
        'FontName','FixedWidth',...
        'FontSize',14,...
        'Position',[20,20,520,650],...
        'Max',100,...
        'Min',1,...
        'HorizontalAlignment','left');


        intf=Simulink.BlockDiagram.Internal.getGraphInterface(g);
        model=mf.zero.getModel(intf);
        listener=@onChange;
        model.addObservingListener(listener);
        listener();
        mlock;
    elseif strcmpi(mode,'stop')
        stopListening();
        delete(fig);
        munlock;
    else
        error('Invalid input');
    end

    function appendString(s)
        text.String={text.String{:},s};
    end

    function onChange(added,modified,removed)
        printInterface();
    end

    function printInterface()
        text.String={};
        parts=intf.parts.toArray();
        for i=1:numel(parts)
            printPart(parts(i));
        end
    end

    function printPart(part)
        appendString(sprintf('\nPart: %s',part.partType));
        ports=part.ports.toArray();
        for i=1:numel(ports)
            printPort(ports(i));
        end
    end

    function printPort(port)
        appendString(sprintf('  Port %d: %s',port.indexOne,port.name));
        blocks=port.blocks.toArray();
        for i=1:numel(blocks)
            printBlock(blocks(i));
        end
    end

    function printBlock(b)
        appendString(sprintf('    Block %d: %s',b.indexOne,b.element));

    end

    function stopListening()
        if~isempty(listener)&&~isempty(model)&&model.isvalid
            model.removeListener(listener);
        end
    end
end
