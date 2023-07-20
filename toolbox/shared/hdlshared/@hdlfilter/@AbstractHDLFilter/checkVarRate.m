function v=checkVarRate(this)







    v=struct('Status',0,'Message','','MessageID','');
    if this.getHDLParameter('RateChangePort')&&this.getHDLParameter('clockinputs')>1
        msgid='HDLShared:hdlfilter:varrateWithMultipleClocksUnsupp';
        m=message(msgid);
        msg=m.getString;
        v=struct('Status',1,'Message',msg,'MessageID',msgid);
    end


    if this.getHDLParameter('RateChangePort')&&~this.isVarRateSupported
        msgid='HDLShared:hdlfilter:varrateSuppFullPrecisionCICs';
        m=message(msgid);
        msg=m.getString;
        v=struct('Status',1,'Message',msg,...
        'MessageID',msgid);
    end