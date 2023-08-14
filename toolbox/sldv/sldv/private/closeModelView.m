function closeModelView(model)


    modelH=get_param(model,'Handle');






    if slavteng('feature','PathBasedTestgen')~=0
        highlightPath('','','clear');
    end
    analysisInProgress=false;

    sldvSession=sldvGetActiveSession(modelH);

    if~isempty(sldvSession)&&isvalid(sldvSession)&&sldvSession.isAnalysisRunning
        analysisInProgress=true;
    end

    dvData=get_param(model,'AutoVerifyData');
    if~isempty(dvData)&&isfield(dvData,'modelView')
        if dvData.modelView.isvalid
            if analysisInProgress
                dvData.modelView.remove_highlight_during_analysis;
            else
                SLStudio.Utils.RemoveHighlighting(modelH);
                delete(dvData.modelView);
                dvData=rmfield(dvData,'modelView');
                set_param(model,'AutoVerifyData',dvData);
            end
        end

    end


end

