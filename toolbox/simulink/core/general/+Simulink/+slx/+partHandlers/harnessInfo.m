function h=harnessInfo






    h=Simulink.slx.PartHandler('harnessinfocreate','blockDiagram',...
    [],@i_save);
end


function i_save(modelHandle,saveOptions)


    if saveOptions.isExportingToReleaseOrOlder('R2014b')






        Simulink.harness.internal.deleteSpecificHarnesses(modelHandle,'R2014bOrEarlier');
        Simulink.libcodegen.internal.deleteCodeContexts(modelHandle);
    elseif saveOptions.isExportingToReleaseOrOlder('R2016b')


        Simulink.harness.internal.deleteSpecificHarnesses(modelHandle,'R2016bOrEarlier');
        Simulink.libcodegen.internal.deleteCodeContexts(modelHandle);
    elseif saveOptions.isExportingToReleaseOrOlder('R2018a')

        Simulink.harness.internal.deleteSpecificHarnesses(modelHandle,'R2018aOrEarlier');
        Simulink.libcodegen.internal.deleteCodeContexts(modelHandle);
    elseif saveOptions.targetRelease=="R2019b"





        Simulink.harness.internal.deleteSpecificHarnesses(modelHandle,'R2019b');
    end
end
