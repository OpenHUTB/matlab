classdef WorkspaceAndFiguresData<handle

    properties
        ALLOWABLE_SESSION_WORKSPACE_SIZE_BYTES=256e6;
logger
    end

    methods

        function this=WorkspaceAndFiguresData()
            this.logger=connector.internal.Logger('connector::session_m');


            try %#ok<TRYNC>
                overrideBytes=str2double(...
                getenv('MATLAB_ALLOWABLE_SESSION_WORKSPACE_SIZE_BYTES')...
                );
                if(overrideBytes>0)
                    this.ALLOWABLE_SESSION_WORKSPACE_SIZE_BYTES=overrideBytes;
                end
            end
        end

        function data=get(this)
            if this.isWorkspaceTooLarge()
                this.logger.info(['SaveSession: Not saving workspace '...
                ,'due to large workspace size.  Size (bytes): '...
                ,num2str(getBaseWorkspaceSizeInBytes())]);
                return;
            end
            data=struct;
            data.workspace=getWorkspaceVariables();
            data.figures=getOpenFigures();
        end

        function set(this,data)
            if this.isWorkspaceTooLarge()
                return;
            end
            setWorkspaceVariables(data.workspace);



        end

        function reset(~)
            close all force;
            evalin('base','clear');
            evalin('base','clc');
        end

    end

    methods(Access=private)

        function tooLarge=isWorkspaceTooLarge(this)
            tooLarge=getBaseWorkspaceSizeInBytes>...
            this.ALLOWABLE_SESSION_WORKSPACE_SIZE_BYTES;
        end

    end

end





function sz=getBaseWorkspaceSizeInBytes(~)
    ws=evalin('base','whos');
    sz=sum([ws.bytes]);
end

function vars=getWorkspaceVariables()
    varNames=evalin('base','who');

    vars=struct;
    for i=1:numel(varNames)
        name=varNames{i};
        value=evalin('base',name);





        if~(isValidFigureHandle(value)&&isFigureHandleAGUI(value))
            vars.(name)=value;
        end
    end
end



function setWorkspaceVariables(vars)
    if~isstruct(vars)
        return;
    end

    names=fieldnames(vars);

    for i=1:numel(names)
        name=names{i};
        assignin('base',name,vars.(name));
    end
end


function allFigHandles=getOpenFigures()

    allFigHandles=findobj(0,'Type','figure','NumberTitle','on');

    try
        deleteHandles=false(length(allFigHandles),1);

        for i=1:numel(allFigHandles)
            shouldRemove=isFigureHandleAGUI(allFigHandles(i))||...
            isFigureHandleInBaseWS(allFigHandles(i));
            if shouldRemove
                deleteHandles(i)=true;
            end
        end

        allFigHandles(deleteHandles)=[];
    catch err

    end
end



function isGUI=isFigureHandleAGUI(f)

    isGUI=~isempty(f.Tag)...
    ||~isempty(f.Name)...
    ||strcmp(f.NumberTitle,'off')...
    ||strcmp(f.WindowStyle,'modal')...
    ||strcmp(f.Resize,'off');
end




function validFigureHandle=isValidFigureHandle(f)


    try
        validFigureHandle=isvalid(f)&&~istall(f)&&isscalar(f)&&ishghandle(f,'figure');
    catch
        validFigureHandle=false;
    end
end



function isInBaseWS=isFigureHandleInBaseWS(fh)
    isInBaseWS=false;
    varNames=evalin('base','who');
    for i=1:numel(varNames)
        name=varNames{i};
        value=evalin('base',name);
        if isequal(value,fh)
            isInBaseWS=true;
            break;
        end
    end
end
