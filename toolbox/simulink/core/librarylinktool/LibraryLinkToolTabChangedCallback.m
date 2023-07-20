function LibraryLinkToolTabChangedCallback(dialogH,tabTag,selectedTabIndex)
    if selectedTabIndex==0
        newDescriptionText=DAStudio.message('Simulink:Libraries:LibraryLinkToolDisabledLinkDescriptionText');
    elseif selectedTabIndex==1
        newDescriptionText=DAStudio.message('Simulink:Libraries:LibraryLinkToolParameterizedLinkDescriptionText');
    end
    dialogH.setWidgetValue('LibraryLinkToolTabSpecificDescription',newDescriptionText);
end
