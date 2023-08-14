function out=execute(c,d,varargin)






    out=[];

    adSF=rptgen_sf.appdata_sf;
    id=adSF.CurrentObject;
    if isempty(id)||~ishandle(id)
        c.status('No current object',2);
        return;
    end


    if~adSF.getTypeInfo(id,'isGraphical')
        c.status(sprintf(getString(message('RptgenSL:rsf_csf_obj_snap:nonGraphicalObjectLabel'))),4);
        return;
    end


    if~rptgen_ud.verifyChildCount(id,c.picMinChildren)
        c.status(getString(message('RptgenSL:rsf_csf_obj_snap:notEnoughChildrenLabel')),4);
        return;
    end


    if c.AvoidRepeatSnapshot&&...
        ~isempty(adSF.LegiblePictureObjects)&&...
        any(adSF.LegiblePictureObjects==id)
        c.status('Object has already been displayed in another picture',4);
        return;




    end

    out=gr_makeGraphic(c,d,id);


