function[status,msg]=validate(hSrc,hDlg,modelName,fromBuild,callMode)




    if nargin>2
        modelName=convertStringsToChars(modelName);
    end

    if nargin>4
        callMode=convertStringsToChars(callMode);
    end

    status=1;



    if~fromBuild
        if~hSrc.PreConfigFlag&&(isempty(hSrc.Data))
            try
                hSrc.preConfig(hDlg);
            catch me
                status=0;
                msg=me.message;
                return;
            end
        end
    end

    thisObj=hSrc;
    if~fromBuild
        if~isempty(hSrc.cache)
            thisObj=hSrc.cache;
        end
    end

    if fromBuild
        thisObj.ModelHandle=get_param(modelName,'Handle');
    end

    cs=getActiveConfigSet(thisObj.ModelHandle);
    commitBuild=slprivate('checkSimPrm',cs);
    if(~commitBuild)
        msg=DAStudio.message('RTW:fcnClass:validationCanceled');
        return;
    end



    if ishandle(hDlg)
        applyFlag=hDlg.hasUnappliedChanges;
    end

    [status,msg]=thisObj.runValidation(callMode);

    if fromBuild


        thisObj.ArgSpecData=thisObj.Data;
    end


    if ishandle(hDlg)
        hDlg.enableApplyButton(applyFlag);
    end
