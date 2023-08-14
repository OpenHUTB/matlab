function[id,fPath]=getGuid(varargin)




    if nargin==3

        fPath=varargin{1};
        dPath=varargin{2};
        label=varargin{3};
        if isempty(dPath)
            if any(label=='.')

                id=pathsToId(fPath,label);
            else

                id=pathsToId(fPath,['Global.',label]);
            end
        else
            id=pathsToId(fPath,[dPath,'.',label]);
        end

    elseif ischar(varargin{1})

        [fPath,dPath,label]=rmide.resolveEntry(varargin{1});
        id=pathsToId(fPath,[dPath,'.',label]);

    elseif isa(varargin{1},'Simulink.DDEAdapter')




        ddEntry=varargin{1};
        dName=ddEntry.getPropValue('DataSource');
        fPath=rmide.resolveDict(dName);
        id=ddAdapterToId(ddEntry);
    else
        error('Invalid argument in a call to rmide.getGuid()');
    end
end


function myId=pathsToId(fPath,dPathString)



    myConnection=Simulink.dd.open(fPath);
    key=myConnection.getEntryKey(dPathString);
    myId=strrep(key.toString,'UUID ','UUID_');
end

function myId=ddAdapterToId(myEntry)
    mySrc=myEntry.getDialogSource;
    ddId=mySrc.m_entryID;
    myConnection=mySrc.m_ddConn;
    info=myConnection.getEntryInfo(ddId);
    myId=['UUID_',info.UUID.char];
end
