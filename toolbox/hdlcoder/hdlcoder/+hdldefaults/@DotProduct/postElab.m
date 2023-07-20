function postElab(this,hN,hPreElabC,hPostElabC)%#ok<INUSL>



    hPostElabC.copyComment(hPreElabC);

...
...
...
...
    hPostElabC.setConstrainedOutputPipeline(hPreElabC.getConstrainedOutputPipeline());

    hN.removeComponent(hPreElabC);

end
