function out=getUDDObjectMethod(obj,method)%#ok


    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    out=eval(['obj.',method]);
end
