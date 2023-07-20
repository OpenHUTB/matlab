function lhs=generateLHS(obj,I)




    generateLHSEfie(obj,I);
    generateLHSMfie(obj,I);
    lhs=obj.Alpha*obj.LHSEfie+(1-obj.Alpha)*obj.eta0*obj.LHSMfie;
    lhs=lhs./obj.Preconditioner;

end

