function info=rendererinfo(h)











    narginchk(0,1);







    if nargin==0
        isWeb=feature('webfigures');
        if isWeb
            f=uifigure('Visible','off','HandleVisibility','on');
            h=axes('Parent',f);
        else
            info=getOpenglInfo();
            return
        end
    end

    drawnow;


    l=length(h);
    info=struct('GraphicsRenderer',cell(1,l),...
    'Vendor',cell(1,l),...
    'Version',cell(1,l),...
    'RendererDevice',cell(1,l),...
    'Details',cell(1,l));

    for i=1:length(h)
        handle=h(i);
        if iscell(handle)
            handle=handle{1};
        end

        if~isValidInputHandle(handle)
            error(message('MATLAB:rendererinfo:InvalidInputHandle'));
        end

        if isPainterRenderer(handle)
            info(i)=getPaintersInfo;
        else
            canvas=getCanvasInfo(handle);
            if isValidState(handle,canvas)
                try
                    info(i)=canvas.getGLInfo();
                catch e
                    error(message(e.identifier));
                end
            else
                error(message('MATLAB:rendererinfo:UnableToGetOutput'));
            end
        end
    end


    if nargin==0
        close(f);
    end
end

function valid=isValidInputHandle(handle)



    valid=isscalar(handle)&&...
    isgraphics(handle)&&...
    (isa(handle,'matlab.graphics.axis.AbstractAxes')||...
    isa(handle,'matlab.graphics.chart.Chart'));
end

function canvas=getCanvasInfo(h)


    if isa(h,'matlab.ui.internal.mixin.CanvasHostMixin')

        canvas=h.getCanvas();
    elseif isgraphics(h)

        canvas=ancestor(h,'matlab.graphics.primitive.canvas.Canvas','node');
    else
        error(message('MATLAB:rendererinfo:InvalidInputHandle'));
    end
end

function result=isValidState(h,canvas)



    result=true;

    if isempty(canvas)
        result=false;
        return;
    end



    hFig=ancestor(h,'matlab.ui.Figure','node');
    if isvalid(hFig)&&strcmpi(hFig.Visible,'off')&&...
        ~matlab.ui.internal.isUIFigure(hFig)
        result=false;
        if isequal(canvas.isGLInfoAvailable(),'on')


            result=true;
        end
    end
end

function result=isPainterRenderer(h)

    result=false;

    hFig=ancestor(h,'matlab.ui.Figure','node');
    if isvalid(hFig)
        if strcmpi(hFig.Renderer,'painters')
            result=true;
        end
    end
end

function painterInfo=getPaintersInfo()


    painterInfo.GraphicsRenderer='MathWorks Painters';
    painterInfo.Vendor='The MathWorks Inc.';
    painterInfo.Version=['R',version('-release')];
    painterInfo.RendererDevice=version('-java');
    painterInfo.Details=struct;
end

function info=getOpenglInfo()


    openglInfo=opengl('data');
    info=struct('GraphicsRenderer',cell(1,1),...
    'Vendor',cell(1,1),...
    'Version',cell(1,1),...
    'RendererDevice',cell(1,1),...
    'Details',struct);
    info.GraphicsRenderer='';

    info.Vendor=openglInfo.Vendor;
    info.RendererDevice=openglInfo.Renderer;
    info.Version=openglInfo.Version;

    fields={'RendererDriverVersion',...
    'RendererDriverReleaseDate','HardwareSupportLevel',...
    'SupportsDepthPeelTransparency','SupportsAlignVertexCenters',...
    'SupportsGraphicsSmoothing','MaxTextureSize','MaxFrameBufferSize'};
    for i=1:size(fields,2)
        field=fields{i};
        if isfield(openglInfo,field)
            info.Details.(field)=openglInfo.(field);
        end
    end

    if isfield(info.Details,'RendererDriverReleaseDate')&&...
        ~isempty(info.Details.RendererDriverReleaseDate)
        info.Details.RendererDriverReleaseDate=char(...
        datetime(info.Details.RendererDriverReleaseDate,'Format','uuuu-MM-dd'));
    end

    isSoftware=openglInfo.Software;
    if(isa(isSoftware,'logical')&&isSoftware)||...
        (isa(isSoftware,'char')&&strcmp(isSoftware,'true'))

        if~strcmp(info.RendererDevice,'None')
            info.GraphicsRenderer='OpenGL Software';
        end
    else
        info.GraphicsRenderer='OpenGL Hardware';
    end

    if isfield(info.Details,'HardwareSupportLevel')

        capitalizeFirstCharacter=@(x)[upper(x(1)),x(2:end)];
        hardwareSupportLevel=info.Details.HardwareSupportLevel;
        info.Details.HardwareSupportLevel=capitalizeFirstCharacter(hardwareSupportLevel);
    end
end
