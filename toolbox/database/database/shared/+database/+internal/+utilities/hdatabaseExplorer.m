function hdatabaseExplorer()










    h=getappdata(groot,'DatabaseExplorerHandle');


    isStartUp=isempty(h)||~isa(h,'handle')||~isvalid(h);

    if isStartUp

        h=dbgui.internal.dbSession();


        setappdata(groot,'DatabaseExplorerHandle',h);


        addlistener(h,'ObjectBeingDestroyed',@removeDatabaseExplorerFromAppData);
    end
end

function removeDatabaseExplorerFromAppData(~,~)
    if isappdata(groot,'DatabaseExplorerHandle')
        rmappdata(groot,'DatabaseExplorerHandle');
    end
end

