function expr=sensitivityList(this)





    if this.isVHDL
        expr=['(',hdlsignalname(this.clock)];
        if this.hasAsyncReset
            expr=[expr,', ',hdlsignalname(this.reset)];
        end
        expr=[expr,')'];
    else
        if this.hasNegEdgeClock
            expr=['(negedge ',hdlsignalname(this.clock)];
        else
            expr=['(posedge ',hdlsignalname(this.clock)];
        end
        if this.hasAsyncReset
            if this.resetAssertedLevel
                expr=[expr,' or posedge ',hdlsignalname(this.reset)];
            else
                expr=[expr,' or negedge ',hdlsignalname(this.reset)];
            end
        end
        expr=[expr,')'];
    end

