function UD=apply_new_channel_data(UD,chIdx,X,Y,dontUpdateUndo)







    if nargin<5||~dontUpdateUndo
        UD=update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
    end


    doUpdate=(isfield(UD.channels,'lineH')&&~isempty(UD.channels(chIdx).lineH)&&...
    ishghandle(UD.channels(chIdx).lineH,'line'));

    ActiveGroup=UD.sbobj.ActiveGroup;

    if isempty(X)

        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData=Y;

        if doUpdate

            set(UD.channels(chIdx).lineH,'YData',Y);
        end

    elseif isempty(Y)

        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData=X;

        if doUpdate

            set(UD.channels(chIdx).lineH,'XData',X);
        end
    else

        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).XData=X;
        UD.sbobj.Groups(ActiveGroup).Signals(chIdx).YData=Y;
        if doUpdate

            set(UD.channels(chIdx).lineH,'XData',X,'YData',Y);
        end
    end

    if doUpdate
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end
