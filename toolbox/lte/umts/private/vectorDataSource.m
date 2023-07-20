
















































function obj=vectorDataSource(sourcespec,initialstate)

    defaultseed=1;
    if nargin==0

        sourcespec=0;
    end

    if isempty(sourcespec)
        error('umts:error','DataSource cannot be empty.')
    end

    if nargin<2

        initialstate=0;
    else

        defaultseed=0;
    end



    if iscell(sourcespec)

        if numel(sourcespec)==2
            initialstate=sourcespec{2};
            defaultseed=0;
        else

            defaultseed=1;
        end
        sourcespec=sourcespec{1};

        if~(ischar(sourcespec)||isstring(sourcespec))
            error('umts:error','The DataSource cell array must be of the format {pnsource,seed} or {pnsource}');
        end
    end

    if ischar(sourcespec)||isstring(sourcespec)
        switch upper(sourcespec)
        case{'PN9-ITU','PN9'}
            shiftreglength=9;
        case 'PN11'
            shiftreglength=11;
        case 'PN15'
            shiftreglength=15;
        case 'PN23'
            shiftreglength=23;
        otherwise
            error('umts:error','The allowed DataSource strings are ''PN9-ITU'',''PN9'',''PN11'',''PN15'',''PN23''');
        end


        if defaultseed
            initialstate=2^shiftreglength-1;
        end


        if~(isnumeric(initialstate)&&isscalar(initialstate)...
            &&((initialstate>=0)&&(initialstate<=2^shiftreglength-1)))
            error('umts:error','For %s, the seed must be an integer between 0 to %d',sourcespec,2^shiftreglength-1);
        end
    end

    currentstate=initialstate;


    if ischar(sourcespec)||isstring(sourcespec)
        obj.getPacket=@getPacketPN;
    elseif isnumeric(sourcespec)
        if currentstate>=length(sourcespec)
            error('umts:error','Invalid seed specified for vector input, must be 0 to %d',length(sourcespec)-1);
        end
        obj.getPacket=@getPacket;
    else
        error('umts:error','Invalid DataSource, must be vector or one of the PN strings (''PN9-ITU'',''PN9'',''PN11'',''PN15'',''PN23'')');
    end
    obj.reset=@reset;


    function bitsout=getPacket(psize)

        bitsout=zeros(psize,1);
        for i=1:psize
            bitsout(i)=sourcespec(currentstate+1);
            currentstate=mod(currentstate+1,length(sourcespec));
        end
    end

    function bitsout=getPacketPN(psize)


        [bitsout,currentstate]=fdd('FddSource',char(sourcespec),psize,currentstate);

    end

    function reset()
        currentstate=initialstate;
    end

end
