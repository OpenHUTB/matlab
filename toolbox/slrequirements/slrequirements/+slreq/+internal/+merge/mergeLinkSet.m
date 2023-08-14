










































function[status,msgs]=mergeLinkSet(baseFile,mineFile,theirsFile,targetFile)
    status=false;
    msgs={};

    if nargin<4
        msg='Not enough input arguments';
        msgs=[msgs,msg];
        return;
    end

    [status,msg,baseFile]=getAbsolutePath(baseFile);
    if~status
        msgs=[msgs,msg];
        msg=sprintf('Invalid argument %d: "%s"',1,baseFile);
        msgs=[msgs,msg];
        return;
    end

    [status,msg,theirsFile]=getAbsolutePath(theirsFile);
    if~status
        msgs=[msgs,msg];
        msg=sprintf('Invalid argument %d: "%s"',2,theirsFile);
        msgs=[msgs,msg];
        return;
    end

    [status,msg,mineFile]=getAbsolutePath(mineFile);
    if~status
        msgs=[msgs,msg];
        msg=sprintf('Invalid argument %d: "%s"',3,mineFile);
        msgs=[msgs,msg];
        return;
    end

    [status,msg,targetFile]=getAbsolutePath(targetFile);
    if~status
        msgs=[msgs,msg];
        msg=sprintf('Invalid argument %d: "%s"',4,targetFile);
        msgs=[msgs,msg];
        return;
    end


    import slreq.internal.merge.*;
    engine=MergeEngine(baseFile,mineFile,theirsFile,targetFile);

    if isempty(engine)
        status=false;
        msg='Internal error: Error in creating merge engine';
        msgs=[msgs,msg];
    else
        [status,msgs]=engine.threeWayCompareMerge();
        if~status
            msg='Merge operation failed';
            msgs=[msgs,msg];
        end
    end

end


function[status,msg,absolutePath]=getAbsolutePath(filePath)
    status=true;
    msg='';
    absolutePath='';

    if isempty(filePath)
        status=false;
        msg=sprintf('The Link Set file is either invalid or corrupt: "%s"',filePath);
        return;
    end

    filePath=convertStringsToChars(filePath);

    if~isfile(filePath)


        try

            fclose(fopen(filePath,'w'));
        catch ME
            status=false;
            msg=ME.message;
            return;
        end

        wc=onCleanup(@()delete(filePath));
    end

    [partFolder,partBase,partExt]=fileparts(filePath);

    if~strcmpi(partExt,'.slmx')
        status=false;
        msg=sprintf('The Link Set file is either invalid or corrupt: "%s"',filePath);
        return;
    end

    if isempty(partFolder)
        absolutePath=pwd;
    elseif isfolder(partFolder)
        try
            current=pwd;
            cd(partFolder);
            absolutePath=pwd;
            cd(current);
        catch ME
            status=false;
            msg=ME.message;
            return;
        end
    else
        status=false;
        msg=sprintf('The Link Set file is either invalid or corrupt: "%s"',filePath);
        return;
    end

    absolutePath=fullfile(absolutePath,[partBase,partExt]);

end
