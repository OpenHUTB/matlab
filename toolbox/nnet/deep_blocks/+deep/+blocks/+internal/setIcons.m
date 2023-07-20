function setIcons()




    classifierMask=Simulink.Mask.get('deeplib/Image Classifier');
    classifierMask.BlockDVGIcon='nnet.dl_block_icon';

    predictMask=Simulink.Mask.get('deeplib/Predict');
    predictMask.BlockDVGIcon='nnet.dl_block_icon';

    statefulClassifyMask=Simulink.Mask.get('deeplib/Stateful Classify');
    statefulClassifyMask.BlockDVGIcon='nnet.stateful_block_icon';

    statefulPredictMask=Simulink.Mask.get('deeplib/Stateful Predict');
    statefulPredictMask.BlockDVGIcon='nnet.stateful_block_icon';

end
