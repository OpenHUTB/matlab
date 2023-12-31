function prepareImageFiles(startDir)













    currentVersion='111';
    localImageDir=fullfile(startDir,'scv_images');

    if exist(localImageDir,'dir')==7
        if exist(fullfile(localImageDir,['version',currentVersion,'.txt']),'file')==2
            return
        else
            copyAllFiles=1;
        end
    else
        mkdir(localImageDir);
        copyAllFiles=1;
    end

    if copyAllFiles
        imageDir=fullfile(matlabroot,'toolbox','slcoverage','gifs');




        imageFiles={...
        'grn01.gif',...
        'grn02.gif',...
        'grn03.gif',...
        'grn04.gif',...
        'grn05.gif',...
        'grn06.gif',...
        'grn07.gif',...
        'grn08.gif',...
        'grn09.gif',...
        'htmlfile.gif',...
        'red.gif',...
        'purple.gif',...
        'pink.gif',...
        'trans.gif',...
        'blue.gif',...
        'aqua.gif',...
        'ltBlu.gif',...
        'ltblue.gif',...
        'ltgrn.gif',...
        'yellow.gif',...
        'black.gif',...
        'dkgrn.gif',...
        'white.gif',...
        'horz_line.gif',...
        'vert_line.gif',...
        'right_arrow.gif',...
        'left_arrow.gif',...
        'filter_add.png',...
'filter_remove.png'
        };
        try
            for file=imageFiles
                copyfile(fullfile(imageDir,file{1}),fullfile(localImageDir,file{1}),'f')
            end
        catch MEx
            throw(addCause(MException('Slvnv:simcoverage:cvhtml:ReportFailed',getString(message('Slvnv:simcoverage:cvhtml:ReportFailed'))),MEx));
        end




        jsDir=fullfile(matlabroot,'toolbox','slcoverage','resources');
        jsFiles={...
        'covreport_utils.js',...
        };

        for file=jsFiles
            copyfile(fullfile(jsDir,file{1}),fullfile(localImageDir,file{1}),'f');
        end




        cssDir=fullfile(matlabroot,'toolbox','slcoverage','resources');

        cssFiles={...
        'modelcovreport.css',...
        };

        for file=cssFiles
            copyfile(fullfile(cssDir,file{1}),fullfile(localImageDir,file{1}),'f');
        end

        copyfile(fullfile(imageDir,'version.txt'),...
        fullfile(localImageDir,['version',currentVersion,'.txt']),'f');


        codeinstrum.internal.codecov.report.copyResourceFiles(localImageDir);
    end



