function blocklist=resolveSyntheticSubsystems(this,blocklist,modelName)%#ok<INUSL>




    for ii=1:numel(blocklist)
        blkH=slhdlcoder.SimulinkFrontEnd.isConcExecSubsystem(blocklist(ii),modelName);
        if blkH>0
            blocklist(ii)=blkH;
            return;
        end

        blkH=slhdlcoder.SimulinkFrontEnd.isMatlabSystemBlockSubsystem(blocklist(ii));
        if blkH>0
            blocklist(ii)=blkH;
        end
    end
end