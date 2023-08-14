function addFigureRendererListener(f)






    if~isprop(f,'SurfaceBrushingRendererListener')
        p=addprop(f,'SurfaceBrushingRendererListener');
        p.Hidden=true;
        p.Transient=true;
    end
    if isempty(f.SurfaceBrushingRendererListener)
        f.SurfaceBrushingRendererListener=event.proplistener(f,f.findprop('Renderer'),...
        'PostSet',@(e,d)localRepaintSurfaceBrushing(f));
    end

    function localRepaintSurfaceBrushing(f)




        allSurfaces=findall(f,'type','surf');
        if~isempty(allSurfaces)
            allSurfaces=findall(allSurfaces,'-function',@(s)any(s.BrushData(:)));
            for k=1:length(allSurfaces)
                allSurfaces(k).BrushHandles.rendererChanged;
            end
        end
