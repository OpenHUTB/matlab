function test=generateTestStructure(varargin)






    test=struct("treatUnspecifiedNodes","open","simTime",20,"minPts",10000,...
    "openNodes",[],"dcNodes",[],"dcValues",[],"dcTypes",string.empty,...
    "stepNodes",[],"stepValues",[],"stepType",string.empty,...
    "sweepNodes",[],"sweepValues",[],"sweepType",string.empty,...
    "loadNodes",[],"loadValues",[]);
    test.SPICEPath="C:\Program Files\LTC\LTspiceXVII\XVIIx64.exe";

    switch nargin

    case{1,2,3,4}
        testType=lower(string(varargin{1}));
        Vt=varargin{2};
        Vds=varargin{3};
        switch testType
        case "idvgst3"
            test.name="idvgst3";
            test.sweepNodes=2;
            test.sweepValues=[0,3*Vt];
            test.sweepType="voltage";
            test.stepNodes=1;
            test.stepValues=2:Vds/5:Vds;
            test.stepType="voltage";
            test.dcNodes=3;
            test.dcValues=0;
            test.dcTypes="voltage";

        case "idvgst4"
            test.name="idvgst4";
            test.sweepNodes=2;
            test.sweepValues=[0,3*Vt];
            test.sweepType="voltage";
            test.stepNodes=1;
            test.stepValues=2:Vds/5:Vds;
            test.stepType="voltage";
            test.dcNodes=[3,4];
            test.dcValues=[0,0];
            test.dcTypes=["voltage","voltage"];

        case "idvgst5tj27"
            test.name="idvgst5tj27";
            test.sweepNodes=2;
            test.sweepValues=[0,3*Vt];
            test.sweepType="voltage";
            test.stepNodes=1;
            test.stepValues=2:Vds/5:Vds;
            test.stepType="voltage";
            test.dcNodes=[3,4,5];
            test.dcValues=[0,27,75];
            test.dcTypes=["voltage","voltage","voltage"];

        case "idvgst5tj75"
            test.name="idvgst5tj75";
            test.sweepNodes=2;
            test.sweepValues=[0,3*Vt];
            test.sweepType="voltage";
            test.stepNodes=1;
            test.stepValues=2:Vds/5:Vds;
            test.stepType="voltage";
            test.dcNodes=[3,4,5];
            test.dcValues=[0,75,27];
            test.dcTypes=["voltage","voltage","voltage"];

        case "idvgst6tj27"
            test.name="idvgst6tj27";
            test.sweepNodes=2;
            test.sweepValues=[0,3*Vt];
            test.sweepType="voltage";
            test.stepNodes=1;
            test.stepValues=2:Vds/5:Vds;
            test.stepType="voltage";
            test.dcNodes=[3,4,5,6];
            test.dcValues=[0,0,27,75];
            test.dcTypes=["voltage","voltage","voltage","voltage"];

        case "idvgst6tj75"
            test.name="idvgst6tj75";
            test.sweepNodes=2;
            test.sweepValues=[0,3*Vt];
            test.sweepType="voltage";
            test.stepNodes=1;
            test.stepValues=2:Vds/5:Vds;
            test.stepType="voltage";
            test.dcNodes=[3,4,5,6];
            test.dcValues=[0,0,75,27];
            test.dcTypes=["voltage","voltage","voltage","voltage"];

        case "idvdst3"
            test.name="idvdst3";
            test.sweepNodes=1;
            test.sweepValues=[0,Vds];
            test.sweepType="voltage";
            test.stepNodes=2;
            test.stepValues=2:2:3*Vt;
            test.stepType="voltage";
            test.dcNodes=3;
            test.dcValues=0;
            test.dcTypes="voltage";

        case "idvdst4"
            test.name="idvdst4";
            test.sweepNodes=1;
            test.sweepValues=[0,Vds];
            test.sweepType="voltage";
            test.stepNodes=2;
            test.stepValues=2:2:3*Vt;
            test.stepType="voltage";
            test.dcNodes=[3,4];
            test.dcValues=[0,0];
            test.dcTypes=["voltage","voltage"];

        case "idvdst5"
            test.name="idvdst5";
            test.sweepNodes=1;
            test.sweepValues=[0,Vds];
            test.sweepType="voltage";
            test.stepNodes=2;
            test.stepValues=2:2:3*Vt;
            test.stepType="voltage";
            test.dcNodes=[3,4,5];
            test.dcValues=[0,27,75];
            test.dcTypes=["voltage","voltage","voltage"];

        case "idvdst6"
            test.name="idvdst6";
            test.sweepNodes=1;
            test.sweepValues=[0,Vds];
            test.sweepType="voltage";
            test.stepNodes=2;
            test.stepValues=2:2:3*Vt;
            test.stepType="voltage";
            test.dcNodes=[3,4,5,6];
            test.dcValues=[0,0,27,75];
            test.dcTypes=["voltage","voltage","voltage","voltage"];

        case "qisst3"
            Ciss=varargin{4};
            test.name="qisst3";
            test.sweepNodes=2;
            test.sweepValues=[1e-1,-(3*Vt*Ciss)/20];
            test.sweepType="current";
            test.loadNodes=[1];%#ok<*NBRAK>
            test.loadValues=[100];
            test.dcNodes=[1,3];
            test.dcValues=[20,0];
            test.dcTypes=["voltage","voltage"];

        case "qisst4"
            Ciss=varargin{4};
            test.name="qisst4";
            test.sweepNodes=2;
            test.sweepValues=[1e-1,-(3*Vt*Ciss)/20];
            test.sweepType="current";
            test.loadNodes=[1];
            test.loadValues=[100];
            test.dcNodes=[1,3,4];
            test.dcValues=[Vds,0,0];
            test.dcTypes=["voltage","voltage","voltage"];

        case "qisst5"
            Ciss=varargin{4};
            test.name="qisst5";
            test.sweepNodes=2;
            test.sweepValues=[1e-1,-(3*Vt*Ciss)/20];
            test.sweepType="current";
            test.loadNodes=[1];
            test.loadValues=[100];
            test.dcNodes=[1,3,4,5];
            test.dcValues=[Vds,0,27,75];
            test.dcTypes=["voltage","voltage","voltage","voltage"];

        case "qisst6"
            Ciss=varargin{4};
            test.name="qisst6";
            test.sweepNodes=2;
            test.sweepValues=[1e-1,-(3*Vt*Ciss)/20];
            test.sweepType="current";
            test.loadNodes=[1];
            test.loadValues=[100];
            test.dcNodes=[1,3,4,5,6];
            test.dcValues=[Vds,0,0,27,75];
            test.dcTypes=["voltage","voltage","voltage","voltage","voltage"];

        case "qosst3"
            Coss=varargin{4};
            test.simTime=1e6*Coss/2;
            test.minPts=1000;
            test.name="qosst3";
            test.sweepNodes=1;
            test.sweepValues=[0.01*test.simTime,-(2*Vds)/10^6];
            test.sweepType="current";
            test.loadNodes=[1];
            test.loadValues=[100];
            test.dcNodes=[2,3];
            test.dcValues=[0,0];
            test.dcTypes=["voltage","voltage"];

        case "qosst4"
            Coss=varargin{4};
            test.simTime=1e6*Coss/2;
            test.minPts=1000;
            test.name="qosst4";
            test.sweepNodes=1;
            test.sweepValues=[0.01*test.simTime,-(2*Vds)/10^6];
            test.sweepType="current";
            test.loadNodes=[1];
            test.loadValues=[100];
            test.dcNodes=[2,3,4];
            test.dcValues=[0,0,0];
            test.dcTypes=["voltage","voltage","voltage"];

        case "qosst5"
            Coss=varargin{4};
            test.simTime=1e6*Coss/2;
            test.minPts=1000;
            test.name="qosst5";
            test.sweepNodes=1;
            test.sweepValues=[0.01*test.simTime,-(2*Vds)/10^6];
            test.sweepType="current";
            test.loadNodes=[1];
            test.loadValues=[100];
            test.dcNodes=[2,3,4,5];
            test.dcValues=[0,0,27,75];
            test.dcTypes=["voltage","voltage","voltage","voltage"];

        case "qosst6"
            Coss=varargin{4};
            test.simTime=1e6*Coss/2;
            test.minPts=1000;
            test.name="qosst6";
            test.sweepNodes=1;
            test.sweepValues=[0.01*test.simTime,-(2*Vds)/10^6];
            test.sweepType="current";
            test.loadNodes=[1];
            test.loadValues=[100];
            test.dcNodes=[2,3,4,5,6];
            test.dcValues=[0,0,0,27,75];
            test.dcTypes=["voltage","voltage","voltage","voltage","voltage"];

        case "breakdownt3"
            n=varargin{4};
            test.name="breakdownt3";
            test.sweepNodes=1;
            test.sweepValues=[0,n*Vds];
            test.sweepType="voltage";
            test.dcNodes=[2,3];
            test.dcValues=[0,0];
            test.dcTypes=["voltage","voltage"];

        case "breakdownt4"
            n=varargin{4};
            test.name="breakdownt4";
            test.sweepNodes=1;
            test.sweepValues=[0,n*Vds];
            test.sweepType="voltage";
            test.dcNodes=[2,3,4];
            test.dcValues=[0,0,0];
            test.dcTypes=["voltage","voltage","voltage"];

        case "breakdownt5"
            n=varargin{4};
            test.name="breakdownt5";
            test.sweepNodes=1;
            test.sweepValues=[0,n*Vds];
            test.sweepType="voltage";
            test.dcNodes=[2,3,4,5];
            test.dcValues=[0,0,27,75];
            test.dcTypes=["voltage","voltage","voltage","voltage"];

        case "breakdownt6"
            n=varargin{4};
            test.name="breakdownt6";
            test.sweepNodes=1;
            test.sweepValues=[0,n*Vds];
            test.sweepType="voltage";
            test.dcNodes=[2,3,4,5,6];
            test.dcValues=[0,0,0,27,75];
            test.dcTypes=["voltage","voltage","voltage","voltage","voltage"];


        otherwise
            pm_error("physmod:ee:SPICE2sscvalidation:SPICE2sscTestConfigurationError");

        end
    otherwise
        pm_error("physmod:ee:SPICE2sscvalidation:SPICE2sscInputArgumentsError");

    end
    if~validateTestParameters(test)
        pm_warning("physmod:ee:SPICE2sscvalidation:SPICE2sscValidateTestParametersWarning");
    end
end

function result=validateTestParameters(test)
    result=true;
    if length(test.treatUnspecifiedNodes)>1...
        ||(~strncmpi(test.treatUnspecifiedNodes,"O",1)&&~strncmpi(test.treatUnspecifiedNodes,"G",1))...
        ||test.simTime<=0...
        ||any(mod(test.openNodes,1)~=0)||any(test.openNodes<=0)...
        ||any(mod(test.dcNodes,1)~=0)||any(test.dcNodes<=0)...
        ||length(test.dcValues)~=length(test.dcNodes)...
        ||length(test.dcTypes)~=length(test.dcNodes)...
        ||any(mod(test.stepNodes,1)~=0)||any(test.stepNodes<=0)...
        ||(~isempty(test.stepNodes)&&isempty(test.stepValues))...
        ||length(test.stepType)>1...
        ||any(mod(test.sweepNodes,1)~=0)||any(test.sweepNodes<=0)...
        ||(~isempty(test.sweepNodes)&&isempty(test.sweepValues))...
        ||length(test.sweepType)>1...
        ||any(mod(test.loadNodes,1)~=0)||any(test.loadNodes<=0)...
        ||length(test.loadNodes)~=length(test.loadValues)
        result=false;
    end
end