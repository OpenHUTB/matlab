function [ val, isValidProperty ] = getSignalProperty( portHandle, propName, options )

arguments
    portHandle
    propName string
    options.ReturnRawValue logical = false;
end

val = [  ];
isValidProperty = true;
switch propName
    case "Complexity"
        val = get_param( portHandle, "CompiledPortComplexSignal" );
        if val == 1
            val = "complex";
        elseif val == 0
            val = "real";
        else
            val = "mixed";
        end
    case { "DataType", "CompiledPortDataType" }
        sh = get_param( portHandle, "SignalHierarchy" );
        if ~options.ReturnRawValue && ~isempty( sh ) && ~isempty( sh.BusObject )

            val = mlreportgen.dom.InternalLink(  ...
                mlreportgen.utils.normalizeLinkID( "bus-" + sh.BusObject ),  ...
                sh.BusObject );
        else
            val = get_param( portHandle, "CompiledPortDataType" );
        end
    case { "Units", "Unit", "CompiledPortUnits" }
        property = "CompiledPortUnit";
        val = get_param( portHandle, property );
    case { "Min", "Max" }
        property = "CompiledPortDesign" + propName;
        val = get_param( portHandle, property );
    case { "Dimensions", "SampleTime" }
        property = "CompiledPort" + propName;
        val = get_param( portHandle, property );
    otherwise


        [ propVal, isInvalid ] = mlreportgen.utils.safeGet( portHandle, propName, 'get_param' );
        if isInvalid
            line = get_param( portHandle, "Line" );
            [ propVal, isInvalid ] = mlreportgen.utils.safeGet( line, propName, 'get_param' );
        end

        if isempty( isInvalid )
            val = propVal{ 1 };
        elseif isInvalid
            isValidProperty = false;
        end
end

if ~options.ReturnRawValue && ~isempty( val ) && ~isa( val, "mlreportgen.dom.Element" )
    val = mlreportgen.utils.toString( val );
end
end
