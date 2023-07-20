



function imgOnly=onlyImagesSelected(cbinfo)
    imgOnly=true;
    sel=cbinfo.getSelection();
    for n=1:length(sel)
        if~SLStudio.toolstrip.internal.objIsImage(sel(n))
            imgOnly=false;
            break;
        end
    end
end