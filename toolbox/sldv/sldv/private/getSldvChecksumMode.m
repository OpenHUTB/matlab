function checksumMode=getSldvChecksumMode(model)




    checksumMode=Sldv.ChecksumMode.SLDV_CHECKSUM_UNKNOWN;




    if~isempty(model)
        modelH=get_param(model,'Handle');

        sldvSession=sldvGetActiveSession(modelH);
        if~isempty(sldvSession)&&isvalid(sldvSession)
            checksumMode=sldvSession.getSldvChecksumMode();
        end
    end
end
