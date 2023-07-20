function hdlpid=waitForHdlClient(TimeOut,EventID)

































    switch nargin
    case 0
        TimeOut=60;
        EventID=1;
    case 1
        EventID=1;
    end

    if(~isnumeric(EventID))
        error(message('HDLLink:waitForHdlClient:EventIDNotNumber'));
    end

    if(~isempty(find(EventID<0,1))||~isempty(find(EventID>2147483647,1)))
        error(message('HDLLink:waitForHdlClient:EventIDOutOfRante'));
    end

    if(~isnumeric(TimeOut))
        error(message('HDLLink:waitForHdlClient:TimeoutNotNumber'));
    end
    if(TimeOut<0)
        error(message('HDLLink:waitForHdlClient:TimeoutNotPositive'));
    end
    timeleft=TimeOut;
    EventID=fix(EventID);


    hdlpid=EventID;
    hdlpid(:)=-1;

    Indx=find(hdlpid==-1);
    while(timeleft>=0)
        for m=1:numel(Indx)
            hdlpid(Indx(m))=hdldaemon('_QUERYHDLEVENT',EventID(Indx(m)));
        end
        Indx=find(hdlpid==-1);
        if(isempty(Indx))
            return;
        else
            timeleft=timeleft-1;
            if(timeleft>=0)
                pause(1);
            end
        end
    end

    if(nargout==0)
        error(message('HDLLink:waitForHdlClient:timeout'));
    end

