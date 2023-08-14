



function out=isAvailable(~,studio)

    out=true;

    modelH=studio.App.blockDiagramHandle;

    if bdIsLibrary(modelH)||bdIsSubsystem(modelH)
        out=false;
        return;
    end

