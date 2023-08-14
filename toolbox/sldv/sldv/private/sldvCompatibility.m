


function[status,msg,sldvData,fullCovAlreadyAchieved]=sldvCompatibility(originalModelH,...
    blockH,...
    opts,...
    showUI,...
    startCov)




    if(nargin<5)
        startCov=[];
    end

    sldvData='';
    fullCovAlreadyAchieved=false;
    msg='';



    status=isTokenFree(showUI);
    if~status
        return;
    end


    clearResults(originalModelH);
    removeModelHighlighting(originalModelH,showUI);


    if isempty(opts)
        opts=sldvoptions(originalModelH);
    end

    sldvSession=sldvGetActiveSession(originalModelH);

    if isempty(sldvSession)
        sldvSession=sldvCreateSession(originalModelH,blockH,opts,showUI,startCov);

        assert(~isempty(sldvSession)&&isvalid(sldvSession));
    else


        sldvSession.reset(blockH,opts,showUI,startCov);
    end





    try


        filterExistingCov=false;
        reuseTranslationCache=false;
        standaloneCompat=true;
        if nargout>2
            [status,~,msg,fullCovAlreadyAchieved,sldvData]=sldvSession.checkCompatibility(filterExistingCov,reuseTranslationCache,[],standaloneCompat);
        else
            [status,~,msg,fullCovAlreadyAchieved]=sldvSession.checkCompatibility(filterExistingCov,reuseTranslationCache,[],standaloneCompat);
        end

    catch MEx
        status=false;





        if(strcmp(MEx.identifier,'Sldv:Session:invalidObj'))
            return;
        end
        rethrow(MEx);
    end



    sldvSession.closeReplacementModel();

    sldvSession.closeExtractedModel();


    if~Sldv.utils.Options.isTestgenTargetForModel(opts)
        sldvSession.deleteATSHarness();
    end

end


function status=isTokenFree(showUI)

    sldvToken=Sldv.Token.get;
    if sldvToken.isInUse
        status=false;
        errMsg=getString(message('Sldv:Setup:OnlyOneAnalysisRun'));
        if showUI
            dialogTitle=getString(message('Sldv:SldvRun:SimulinkDesignVerifier'));
            errordlg(errMsg,dialogTitle);
        else
            error('Sldv:Setup:MultipleAnalysis',errMsg);
        end
    else
        status=true;
    end
end

function clearResults(modelH)



    handles=get_param(modelH,'AutoVerifyData');
    if isfield(handles,'res_dialog')
        res_dialog=handles.res_dialog;
        if~isempty(res_dialog)
            try
                res_dialog.delete();
            catch



            end
        end
    end
    if isfield(handles,'analysisFilter')
        if slavteng('feature','MultiFilter')
            filterExplorer=handles.analysisFilter;
            if~isempty(filterExplorer)
                try
                    Sldv.FilterExplorer.close(filterExplorer);
                catch Mex %#ok<NASGU>
                end
            end
        else
            filter=handles.analysisFilter;
            if~isempty(filter)
                try
                    filter.reset;
                    filter.delete;
                catch Mex %#ok<NASGU>
                end
            end
        end
    end
end

function removeModelHighlighting(modelH,showUI)


    if showUI
        handles=get_param(modelH,'AutoVerifyData');
        if isfield(handles,'modelView')&&handles.modelView.isvalid

            SLStudio.Utils.RemoveHighlighting(modelH);

            delete(handles.modelView);
            handles=rmfield(handles,'modelView');
            set_param(modelH,'AutoVerifyData',handles);
        end
    end
end
