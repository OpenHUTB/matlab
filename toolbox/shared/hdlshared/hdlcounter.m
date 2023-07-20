function[hdlbody,hdlsignals]=hdlcounter(varargin)





















    gConnOld=hdlconnectivity.genConnectivity(0);

    if hdlgetparameter('isvhdl')
        [hdlbody,hdlsignals]=vhdlcounter(varargin{:});
    elseif hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog')
        [hdlbody,hdlsignals]=verilogcounter(varargin{:});
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end



    if gConnOld
        hCD=hdlconnectivity.getConnectivityDirector;
        cout=varargin{1};

        if nargin<8
            hCD.addRegister(cout,cout,...
            hdlgetcurrentclock,hdlgetcurrentclockenable,...
            'realonly',true);
        else
            hCD.addDriverReceiverRegistered({cout,varargin{8}},cout,...
            hdlgetcurrentclock,hdlgetcurrentclockenable);
        end


        if~isempty(hdlsignals)
            if nargin>6&&(varargin{7}==1)
                countregout=true;
            else
                countregout=false;
            end

            for ii=1:numel(varargin{6})
                if countregout
                    hCD.addRegister(cout,hdlsignals(ii),...
                    hdlgetcurrentclock,hdlgetcurrentclockenable,...
                    'realonly',true);
                else
                    hCD.addDriverReceiverPair(cout,hdlsignals(ii),'realonly',true);
                end

            end
        end

    end

    hdlconnectivity.genConnectivity(gConnOld);
end

