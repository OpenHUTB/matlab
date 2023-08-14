function value=IMTGlobalSetting(param,varargin)






    if nargin>2
        error('Too many parameters.');
    end;




    IMTHarnessRoot=fileparts(fileparts(which('IMTGlobalSetting')));

    if nargin==2

        IMTHarnessRoot=fullfile(varargin{1},'Apps','Harness');
    end;

    switch lower(param)
    case 'autogendir',value=fullfile(IMTHarnessRoot,'autogen');
    case 'tempdir',value=fullfile(IMTHarnessRoot,'temp');
    case 'batfile',value=fullfile(IMTHarnessRoot,'autogen','imt_run_testharness.bat');
    case 'logfile',value=fullfile(IMTHarnessRoot,'temp','imt_log_file.txt');
    case 'diaryfilename'
        tempdirExist=false;
        while~tempdirExist
            tempdirName=tempname;
            if exist(tempdirName,'dir')~=7
                mkdir(tempdirName);
                tempdirExist=true;
            end
        end
        value=fullfile(tempdirName,'diary.txt');
    otherwise,error(['Unknown setting: ',param]);
    end