classdef(Hidden)UVMCodeInfo<handle






    properties(Access=private)
Fcn
S_Fcn
    end
    properties(GetAccess=public,SetAccess=private)
UVMCompFcnInfo
UVMRunTimeErrFcnInfo
UVMStopSimFcnInfo
AssertionInfo
TSAssertionInfo
UVMBuildInfo
TimingInfo

CompPortInfo
    end

    methods(Hidden=true)
        function obj=UVMCodeInfo()

            obj.Fcn=struct('ReturnTypes',{{}},...
            'ReturnSizes',{{}},...
            'FunctionName',{{}},...
            'ArgumentDirections',{{}},...
            'ArgumentTypes',{{}},...
            'ArgumentSizes',{{}},...
            'ArgumentIdentifiers',{{}},...
            'ArgumentValues',{{}},...
            'ArgumentRanges',{{}},...
            'ArgumentST',{{}});
            obj.S_Fcn=struct('InitializeFunction',obj.Fcn,...
            'OutputFunction',obj.Fcn,...
            'UpdateFunction',obj.Fcn,...
            'TerminateFunction',obj.Fcn,...
            'TunablePrmFunction',obj.Fcn);
            obj.UVMCompFcnInfo=obj.S_Fcn;
            obj.UVMRunTimeErrFcnInfo=struct('ReturnValDecl','',...
            'ReturnIdentifier','errMsg',...
            'FunctionName','',...
            'ArgumentType','',...
            'ArgumentIdentifier','',...
            'Severity','Fatal',...
            'UVMMacro','');
            obj.AssertionInfo=struct('AssertionPresent',false,...
            'AssertionInfoStructDecl','',...
            'AssertionQueryingSVCode','');

            obj.TSAssertionInfo=struct('TSAssertionPresent',false,...
            'TSAssertionInfoStructDecl','',...
            'TSAssertionQueryingSVCode','');
            obj.UVMStopSimFcnInfo=struct('FunctionName','',...
            'ArgumentType','',...
            'ArgumentIdentifier','');
            obj.UVMBuildInfo=struct('DPIPkg','',...
            'DPIModule','',...
            'SharedLib','');
            obj.TimingInfo=struct('SimTime',[],...
            'BaseRate',[]);
            obj.CompPortInfo=struct('CommonDpiPkgName','',...
            'StructEnabled',false,...
            'ScalarizePortsEnabled',false,...
            'ContainEnum',false,...
            'ContainStruct',false,...
            'InportInfo',[],...
            'OutportInfo',[]);
        end

        function SetFcnIfInfo(obj,UVMComponentInfoType,varargin)



            parserObj=inputParser;
            addRequired(parserObj,'FcnInfoType',@(x)any(validatestring(x,transpose(fieldnames(obj.Fcn)))));
            addRequired(parserObj,'FcnInfo',@(x)iscell(x));
            if strcmpi(UVMComponentInfoType,{'UVMCompFcnInfo'})

                addRequired(parserObj,'FcnType',@(x)any(validatestring(x,transpose(fieldnames(obj.S_Fcn)))));
                parse(parserObj,varargin{:});

                tmp_cell=obj.(UVMComponentInfoType).(parserObj.Results.FcnType).(parserObj.Results.FcnInfoType);
                obj.(UVMComponentInfoType).(parserObj.Results.FcnType).(parserObj.Results.FcnInfoType)=[tmp_cell;parserObj.Results.FcnInfo];
            else

                parse(parserObj,varargin{:});
                obj.(UVMComponentInfoType).(parserObj.Results.FcnInfoType)=parserObj.Results.FcnInfo;
            end
        end

        function AddGeneratedArtifactInfo(obj,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'DPIPkg','');
            addParameter(p,'DPIModule','');
            addParameter(p,'SharedLib','');
            parse(p,varargin{:});
            obj.UVMBuildInfo=struct('DPIPkg',p.Results.DPIPkg,...
            'DPIModule',p.Results.DPIModule,...
            'SharedLib',p.Results.SharedLib);
        end

        function AddAssertionInfo(obj,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'AssertionInfoStructDecl','');
            addParameter(p,'AssertionQueryingSVCode','');
            parse(p,varargin{:});
            if~isempty(p.Results.AssertionInfoStructDecl)
                obj.AssertionInfo=struct('AssertionPresent',true,...
                'AssertionInfoStructDecl',p.Results.AssertionInfoStructDecl,...
                'AssertionQueryingSVCode',p.Results.AssertionQueryingSVCode);
            end
        end

        function AddTSAssertionInfo(obj,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'TSAssertionInfoStructDecl','');
            addParameter(p,'TSAssertionQueryingSVCode','');
            addParameter(p,'TSVerifyInfoInstantiation','');
            addParameter(p,'TSVerifyInfoReporting','');
            parse(p,varargin{:});
            if~isempty(p.Results.TSAssertionInfoStructDecl)
                obj.TSAssertionInfo=struct('TSAssertionPresent',true,...
                'TSAssertionInfoStructDecl',p.Results.TSAssertionInfoStructDecl,...
                'TSAssertionQueryingSVCode',p.Results.TSAssertionQueryingSVCode,...
                'TSVerifyInfoInstantiation',p.Results.TSVerifyInfoInstantiation,...
                'TSVerifyInfoReporting',p.Results.TSVerifyInfoReporting);
            end
        end

        function AddTimingInfo(obj,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'SimTime',[]);
            addParameter(p,'BaseRate',[]);
            parse(p,varargin{:});
            obj.TimingInfo=struct('SimTime',p.Results.SimTime,...
            'BaseRate',p.Results.BaseRate);
        end
        function AddCompPortInfo(obj,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'InportInfo',[]);
            addParameter(p,'OutportInfo',[]);
            addParameter(p,'StructEnabled',[]);
            addParameter(p,'ScalarizePortsEnabled',[]);
            addParameter(p,'ContainStruct',[]);
            addParameter(p,'ContainEnum',[]);
            addParameter(p,'CommonDpiPkgName','');
            parse(p,varargin{:});
            obj.CompPortInfo.InportInfo=p.Results.InportInfo;
            obj.CompPortInfo.OutportInfo=p.Results.OutportInfo;
            obj.CompPortInfo.CommonDpiPkgName=p.Results.CommonDpiPkgName;
            obj.CompPortInfo.StructEnabled=p.Results.StructEnabled;
            obj.CompPortInfo.ScalarizePortsEnabled=p.Results.ScalarizePortsEnabled;
            obj.CompPortInfo.ContainStruct=p.Results.ContainStruct;
            obj.CompPortInfo.ContainEnum=p.Results.ContainEnum;
        end
        function AddStopSimFcnInfo(obj,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addOptional(p,'FunctionName',[]);
            addOptional(p,'ArgumentType',[]);
            addOptional(p,'ArgumentIdentifier',[]);
            parse(p,varargin{:});
            obj.UVMStopSimFcnInfo.FunctionName=p.Results.FunctionName;
            obj.UVMStopSimFcnInfo.ArgumentType=p.Results.ArgumentType;
            obj.UVMStopSimFcnInfo.ArgumentIdentifier=p.Results.ArgumentIdentifier;
        end
        function AddRunTimeErrFcnInfo(obj,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addOptional(p,'FunctionName',[]);
            addOptional(p,'ArgumentType',[]);
            addOptional(p,'ArgumentIdentifier',[]);
            addOptional(p,'Severity',[]);
            parse(p,varargin{:});
            obj.UVMRunTimeErrFcnInfo.FunctionName=p.Results.FunctionName;
            obj.UVMRunTimeErrFcnInfo.ArgumentType=p.Results.ArgumentType;
            obj.UVMRunTimeErrFcnInfo.ArgumentIdentifier=p.Results.ArgumentIdentifier;
            obj.UVMRunTimeErrFcnInfo.Severity=p.Results.Severity;
            obj.UVMRunTimeErrFcnInfo.ReturnValDecl=['string  ',obj.UVMRunTimeErrFcnInfo.ReturnIdentifier,';'];
            uvmMacroStr=['%s("Run-time error", ',obj.UVMRunTimeErrFcnInfo.ReturnIdentifier,');'];
            switch p.Results.Severity
            case 'Fatal'
                obj.UVMRunTimeErrFcnInfo.UVMMacro=sprintf(uvmMacroStr,'`uvm_fatal');
            case 'Info'
                obj.UVMRunTimeErrFcnInfo.UVMMacro=sprintf('`uvm_info("Run-time error", %s, UVM_NONE);',obj.UVMRunTimeErrFcnInfo.ReturnIdentifier);
            case 'Warning'
                obj.UVMRunTimeErrFcnInfo.UVMMacro=sprintf(uvmMacroStr,'`uvm_warning');
            case 'Error'
                obj.UVMRunTimeErrFcnInfo.UVMMacro=sprintf(uvmMacroStr,'`uvm_error');
            otherwise
                obj.UVMRunTimeErrFcnInfo.UVMMacro=sprintf(uvmMacroStr,'`uvm_fatal');
            end
        end
    end
end
