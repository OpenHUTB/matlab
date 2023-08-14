function generatetb(filterobj,varargin)









































    [cando,~]=ishdlable(filterobj);
    if~cando
        error(message('hdlfilter:filtergroup:usrp2:generatetb:unsupportedarch',class(filterobj)));
    end



    if~any(strcmpi(varargin,'name'))
        varargin(end+1)={'name'};
        if~isempty(inputname(1))
            varargin(end+1)={inputname(1)};
        else
            error(message('hdlfilter:filtergroup:usrp2:generatetb:genhdlcalledwithconst'));
        end
    end



    indices=strcmpi(varargin,'generatehdltestbench');
    pos=1:length(indices);
    pos=pos(indices);

    indices_name=strcmpi(varargin,'name');
    posname=1:length(indices_name);
    posname=posname(indices_name);

    if~any(strcmpi(varargin,'testbenchname'))
        varargin(end+1)={'testbenchname'};
        if~isempty(pos)
            varargin(end+1)={[varargin{posname+1},'_tb']};
        else
            varargin(end+1)={[inputname(1),'_tb']};
        end
    end



    hprop=PersistentHDLPropSet;
    if isempty(hprop),
        error(message('hdlfilter:filtergroup:usrp2:generatetb:HDLCodeNotGenerated'));
    end

    if rem(length(varargin),2)~=0
        tbtype=varargin(1);
        tbtype=tbtype{:};
        pvpairs=varargin(2:end);


        props=pvpairs(1:2:end);
        for n=1:length(props)
            if~isempty(strmatch(lower(props(n)),'targetlanguage')),
                pvpairs(2*n)=[];
                pvpairs(2*n-1)=[];
            end
        end
        set(hprop.CLI,pvpairs{:});
        updateINI(hprop);
    else

        pvpairs=varargin;


        set(hprop.CLI,pvpairs{:});
        updateINI(hprop);
        tbtype={hdlgetparameter('target_language')};
    end

    pvpairs{end+1}='GenerateHDLTestbench';
    pvpairs{end+1}='on';

    generatehdl(filterobj,pvpairs{:});


