function[wmsg,emsg]=m2m_obj_creation(aSystem,aTask,aM2mClass)





    wmsg='';
    emsg='';
    MAObj=Simulink.ModelAdvisor.getModelAdvisor(aSystem);
    MATask=aTask;

    ME=MException('','');
    MAObj.setCheckErrorSeverity(false);

    if hasAnyTaskRun(MAObj)&&isaModel2ModelObject(MAObj.UserData)
        if strcmpi(aM2mClass,'slEnginePir.m2m_dsm')
            if isa(MAObj.UserData,aM2mClass)
                mdl=MAObj.UserData.fOriMdl;
            else
                if MAObj.UserData.fTransformed
                    mdl=MAObj.UserData.fXformedMdl;
                else
                    mdl=MAObj.UserData.fOriMdl;
                end
            end
        else
            if isa(MAObj.UserData,aM2mClass)
                if MAObj.UserData.fTransformed||(MATask.State==ModelAdvisor.CheckStatus.NotRun)
                    mdl=MAObj.UserData.fOriMdl;
                else
                    return;
                end
            else
                if MAObj.UserData.fTransformed
                    mdl=MAObj.UserData.fXformedMdl;
                else
                    mdl=MAObj.UserData.fOriMdl;
                end
            end
        end
    else
        mdl=aSystem;
    end

    MAObj.UserData='';

    creationCmd=['try MAObj.UserData = ',aM2mClass,'(bdroot(mdl)); catch ME; end'];

    wmsg=evalc(creationCmd);
    if~isempty(ME.message)
        MAObj.setCheckErrorSeverity(true);
        emsg=ME.message;
    end
end


function isaM2M=isaModel2ModelObject(aUserData)
    isaM2M=isa(aUserData,'slEnginePir.m2m')||...
    isa(aUserData,'slEnginePir.model2model');
end

function hasRun=hasAnyTaskRun(aMAObj)
    task1=aMAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.IdentifyVariantConstant');
    task2=aMAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.DSMElim');
    task3=aMAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.LutXform');
    task4=aMAObj.getTaskObj('com.mathworks.Simulink.MdlTransformer.CommonSrcInterpXform');
    hasRun=~((task1.State==ModelAdvisor.CheckStatus.NotRun)&&(task2.State==ModelAdvisor.CheckStatus.NotRun)&&(task3.State==ModelAdvisor.CheckStatus.NotRun)&&((task4.State==ModelAdvisor.CheckStatus.NotRun)));
end


