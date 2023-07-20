function[hdlbody,hdlsignals]=hdlunitdelay(varargin)









    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode

        gConnOld=hdlconnectivity.genConnectivity(0);
        if gConnOld,
            hConnDir=hdlconnectivity.getConnectivityDirector;
            in=varargin{1};
            out=varargin{2};
            if isscalar(in)&&isscalar(out),
                hConnDir.addRegister(in,out,...
                hdlgetcurrentclock,hdlgetcurrentclockenable,...
                'realonly',false);
            elseif numel(in)==numel(out),
                for ii=1:numel(in),
                    hConnDir.addRegister(in(ii),out(ii),...
                    hdlgetcurrentclock,hdlgetcurrentclockenable,...
                    'realonly',false);
                end
            end
        end


        if hdlgetparameter('isvhdl')
            [hdlbody,hdlsignals]=vhdlunitdelay(varargin{:});
        elseif hdlgetparameter('isverilog')
            [hdlbody,hdlsignals]=verilogunitdelay(varargin{:});
        else
            error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
        end


        hdlconnectivity.genConnectivity(gConnOld);


        in=varargin{1};
        out=varargin{2};
        numports=length(in);
        for i=1:numports
            vec=hdlsignalvector(in(i));
            vecsize=max(max(vec(:)),1);
            cplx=hdlsignaliscomplex(in(i));
            [size,~,~]=hdlwordsize(hdlsignalsltype(out(i)));
            resourceLog(size,(1+cplx)*vecsize,'reg');
        end
    else
        hdlbody='';
        hdlsignals='';
        if length(varargin{1})>1
            if nargin>2
                compName=varargin{3};
                for ii=1:length(varargin{1})
                    pirelab.getUnitDelayComp(hN,varargin{1}(ii),varargin{2}(ii),compName);
                end
            else
                for ii=1:length(varargin{1})
                    pirelab.getUnitDelayComp(hN,varargin{1}(ii),varargin{2}(ii));
                end
            end
        else
            if nargin>2
                compName=varargin{3};
                pirelab.getUnitDelayComp(hN,varargin{1},varargin{2},compName);
            else
                pirelab.getUnitDelayComp(hN,varargin{1},varargin{2});
            end
        end
    end

end



