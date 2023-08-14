function exportSimscapeWarning(obj)





    simscapeBlocks=obj.findBlocksOfType('SimscapeBlock');
    if~isempty(simscapeBlocks)
        obj.reportWarning('physmod:simscape:simscape:slexportprevious:ExportNotSupported');
    end

end