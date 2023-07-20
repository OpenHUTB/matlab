function decision=qpskCompareAndDecide(this,prm,derot)









    compout_sig=slicerCompares(this,prm.hN,prm.compOps,derot);


    decision=slicerLUT(this,prm.hN,prm.LUTvalues,compout_sig,prm.decision_name);

