function dirtySubsystemBDs=getDirtySubsystemBDs(cbinfo)




    dirtySubsystemBDs=[];
    handles=cbinfo.studio.App.getBlockDiagramHandles;
    for i=1:numel(handles)
        h=handles(i);
        dirtySSRefs=slInternal('getAllDirtySSRefBDs',h);

        if~isempty(dirtySSRefs)
            dirtySubsystemBDs=[dirtySubsystemBDs;dirtySSRefs];%#ok<AGROW>
        end
    end
end
