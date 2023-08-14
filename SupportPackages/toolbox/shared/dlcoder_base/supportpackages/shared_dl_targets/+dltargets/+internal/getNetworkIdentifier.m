













function networkIdentifier=getNetworkIdentifier(net)

    if~(isa(net,'dlnetwork')||isa(net,'DAGNetwork')||isa(net,'SeriesNetwork'))

        errorId='dlcoder_spkg:ValidateNetwork:invalidNetwork';
        throw(MException(errorId,getString(message(errorId))));
    end





    byteArray=getByteStreamFromArray(net);

    digester=matlab.internal.crypto.BasicDigester("Blake-2b");

    intDigest=digester.computeDigest(byteArray);

    networkIdentifier=string(matlab.internal.crypto.hexEncode(intDigest));

end

