function v=checkOneBitInput(this)



    v=struct('Status',0,'Message','','MessageID','');

    if hdlgetsizesfromtype(this.InputSLType)==1
        msg='One bit inputs are not supported.';
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:OneBitInputNotSupported');
    end
