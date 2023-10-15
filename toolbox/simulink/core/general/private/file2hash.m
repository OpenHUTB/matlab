function result = file2hash( aFile )

arguments
    aFile{ mustBeTextScalar, mustBeFile }
end

result = builtin( '_getFileChecksum', convertStringsToChars( aFile ) );
end
