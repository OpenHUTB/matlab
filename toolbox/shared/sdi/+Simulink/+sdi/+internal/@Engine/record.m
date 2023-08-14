function record(this)







    if~this.isRecording()
        Simulink.sdi.Instance.record(true);


        this.RecordStatus=true;
    end
end