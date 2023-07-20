function verifyXLColLimit(this,numCols)



    if numCols>this.MAX_COLS_ALLOWED
        errStr=getString(message('SDI:sdi:XLSMaxColsErr',num2str(this.MAX_COLS_ALLOWED)));
        me=MException('SDI:sdi:XLSMaxColsErr',errStr);
        throw(me);
    end
end
