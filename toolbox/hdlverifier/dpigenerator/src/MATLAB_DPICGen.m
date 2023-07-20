classdef MATLAB_DPICGen<handle

    properties(Constant)
        DPICGenInst=MATLAB_DPICGen;
    end

    properties
        moduleName;
        tbModuleName;
        dpig_codeinfo;
        buildInfo;
        SrcPath;
        InputArgs;
        GenCodeOnly;
        PortsDataType;
ComponentTemplateType
        configObj;
        testBench;
        dllOutputName;
        topDir;
    end

    methods(Access=private)
        function obj=MATLAB_DPICGen
            obj.moduleName=[];
            obj.tbModuleName=[];
            obj.dpig_codeinfo=[];
            obj.buildInfo=[];
            obj.SrcPath=[];
            obj.configObj=[];
            obj.testBench=[];
            obj.dllOutputName=[];
            obj.topDir=[];
        end
    end
    methods(Static)
        function PostCodeGenHook(projectName,buildInfo)
            dpigenerator_MATLAB_hookpoint(projectName,buildInfo);
        end

        function varSizeDataActualSizeMap=captureTestVectors(dpigTbOutDir,DataFileMap,PortMap)
            tbobj=dpig.internal.MATLABCaptureVector;
            tbobj.RunSimulation;


            varSizeDataActualSizeMap=tbobj.saveToMatFile(dpigTbOutDir,DataFileMap,PortMap);
        end
    end

end
