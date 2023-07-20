function iFace=getModePanelInterface(hFig)








    hPanel=findall(hFig,'Tag','DataCursorMode:FigurePanel',...
    '-class','matlab.graphics.shape.internal.FigurePanel');

    if~isempty(hPanel)
        iFace=localCreateInterface(hPanel);
    else
        iFace=[];
    end
end


function iFace=localCreateInterface(hPanel)


    iFace=struct(...
    'isValid',@isValid,...
    'setData',@setData,...
    'removeData',@removeData);



    if~isprop(hPanel,'DataCursorMode_DataSource')
        p=addprop(hPanel,'DataCursorMode_DataSource');
        p.Hidden=true;
        p.Transient=true;
    end

    function ret=isValid(src)


        ret=isvalid(hPanel)&&~strcmp(hPanel.BeingDeleted,'on');
        if nargin
            ret=ret&&ancestor(hPanel,'figure')==ancestor(src,'figure');
        end
    end

    function setData(src,str,title)
        if isvalid(hPanel)


            hPanel.String=str;
            hPanel.Title=title;
            hPanel.DataCursorMode_DataSource=src;
            hPanel.Visible='on';
        end
    end

    function removeData(src)
        if isvalid(hPanel)


            currentSrc=hPanel.DataCursorMode_DataSource;
            if~isempty(currentSrc)&&src==currentSrc
                hPanel.String=getString(message('MATLAB:graphics:datacursormanager:MouseClickOnPlottedData'));
                hPanel.Title='';
            end
        end
    end
end
