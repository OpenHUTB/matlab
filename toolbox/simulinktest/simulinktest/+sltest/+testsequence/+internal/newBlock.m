
function testSequence=newBlock(testSequencePath)
    try
        if~Simulink.harness.internal.licenseTest()
            error(message('Simulink:Harness:LicenseNotAvailable'));
        end
        validateattributes(testSequencePath,{'char'},{'nonempty'});
        if getSimulinkBlockHandle(testSequencePath)==-1
            testSequence=add_block('sltestutillib/Blank Test Sequence',testSequencePath);
        else
            error(message('Stateflow:reactive:TSBNameConflict',testSequencePath))
        end
    catch ME
        throwAsCaller(ME);
    end
end
