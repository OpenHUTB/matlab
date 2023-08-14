function onlyAutoscale=updateAutoscalingResults(coveng,isInModelPause)








    onlyAutoscale=false;
    allModelcovIds=coveng.getAllModelcovIds;


    if~coveng.isCvCmdCall
        onlyAutoscale=true;


        for currModelcovId=allModelcovIds(:)'
            autoscaled=false;



            if~coveng.autoscaleInFastRestart||isInModelPause



                currentTest=cv('get',currModelcovId,'.currentTest');
                isScript=cv('get',currModelcovId,'.isScript');

                isAutoscalingForced=onlyAutoscale;

                if~isScript
                    modelH=cv('get',currModelcovId,'.handle');
                    isAutoscalingForced=false;




                    autoscaled=ishandle(modelH)&&modelH~=0&&strcmpi(get_param(modelH,'CovAutoscale'),'on');

                    if autoscaled

                        sendAutoscalingResults(currentTest);




                        if~isInModelPause
                            isAutoscalingForced=cvprivate('cv_autoscale_settings','isForce',modelH);
                            handlAutoscaleSettingsOnTerm(coveng.topModelH,modelH,currentTest);
                        end
                    end
                    onlyAutoscale=onlyAutoscale&&isAutoscalingForced;
                end


                if~isInModelPause&&~isAutoscalingForced
                    updateResults(coveng,cvdata(currentTest));
                end
            end
            cleanupAutoscaleSettings(coveng,isInModelPause,autoscaled);
        end
    end
end
function cleanupAutoscaleSettings(coveng,isInModelPause,autoscaled)



    if~isInModelPause
        coveng.autoscaleInFastRestart=false;
    else
        coveng.autoscaleInFastRestart=autoscaled;
    end
end
function sendAutoscalingResults(currentTest)




    covData=cvdata(currentTest);


    cvprivate('cv_append_autoscale_data',covData);
end
function handlAutoscaleSettingsOnTerm(topModelH,modelH,currentTest)



    cvprivate('cv_autoscale_settings','restore',modelH);
    cvt=cvtest(currentTest);
    copyMetricsFromModel(cvt,topModelH);
end
