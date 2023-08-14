function privsetupxilinxtools(varargin)




    narginchk(0,1);












    supportedOS={'PCWIN','PCWIN64','GLNX86','GLNXA64'};
    fpgaInstalled=license('test','EDA_Simulator_Link')&&...
    ~isempty(ver('hdlverifier'))&&any(strcmp(computer,supportedOS));

    if~fpgaInstalled
        warning(message('EDALink:privsetupxilinxtools:nofpgafeature'));
        return;
    end




    xilinxVar=getenv('XILINX');

    if nargin==1

        newXilinxVar=varargin{1};

        if~ischar(newXilinxVar)
            error(message('EDALink:privsetupxilinxtools:inputstr'));
        end


        orgDir=pwd;
        try
            cd(newXilinxVar);
            newXilinxVar=pwd;
            cd(orgDir);
        catch me
            cd(orgDir);
            error(message('EDALink:privsetupxilinxtools:invaliddir',newXilinxVar));
        end


        fprintf('\nSetting XILINX environment variable to:\n%s\n\n',newXilinxVar);
        setenv('XILINX',newXilinxVar);

    else

        if isempty(xilinxVar)
            warning(message('EDALink:privsetupxilinxtools:noxilinxenv'));
            return;
        end


        fprintf('\nCurrent value of the XILINX environment variable:\n%s\n\n',xilinxVar);

    end





    [apipath,supportedise]=getxilinxpaths;

    if isempty(apipath)&&supportedise



        if nargin==1

            fprintf('\nRestored XILINX environment variable to original value.\n\n');
            setenv('XILINX',xilinxVar);
        end

        return;
    end





    if nargin==1
        l_addISEPath;
    end





    if~isclockmodulesupported
        return;
    end

    if isempty(apipath)




        warning(message('EDALink:privsetupxilinxtools:noapipath'));

        return;
    end


    addpath(apipath.path{:});

    fprintf('\nThe following folder has been added to the MATLAB search path:\n');
    for n=1:length(apipath.path)
        fprintf('%s\n',apipath.path{n});
    end
    disp(' ');

end














function l_addISEPath
    persistent pathToAdd;

    xilVar=getenv('XILINX');
    tag=l_getPlatformTag;
    isePath=[fullfile(xilVar,'bin',tag),pathsep];
    if ispc
        isePath=[isePath,fullfile(xilVar,'lib',tag),pathsep];
    end

    if~strcmp(pathToAdd,isePath)

        fprintf('\nPrepending the following ISE path(s) to the system path:\n%s\n\n',isePath);
        setenv('PATH',[isePath,getenv('PATH')]);

        pathToAdd=isePath;
    else

        fprintf('\nThe following ISE path is already on the system path:\n%s\n\n',isePath);
    end

end


function tag=l_getPlatformTag

    platform=upper(computer);
    switch platform
    case 'PCWIN'
        tag='nt';
    case 'PCWIN64'
        tag='nt64';
    case 'GLNX86'
        tag='lin';
    case 'GLNXA64'
        tag='lin64';
    otherwise
        error(message('EDALink:privsetupxilinxtools:platformtag'));
    end
end

