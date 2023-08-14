function setActiveData(model,cvd)





    coveng=cvi.TopModelCov.getInstance(model);
    coveng.activeData=cvd;


    SlCov.coder.EmbeddedCoderAnnotations.writeCodeViewInformation(cvd);
end
