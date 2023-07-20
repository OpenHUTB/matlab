function generateRHS(obj)

    b=obj.Alpha*obj.V_efie+(1-obj.Alpha)*obj.eta0*obj.I_mfie;
    b=b./obj.Preconditioner;
    obj.RHS=b;
end