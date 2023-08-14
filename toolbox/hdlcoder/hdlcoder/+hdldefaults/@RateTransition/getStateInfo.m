function stateInfo=getStateInfo(this,hC)



    [~,dintegrity_on,ddtransfer_on,inputRate,outputRate]=getBlockInfo(this,hC);

    stateInfo.HasState=(dintegrity_on||ddtransfer_on)&&(inputRate~=outputRate);
    stateInfo.HasFeedback=false;
end
