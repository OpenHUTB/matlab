function highlightPartialResults(handle)






    if~slavteng('feature','IncrementalHighlighting')

        testcomp=handle.testComp;






        modelH=get_param(handle.modelName,'Handle');
        session=sldvprivate('sldvGetActiveSession',modelH);
        session.HighlightStatusFlag=false;


        progressBar=Sldv.Utils.ScopedProgressIndicator(...
        'Sldv:SldvresultsSummary:GeneratingDataModelHighlighting');%#ok<NASGU>

        sldvData=Sldv.DataUtils.save_data(modelH,testcomp);

        highlightResults(modelH,sldvData);
    end
end


function highlightResults(modelH,sldvData)

    mdlVnvDataH=get_param(modelH,'AutoVerifyData');


    initResFiles=initAnalResFileNames();

    if~slavteng('feature','IncrementalHighlighting')

        if isfield(mdlVnvDataH,'modelView')&&mdlVnvDataH.modelView.isvalid
            delete(mdlVnvDataH.modelView);
        end

        modelView=Sldv.ModelView(sldvData,initResFiles);
    else


        if isfield(mdlVnvDataH,'modelView')&&mdlVnvDataH.modelView.isvalid

            modelView=mdlVnvDataH.modelView;
            modelView.updateSldvData(sldvData);

        else
            modelView=Sldv.ModelView(sldvData,initResFiles);
        end
    end


    modelView.view;


    mdlVnvDataH.modelView=modelView;


    set_param(modelH,'AutoVerifyData',mdlVnvDataH);
end

function resFileNames=initAnalResFileNames()
    resFileNames=Sldv.Utils.initDVResultStruct();
end
