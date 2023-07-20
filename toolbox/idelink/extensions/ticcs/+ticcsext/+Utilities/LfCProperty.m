function resp=LfCProperty(opt,subopt)




    narginchk(1,2);

    switch opt
    case 'method-in-use'
        resp='in-process';

    case 'ccslinkpref-groupname'
        resp='MathWorks_Link_For_CCS_Application_Preferences';

    case 'inprocFile-current-client'
        resp=fullfile(matlabroot,'toolbox','idelink','extensions','ticcs','bin','win32','MWCCSStu.ocx');

    case 'inprocFile-current-server'
        switch(computer)
        case 'PCWIN64',
            resp=fullfile(matlabroot,'bin','win64','LinkCCS.dll');
        case 'PCWIN'
            resp=fullfile(matlabroot,'bin','win32','LinkCCS.dll');
        otherwise
            resp=[];
        end

    otherwise
        resp=[];
    end


