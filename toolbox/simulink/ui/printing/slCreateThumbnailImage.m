function slCreateThumbnailImage(modelname,thumbnail_file,varargin)









    if exist(thumbnail_file,'file')

        fileattrib(thumbnail_file,'+w');
        delete(thumbnail_file);
    end


    if~matlab.ui.internal.hasDisplay
        return;
    end

    status=get_param(modelname,'SimulationStatus');
    switch status
    case{'updating','initializing','running','paused'}



        return;
    end

    if~ischar(modelname)
        modelname=get_param(modelname,'Name');
    end

    try
        i_create(modelname,thumbnail_file,varargin{:});
    catch E

        if~strcmp(E.identifier,...
            'glue2:portal:BadContextCannotUpdateBlockGraphics')
            rethrow(E);
        end
    end
end


function i_create(modelname,thumbnail_file,varargin)

    if numel(varargin)>0
        p=inputParser;
        p.addParameter('Width',i_default_image_size,@isnumeric);
        p.addParameter('Height',i_default_image_size,@isnumeric);
        p.parse(varargin{:});
        preferred_width=p.Results.Width;
        preferred_height=p.Results.Height;
    else

        [preferred_width,preferred_height]=i_getprefs;
    end


    scene=[];
    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    if~isempty(allStudios)
        modelhandle=get_param(modelname,'Handle');
        for s=allStudios
            if s.App.blockDiagramHandle==modelhandle
                editors=s.App.getAllEditors;
                for e=editors
                    if strcmp(e.getName,modelname)


                        scene=e.getCanvas.Scene;
                        break;
                    end
                end
            end
        end
    end

    if isempty(scene)




        ss=SLPrint.Snapshot;
        ss.Target=modelname;
        ss.Format='png';
        ss.SizeMode='UseSpecifiedSize';
        ss.SpecifiedSize=[preferred_width,preferred_height];
        ss.FileName=thumbnail_file;
        ss.setIsSaveThumbnailExportFlag();
        ss.snap();
        return;
    end



    p=GLUE2.Portal;
    p.exportOptions.format='png';
    p.exportOptions.fileName=thumbnail_file;
    p.exportOptions.backgroundColorMode=get_param(0,'ExportBackgroundColorMode');

    aspectRatio=preferred_width/preferred_height;
    bounds=scene.Bounds;
    w=bounds(3);
    h=bounds(4);

    if w/h<aspectRatio
        w2=h*aspectRatio;
        bounds(1)=bounds(1)-(w2-w)/2;
        bounds(3)=w2;
    else
        h2=w/aspectRatio;
        bounds(2)=bounds(2)-(h2-h)/2;
        bounds(4)=h2;
    end


    padding=[10,10,10,10];
    bounds(1)=bounds(1)-padding(1);
    bounds(2)=bounds(2)-padding(2);
    bounds(3)=bounds(3)+padding(2)+padding(4);
    bounds(4)=bounds(4)+padding(1)+padding(3);


    sx=preferred_width/bounds(3)*double(scene.DpiX);
    sy=preferred_height/bounds(4)*double(scene.DpiY);
    p.exportOptions.resolution=min([sx,sy]);
    p.export(scene,bounds);

end


function[w,h]=i_getprefs
    s=settings;
    if~s.hasGroup('simulinkPreferenceFlags')

        w=i_default_image_size;
        h=i_default_image_size;
        return;
    end
    s=s.simulinkPreferenceFlags;
    w=i_get(s,'SimulinkModelThumbnailWidth');
    h=i_get(s,'SimulinkModelThumbnailHeight');
end


function val=i_get(s,prefkey)
    val=i_default_image_size;
    if s.hasSetting(prefkey)
        try
            val=s.(prefkey).ActiveValue;
        catch E


            warning(E.identifier,'%s',E.message);
        end
    end
end


function s=i_default_image_size
    s=500;
end
