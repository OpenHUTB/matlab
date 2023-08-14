function gr=getNewMesherGrowthRate(obj)




    objtype=class(obj);
    switch objtype
    case 'bicone'
        gr=1.75;
    case 'biquad'
        gr=1.05;
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
    case 'cassegrain'
        gr=1.75;
    case 'hornConical'
        gr=1.75;
    case 'hornConicalCorrugated'
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
        gr=1.95;
    case 'dipoleBlade'
        gr=1.95;
    case 'dipoleCycloid'
        gr=1.7;
    case 'dipoleFolded'
        gr=1.95;
    case 'dipoleHelix'
        gr=1.95;
    case 'dipoleHelixMultifilar'
        gr=1.95;
    case 'dipoleJ'
        gr=1.7;
    case 'dipoleMeander'
        gr=1.7;
    case 'dipoleVee'
        gr=1.7;
    case 'dipoleCrossed'
        gr=1.5;
    case 'discone'
        gr=1.75;
    case 'gregorian'
        gr=1.75;
    case 'helix'
        gr=1.95;
    case 'helixMultifilar'
        gr=1.95;
    case 'horn'
        gr=1.95;
    case 'hornRidge'
        gr=1.75;
    case 'hornCorrugated'
        gr=1.75;
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
    case 'monocone'
        gr=1.75;
    case 'monopole'
        gr=1.95;
    case 'monopoleTopHat'
        gr=1.95;
    case 'patchMicrostrip'
        if isDielectricSubstrate(obj)
            gr=1.95;
        else
            gr=1.3;
        end
    case 'patchMicrostripCircular'
        gr=1.7;
    case 'patchMicrostripElliptical'
        gr=1.7;
    case 'patchMicrostripEnotch'
        gr=1.75;
    case 'patchMicrostripHnotch'
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
    case 'rhombic'
        gr=1.75;
    case 'sectorInvertedAmos'
        gr=1.75;
    case 'slot'
        gr=1.75;
    case 'spiralArchimedean'
        gr=1.75;
    case 'spiralEquiangular'
        gr=1.75;
    case 'spiralRectangular'
        gr=1.75;
    case 'vivaldi'
        gr=1.7;
    case 'waveguide'
        gr=1.95;
    case 'waveguideCircular'
        gr=1.95;
    case 'waveguideSlotted'
        gr=1.95;
    case 'yagiUda'
        gr=1.75;
    case 'quadCustom'
        gr=1.75;
    case 'reflectorParabolic'
        gr=1.75;
    case 'fractalGasket'
        gr=1.75;
    case 'fractalKoch'
        gr=1.95;
    case 'fractalSnowflake'
        gr=1.95;
    case 'fractalCarpet'
        gr=1.4;
    case 'fractalIsland'
        gr=1.5;
    case 'lpda'
        gr=1.15;
    case 'vivaldiAntipodal'
        gr=1.95;
    case 'installedAntenna'
        gr=1.5;
    case 'platform'
        gr=1.5;
    case 'waveguideRidge'
        gr=1.75;
    case 'planeWaveExcitation'
        gr=1.75;
    case 'customAntennaStl'
        gr=1.25;
    case 'em.internal.stl.Stl'
        gr=1.25;
    case 'disconeStrip'
        gr=1.75;
    case 'biconeStrip'
        gr=1.75;
    case 'reflectorGrid'
        gr=1.75;
    case 'monopoleCustom'
        gr=1.95;
    case 'monopoleRadial'
        gr=1.75;
    case 'reflectorCylindrical'
        gr=1.75;
    case 'reflectorSpherical'
        gr=1.75;
    case 'draRectangular'
        gr=1.15;
    case 'draCylindrical'
        gr=1.15;
    case 'cassegrainOffset'
        gr=1.75;
    case 'gregorianOffset'
        gr=1.75;
    case 'microstripLine'
        gr=1.5;
    case 'stripLine'
        gr=1.75;
    case 'couplerBranchline'
        gr=1.5;
    case 'spiralInductor'
        gr=1.75;
    case 'wilkinsonSplitter'
        gr=1.5;
    case 'couplerRatrace'
        gr=1.5;
    case 'coplanarWaveguide'
        gr=1.5;
    case 'interdigitalCapacitor'
        gr=1.75;
    case 'hornPotter'
        gr=1.75;
    case 'monopoleCylindrical'
        gr=1.75;
    case 'dipoleCylindrical'
        gr=1.75;
    case 'hornScrimp'
        gr=1.75;
    case 'vivaldiOffsetCavity'
        gr=1.25;
    case 'eggCrate'
        gr=1.25;
    case 'coupledMicrostripLine'
        gr=1.5;
    case 'filterCoupledLine'
        gr=1.5;
    case 'stubRadialShunt'
        gr=1.5;
    case 'filterStepImpedanceLowPass'
        gr=1.75;
    case 'filterHairpin'
        gr=1.5;
    case 'couplerLange'
        gr=1.75;
    case 'customDualReflectors'
        gr=1.75;
    case 'wilkinsonSplitterUnequal'
        gr=1.5;
    case 'coupledStripLine'
        gr=1.5;
    case 'pcbStack'
        gr=getMeshGrowthRate(obj);
    case 'balunCoupledLine'
        gr=1.57;
    case 'wilkinsonSplitterWideband'
        gr=1.5;
    case 'powerDividerCorporate'
        gr=1.5;
    case 'resonatorRing'
        gr=1.5;
    case 'viaSingleEnded'
        gr=1.5;
    case 'viaDifferential'
        gr=1.5;
    case 'phaseShifter'
        gr=1.5;
    case 'couplerDirectional'
        gr=1.5;
    case 'microstripLineCustom'
        gr=1.5;
    case 'splitterTee'
        gr=1.5;
    case 'resonatorSplitRingSquare'
        gr=1.5;
    case 'filterCombline'
        gr=1.5;
    case 'balunMarchand'
        gr=1.5;
    case 'filterStub'
        gr=1.5;
    case 'em.internal.authoring.customAntenna'
        gr=1.75;







    end
