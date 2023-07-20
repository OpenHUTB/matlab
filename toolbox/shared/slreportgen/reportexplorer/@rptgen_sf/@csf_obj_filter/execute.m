function out=execute(c,d,varargin)






    out=[];
    adSF=rptgen_sf.appdata_sf;
    currObj=adSF.CurrentObject;

    if(isempty(currObj)||~ishandle(currObj))
        c.status('No current object',4);
        return;
    end

    if~adSF.isaSF(currObj,c.ObjectType)

        return;
    end


    if~rptgen_ud.verifyChildCount(currObj,c.repMinChildren)
        return;
    end

    out=createDocumentFragment(d);

    if c.addAnchor
        anchor=makeLinkScalar(rptgen_sf.propsrc_sf,...
        currObj,...
        [],...
        'anchor',...
        d,...
        '');
        out.appendChild(anchor);
    end

    out=c.runChildren(d,out);