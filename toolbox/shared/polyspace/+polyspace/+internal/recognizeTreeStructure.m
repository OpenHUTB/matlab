function[recognizedPrefix,matchingRoots]=...
    recognizeTreeStructure(inputPaths,from)

    narginchk(2,2);

    currDir=pwd;

    validateattributes(inputPaths,{'cell'},{});
    validateattributes(from,{'char'},{});

    FILESYSTEM_RECOGNIZE_TREE_STRUCTURE=3;
    [recognizedPrefix,matchingRoots]=...
    filesystem_mex(FILESYSTEM_RECOGNIZE_TREE_STRUCTURE,...
    currDir,inputPaths,from);
