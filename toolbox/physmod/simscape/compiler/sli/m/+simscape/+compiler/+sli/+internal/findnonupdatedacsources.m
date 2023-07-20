function[oldAcBlocks,oldAcExceptions]=findnonupdatedacsources(simscapeBlocks)











    simscapeFiles=get_param(simscapeBlocks,'SourceFile');

    acBlocks=simscapeBlocks(...
    strcmp('foundation.electrical.sources.ac_current',simscapeFiles)|...
    strcmp('foundation.electrical.sources.ac_voltage',simscapeFiles));

    oldAcBlocks=acBlocks(~strcmp(get_param(acBlocks,'omega'),'0'));

    if nargout>1
        oldAcExceptions=cell(size(oldAcBlocks));
        for i=1:length(oldAcBlocks)
            msgObject=message(...
            'physmod:simscape:compiler:sli:block:NonUpdatedBlock');
            oldAcExceptions{i}=MException(msgObject);
        end
    end

end