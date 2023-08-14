function[overlap,FRAMES_LENGTH]=ComputeOverlapSize(obj,StateLength,SubFrameCapable)



    FRAMES_LENGTH=1;


    if isempty(find(obj.data.FrameInputs,true))||(obj.StateLength==0)
        overlap.SKIP_AHEAD=StateLength;
        overlap.SKIP_AHEAD=min(overlap.SKIP_AHEAD,(obj.Threads-1)*obj.Repetition);
        overlap.SKIP_AHEAD_SUBFRAME=0;
    else
        FRAMES_LENGTH=DetectGeneralFrameSize(obj);
        sLength=min(StateLength,((obj.Threads-1)*obj.Repetition)*FRAMES_LENGTH);
        overlap.SKIP_AHEAD=ceil(sLength/FRAMES_LENGTH);
        if(~SubFrameCapable)||(mod(sLength,FRAMES_LENGTH)==0)
            overlap.SKIP_AHEAD_SUBFRAME=0;
        else
            overlap.SKIP_AHEAD_SUBFRAME=mod(sLength,FRAMES_LENGTH);
        end
    end


end

