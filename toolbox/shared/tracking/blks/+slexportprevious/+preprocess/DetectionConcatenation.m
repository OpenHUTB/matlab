function DetectionConcatenation(obj)
    if isR2020bOrEarlier(obj.ver)

        if isfile(fullfile(matlabroot,'toolbox','driving','driving','drivinglib.slx'))

            newRef='trackingutilitieslib/Detection Concatenation';
            oldRef='drivinglib/Detection Concatenation';
            obj.appendRule(['<Block<SourceBlock|"',newRef,'":repval "',oldRef,'">>']);
        else
            obj.removeLibraryLinksTo(sprintf('trackingutilitieslib/Detection Concatenation'));
        end

    end

end
