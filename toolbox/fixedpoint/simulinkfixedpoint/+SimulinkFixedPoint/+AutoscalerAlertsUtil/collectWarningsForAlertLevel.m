function diagnosticWarnings=collectWarningsForAlertLevel(diagnosticsArray,alertLevel)










    diagnosticWarnings={};


    if~isempty(diagnosticsArray)


        for diagnosticsIndex=1:length(diagnosticsArray)




            for warningsIndex=1:length(diagnosticsArray(diagnosticsIndex))


                if diagnosticsArray(diagnosticsIndex).alertLevels{warningsIndex}==alertLevel


                    diagnosticWarnings=[diagnosticWarnings,diagnosticsArray(diagnosticsIndex).warningMessages(warningsIndex)];%#ok<AGROW>
                end

            end
        end

    end
end