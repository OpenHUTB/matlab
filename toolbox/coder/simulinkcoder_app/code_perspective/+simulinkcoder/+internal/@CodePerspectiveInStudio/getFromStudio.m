function out=getFromStudio(studio)


    mdl=studio.App.blockDiagramHandle;
    cp=simulinkcoder.internal.CodePerspective.getInstance();
    out=cp.getFlag(mdl,studio);