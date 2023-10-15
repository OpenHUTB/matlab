function [ comps, isInBatchMode ] = validateAndConvertSubsystemInputToStrings( subsys, isInUIMode )




arguments
    subsys;
    isInUIMode = false;
end

comps = [  ];
isInBatchMode = [  ];
isValid = false;
if isempty( subsys )
    error( message( 'stm:TestForSubsystem:NoSubsystemSpecified' ) );
end
if ~isvector( subsys )
    error( message( 'stm:TestForSubsystem:SubsystemInputMustBeVector' ) );
end
dataTypeOfSubsys = class( subsys );
switch dataTypeOfSubsys
    case "char"
        validInds = true;
        isValid = true;
        comps = string( subsys );
    case "string"
        validInds = subsys ~= "";
        isValid = all( validInds );
        if isValid
            comps = subsys;
        end
    case "cell"
        validInds = cellfun( @( x )( ( ischar( x ) || isstring( x ) ) && x ~= "" ), subsys, 'UniformOutput', true );
        isValid = all( validInds );
        if isValid
            comps = string( subsys );
        end
    case "Simulink.BlockPath"
        lengths = arrayfun( @( x )( x.getLength ), subsys, "UniformOutput", true );
        validInds = lengths > 0;
        isValid = all( validInds );
        if isValid
            comps = string( arrayfun( @( len, bp )( bp.getBlock( len ) ), lengths, subsys, "UniformOutput", false ) );
        end
end
if ~isValid
    if ~isInUIMode
        stm.internal.TestForSubsystem.throwInvSimulinkObjError( ~validInds );
    else
        stm.internal.TestForSubsystem.throwInvBlkErrorForUI( strjoin( subsys( ~validInds ), ", " ) );
    end
end
numOfComps = numel( comps );
isInBatchMode = numOfComps > 1;
end
