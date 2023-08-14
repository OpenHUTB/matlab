function connection=connection(ddFile)








    persistent ddConnection currentFile

    if nargin==0


    elseif isempty(ddFile)


        ddConnection=[];
        currentFile='';

    elseif~isValidConnection(ddConnection)||~strcmp(currentFile,ddFile)
        if~rmiut.isCompletePath(ddFile)
            ddFile=rmide.resolveDict(ddFile,true);
            if isempty(ddFile)
                connection=[];
                return;
            end
        end
        currentFile=ddFile;
        ddConnection=Simulink.dd.open(ddFile);






    end

    connection=ddConnection;
end

function tf=isValidConnection(oldConnection)
    if isempty(oldConnection)
        tf=false;
    else
        try
            tf=oldConnection.isOpen();
        catch ex %#ok<NASGU>  DD must have closed since we cached this Connection
            tf=false;
        end
    end
end












