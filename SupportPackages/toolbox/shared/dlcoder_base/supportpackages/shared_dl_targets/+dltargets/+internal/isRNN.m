function isSequenceNet=isRNN(lgraph)




    isSequenceNet=any(nnet.internal.cnn.util.hasSequenceInput(lgraph.Layers));
end
