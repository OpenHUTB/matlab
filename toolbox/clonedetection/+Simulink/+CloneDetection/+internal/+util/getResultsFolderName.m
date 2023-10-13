function resultsFolderName = getResultsFolderName( modelName )

arguments
    modelName = ''
end
resultsFolderSuffixName = modelName;
if isempty( modelName )
    resultsFolderSuffixName = 'ClonesAcrossModels';
end

resultsFolderName = [ 'm2m_', resultsFolderSuffixName ];
end


