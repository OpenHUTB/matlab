function solveDrivenVoltage(obj,f,V)



    obj.Frequency=f;
    obj.V_efie=V;
    obj.I_mfie=V;
    obj.Wavenumber=2*pi*f/obj.c0;
    findElementsPerLambda(obj);
    solve(obj,'voltage');
    cacheSolution(obj);





end

