function datcomData = extractDATCOMdata( datcomStruct, field, states )

arguments
    datcomStruct
    field( 1, 1 )string
    states( :, 1 )string
end

datcomData = datcomStruct.( field );

inds = repmat( { ':' }, size( states ) );
buildidx = states == "build";
if any( buildidx )
    inds{ buildidx } = datcomStruct.build;
end
datcomData = datcomData( inds{ : } );

end


