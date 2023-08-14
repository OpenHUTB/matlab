function parr=getConnectedSources(blk)
    tarr=Simulink.CMI.cpp.getConnectedSources(blk.sess,blk);
    parr=Simulink.CMI.OutPort.empty;
    for i=1:length(tarr)
        parr=[parr,Simulink.CMI.util.createPort(blk.sess,tarr(i).Handle)];%#ok<AGROW>
    end
end
