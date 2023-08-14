function constants=hdlconstantdecl(this)



    strValue=int2str(min(this.simTermCondition,2^31-1));
    [~,tmpidx]=hdlnewsignal('MAX_ERROR_COUNT','block',-1,0,0,'integer','uint32');
    constants=[makehdlconstantdecl(tmpidx,strValue),'\n\n'];
end


