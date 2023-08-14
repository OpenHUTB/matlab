function solvePlaneWave(obj,f,dirn,pol)



    obj.Frequency=f;
    obj.WaveDirection=dirn;
    obj.WavePolarization=pol;
    obj.Wavenumber=2*pi*f/obj.c0;
    findElementsPerLambda(obj);
    solve(obj,'PlaneWave');
    cacheSolution(obj);




end

