function createMachineLearningProject( projectFile, archiveName, entryFunctionFiles, additionalFiles )
arguments
    projectFile{ mustBeNonempty, mustBeNonzeroLengthText, mustBeTextScalar }
    archiveName{ mustBeNonempty, mustBeNonzeroLengthText, mustBeTextScalar }
    entryFunctionFiles{ mustBeNonempty, mustBeNonzeroLengthText, mustBeText }
    additionalFiles{ mustBeNonempty, mustBeNonzeroLengthText, mustBeText }
end

templateProject = fullfile( matlabroot, 'toolbox', 'compiler_sdk',  ...
    'java', '+compiler', '+internal', 'machineLearningTemplate.prj.template' );
parser = matlab.io.xml.dom.Parser(  );
dom = parser.parseFile( templateProject );


appNameElements = dom.getElementsByTagName( 'param.appname' );
appNameElements.item( 0 ).TextContent = archiveName;


exportNodes = dom.getElementsByTagName( 'fileset.exports' );
insertFiles( cellstr( entryFunctionFiles ), exportNodes );


resourcesNodes = dom.getElementsByTagName( 'fileset.resources' );
insertFiles( cellstr( additionalFiles ), resourcesNodes );


if exist( projectFile, 'file' )

    movefile( projectFile, [ projectFile, '.bak' ], 'f' );
end
writer = matlab.io.xml.dom.DOMWriter(  );
writer.write( dom, matlab.io.xml.dom.FileWriter( projectFile ) );


    function insertFiles( files, nodes )
        theNode = nodes.item( 0 );
        nodeChildren = theNode.getChildNodes;

        if length( files ) == 1

            nodeChildren.item( 1 ).TextContent =  ...
                compiler.internal.validate.makePathAbsolute( files{ 1 } );
        else



            for i = 2:length( files )
                theNode.appendChild( nodeChildren.item( 1 ).cloneNode( true ) );
                theNode.appendChild( nodeChildren.item( 2 ).cloneNode( true ) );
            end


            for i = 1:length( files )
                nodeChildren.item( i * 2 - 1 ).TextContent =  ...
                    compiler.internal.validate.makePathAbsolute( files{ i } );
            end
        end
    end

end


