function result=lcm_clocktable(this)




    result=1;
    for ii=1:length(this.clockTable)
        if this.clockTable(ii).Kind==0
            result=lcm(result,this.clockTable(ii).Ratio);
        end
    end
