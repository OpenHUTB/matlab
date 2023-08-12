function [ matches, dataset ] = getClassCompletions( stringToComplete, passNum, dataset, opts )











































R36
stringToComplete{ mustBeTextScalar } = ''
passNum{ mustBePositive, mustBeInteger } = 1
dataset{ mustBeText } = ""
opts.timeLimit{ mustBePositive } = 0.4
opts.resultLimit{ mustBePositive, mustBeInteger } = 200
end 

persistent classList
if isempty( classList )
defaultClasses = { 
'categorical', 'cell', 'char', 'double',  ...
'embedded.fi', 'half', 'int8', 'int16',  ...
'int32', 'int64', 'logical', 'single',  ...
'string', 'struct', 'table', 'timetable',  ...
'uint8', 'uint16', 'uint32', 'uint64' ...
 };
fid = fopen( fullfile( matlabroot, "toolbox", "shared", "coder", "coder", "screener", "wte_class_list.txt" ) );
additionalClasses = textscan( fid, '%s' );
classList = [ defaultClasses';additionalClasses{ : } ];
closeFile = onCleanup( @(  )fclose( fid ) );
end 

stringToComplete = convertStringsToChars( stringToComplete );

if passNum == 1 && ~isempty( stringToComplete )
dataset = builtin( '_tabCompletionTest', stringToComplete, numel( stringToComplete ), [  ] );
dataset = dataset( 3:end  );
end 

classFilter = false( 1, numel( dataset ) );
numMatches = 0;
numProcessed = 0;
tStart = tic;
for i = 1:numel( dataset )
if ( numMatches >= opts.resultLimit ) || ( toc( tStart ) >= opts.timeLimit && numMatches > 0 )
break ;
end 
isMatch = ismember( dataset( i ), classList ) ||  ...
( exist( dataset{ i }, 'class' ) == 8 && ~contains( which( dataset{ i } ), matlabroot ) );
if isMatch
numMatches = numMatches + 1;
end 
classFilter( i ) = isMatch;
numProcessed = numProcessed + 1;
end 
matches = dataset( classFilter );
dataset = dataset( numProcessed + 1:end  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpV5nM9B.p.
% Please follow local copyright laws when handling this file.

