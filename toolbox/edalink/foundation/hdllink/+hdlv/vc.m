classdef vc

    properties(Access=private,Constant)

        hsiStr={'ModelSim','Xcelium','Vivado Simulator'};
        hsiInt=[0,1,2];
        hsiS2I=containers.Map(hdlv.vc.hsiStr,hdlv.vc.hsiInt);
        hsiI2S=containers.Map(hdlv.vc.hsiInt,hdlv.vc.hsiStr);



        swfStr={'Simulink','MATLAB System Object'};





        connStr={'Socket','Shared Memory'};
        connInt=[0,1];
        connS2I=containers.Map(hdlv.vc.connStr,hdlv.vc.connInt);
        connI2S=containers.Map(hdlv.vc.connInt,hdlv.vc.connStr);

        iptStr={'Input','Clock','Reset','Unused'}
        iptInt=[0,1,2,3];
        iptS2I=containers.Map(hdlv.vc.iptStr,hdlv.vc.iptInt);
        iptI2S=containers.Map(hdlv.vc.iptInt,hdlv.vc.iptStr);

        optStr={'Output','Unused'}
        optInt=[0,1];
        optS2I=containers.Map(hdlv.vc.optStr,hdlv.vc.optInt);
        optI2S=containers.Map(hdlv.vc.optInt,hdlv.vc.optStr);

        opsiStr={'Unsigned','Signed'};
        opsiInt=[0,1];
        opsiS2I=containers.Map(hdlv.vc.opsiStr,hdlv.vc.opsiInt);
        opsiI2S=containers.Map(hdlv.vc.opsiInt,hdlv.vc.opsiStr);

        opdtslStr={'Inherit','Fixedpoint','Double','Single'};
        opdtslInt=[0,1,2,3];
        opdtslS2I=containers.Map(hdlv.vc.opdtslStr,hdlv.vc.opdtslInt);
        opdtslI2S=containers.Map(hdlv.vc.opdtslInt,hdlv.vc.opdtslStr);

        opdtmlStr={'Fixedpoint','Double','Single'};
        opdtmlInt=[0,1,2];
        opdtmlS2I=containers.Map(hdlv.vc.opdtmlStr,hdlv.vc.opdtmlInt);
        opdtmlI2S=containers.Map(hdlv.vc.opdtmlInt,hdlv.vc.opdtmlStr);

        crtStr={'Active Falling Edge Clock','Active Rising Edge Clock','Step 1 to 0','Step 0 to 1'};
        crtInt=[1,2,3,4];
        crtS2I=containers.Map(hdlv.vc.crtStr,hdlv.vc.crtInt);
        crtI2S=containers.Map(hdlv.vc.crtInt,hdlv.vc.crtStr);

        ctStr={'Rising','Falling'};
        ctInt=[0,1];
        ctS2I=containers.Map(hdlv.vc.ctStr,hdlv.vc.ctInt);
        ctI2S=containers.Map(hdlv.vc.ctInt,hdlv.vc.ctStr);

        rtStr={'0','1'};
        rtInt=[0,1];
        rtS2I=containers.Map(hdlv.vc.rtStr,hdlv.vc.rtInt);
        rtI2S=containers.Map(hdlv.vc.rtInt,hdlv.vc.rtStr);

        htuStr={'fs','ps','ns','us','ms','s'};
        htuInt=[0,1,2,3,4,5];
        htuTime=[1e-15,1e-12,1e-9,1e-6,1e-3,1];
        htuS2I=containers.Map(hdlv.vc.htuStr,hdlv.vc.htuInt);
        htuI2S=containers.Map(hdlv.vc.htuInt,hdlv.vc.htuStr);
        htuS2T=containers.Map(hdlv.vc.htuStr,hdlv.vc.htuTime);

        htpStr={'1fs','10fs','100fs','1ps','10ps','100ps','1ns','10ns','100ns','1us','10us','100us','1ms','10ms','100ms','1s','10s','100s'};
        htpInt=[-15:2];
        htpS2I=containers.Map(hdlv.vc.htpStr,hdlv.vc.htpInt);
        htpI2S=containers.Map(hdlv.vc.htpInt,hdlv.vc.htpStr);



        htStr={'Logic','Integer','Real'};
        htInt={12,14,15};
        htStr2Int=containers.Map(hdlv.vc.htStr,hdlv.vc.htInt);
        htInt2Str=containers.Map(hdlv.vc.htInt,hdlv.vc.htStr);

        hdbgStr={'off','wave','all'};
        hdbgInt=[0,1,2];
        hdbgStr2Int=containers.Map(hdlv.vc.hdbgStr,hdlv.vc.hdbgInt);
        hdbgInt2Str=containers.Map(hdlv.vc.hdbgInt,hdlv.vc.hdbgStr);

        propNameMap={...
        'HDLSimulator','hsi',...
        'SubWorkflow','swf',...
        'Connection','conn',...
        'InputPortType','ipt',...
        'OutputPortType','opt',...
        'OutputPortSigned','opsi',...
        'OutputPortDataTypeSimulink','opdtsl',...
        'OutputPortDataTypeMATLAB','opdtml',...
        'ClockResetType','crt',...
        'ClockType','ct',...
        'ResetType','rt',...
        'HDLTimeUnit','htu',...
        'HDLTimePrecision','htp',...
        'HDLType','ht',...
        'HDLDebug','hdbg'...
        };
        propL2S=containers.Map(hdlv.vc.propNameMap(1:2:end),hdlv.vc.propNameMap(2:2:end));

    end

    methods(Static)
        function valout=convertPropValue(propname,valin)
            spn=hdlv.vc.propL2S(propname);
            if ischar(valin),valout=hdlv.vc.([spn,'S2I'])(valin);
            else,valout=hdlv.vc.([spn,'I2S'])(valin);
            end
        end
        function valout=toString(propname,valin)
            spn=hdlv.vc.propL2S(propname);
            valout=hdlv.vc.([spn,'I2S'])(valin);
        end
        function valout=toInteger(propname,valin)
            spn=hdlv.vc.propL2S(propname);
            valout=hdlv.vc.([spn,'S2I'])(valin);
        end
        function allInts=integerValues(propname)
            spn=hdlv.vc.propL2S(propname);
            allInts=hdlv.vc.([spn,'Int']);
        end
        function allStrs=stringValues(propname)
            spn=hdlv.vc.propL2S(propname);
            allStrs=hdlv.vc.([spn,'Str']);
        end
        function timeval=toTimeSeconds(varargin)
            if nargin==1
                multi=1;unit=varargin{1};
            elseif nargin==2
                multi=varargin{1};unit=varargin{2};
            else
                error('(internal) usage: toTimeSeconds(''ns'') or toTimeSeconds(5,''ns'')');
            end
            spn=hdlv.vc.propL2S('HDLTimeUnit');
            unitval=hdlv.vc.([spn,'S2T'])(unit);
            timeval=multi*unitval;
        end
    end
end
