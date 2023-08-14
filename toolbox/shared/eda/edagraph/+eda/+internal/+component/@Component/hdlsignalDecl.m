function hdlcode=hdlsignalDecl(this)







    hdlcode=this.hdlcodeinit;
    hdlsignals='';

    signalList=this.ChildEdge;
    for i=1:length(signalList)
        fitype=signalList{i}.FiType;
        if isstruct(fitype)
            fitype=fitype.Name;
        end
        htype=hdltype(this,fitype);

        [tempName,tempIdx]=hdlnewsignal(signalList{i}.Name,'block',-1,0,0,htype,fitype);%#ok

        hdlsignals=[hdlsignals,makehdlsignaldecl(tempIdx)];%#ok<AGROW>
        signalList{i}.UniqueName=tempName;
    end
    hdlcode.arch_signals=hdlsignals;

    this.HDL=hdlcodeconcat([this.HDL,hdlcode]);

end


