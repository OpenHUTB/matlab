function [  ] = throwExceptionForListItems( exceptionDataList, exceptionId, exceptionType )
arguments
    exceptionDataList
    exceptionId char = 'sl_pir_cpp:creator:InvalidInputGeneric'
    exceptionType char = 'Warning'
end

if iscell( exceptionDataList )
    for exceptionIndex = 1:length( exceptionDataList )
        try
            exceptionItem = string( exceptionDataList{ exceptionIndex } );
        catch
            continue ;
        end

        if ( strcmp( exceptionType, 'Warning' ) )
            DAStudio.warning( exceptionId, exceptionItem );
        end
    end
end
end

