function[fullSTFName,fid,prevfpos]=getstf(varargin)











    if nargin>0
        hModel=varargin{1};
        editedSTF='';
        if nargin>1
            editedSTF=varargin{2};
        end
    else
        hModel=[];
        editedSTF='';
    end


    if((isempty(editedSTF))&&(~isempty(hModel)))
        systemTargetFile=get_param(hModel,'SystemTargetFile');
    else
        systemTargetFile=editedSTF;
    end
    systemTargetFile=strtrim(systemTargetFile);

    k=find(isspace(systemTargetFile)==1);
    if~isempty(k)
        systemTargetFile=systemTargetFile(1:k(1)-1);
    end

    if isempty(systemTargetFile)
        DAStudio.error('RTW:utility:emptyValue','system target file');
    end



    if((~isempty(hModel))&&...
        (~isempty(findstr(get_param(hModel,'RTWMakeCommand'),'-ada'))))
        languageDir='ada';
    else
        languageDir='c';
    end


    fullSTFName=which(systemTargetFile);

    if isempty(fullSTFName)






        tmwV5Sandbox=getenv('TMW_V5_SANDBOX');
        if(~isempty(tmwV5Sandbox)&&...
            (exist(fullfile(tmwV5Sandbox,'rtw'),'dir')==7)&&...
            (exist(fullfile(tmwV5Sandbox,'simulink','include'),'dir')==7)&&...
            (exist(fullfile(tmwV5Sandbox,'extern','include'),'dir')==7))
            rtwroot=fullfile(tmwV5Sandbox,'rtw');
            disp(['### Using rtwroot = ',rtwroot]);
        else
            rtwroot=fullfile(matlabroot,'rtw');
        end

        fullSTFName=getstf_in_rtwroot(rtwroot,languageDir,systemTargetFile);
    end


    fids=fopen('all');
    fid=fopen(fullSTFName,'rt');

    if(any(fids==fid))

        prevfpos=ftell(fid);
    else
        prevfpos=-1;
    end

    return;







    function fullSTFName=getstf_in_rtwroot(rtwroot,langDir,fileIn)

        fullSTFName='';


        targetDir=strtok(fileIn,'.');
        candidateSTF=fullfile(rtwroot,langDir,targetDir,fileIn);
        if(exist(candidateSTF,'file')==2)&&loc_isCaseMatched(candidateSTF)
            fullSTFName=candidateSTF;
        else
            targetDirs=dir(fullfile(rtwroot,langDir));
            for i=1:length(targetDirs)
                if targetDirs(i).isdir
                    targetDir=targetDirs(i).name;
                    if((~strcmp(targetDir,'.'))&&...
                        (~strcmp(targetDir,'..'))&&...
                        (~strcmp(targetDir,'src'))&&...
                        (~strcmp(targetDir,'libsrc'))&&...
                        (~strcmp(targetDir,'lib'))&&...
                        (~strcmp(targetDir,'tlc')))
                        candidateSTF=fullfile(rtwroot,langDir,targetDir,fileIn);
                        if(exist(candidateSTF,'file')==2)&&loc_isCaseMatched(candidateSTF)
                            fullSTFName=candidateSTF;
                            break;
                        end
                    end
                end
            end
        end




        function matched=loc_isCaseMatched(fullname)
            matched=false;

            [~,filename,extension]=fileparts(fullname);
            file=dir([fullname(1:end-1),'*']);

            if~isempty(file)&&strcmp([filename,extension],file(1).name)
                matched=true;
            end


