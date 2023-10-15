function tf = isGenericMUnitFile( fileName )

arguments
    fileName string{ mustBeNonempty };
end

[ ~, ~, fileExt ] = fileparts( fileName );
tf = false;

if fileExt == ".m"
    try
        suite = matlab.unittest.TestSuite.fromFile( fileName );

        tf = isa( suite, 'matlab.unittest.Test' );
    catch
        tf = false;
    end
end
end

