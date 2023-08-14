function[base]=createEmptyBase()%#codegen




    coder.allowpcode('plain');

    base=struct(...
    'SRated',nan,...
    'VRated',nan,...
    'FRated',nan,...
    'connection',ee.enum.Connection.wye,...
    'SPerPhase',nan,...
    'PPerPhase',nan,...
    'QPerPhase',nan,...
    'V',nan,...
    'v',nan,...
    'I',nan,...
    'i',nan,...
    'Z',nan,...
    'R',nan,...
    'X',nan,...
    'Y',nan,...
    'G',nan,...
    'B',nan,...
    'L',nan,...
    'C',nan,...
    'Psi',nan,...
    'psi',nan,...
    'wElectrical',nan,...
    'nPolePairs',nan,...
    'wMechanical',nan,...
    'torque',nan);
end

