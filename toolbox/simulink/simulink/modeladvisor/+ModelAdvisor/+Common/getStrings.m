function maStr=getStrings(ID)




    switch ID

    case 'SFMChartNote'
        maStr=DAStudio.message('ModelAdvisor:engine:SFMChartNotSupportedNote');


    case 'CheckNotAppliesToMatlabActionLanguage'
        maStr=DAStudio.message('ModelAdvisor:engine:CheckNotAppliesToMatlabActionLanguage');




    case 'WarningCheckDoesNotSupportHarnessModels'
        maStr=DAStudio.message('ModelAdvisor:engine:WarningCheckDoesNotSupportHarnessModels');
    case 'ActionCheckDoesNotSupportHarnessModels'
        maStr=DAStudio.message('ModelAdvisor:engine:ActionCheckDoesNotSupportHarnessModels');


    end

end
