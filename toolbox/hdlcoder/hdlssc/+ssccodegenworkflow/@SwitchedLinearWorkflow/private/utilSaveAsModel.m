function utilSaveAsModel(model,newModel)




    try

        if bdIsLoaded(newModel)
            bdclose(newModel);
        end
        shadowWarnID='Simulink:Engine:MdlFileShadowing';
        shadowWarnPrev=warning('query',shadowWarnID);
        warning('off',shadowWarnID);
        oc=onCleanup(@()warning(shadowWarnPrev.state,shadowWarnID));


        tempModel=getGeneratedModelName('temp_',newModel);
        new_system(tempModel,'model');
        hTempSubsystem=add_block('built-in/SubSystem',strcat(tempModel,'/temp'));

        Simulink.BlockDiagram.copyContentsToSubSystem(model,hTempSubsystem);


        new_system(newModel,'model');

        Simulink.SubSystem.copyContentsToBlockDiagram(hTempSubsystem,newModel);

        slpir.PIR2SL.initOutputModel(model,newModel);

        close_system(tempModel,0);
    catch me
        close_system(tempModel,0);
        throwAsCaller(me);
    end

end