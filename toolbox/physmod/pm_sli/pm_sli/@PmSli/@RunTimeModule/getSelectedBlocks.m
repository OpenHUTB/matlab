function selectedBlockHandles=getSelectedBlocks(~,hModel)






    if~isempty(hModel)
        h=hModel.handle;






        selectedSimscapeBlocks=find_system(h,'MatchFilter',@Simulink.match.activeVariants,...
        'BlockType','SimscapeBlock','Selected','on');

        selectedNeUtilBlocks=find_system(h,'MatchFilter',@Simulink.match.activeVariants,...
        'DialogController','NetworkEngine.DynNeUtilDlgSource',...
        'Selected','on');


        selectedBlockHandles=[selectedSimscapeBlocks;selectedNeUtilBlocks];
    else
        selectedBlockHandles=[];
    end

end