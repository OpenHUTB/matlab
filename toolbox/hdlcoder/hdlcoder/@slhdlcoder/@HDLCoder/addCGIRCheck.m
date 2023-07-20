


function addCGIRCheck(blockOrModelPath,severityLevel,messageText,messageID)
    hdrv=hdlcurrentdriver;



    if isempty(hdrv)
        return;
    end

    if isempty(messageID)
        messageID='hdlcoder:makehdl:GenericWarning';
    end

    T=regexp(blockOrModelPath,'/','split');
    if~isempty(blockOrModelPath)&&~isempty(T{1})
        mdlTopName=T{1};
    else
        if isempty(blockOrModelPath)
            models=hdrv.ChecksCatalog.keys();
            if isempty(models)
                mdlTopName=hdrv.ModelName;
            else
                mdlTopName=models{1};
            end
            blockOrModelPath=mdlTopName;
        else
            mdlTopName=blockOrModelPath;
        end
    end

    qchk.level=severityLevel;
    qchk.path=blockOrModelPath;
    qchk.message=messageText;
    qchk.MessageID=messageID;
    qchk.type='model';

    if~isempty(blockOrModelPath)
        try



            slbh=get_param(blockOrModelPath,'Object');
            if isprop(slbh,'BlockType')
                qchk.type='block';
            end
        catch

            qchk.path=mdlTopName;
        end
    end

    hdrv.updateChecksCatalog(mdlTopName,qchk);
end
