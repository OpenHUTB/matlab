function logScreenerUnsupportedFunctions( funcs, appType )
arguments
    funcs
    appType{ mustBeMember( appType, { 'screener', 'matlabcoder', 'gpucoder', 'fixedpoint', 'matlabhdlcoder' } ) } = 'screener'
end



if isjava( funcs )
    if isa( funcs, 'java.util.Collection' )
        funcs = funcs.toArray(  );
    end
    funcs = cell( funcs );
else
    funcs = cellstr( funcs );
end

funcs( cellfun( 'isempty', funcs ) ) = [  ];
if isempty( funcs )
    return
end
funcs = unique( funcs, 'stable' );

dataId = matlab.ddux.internal.DataIdentification(  ...
    'ME', 'ME_EML', 'ME_EML_INFERENCEDATA' );
data.clientName = appTypeToClientName( appType );
data.errorID = '';

for i = 1:numel( funcs )
    data.missingFcnName = funcs{ i };
    matlab.ddux.internal.logData( dataId, data );
end
end


function clientName = appTypeToClientName( appType )


switch appType
    case 'matlabcoder'
        clientName = 'MATLAB Coder App';
    case 'gpucoder'
        clientName = 'GPU Coder App';
    case 'fixedpoint'
        clientName = 'Fixed-Point Converter App';
    case 'matlabhdlcoder'
        clientName = 'HDL Coder App';
    otherwise
        clientName = 'Screener';
end
end

