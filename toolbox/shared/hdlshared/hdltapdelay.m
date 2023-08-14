function[vbody,vsignals]=hdltapdelay(varargin)







    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);


    if emitMode
        if hdlgetparameter('isvhdl')
            [vbody,vsignals]=vhdltapdelay(varargin{:});
        else
            [vbody,vsignals]=verilogtapdelay(varargin{:});
        end


        in=varargin{1};
        out=varargin{2};
        numdelays=varargin{4};
        cplx=hdlsignalcomplex(in);
        [size,~,~]=hdlwordsize(hdlsignalsltype(out));
        if numdelays>1
            if cplx
                resourceLog(size,2*numdelays,'reg');
            else
                resourceLog(size,numdelays,'reg');
            end
        end
    else
        vbody='';
        vsignals='';

        hSignalsIn=varargin{1};
        hSignalsOut=varargin{2};
        compName=varargin{3};
        delaylen=varargin{4};
        if nargin>4
            delayOrder=strcmpi(varargin{5},'oldest');
        else
            delayOrder=true;
        end
        if nargin>5
            ic=varargin{6};
        else
            ic=0;
        end



        if hSignalsIn.Type.getDimensions==1
            pirelab.getTapDelayComp(hN,hSignalsIn,hSignalsOut,delaylen,...
            compName,ic,delayOrder);
        else
            tdl_sig_in=hSignalsIn;
            if delaylen==0
                vsignals=[];
            else
                for i_delay=1:delaylen
                    tdl_sig_out=hN.addSignal(tdl_sig_in.Type,['tap_',num2str(i_delay)]);
                    pirelab.getIntDelayComp(hN,tdl_sig_in,tdl_sig_out,1);
                    tdl_sig_in=tdl_sig_out;
                    tdl_sig_array(i_delay)=tdl_sig_out;
                end
                vsignals=tdl_sig_array;
            end

        end
    end
