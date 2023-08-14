
function openCodeContext(owner,name)
    try

        harnessStruct=Simulink.libcodegen.internal.loadCodeContext(owner,name);
        open_system(harnessStruct.name);
    catch ME

        ME.throwAsCaller;
    end
end
