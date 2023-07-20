



function style=highlightObjs(hSegments,hObjs,varargin)

    import Simulink.SLHighlight.*;

    style=[];



    indexToRemove=[];

    for i=1:length(hSegments)
        try
            get_param(hSegments(i),'Name');
        catch
            indexToRemove=[indexToRemove;i];
        end
    end

    hSegments(indexToRemove)=[];

    indexToRemove=[];
    for i=1:length(hObjs)
        try
            get_param(hObjs(i),'Name');
        catch
            indexToRemove=[indexToRemove;i];
        end
    end

    hObjs(indexToRemove)=[];

    try
        style=highlightSegments(hSegments,hObjs,varargin{:});
    catch

    end

end