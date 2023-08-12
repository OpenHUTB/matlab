classdef DictionaryClosureUtils < handle





methods ( Static )
function [ isLinkedToDict, dictFiles ] = isModelLinkedToInterfaceDict( modelName, namedargs )


R36
modelName
namedargs.WithPlatformMapping{ mustBeMember( namedargs.WithPlatformMapping, { '', 'AUTOSARClassic' } ) } = ''
end 

import Simulink.interface.dictionary.internal.DictionaryClosureUtils

isLinkedToDict = false;
dictFiles = {  };


interfaceDicts = DictionaryClosureUtils.findReferencedInterfaceDictionaries( modelName );

if ~isempty( interfaceDicts )
if isempty( namedargs.WithPlatformMapping )
isLinkedToDict = true;
dictFiles = interfaceDicts;
else 
for dictIdx = 1:length( interfaceDicts )
dictImpl = sl.interface.dict.api.openInterfaceDictionary( interfaceDicts{ dictIdx } );
if dictImpl.MappingManager.hasMappingFor( namedargs.WithPlatformMapping )
isLinkedToDict = true;
dictFiles{ end  + 1 } = interfaceDicts{ dictIdx };%#ok<AGROW>
end 
end 
end 
end 
end 

function dictFiles = getLinkedInterfaceDicts( modelName )
import Simulink.interface.dictionary.internal.DictionaryClosureUtils
[ ~, dictFiles ] = DictionaryClosureUtils.isModelLinkedToInterfaceDict( modelName );
end 

function [ isInterfaceDictInClosure, interfaceDicts ] = hasInterfaceDictInClosure( dictName )


import Simulink.interface.dictionary.internal.DictionaryClosureUtils


interfaceDicts = DictionaryClosureUtils.findInterfaceDictionariesInSlddClosure( dictName );
isInterfaceDictInClosure = ~isempty( interfaceDicts );
end 
end 

methods ( Static, Access = private )
function interfaceDicts = findInterfaceDictionariesInSlddClosure( dictName )



interfaceDicts = [  ];



try 
ddConn = Simulink.dd.open( dictName );
catch 


return ;
end 
allDictsPath = ddConn.DependencyClosure;

for idx = 1:length( allDictsPath )
if sl.interface.dict.api.isInterfaceDictionary( allDictsPath{ idx } )
interfaceDicts{ end  + 1 } = allDictsPath{ idx };%#ok<AGROW>
end 
end 
end 

function interfaceDicts = findReferencedInterfaceDictionaries( modelName )


import Simulink.interface.dictionary.internal.DictionaryClosureUtils

interfaceDicts = {  };


mainDictName = get_param( modelName, 'DataDictionary' );
if isempty( mainDictName )
return ;
end 


interfaceDicts = DictionaryClosureUtils.findInterfaceDictionariesInSlddClosure( mainDictName );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnCbYwc.p.
% Please follow local copyright laws when handling this file.

