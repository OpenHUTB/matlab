function segments = getPageSwitchingSegments( cDesc, nameValuePairs )

arguments
    cDesc
    nameValuePairs.ExternalParameterWriter = slrealtime.internal.cal.ExternalParameterWriter.empty;
end

visited = {  };
segments = slrealtime.internal.cal.PageSwitchingSegment.empty;
segments = getSegmentsRecursive( cDesc, segments, visited );

segments = segments( end : - 1:1 );

parameterWriter = nameValuePairs.ExternalParameterWriter;
if isempty( parameterWriter )

    parameterWriter = slrealtime.internal.cal.ExternalParameterWriter( cDesc );
end

if parameterWriter.HasPageSwitchingExternalParameters
    segment0 = parameterWriter.getSegment( cDesc );
    segments = [ segment0, segments ];
end


for kSegment = 1:numel( segments )
    segments( kSegment ).Index = kSegment - 1;
end
end

function [ segments, visited ] = getSegmentsRecursive( cDesc, segments, visited )


referencedModelNames = cDesc.getReferencedModelNames;
for kRefModel = 1:numel( referencedModelNames )
    currRefModel = referencedModelNames{ kRefModel };
    if ~ismember( currRefModel, visited )
        cDescRef = cDesc.getReferencedModelCodeDescriptor( currRefModel );
        [ segments, visited ] = getSegmentsRecursive( cDescRef, segments, visited );
    end
end
if ~ismember( cDesc.ModelName, visited )
    segments = [ segments, getSegmentsInModel( cDesc ) ];
    visited{ end  + 1 } = cDesc.ModelName;%#ok<AGROW>
end
end


function segments = getSegmentsInModel( cDesc )

[ segmentRootTypeNames, segmentRootHeaderFiles ] = getSegmentRootTypeAndHeaderFileNames( cDesc );
ci = cDesc.getFullComponentInterface;
params = ci.Parameters;
modelHeader = sprintf( '%s.h', ci.HeaderFile );
segments = slrealtime.internal.cal.PageSwitchingSegment.empty;
for kSegment = 1:numel( segmentRootTypeNames )
    currSeg = getSegmentInfo( params, segmentRootTypeNames{ kSegment }, segmentRootHeaderFiles{ kSegment }, cDesc.ModelName, modelHeader, cDesc.BuildDir );
    segments = [ segments, currSeg ];%#ok<AGROW>
end
end

function currSeg = getSegmentInfo( params, typeName, headerFile, modelName, modelHeader, buildDir )

instance = getBaseVariableIdentifier( params, typeName );
if isempty( instance )
    currSeg = slrealtime.internal.cal.PageSwitchingSegment.empty;
else
    currSeg = slrealtime.internal.cal.PageSwitchingSegment;
    currSeg.Type = typeName;
    currSeg.Instance = instance;

    headerTxt = fileread( fullfile( buildDir, headerFile ) );
    regexpStr = [ '(?:(extern\s+',  ...
        typeName,  ...
        '\s+\*\s*))(\S*)(?:\s*;)' ];
    pointer = regexp( headerTxt, regexpStr, 'tokens', 'once' );
    assert( numel( pointer ) == 1,  ...
        'Could not find pointer variable for type %s in header file', typeName );
    pointer = pointer{ 1 };

    currSeg.Pointer = pointer;
    currSeg.Header = headerFile;
    currSeg.ModelName = modelName;
    currSeg.ModelHeader = modelHeader;
end
end

function [ segmentRootTypeNames, segmentRootHeaderFiles ] = getSegmentRootTypeAndHeaderFileNames( cDesc )




cg = cDesc.getCoderGroups.toArray;
allUserProvidedNames = { cg.UserProvidedName };
allRootTypeNames = { cg.RootTypeName };
allRootHeaderFiles = { cg.RootHeaderFileName };

isSegment = strcmp( allUserProvidedNames, 'PageSwitching' ) & cellfun( @( x )~isempty( x ), allRootTypeNames );
segmentRootTypeNames = allRootTypeNames( isSegment );
segmentRootHeaderFiles = allRootHeaderFiles( isSegment );
end


function baseVariableIdentifier = getBaseVariableIdentifier( params, segmentTypeIdentifier )

baseVariableIdentifier = '';
for kParam = 1:params.Size(  )
    currParam = params( kParam );
    currParamImpl = currParam.Implementation;
    if ~isempty( currParamImpl ) && isa( currParamImpl, 'coder.descriptor.StructExpression' )
        baseVariable = currParamImpl.getBaseVariable;
        baseVariableType = baseVariable.Type;
        if ~isempty( baseVariableType ) &&  ...
                baseVariableType.isStructure &&  ...
                strcmp( baseVariableType.Identifier, segmentTypeIdentifier )
            baseVariableIdentifier = baseVariable.Identifier;
            return ;
        end
    end
end
end
