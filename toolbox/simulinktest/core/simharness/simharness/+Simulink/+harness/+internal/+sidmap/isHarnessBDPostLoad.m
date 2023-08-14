function[isHarnessBD,mainModel]=isHarnessBDPostLoad(modelH)
    isHarnessBD=false;
    mainModel=[];%#ok<NASGU>

    try
        if Simulink.harness.isHarnessBD(modelH)

            isHarnessBD=true;
            mainModel=Simulink.harness.internal.getHarnessOwnerBD(modelH);
            return;
        else


            mainModel=get_param(modelH,'ownerBDName');
            if~isempty(mainModel)
                try
                    mainModelH=get_param(mainModel,'Handle');%#ok<NASGU>
                catch ME %#ok<NASGU>



                    isHarnessBD=false;
                    mainModel=[];
                    return;
                end
                isHarnessBD=true;
            end
        end
    catch ME %#ok<NASGU>

        isHarnessBD=false;
        mainModel=[];
    end
end
