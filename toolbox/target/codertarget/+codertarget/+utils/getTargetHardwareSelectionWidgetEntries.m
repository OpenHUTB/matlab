function hardwareBoardComboEntries=getTargetHardwareSelectionWidgetEntries(hCS,enabled)







    if nargin<2
        enabled=true;
    end

    defaultBoardChoiceName=codertarget.utils.getDefaultHardwareBoardSelection(hCS);
    defaultBoardChoice.str='None';
    defaultBoardChoice.disp=defaultBoardChoiceName;

    if enabled

        hardwareBoards=codertarget.targethardware.getRegisteredTargetHardwareNames;

        hardwareBoardChoices=cellfun(@getDropDownItem,hardwareBoards);
        targetFrameworkBoardChoices=codertarget.utils.getTargetFrameworkBoardEntries();

        boardChoices=[hardwareBoardChoices,targetFrameworkBoardChoices];

        if~isempty(boardChoices)
            [~,ui]=unique({boardChoices.disp});
            boardChoices=boardChoices(ui);
            [~,si]=sort({boardChoices.disp});
            boardChoices=boardChoices(si);
        end

        getHSPChoice=getDropDownItem(DAStudio.message('codertarget:build:GetHSP'));

        hardwareBoardComboEntries=[defaultBoardChoice,boardChoices,getHSPChoice];
    else

        if codertarget.target.isCoderTarget(hCS)
            targetHW=codertarget.data.getParameterValue(hCS,'TargetHardware');
        elseif isequal(get_param(hCS,'SystemTargetFile'),'realtime.tlc')
            targetHW=get_param(hCS,'TargetExtensionPlatform');
        else
            targetHW=defaultBoardChoiceName;
        end
        hardwareBoardComboEntries=getDropDownItem(targetHW);
    end
end

function item=getDropDownItem(coderTargetHardwareName)

    item.str=coderTargetHardwareName;
    item.disp=coderTargetHardwareName;
end
