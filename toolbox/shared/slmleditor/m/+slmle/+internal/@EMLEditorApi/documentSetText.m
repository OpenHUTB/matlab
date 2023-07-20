function out=documentSetText(obj,objectId,text,dirty)




    out=false;
    if obj.logger
        disp(mfilename);
    end

    if sf('get',objectId,'.isa')==14


        out=true;
        return;
    end


    m=slmle.internal.slmlemgr.getInstance;
    ed=m.getMLFBEditor(objectId);

    if~isempty(ed)
        ed.setText(text);
    end

    out=true;

