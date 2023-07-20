function generatetb(Hb,varargin)








































    if isa(Hb,'dfilt.basefilter')
        generatetb(Hb,varargin{:});
    else
        [cando,errstr]=ishdlable(Hb);
        if~cando
            error(message('hdlfilter:generatehdl:unsupportedSysObj',errstr));
        end


        if~any(strcmpi(varargin,'testbenchname'))
            varargin(end+1)={'testbenchname'};
            varargin(end+1)={[inputname(1),'_tb']};
        end


        hprop=PersistentHDLPropSet;
        if isempty(hprop),
            error(message('signal:dfilt:basefilter:generatetb:HDLCodeNotGenerated'));
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

        privgeneratetb(Hb,tbtype,pvpairs{:});
    end
