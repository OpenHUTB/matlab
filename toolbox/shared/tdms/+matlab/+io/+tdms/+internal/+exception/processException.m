function decoratedME = processException( ME )

arguments
    ME( 1, 1 )MException
end
logException( ME );
decoratedME = decorateException( ME );
end

function logException( ME )
arguments
    ME( 1, 1 )MException
end
if ~isLogEnabled(  )
    return ;
end
msgText = getReport( ME, 'extended', 'hyperlinks', 'off' );
filePath = fullfile( tempdir, "TDMS.txt" );
fid = fopen( filePath, 'w' );
fprintf( fid, msgText );
fprintf( fid, "\n Stack Info: \n" );
for i = 1:length( ME.stack )
    fprintf( fid, '%s in %s at %i\n', ME.stack( i ).name, ME.stack( i ).file, ME.stack( i ).line );
end
fclose( fid );
end

function decoratedME = decorateException( ME )
arguments
    ME( 1, 1 )MException
end
if ME.identifier == "MATLAB:mex:CppMexException"
    decoratedME = decorateCppMexException( ME );
    return ;
elseif contains( ME.identifier, "MATLAB:timetable:" ) || contains( ME.identifier, "MATLAB:table2timetable:" )
    decoratedME = decorateTimeTableException( ME );
    return ;
else
    decoratedME = ME;
end
end

function processedME = decorateCppMexException( ME )
arguments
    ME( 1, 1 )MException
end
expr = "(?<errCode>\d+)\s:\s(?<errMsg>(\w+).*)";
tokens = regexp( ME.message, expr, 'names' );
if isempty( tokens )
    processedME = ME;
    return ;
else
    errId = "tdms:TDMS:ErrorInLibrary";
    processedME = MException( errId, message( errId, tokens.errCode, tokens.errMsg ) );
end
end

function decoratedME = decorateTimeTableException( ME )
arguments
    ME( 1, 1 )MException
end

ttIdentifiers = [  ...
    "MATLAB:timetable:NoTimeVector" ...
    , "MATLAB:table2timetable:IncorrectNumberOfRowTimes" ...
    , "MATLAB:timetable:RowTimesParamConflict" ...
    , "MATLAB:timetable:ImpureCalDurTimeStep" ...
    , "MATLAB:timetable:DurationStartTimeWithCalDurTimeStep"
    ];

if ~ismember( ME.identifier, ttIdentifiers )
    decoratedME = ME;
    return ;
end

if isNameInStack( ME, "tdmsread" )
    errId = "tdms:TDMS:UnableToCreateTimeTable";
    decoratedME = MException( errId, message( errId ) );
elseif isNameInStack( ME, "read" )
    errId = "tdms:TDMS:UnableToCreateTimeTableDatastore";
    decoratedME = MException( errId, message( errId ) );
else
    decoratedME = ME;
end
end

function b = isNameInStack( ME, name )
b = false;
for i = 1:length( ME.stack )
    if ME.stack( i ).name == name
        b = true;
        return ;
    end
end
end

function logEnabled = isLogEnabled(  )
logEnabled = false;
if ispref( "shared_tdms", "logexception" )
    logEnabled = getpref( "shared_tdms", "logexception" );
end
end

