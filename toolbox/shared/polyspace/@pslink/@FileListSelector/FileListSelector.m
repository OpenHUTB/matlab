

function this=FileListSelector(pslinkcc,fileList)

    narginchk(1,2);

    if nargin<1
        fileList={};
    end

    this=pslink.FileListSelector;

    assert(isa(pslinkcc,'pslink.ConfigComp'),...
    'First argument must be a pslink.ConfigComp object');
    assert(iscellstr(fileList),...
    'Second argument must be a cell of strings or empty');

    this.pslinkcc=pslinkcc;
    this.AdditionalFileList=fileList;


