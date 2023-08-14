function isRecording=record(setVal)
    mlock;
    persistent SDIIsRecording;
    if nargin>0
        SDIIsRecording=setVal;
    elseif isempty(SDIIsRecording)
        SDIIsRecording=false;
    end
    isRecording=SDIIsRecording;
end
