function errmsg=generateErrMsg(obj,showUI)




    if obj.BlockReplacementsEnforced||obj.StandAloneMode
        compatibilityMsg=getString(message('Sldv:xform:BlkReplacer:GenErrMsg:BlockRepFailed'));
    else
        compatibilityMsg=getString(message('Sldv:xform:BlkReplacer:GenErrMsg:CheckCompatFailed'));
    end
    modelHToReportError=[];

    if obj.ErrorGroup==3

        modelHToReportError=obj.MdlInfo.ModelH;
        replacementModelH=obj.MdlInfo.ModelH;
    elseif obj.ErrorGroup==2

        modelHToReportError=obj.ModelH;
        replacementModelH=obj.MdlInfo.ModelH;
    elseif obj.ErrorGroup==1

        modelHToReportError=obj.ModelH;
        replacementModelH=[];
    end

    if~isempty(modelHToReportError)
        sldvshareprivate('avtcgirunsupcollect','clear');

        sldvshareprivate('avtcgirunsupcollect','push',modelHToReportError,'sldv',...
        getString(message('Sldv:xform:BlkReplacer:GenErrMsg:FailedInit','$PRODUCT$',compatibilityMsg)),...
        'Sldv:Compatibility:BlockReplacement');

        populateErrorMessages(obj.ErrorMex,modelHToReportError,replacementModelH,obj.ErrorGroup);

        if obj.ErrorGroup==3
            warningIds=Sldv.xform.BlkReplacer.listWarningsToTurnOff;
            warningStatus=Sldv.xform.BlkReplacer.turnOffWarnings(warningIds);

            save_system(modelHToReportError);
            open_system(modelHToReportError);

            Sldv.xform.BlkReplacer.restoreWarningStatus(warningIds,warningStatus);
        end
        if(obj.StandAloneMode)
            errmsg=sldvshareprivate('avtcgirunsupdialog',modelHToReportError,showUI);
        else
            errmsg='';
        end
    else
        errmsg=genErrorMessage(obj.ErrorMex,modelHToReportError,replacementModelH,obj.ErrorGroup);
        if showUI
            sldvshareprivate('local_error_dlg',errmsg);
        end
    end
end

function populateErrorMessages(mException,modelHToReportError,replacementModelH,errorGroup)

    assert(isa(mException,'MException'));
    if~isempty(mException.cause)
        mExceptionCauseFlat=sldvshareprivate('util_get_error_causes',mException,true);
        messagesToGenerate=cell(1,length(mExceptionCauseFlat)+1);
        if errorGroup==2
            originalMessage=strrep(mException.message,...
            get_param(replacementModelH,'Name'),get_param(modelHToReportError,'Name'));
            newExc=MException(mException.identifier,originalMessage);
            messagesToGenerate{1}=newExc;
            for idx=1:length(mExceptionCauseFlat)
                filterCauseMsg=filteredMessage(mExceptionCauseFlat{idx},replacementModelH,modelHToReportError);
                newExc=MException(mExceptionCauseFlat{idx}.identifier,'%s',filterCauseMsg);
                messagesToGenerate{idx+1}=newExc;
            end
        else
            messagesToGenerate{1}=mException;
            messagesToGenerate(2:end)=mExceptionCauseFlat;
        end
        sldvshareprivate('util_add_error_causes',modelHToReportError,messagesToGenerate);
    else
        messagesToGenerate{1}=mException;
        sldvshareprivate('util_add_error_causes',modelHToReportError,messagesToGenerate);
    end
end

function errMsg=genErrorMessage(mException,modelHToReportError,replacementModelH,errorGroup)
    if isa(mException,'MException')&&~isempty(mException.cause)
        causeExcp=mException;
        while true
            if isa(causeExcp,'MException')&&~isempty(causeExcp.cause)
                causeExcp=causeExcp.cause{1};
            else
                break;
            end
        end
        if errorGroup==2
            originalMessage=strrep(mException.message,...
            sprintf('''%s''',get_param(replacementModelH,'Name')),getString(message('Sldv:xform:BlkReplacer:GenErrMsg:ReplaceModel')));
            filterCauseMsg=filteredMessage(causeExcp,replacementModelH,modelHToReportError);
        else
            originalMessage=mException.message;
            filterCauseMsg=causeExcp.message;
        end
        errMsg=[originalMessage,'. ',getString(message('Sldv:xform:BlkReplacer:GenErrMsg:Cause')),': ',filterCauseMsg];
    else
        errMsg=mException.message;
    end
end

function filterCauseMsg=filteredMessage(causeExcp,replacementModelH,modelHToReportError)
    if sldvshareprivate('util_is_related_exc',causeExcp,Sldv.utils.errorIdsForStrictBusMsg)
        filterCauseMsg=getString(message('Sldv:xform:BlkReplacer:GenErrMsg:BlockDiagram',get_param(modelHToReportError,'Name'),char(10)));
    else
        filterCauseMsg=strrep(causeExcp.message,...
        get_param(replacementModelH,'Name'),get_param(modelHToReportError,'Name'));
        if strcmp(causeExcp.identifier,'Simulink:blocks:BusCC_BusCheckFailed')
            errorPattern=strfind(filterCauseMsg,getString(message('Sldv:xform:BlkReplacer:GenErrMsg:ErrsDetected')));
            if~isempty(errorPattern)
                filterCauseMsg=filterCauseMsg(1:errorPattern(1)-1);
            end
        end
    end
end
