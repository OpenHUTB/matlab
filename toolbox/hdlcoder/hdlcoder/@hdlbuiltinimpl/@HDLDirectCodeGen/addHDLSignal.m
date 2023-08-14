
function hsig=addHDLSignal(this,varargin)





    arg=hdlSignalArg(varargin{:});
    hN=arg.Network;
    hS=arg.SignalType;

    if isa(hS,'hdlcoder.signal')
        hsig=hN.addSignal;
        hsig.Name=arg.Name;
        hsig.Type=hS.Type;
        hsig.SimulinkRate=hS.SimulinkRate;
        hsig.VType(hS.VType);
        hsig.Imag(hS.Imag);
    else
        type=hdlgetallfromsltype(hS.type);
        hT=getpirsignaltype(type.sltype,hS.complex,hS.dim);
        hsig=hN.addSignal(hT,arg.Name);
        hsig.SimulinkRate=arg.SignalRate;
        hsig.VType(type.vtype);
    end

    hsig.SimulinkHandle=arg.SimulinkHandle;


    function sigArg=hdlSignalArg(varargin)

        persistent p;
        if isempty(p)
            p=inputParser;

            p.addParamValue('Name','',@isaChar);
            p.addParamValue('Network','',@isaNetWork);
            p.addParamValue('SignalType','',@isaSignalType);
            p.addParamValue('SimulinkHandle',-1);
            p.addParamValue('SignalRate',-1);
        end

        p.parse(varargin{:});
        sigArg=p.Results;

        function status=isaChar(in)
            if isempty(in)
                status=false;
                error(message('hdlcoder:addHDLSignal:CharRequiredArgument'));
            elseif~ischar(in)
                status=false;
                error(message('hdlcoder:addHDLSignal:CharTypeMismatch'));
            else
                status=true;
            end


            function status=isaNetWork(in)
                if isempty(in)
                    status=false;
                    error(message('hdlcoder:addHDLSignal:NetworkRequiredArgument'));
                elseif~isa(in,'hdlcoder.network')
                    status=false;
                    error(message('hdlcoder:addHDLSignal:NetworkTypeMismatch'));
                else
                    status=true;
                end

                function status=isaSignalType(in)
                    if isempty(in)
                        status=false;
                        error(message('hdlcoder:addHDLSignal:SignalRequiredArgument'));
                    elseif~(isa(in,'hdlcoder.signal')||isa(in,'struct'))
                        status=false;
                        error(message('hdlcoder:addHDLSignal:SignalTypeMismatch'));
                    else
                        status=true;
                    end
