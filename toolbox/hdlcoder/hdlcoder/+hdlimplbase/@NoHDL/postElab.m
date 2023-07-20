function postElab(this,hN,hPreElabC,hPostElabC)



    hPostElabC.copyComment(hPreElabC);
    hN.removeComponent(hPreElabC);

end
