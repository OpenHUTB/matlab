function UpdateRTPParams(matFile,properties)




    if exist(matFile,'file')==2
        rtpTmp=load(matFile);
        for i=1:length(properties)
            val=eval(properties(i).value);
            rtpTmp=Simulink.BlockDiagram.modifyTunableParameters(rtpTmp,...
            properties(i).name,val);
        end
        modelChecksum=rtpTmp.modelChecksum;
        parameters=rtpTmp.parameters;
        globalParameterInfo=rtpTmp.globalParameterInfo;
        save(matFile,'-v7','modelChecksum','parameters','globalParameterInfo');
    end

end
