function tbCompletionComp=getTBCompletionComp(hN,hInSignals,extraMsgStr)


    narginchk(3,3);
    tbCompletionComp=hN.addComponent2(...
    'kind','tb_completion_comp',...
    'InputSignals',hInSignals,...
    'ExtraMsgStr',extraMsgStr);
end


