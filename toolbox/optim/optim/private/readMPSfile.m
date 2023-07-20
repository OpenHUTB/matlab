function[f,varType,A,b,Aeq,beq,lb,ub,varNames,constrNames]=readMPSfile(mpsfileIn,addNames)















    if~matlab.internal.datatypes.isScalarText(mpsfileIn)
        error(message('optim:mpsread:fileNameNotScalarText'));
    end


    mpsfile=which(mpsfileIn);
    if isempty(mpsfile)

        mpsfile=mpsfileIn;
    end


    [pathstr,name,ext]=fileparts(mpsfile);
    if isempty(pathstr)

        mpsfile=sprintf('./%s',mpsfile);
        [pathstr,name,ext]=fileparts(mpsfile);
    end
    if exist(mpsfile,'dir')||~exist(mpsfile,'file')||...
        isempty(pathstr)||isempty(name)
        error(message('optim:mpsread:fileNameInvalid',name));
    end



    copy_file=length(mpsfile)>255||~strcmpi(ext,'.mps');
    if copy_file

        mpsfile_loc=[tempname,'.mps'];
        [flag,msg]=copyfile(mpsfile,mpsfile_loc);
        if flag

            C=onCleanup(@()delete(mpsfile_loc));
        else
            error('optim:mpsread:fileCopyError',msg);
        end
    else
        mpsfile_loc=mpsfile;
    end
    try
        [f,A,b,Aeq,beq,lb,ub,varType,varNames,constrNames]=slbiMexMPSreader(mpsfile_loc,addNames);
    catch ME
        code='-1000@1000';
        if~isempty(strfind(ME.message,'110:'))


            error(message('optim:mpsread:prematureEndOfFile'));

        elseif~isempty(strfind(ME.message,'162:'))


            error(message('optim:mpsread:unknownRowName'));

        elseif~isempty(strfind(ME.message,'128:'))

            error(message('optim:mpsread:duplicateColumnEntry'));

        elseif strcmpi(ME.identifier,'optim:slbimexmpsreader:NotEnoughSpace')
            error(message('optim:mpsread:outOfMemory'));

        elseif strcmpi(ME.identifier,'optim:slbimexmpsreader:ReadMpsError')&&...
            ~isempty(ME.message)
            slbicode=strtok(ME.message,':');
            slbicode=str2double(slbicode);
            if isempty(slbicode)
                code='1000@1001';

            elseif ismember(slbicode,[112,122,228,185,226,166,132,401])

                error(message('optim:mpsread:invalidMPSFormat'));

            elseif ismember(slbicode,[30,31,33])

                error(message('optim:mpsread:fileOpenError',name))
            else

                code=['1000@',num2str(slbicode)];
            end

        elseif strcmpi(ME.identifier,'optim:readMPSfile:initError')
            code='1000@1002';
        end

        error(message('optim:mpsread:unknownError',code));
    end

