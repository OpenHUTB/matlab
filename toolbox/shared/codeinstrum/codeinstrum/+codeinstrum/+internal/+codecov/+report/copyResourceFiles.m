


function copyResourceFiles(aDir)

    persistent rcDir;
    if isempty(rcDir)
        rcDir=fullfile(matlabroot,...
        'toolbox','shared','codeinstrum','codeinstrum',...
        '+codeinstrum','+internal','+codecov','+report','resources');
    end

    if nargin<1
        aDir=pwd;
    end

    if exist(aDir,'dir')~=7
        try
            aDir=rtwprivate('rtw_create_directory_path',aDir,'');
        catch Mex
            throwAsCaller(Mex);
        end
    end

    rcFiles={...
    'codecovreport_utils.js',...
'codecovreport.css'...
    };
    for ii=1:numel(rcFiles)
        copyfile(fullfile(rcDir,rcFiles{ii}),fullfile(aDir,rcFiles{ii}),'f');
    end


