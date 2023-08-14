function status=isDUTsingleClock(this)


    numClocks=0;
    for ii=1:length(this.clockTable)
        if this.clockTable(ii).Kind==0
            numClocks=numClocks+1;
        end
    end

    status=(numClocks<=1);
end
