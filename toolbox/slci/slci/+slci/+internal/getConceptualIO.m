


function conceptualIO=getConceptualIO(sys)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    conceptualIO=[];
    try
        blk=Simulink.CMI.Subsystem(sess,sys);
        io=blk.conceptualIO;
        conceptualIO.Inputs=getIOData(io.Inputs);
        conceptualIO.Outputs=getIOData(io.Outputs);
    catch
        conceptualIO.Inputs={};
        conceptualIO.Outputs={};
    end
end


function out=getIOData(ios)
    out={};
    for i=1:numel(ios)
        io=ios(i);
        data.PortIndex=io.PortIndex;
        data.ParentBlockHandle=io.ParentBlock.Handle;
        out{end+1}=data;%#ok
    end
end
