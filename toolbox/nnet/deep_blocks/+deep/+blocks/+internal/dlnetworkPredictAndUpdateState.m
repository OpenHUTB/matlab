function varargout=dlnetworkPredictAndUpdateState(net,inputs,inputFormats)





    inputDlArrays=cell(size(inputs));
    for i=1:numel(inputs)
        inputDlArrays{i}=dlarray(inputs{i},inputFormats{i});
    end


    dlArrayOutputs=cell(size(net.OutputNames));
    varargout=cell(numel(net.OutputNames)+1);
    [dlArrayOutputs{:},state]=predict(net,inputDlArrays{:});


    net.State=state;
    varargout{1}=net;


    for i=1:length(dlArrayOutputs)
        varargout{i+1}=extractdata(dlArrayOutputs{i});
    end

end
