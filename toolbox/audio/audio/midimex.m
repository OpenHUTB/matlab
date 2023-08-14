classdef midimex<coder.ExternalDependency %#codegen



    methods
        function obj=midimex
            coder.allowpcode('plain');
        end
    end

    methods(Static,Hidden)
        function tf=isSupportedContext(ctx)
            if ctx.isMatlabHostTarget()
                tf=true;
            else
                error('MIDI MEX interface library not available for this target');
            end
        end

        function updateBuildInfo(~,~)
        end


        function[txid,err]=midiOpenTx(device)

            assert(isa(device,'double')&&isscalar(device)&&isreal(device));

%#codegen
            coder.allowpcode('plain');

            if isempty(coder.target)

                [txid,err]=midimexif('midiOpenTx',device);
            else



                coder.ceval('mexLock');
                txid=coder.nullcopy(uint64(0));
                err=coder.nullcopy(0);
                err=coder.ceval('openTxCpp',device,coder.wref(txid));
            end
        end


        function midiCloseTx(txid)

            assert(isa(txid,'uint64')&&isscalar(txid)&&isreal(txid));

%#codegen
            coder.allowpcode('plain');

            if isempty(coder.target)

                midimexif('midiCloseTx',txid);
            else



                coder.ceval('mexLock');
                coder.ceval('closeTxCpp',txid);
            end
        end


        function[err]=midiSendMsgs(txid,msgs)

            assert(isa(txid,'uint64')&&isscalar(txid)&&isreal(txid));

            coder.cstructname(msgs,'midimsg','extern','HeaderFile','midi.hpp');

%#codegen
            coder.allowpcode('plain');



            if isempty(coder.target)

                err=midimexif('midiSendMsgs',txid,msgs);
            else
                err=coder.nullcopy(0);
                err=coder.ceval('sendMsgsCpp',txid,msgs,int32(numel(msgs)));
            end
        end


        function[rxid,err]=midiOpenRx(device)

            assert(isa(device,'double')&&isscalar(device)&&isreal(device));

%#codegen
            coder.allowpcode('plain');

            if isempty(coder.target)

                [rxid,err]=midimexif('midiOpenRx',device);
            else



                coder.ceval('mexLock');
                rxid=coder.nullcopy(uint64(0));
                err=coder.nullcopy(0);
                err=coder.ceval('openRxCpp',device,coder.wref(rxid));
            end
        end


        function midiCloseRx(rxid)

            assert(isa(rxid,'uint64')&&isscalar(rxid)&&isreal(rxid));

%#codegen
            coder.allowpcode('plain');

            if isempty(coder.target)

                midimexif('midiCloseRx',rxid);
            else



                coder.ceval('mexLock');
                coder.ceval('closeRxCpp',rxid);
            end
        end


        function[err,msgs]=midiReceiveMsgs(rxid,maxmsgs)

            assert(isa(rxid,'uint64')&&isscalar(rxid)&&isreal(rxid));
            assert(isnumeric(maxmsgs)&&isscalar(maxmsgs)&&isreal(maxmsgs)&&~isnan(maxmsgs));

%#codegen
            coder.allowpcode('plain');
            maxmsgs=cast(maxmsgs,'double');

            if isempty(coder.target)

                [err,msgs]=midimexif('midiReceiveMsgs',rxid,maxmsgs);
            else

                err=int32(0);

                msgs=repmat(struct('RawBytes',zeros(1,8,'uint8'),'Timestamp',0),0);
                coder.varsize('msgs',[inf,1]);
                coder.cstructname(msgs,'midimsg','extern','HeaderFile','midi.hpp');

                bufsize=int32(8192);
                buf=(repmat(...
                struct('RawBytes',zeros(1,8,'uint8'),'Timestamp',0),...
                [bufsize,1]));
                nrcvd=int32(0);%#ok<NASGU>
                while numel(msgs)<maxmsgs
                    nrcvd=coder.ceval('receiveMsgsCpp',rxid,coder.wref(buf),min(bufsize,maxmsgs-numel(msgs)));
                    if nrcvd>0
                        msgs=[msgs;buf(1:nrcvd)];%#ok<AGROW>
                    else
                        err=nrcvd;
                        break;
                    end
                end
            end
        end


        function yes=midiHasData(rxid)

            assert(isa(rxid,'uint64')&&isscalar(rxid)&&isreal(rxid));

%#codegen
            coder.allowpcode('plain');

            if isempty(coder.target)

                yes=midimexif('midiHasData',rxid);
            else

                yes=false;
                yes=coder.ceval('rxHasDataCpp',rxid);
            end
        end

        function msg=getErrorMessage(err)
            assert(nargin==1);
            assert(isa(err,'double'));
            assert(isscalar(err));
            assert(isreal(err));

%#codegen
            coder.allowpcode('plain');

            msg=midiGetErrorMessage(err);
        end

    end
end
