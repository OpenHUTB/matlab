function gr=getOldMesherGrowthRate(obj)

    objtype=class(obj);
    switch objtype
    case 'biquad'
        gr=1.3;
    case 'birdcage'
        gr=1.7;
    case 'bowtieRounded'
        gr=1.8;
    case 'bowtieTriangular'
        gr=1.75;
    case 'cavity'
        gr=1.75;
    case 'cavityCircular'
        gr=1.75;
    case 'circularArray'
        gr=1.75;
    case 'cloverleaf'
        gr=1.7;
    case 'conformalArray'
        gr=1.75;
    case 'customAntennaGeometry'
        gr=1.7;
    case 'customAntennaMesh'
        gr=1.75;
    case 'customArrayGeometry'
        gr=1.7;
    case 'customArrayMesh'
        gr=1.75;
    case 'dipole'
        gr=1.7;
    case 'dipoleBlade'
        gr=1.95;
    case 'dipoleCycloid'
        gr=1.7;
    case 'dipoleFolded'
        gr=1.7;
    case 'dipoleHelix'
        gr=1.95;
    case 'dipoleJ'
        gr=1.7;
    case 'dipoleMeander'
        gr=1.7;
    case 'dipoleVee'
        gr=1.7;
    case 'helix'
        gr=1.95;
    case 'horn'
        gr=1.95;
    case 'infiniteArray'
        gr=1.75;
    case 'invertedF'
        gr=1.75;
    case 'invertedFcoplanar'
        gr=1.75;
    case 'invertedL'
        gr=1.2;
    case 'invertedLcoplanar'
        gr=1.75;
    case 'linearArray'
        gr=1.75;
    case 'loopCircular'
        gr=1.7;
    case 'loopRectangular'
        gr=1.7;
    case 'monopole'
        gr=1.95;
    case 'monopoleTopHat'
        gr=1.95;
    case 'patchMicrostrip'
        if isDielectricSubstrate(obj)
            gr=1.95;
        else
            gr=1.75;
        end
    case 'patchMicrostripCircular'
        gr=1.7;
    case 'patchMicrostripEnotch'
        gr=1.75;
    case 'patchMicrostripInsetfed'
        if isDielectricSubstrate(obj)
            gr=1.95;
        else
            gr=1.65;
        end
    case 'patchMicrostripTriangular'
        gr=1.75;
    case 'pifa'
        gr=1.75;
    case 'rectangularArray'
        gr=1.75;
    case 'reflector'
        gr=1.75;
    case 'reflectorCircular'
        gr=1.75;
    case 'reflectorCorner'
        gr=1.7;
    case 'sectorInvertedAmos'
        gr=1.75;
    case 'slot'
        gr=1.75;
    case 'spiralArchimedean'
        gr=1.75;
    case 'spiralEquiangular'
        gr=1.75;
    case 'vivaldi'
        gr=1.75;
    case 'waveguide'
        gr=1.95;
    case 'yagiUda'
        gr=1.75;

    end
