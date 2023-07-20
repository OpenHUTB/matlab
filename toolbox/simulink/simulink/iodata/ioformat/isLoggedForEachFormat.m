function IS_FOREACH=isLoggedForEachFormat(aVar)



    IS_FOREACH=false;

    if Simulink.sdi.internal.Util.isSimulationDataElement(aVar)

        if~isscalar(aVar.Values)&&(Simulink.sdi.internal.Util.isMATLABTimeseries(aVar.Values))









            for kIt=1:numel(aVar.Values)
                if timeSeriesUnsupportedCheck(aVar.Values(kIt))
                    return;
                end
            end

            IS_FOREACH=true;

        elseif iscell(aVar.Values)

            IS_FOREACH=all(cellfun(@isSLTimeTable,aVar.Values));

        end

    end
