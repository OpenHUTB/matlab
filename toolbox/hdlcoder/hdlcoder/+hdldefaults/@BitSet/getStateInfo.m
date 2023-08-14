function stateInfo=getStateInfo(this,hC)%#ok<INUSL>




    stateInfo.HasState=false;
    stateInfo.HasFeedback=false;
    stateInfo.MaskType=get_param(hC.SimulinkHandle,'MaskType');
    stateInfo.iBit=hdlslResolve('iBit',hC.SimulinkHandle);

end
