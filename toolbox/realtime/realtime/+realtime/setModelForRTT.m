function isset=setModelForRTT(cs,goahead)





    isset=realtime.setOrCheckModelForRTT(cs,'check');

    if~isset
        if~goahead
            prompt=DAStudio.message('realtime:build:SetModelQuestDlgPrompt');
            answer=questdlg(prompt,'Set Model','Yes','No','Yes');
            goahead=isequal(answer,'Yes');
        end
        if goahead
            isset=realtime.setOrCheckModelForRTT(cs,'set');
        end
    end

end
