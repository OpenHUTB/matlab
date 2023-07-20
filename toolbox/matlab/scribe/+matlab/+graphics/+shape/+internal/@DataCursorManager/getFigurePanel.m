function hPanel=getFigurePanel(hFig)










    hPanel=findall(hFig,'Tag','DataCursorMode:FigurePanel',...
    '-class','matlab.graphics.shape.internal.FigurePanel');

    if isempty(hPanel)||~isvalid(hPanel)




        ConstructArgs={...
        'Parent',hFig,...
        'HandleVisibility','off',...
        'Units','pixels',...
        'Tag','DataCursorMode:FigurePanel',...
        'String',getString(message('MATLAB:graphics:datacursormanager:MouseClickOnPlottedData')),...
        'Title','',...
        'Serializable','off'};
        hPanel=feval('matlab.graphics.shape.internal.FigurePanel',ConstructArgs{:});



        figPosition=hgconvertunits(hFig,hFig.Position,hFig.Units,'pixels',groot);
        framePosition=hPanel.Position;
        framePosition(1)=figPosition(3)-framePosition(3)-3;
        framePosition(2)=3;
        hPanel.Position=framePosition;


        addlistener(hPanel,'ObjectBeingDestroyed',@localDelete);


        addlistener(hPanel,'Hit',@localShowModeContextMenu);
    end

    if strcmpi(hPanel.Visible,'off')
        hPanel.Visible='on';
    end

end


function localDelete(src,~)
    hFig=ancestor(src,'figure');
    if~isempty(hFig)

        hDCM=datacursormode(hFig);
        hDCM.Enable='off';
    end
end

function localShowModeContextMenu(src,~)
    if isempty(src.UIContextMenu)

        hFig=ancestor(src,'figure');
        if isempty(hFig)||~strcmp(hFig.SelectionType,'alt')
            return
        end
        dcm=datacursormode(hFig);

        hMenu=dcm.UIContextMenu;
        if~isempty(hMenu)
            hMenu.Position=hFig.CurrentPoint;
            hgfeval(hMenu.Callback,hMenu,[]);
            hMenu.Visible='on';
        end
    end
end
