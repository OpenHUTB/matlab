function out=isSynthesized(blkObj)


    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    out=blkObj.isSynthesized;
end
