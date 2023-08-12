

function resultsFolderName = getResultsFolderName( modelName )





R36
modelName = ''
end 
resultsFolderSuffixName = modelName;
if isempty( modelName )
resultsFolderSuffixName = 'ClonesAcrossModels';
end 

resultsFolderName = [ 'm2m_', resultsFolderSuffixName ];
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp1BrCs2.p.
% Please follow local copyright laws when handling this file.

