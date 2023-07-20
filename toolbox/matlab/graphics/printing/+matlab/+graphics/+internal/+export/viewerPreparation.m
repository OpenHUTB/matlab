function pj=viewerPreparation(pj,mode)




    if strcmp(mode,'prepare')
        pj=viewerPrepare(pj);
    else
        viewerRestore(pj);
    end

end

function pj=viewerPrepare(pj)
    pj.temp.viewers=[];
    if isa(pj.Handles{1},'matlab.graphics.primitive.canvas.JavaCanvas')||...
        isa(pj.Handles{1},'matlab.graphics.primitive.canvas.HTMLCanvas')
        pj=saveAndUpdateViewerState(pj,pj.Handles{1});
    else


        containers=matlab.graphics.internal.export.findContainers(pj.ParentFig);
        for i=1:length(containers)
            viewer=LocalGetSceneViewer(containers{i});
            if~isempty(viewer)
                pj=saveAndUpdateViewerState(pj,viewer);
            end
        end
    end
end

function pj=saveAndUpdateViewerState(pj,viewer)

    pj.temp.viewers(end+1).handle=viewer;
    pj.temp.viewers(end).OpenGL=viewer.OpenGL;
    pj.temp.viewers(end).OpenGLMode=viewer.OpenGLMode;
    pj.temp.viewers(end).ScreenPixelsPerInch=viewer.ScreenPixelsPerInch;
    pj.temp.viewers(end).ScreenPixelsPerInchMode=viewer.ScreenPixelsPerInchMode;
    pj.temp.viewers(end).ColorMode=viewer.ColorMode;
    pj.temp.viewers(end).Color=viewer.Color;

    if pj.rendererOption
        viewerOpenGLSetting=viewer.OpenGL;
        switch lower(pj.Renderer)

        case 'opengl'
            viewerOpenGLSetting='on';
        case 'painters'
            viewerOpenGLSetting='off';
        end




        viewer.OpenGL=viewerOpenGLSetting;
    end


    if isfield(pj.temp,'dpiAdjustment')&&...
        ~isempty(pj.temp.dpiAdjustment)
        dpi=dpi*pj.temp.dpiAdjustment;
    end
    if strcmp(viewer.OpenGL,'on')
        viewer.ScreenPixelsPerInch=pj.DPI;
    end

    if~isempty(pj.BackgroundColor)
        viewer.Color=pj.BackgroundColor;
    end
end

function viewerRestore(pj)



    if isfield(pj.temp,'viewers')
        for idx=1:length(pj.temp.viewers)
            set(pj.temp.viewers(idx).handle,...
            'OpenGL',pj.temp.viewers(idx).OpenGL,...
            'OpenGLMode',pj.temp.viewers(idx).OpenGLMode,...
            'ScreenPixelsPerInch',pj.temp.viewers(idx).ScreenPixelsPerInch,...
            'ScreenPixelsPerInchMode',pj.temp.viewers(idx).ScreenPixelsPerInchMode,...
            'Color',pj.temp.viewers(idx).Color,...
            'ColorMode',pj.temp.viewers(idx).ColorMode);
        end
    end
end

function sceneViewer=LocalGetSceneViewer(container)

    sceneViewer=findobjinternal(container,...
    {'-isa','matlab.graphics.primitive.canvas.JavaCanvas','-or',...
    '-isa','matlab.graphics.primitive.canvas.HTMLCanvas'},...
    '-depth',1);
end
