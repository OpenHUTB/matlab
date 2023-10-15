function [ matObj, variableName ] = loadCachedDeepLearningObj( matFileOrFcnCall, variableName, nvps )

arguments
    matFileOrFcnCall
    variableName{ mustBeTextScalar } = ''
    nvps.ReturnNetwork( 1, 1 )logical = false
    nvps.UseCache( 1, 1 )logical = true;
end



persistent matObjMap;
if isempty( matObjMap )
    matObjMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
end

[ fullName, timeStamp, usingCache ] = coder.internal.getFileInfo( matFileOrFcnCall );


matObjLoaded = false;
if ~usingCache || ~nvps.UseCache
    [ matObj, variableName ] = coder.internal.loadCachedDeepLearningObjImpl( matFileOrFcnCall, variableName );
    matObjLoaded = true;
elseif matObjMap.isKey( fullName )
    timeStampOldAndVarObjMap = matObjMap( fullName );
    timeStampOld = timeStampOldAndVarObjMap{ 1 };
    varObjMap = timeStampOldAndVarObjMap{ 2 };
    if timeStamp == timeStampOld

        if isempty( variableName )

            matObjCell = varObjMap.values(  );
            matObj = matObjCell{ 1 };
            varNameCell = varObjMap.keys(  );
            variableName = varNameCell{ 1 };
            matObjLoaded = true;
        elseif varObjMap.isKey( variableName )

            matObj = varObjMap( variableName );
            matObjLoaded = true;
        else

            [ matObj, variableName ] = coder.internal.loadCachedDeepLearningObjImpl( matFileOrFcnCall, variableName );
            varObjMap( variableName ) = matObj;
            matObjLoaded = true;
        end
    end
end

if ~matObjLoaded
    [ matObj, variableName ] = coder.internal.loadCachedDeepLearningObjImpl( matFileOrFcnCall, variableName );

    varObjMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
    varObjMap( variableName ) = matObj;
    matObjMap( fullName ) = { timeStamp, varObjMap };
    matObjLoaded = true;
end

if nvps.ReturnNetwork && coder.internal.hasPublicMethod( class( matObj ), 'matlabCodegenPrivateNetwork' )
    matObj = matlabCodegenPrivateNetwork( matObj );
end

end
