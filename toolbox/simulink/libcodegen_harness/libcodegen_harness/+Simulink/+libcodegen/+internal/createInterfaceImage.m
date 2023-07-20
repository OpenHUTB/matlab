function thumbnail_file=createInterfaceImage(dlgSrc)



    ownerH=dlgSrc.ccInfo.ownerHandle;
    name=dlgSrc.ccInfo.name;
    ssName=[name,'/',get_param(ownerH,'Name')];

    thumbnail_file=[tempname,'.png'];

    preferred_width=i_getpref('SimulinkModelThumbnailWidth');
    preferred_height=i_getpref('SimulinkModelThumbnailHeight');
    dstBounds=[0,0,preferred_width,preferred_height];



    scene=[];

    try
        if~slprivate('is_stateflow_based_block',ownerH)
            open_system(ssName,'force');
            oc=onCleanup(@()close_system(ssName));

            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(allStudios)
                modelhandle=get_param(name,'Handle');
                for s=allStudios
                    if s.App.blockDiagramHandle==modelhandle
                        editors=s.App.getAllEditors;
                        for e=editors
                            if strcmp(e.getName,ssName)

                                SLM3I.SLDomain.toggleInterfaceView(false,e,get_param(ssName,'Handle'));
                                editor=s.App.getActiveEditor;


                                scene=editor.getCanvas.Scene;
                                break;
                            end
                        end
                    end
                end
            end
        end
    catch me %#ok unused

    end

    if isempty(scene)
        ss=SLPrint.Snapshot;
        ss.Target=name;
        ss.Format='png';
        ss.SizeMode='UseSpecifiedSize';
        ss.SpecifiedSize=[preferred_width,preferred_height];
        ss.FileName=thumbnail_file;
        ss.snap();
        return;
    end

    p=GLUE2.Portal;
    bounds=scene.Bounds;
    p.targetOutputRect=getTargetOutputRect(p,bounds,dstBounds);
    p.exportOptions.format='png';
    p.exportOptions.fileName=thumbnail_file;
    p.exportOptions.backgroundColorMode='Transparent';


    sx=preferred_width/bounds(3)*double(scene.DpiX);
    sy=preferred_height/bounds(4)*double(scene.DpiY);
    p.exportOptions.resolution=min([sx,sy]);
    p.export(scene,bounds)

end

function outputRect=getTargetOutputRect(portal,srcBounds,dstBounds)
    [offset,scale]=SLPrint.Utils.GetOffsetAndScaleToFitWithAspectRatio(srcBounds,dstBounds);
    trgSize=[dstBounds(3),dstBounds(4)];
    outputRect=[offset,scale*trgSize];


    portal.targetOutputRect=outputRect;
end


function n=i_getpref(prefkey)
    n=250;

    s=settings;
    if~s.hasGroup('simulinkPreferenceFlags')

        return;
    end
    s=s.simulinkPreferenceFlags;
    if~s.hasSetting(prefkey)

        return;
    end
    try
        n=s.(prefkey).ActiveValue;
    catch E


        warning(E.identifier,'%s',E.message);
    end
end
