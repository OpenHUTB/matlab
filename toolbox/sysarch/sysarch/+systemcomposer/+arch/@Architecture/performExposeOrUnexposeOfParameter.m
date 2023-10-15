function performExposeOrUnexposeOfParameter( this, options )

arguments
    this{ mustBeA( this, 'systemcomposer.arch.Architecture' ) }
    options.Path{ mustBeTextScalarOrObject }
    options.operation{ mustBeMember( options.operation, { 'expose', 'unexpose' } ) } = ""
    options.Parameters{ mustBeText } = "all"
    options.ShortName{ mustBeTextScalar } = ""
end

if isa( options.Path, 'systemcomposer.arch.BaseComponent' )
    childSlObj = get_param( options.Path.SimulinkHandle, 'Object' );
    childPath = childSlObj.getFullName;
else
    childPath = string( options.Path );
end
options.Parameters = string( options.Parameters );
options.ShortName = string( options.ShortName );


slObj = get_param( this.SimulinkHandle, 'Object' );
thisPath = string( slObj.getFullName );

try


    fullPathOfChild = find_system( childPath, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices );
    fullPathOfChild = string( fullPathOfChild{ 1 } );



    if ~startsWith( fullPathOfChild, thisPath )
        fullPathOfChild = thisPath.append( "/", childPath );
    end
catch
    if ~isempty( regexp( childPath, [ '^\.\', '/' ], 'once' ) )
        childPath = childPath.extractAfter( 2 );
    end

    if ~isempty( regexp( childPath, [ '^\', '/' ], 'once' ) )
        childPath = options.Path( 2:end  );
    end
    fullPathOfChild = thisPath.append( "/", childPath );
end


try


    find_system( fullPathOfChild, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices );
catch e
    metaData = jsondecode( e.json );
    error( 'Cannot find component %s in %s', metaData.args{ 1 }, metaData.args{ 2 } );
end

childComp = this.Model.lookup( 'Path', fullPathOfChild );
allChildParams = childComp.getParameterNames;

cnt = 1;
if strcmpi( options.Parameters, "all" )
    paramNames = string.empty( 0, numel( allChildParams ) );
    for paramName = allChildParams
        paramNames( cnt ) = paramName;
        cnt = cnt + 1;
    end
else

    paramNames = string.empty( 0, numel( options.Parameters ) );
    for specifiedParam = options.Parameters
        paramName = specifiedParam;
        if paramName.contains( "." )

            idx = allChildParams.matches( paramName );
        else
            idx = allChildParams.matches( strcat( paramName ) );
        end
        if ~any( idx )
            if strcmpi( options.operation, 'expose' )
                error( 'Parameter does not exist on %s', fullPathOfChild );
            else

                continue ;
            end
        end
        if ~isempty( idx )
            paramNames( cnt ) = allChildParams( idx );
            cnt = cnt + 1;
        end
    end
end

if isequal( options.ShortName, "" )
    shortName = fullPathOfChild;
end

if ~isempty( paramNames )
    if size( paramNames, 2 ) == 1
        paramNamesCell = { convertStringsToChars( paramNames ) };
    else
        paramNamesCell = convertStringsToChars( paramNames );
    end


    isChildSSRefComponent = systemcomposer.internal.isSubsystemReferenceComponent( childComp.SimulinkHandle );
    isChildModelRefComponent = childComp.isReference && ~isChildSSRefComponent;

    bh = get_param( fullPathOfChild, 'handle' );

    if isempty( this.Parent )
        if isChildModelRefComponent


            if strcmpi( options.operation, "expose" )
                argumentVal = true;
            else
                argumentVal = false;
            end
            systemcomposer.internal.arch.internal.updateInstanceParamsInSL( bh, paramNamesCell, 'Argument', argumentVal );
        else

            if ~isChildSSRefComponent

                mdlWks = get_param( this.SimulinkHandle, 'ModelWorkspace' );
                if strcmpi( options.operation, "expose" )
                    this.getImpl.exposeParameter( childComp.getImpl, shortName, paramNamesCell );


                    mdlArgs = "";
                    for i = 1:numel( paramNamesCell )
                        aParamName = paramNamesCell{ i };
                        aParam = childComp.getParameter( aParamName );
                        aPath = extractAfter( shortName, "/" );
                        argName = replace( aPath, '/', '_' ) + "_" + aParamName;

                        value = eval( aParam.Value );
                        po = Simulink.Parameter( value );
                        po.DataType = aParam.Type.DataType;
                        po.Unit = aParam.Type.Units;
                        if strlength( aParam.Type.Minimum ) > 0
                            po.Min = eval( aParam.Type.Minimum );
                        else
                            po.Min = [  ];
                        end
                        if strlength( aParam.Type.Maximum ) > 0
                            po.Max = eval( aParam.Type.Maximum );
                        else
                            po.Max = [  ];
                        end

                        assignin( mdlWks, argName, po );

                        mdlArgs = mdlArgs.append( argName + "," );
                    end


                    argList = get_param( this.SimulinkHandle, 'ParameterArgumentNames' );
                    if isempty( argList )
                        newArgList = mdlArgs.strip( 'right', ',' );
                    else
                        newArgList = mdlArgs + argList;
                    end
                    set_param( this.SimulinkHandle, 'ParameterArgumentNames', newArgList );
                else
                    this.getImpl.unexposeParameter( childComp.getImpl, paramNamesCell );


                    mdlArgsToClear = "";
                    for i = 1:numel( paramNamesCell )
                        aParamName = paramNamesCell{ i };
                        aPath = extractAfter( shortName, "/" );
                        argName = aPath + "_" + aParamName;
                        mdlArgsToClear = mdlArgsToClear.append( argName + "," );
                    end
                    clearCommand = "clear " + mdlArgsToClear.strip( 'right', ',' );
                    evalin( mdlWks, clearCommand );
                end
            end
        end
    else


        if ~isChildSSRefComponent
            if strcmpi( options.operation, "expose" )
                this.getImpl.exposeParameter( childComp.getImpl, shortName, paramNamesCell );
            else
                this.getImpl.unexposeParameter( childComp.getImpl, paramNamesCell );
            end
        end
    end
end

end

function mustBeTextScalarOrObject( value )


valid = false;
if isa( value, 'systemcomposer.arch.BaseComponent' )
    valid = true;
else
    inputTxt = string( value );
    if numel( inputTxt ) == 1
        valid = true;
    end
end

if ~valid
    error( 'Specify the path as a Component object or a string' );
end
end

