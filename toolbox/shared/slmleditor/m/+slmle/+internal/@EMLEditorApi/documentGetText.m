function text=documentGetText(obj,objectId)




    if obj.logger
        disp(mfilename);
    end

    text='';
    persistent ISA_SCRIPT;
    if(isempty(ISA_SCRIPT))
        ISA_SCRIPT=sf('get','default','script.isa');
    end

    if sf('get',objectId,'.isa')==ISA_SCRIPT

        try
            filePath=sf('get',objectId,'script.filePath');
            doc=matlab.desktop.editor.findOpenDocument(filePath);
            if(~isempty(doc))

                text=doc.Text;
            end
        catch
        end
        return;
    end


    m=slmle.internal.slmlemgr.getInstance;



    mlfbEds=m.getMLFBEditorsFromAllStudios(objectId);

    if~isempty(mlfbEds)
        ed=mlfbEds{1};

        text=ed.Text;
    end
