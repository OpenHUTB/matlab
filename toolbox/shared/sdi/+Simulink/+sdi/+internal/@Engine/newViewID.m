function out=newViewID(this)%#ok - we don't need a static method





    persistent highWaterMark;


    if isempty(highWaterMark)

        highWaterMark=1;
    end


    highWaterMark=highWaterMark+1;

    out=highWaterMark;
end