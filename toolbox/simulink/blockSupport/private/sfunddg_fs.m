function srcFile=sfunddg_fs(varargin)




    sfun=varargin{1};




    extensions={...
    '.c','.cpp',...
    '.f','.for','.f77','.f90',...
    '.adb','.ada','.ads'};



    loc=[matlabroot,filesep,'simulink',filesep,'src',filesep];

    for i=1:length(extensions)

        srcCandidate=[sfun,extensions{i}];


        srcFile=which(srcCandidate);
        if exist(srcFile,'file')==2
            return;
        end


        srcFile=[loc,srcCandidate];
        if exist(srcFile,'file')==2
            return;
        end

    end




    rtwsrcfull=which('rtwmakecfg','-all');
    pwd_init=pwd;
    toolboxPath=fullfile(matlabroot,'toolbox');
    inMatlabToolbox=startsWith(rtwsrcfull,toolboxPath);
    toolboxAndDemo=inMatlabToolbox;
    toolboxAndDemo(inMatlabToolbox)=contains(eraseBetween(rtwsrcfull(inMatlabToolbox),1,length(toolboxPath)),'demos');
    toolboxAndDemoAndNotRtw=toolboxAndDemo;
    toolboxAndDemoAndNotRtw(toolboxAndDemo)=~contains(eraseBetween(rtwsrcfull(toolboxAndDemo),1,length(toolboxPath)),'rtwdemos');

    rtwsrc=rtwsrcfull(~inMatlabToolbox|toolboxAndDemoAndNotRtw);

    for k=1:length(rtwsrc)
        makeInfo=[];
        pth=fileparts(rtwsrc{k});
        if exist(pth,'dir')
            cd(pth);
            [~,makeInfo]=evalc('rtwmakecfg','cd(pwd_init)');%#ok<EVLC>
            cd(pwd_init);
        end




        if~isempty(makeInfo)&&isfield(makeInfo,'sourcePath')
            extensions={'.c','.cpp'};
            for m=1:length(makeInfo.sourcePath)
                loc=makeInfo.sourcePath{m};
                if~contains(loc,['toolbox',filesep,'rtw'])
                    for n=1:length(extensions)
                        srcCandidate=[sfun,extensions{n}];
                        srcFile=[loc,filesep,srcCandidate];
                        if exist(srcFile,'file')==2
                            return;
                        end
                    end
                end
            end
        end

    end



    if length(sfun)>4&&strcmp(sfun(1:4),'ada_')

        adaExRoot=fullfile(...
        matlabroot,...
        'toolbox',...
        'simulink',...
        'simdemos',...
        'simfeatures',...
        'src_ada');
        adaExt={'.adb','.ada','.ads'};
        exDirs=dir(adaExRoot);


        for k=1:length(exDirs)
            if exDirs(k).isdir
                loc=[adaExRoot,filesep,exDirs(k).name];

                for ii=1:length(adaExt)

                    srcCandidate=[sfun(5:end),adaExt{ii}];
                    srcFile=[loc,filesep,srcCandidate];
                    if exist(srcFile,'file')==2
                        return;
                    end
                end
            end

        end
    end


    srcFile='';
    return;
