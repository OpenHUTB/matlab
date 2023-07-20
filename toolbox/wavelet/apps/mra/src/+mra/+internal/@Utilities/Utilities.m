



classdef Utilities<handle


    methods(Static,Hidden)
        function samplePeriodUnits=getSamplePeriodUnitLabels()

            samplePeriodUnits=[string(getString(message("wavelet_mraapp:toolstrip:samplePeriodUnitSeconds")));...
            string(getString(message("wavelet_mraapp:toolstrip:samplePeriodUnitMinutes")));...
            string(getString(message("wavelet_mraapp:toolstrip:samplePeriodUnitHours")));...
            string(getString(message("wavelet_mraapp:toolstrip:samplePeriodUnitDays")));...
            string(getString(message("wavelet_mraapp:toolstrip:samplePeriodUnitYears")))];
        end

        function samplePeriodUnits=getSamplePeriodUnits()

            samplePeriodUnits=["seconds";"minutes";"hours";"days";"years"];
        end

        function catalogMessageKey=getCatalogMessageKeyForSamplePeriod(timeInfo)
            switch timeInfo.SamplePeriodUnit
            case "seconds"
                catalogMessageKey="samplePeriodUnitSeconds";
            case "minutes"
                catalogMessageKey="samplePeriodUnitMinutes";
            case "hours"
                catalogMessageKey="samplePeriodUnitHours";
            case "days"
                catalogMessageKey="samplePeriodUnitDays";
            case "years"
                catalogMessageKey="samplePeriodUnitYears";
            end
        end

        function filtNumbers=getFilterNumbers(waveletName)
            filtNumbers=cellstr(wavemngr("tabnums",waveletName));
            filtNumbers(strcmpi(filtNumbers,"**"))=[];
            filtNumbers=filtNumbers(:);
        end

        function waveletNames=getWaveletNames()
            waveletNames=["sym";"db";"fk";"coif"];
        end

        function waveletNames=getInterpolations()
            waveletNames=["spline";"pchip"];
        end

        function initializeMethods=getVMDInitializeMethod()
            initializeMethods=["Peaks";"Random";"Grid";"Specify"];
        end

        function variableNames=getVMDWorkSpace(parameterName,reqLength)
            tempVariableNames=mra.internal.filteredworkspace.filteredVMDWorkspace(parameterName,reqLength);
            variableNames=string(tempVariableNames.currentVariables).';
        end

        function flag=checkForVariableNameInWorkspace(signalName)

            S=evalin('base',"whos('"+signalName+"')");

            flag=~isempty(S);
        end
    end
end
