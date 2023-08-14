function validateRunAndSignalIDs(~,eng,runIDs,signalIDs)
    if~isempty(runIDs)>0

        for rIdx=1:length(runIDs)
            if~eng.isValidRunID(runIDs(rIdx))
                error(message('SDI:sdi:InvalidRunID'));
            end
        end
    elseif~isempty(signalIDs)>0

        for sIdx=1:length(signalIDs)
            if~eng.isValidSignalID(signalIDs(sIdx))
                error(message('SDI:sdi:InvalidSignalID'));
            end
        end
    end
end
