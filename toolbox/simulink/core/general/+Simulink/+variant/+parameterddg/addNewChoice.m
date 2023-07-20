function addNewChoice(ddgCreator,dlg)






    var=ddgCreator.fVariantVariable;
    currChoices=var.getChoice();
    currConds=currChoices(1:2:end);
    newChoiceCond=matlab.lang.makeUniqueStrings('Choice',currConds);



    ddgCreator.addChoice(newChoiceCond,[]);

    spreadSheetInterface=dlg.getWidgetInterface(ddgCreator.SpreadSheetTag);
    spreadSheetInterface.update();

    dlg.enableApplyButton(true);
end
