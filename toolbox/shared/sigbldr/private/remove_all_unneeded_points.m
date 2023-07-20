function UD=remove_all_unneeded_points(UD)





    chIdx=UD.current.channel;
    if(chIdx>0)


        UD=locRemovePoints(UD,chIdx);
    else
        for chIdx=1:UD.numChannels
            UD=locRemovePoints(UD,chIdx);
        end
    end

    function UD=locRemovePoints(UD,chIdx)



        if isfield(UD.channels,'lineH')&&~isempty(UD.channels(chIdx).lineH)

            oldX=get(UD.channels(chIdx).lineH,'XData');
            oldY=get(UD.channels(chIdx).lineH,'YData');
        else
            grpIdx=UD.current.dataSetIdx;
            sbobj=UD.sbobj;
            sig=sbobj.Groups(grpIdx).Signals(chIdx);

            oldX=sig.XData;
            oldY=sig.YData;
        end


        [X,Y]=remove_unneeded_points(oldX,oldY);


        if(length(X)~=length(oldX)||length(Y)~=length(oldY))
            UD=apply_new_channel_data(UD,chIdx,X,Y,true);
        end
