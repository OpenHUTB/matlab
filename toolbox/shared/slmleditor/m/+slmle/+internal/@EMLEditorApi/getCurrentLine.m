function lineNum=getCurrentLine(obj,objectId)




    if obj.logger
        disp(mfilename);
    end


    m=slmle.internal.slmlemgr.getInstance;
    eds=m.getMLFBEditorsFromAllStudios(objectId);


    if~isempty(eds)
        ed=eds{1};

        cursor=ed.Cursor;

        lineNum=cursor(1)-1;
    end

