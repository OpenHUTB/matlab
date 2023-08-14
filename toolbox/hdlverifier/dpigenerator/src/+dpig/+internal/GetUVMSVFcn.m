
classdef GetUVMSVFcn<dpig.internal.GetSVFcn

    properties(Access=private)
        UVMCodeInfoObj;
    end

    properties(Access=private,Constant)



        UVMCompFcnInfo='UVMCompFcnInfo'

        InitializeFunction='InitializeFunction'
        OutputFunction='OutputFunction'
        UpdateFunction='UpdateFunction'
        TerminateFunction='TerminateFunction'
        TunablePrmFunction='TunablePrmFunction'

        ReturnTypes='ReturnTypes'
        ReturnSizes='ReturnSizes'
        FunctionName='FunctionName'
        ArgumentDirections='ArgumentDirections'
        ArgumentTypes='ArgumentTypes'
        ArgumentSizes='ArgumentSizes'
        ArgumentRanges='ArgumentRanges'
        ArgumentIdentifiers='ArgumentIdentifiers'
        ArgumentValues='ArgumentValues'
        ArgumentST='ArgumentST';
        CommonDpiPkgName='mw_dpi_types_pkg';
    end

    methods

        function obj=GetUVMSVFcn(codeInfo,varargin)
            obj=obj@dpig.internal.GetSVFcn(codeInfo,varargin{:});
            obj.UVMCodeInfoObj=uvmcodegen.UVMCodeInfo();
        end

        function str=getImportInitializeFcn(obj)

            str=getImportInitializeFcn@dpig.internal.GetSVFcn(obj);

            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.FunctionName,{obj.mCodeInfo.InitializeFcn.DPIName},...
            obj.InitializeFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ReturnTypes,{'chandle'},...
            obj.InitializeFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ReturnSizes,{1},...
            obj.InitializeFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentDirections,{'input'},...
            obj.InitializeFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentTypes,{'chandle'},...
            obj.InitializeFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentSizes,{1},...
            obj.InitializeFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentIdentifiers,{'existhandle'},...
            obj.InitializeFunction);
        end

        function str=getImportOutputFcn(obj,varargin)

            str=getImportOutputFcn@dpig.internal.GetSVFcn(obj,varargin{:});

            DPIFcnName=obj.getDPIFcnName('OutputFcn');
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.FunctionName,{DPIFcnName},...
            obj.OutputFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentDirections,[{'input'},obj.getInputDirections(),obj.getOutputDirections()],...
            obj.OutputFunction);
            [inputArgsName,inputArgsType]=obj.getInputFcnCallArgs();
            [outputArgsName,outputArgsType]=obj.getOutputFcnCallArgs();
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentTypes,[{'chandle'},inputArgsType,outputArgsType],...
            obj.OutputFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentSizes,[{1},obj.getInputInfo('Dim'),obj.getOutputInfo('Dim')],...
            obj.OutputFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentIdentifiers,[{obj.ObjHandle},inputArgsName,outputArgsName],...
            obj.OutputFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentST,[{inf},obj.getInputFcnArgsST(),obj.getOutputFcnArgsST()],...
            obj.OutputFunction);
        end


        function str=getImportUpdateFcn(obj)

            str=getImportUpdateFcn@dpig.internal.GetSVFcn(obj);

            DPIFcnName=obj.getDPIFcnName('UpdateFcn');
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.FunctionName,{DPIFcnName},...
            obj.UpdateFunction);
            [inputArgsName,inputArgsType]=obj.getInputFcnCallArgs();
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentDirections,[{'input'},obj.getInputDirections()],...
            obj.UpdateFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentTypes,[{'chandle'},inputArgsType],...
            obj.UpdateFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentSizes,[{1},obj.getInputInfo('Dim')],...
            obj.UpdateFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentIdentifiers,[{obj.ObjHandle},inputArgsName],...
            obj.UpdateFunction);
        end

        function str=getImportTerminateFcn(obj)

            str=getImportTerminateFcn@dpig.internal.GetSVFcn(obj);

            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.FunctionName,{obj.mCodeInfo.TerminateFcn.DPIName},...
            obj.TerminateFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentDirections,{'input'},...
            obj.TerminateFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentTypes,{'chandle'},...
            obj.TerminateFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentSizes,{1},...
            obj.TerminateFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentIdentifiers,{obj.ObjHandle},...
            obj.TerminateFunction);
        end

        function str=getImportRunTimeErrFcn(obj)

            str=getImportRunTimeErrFcn@dpig.internal.GetSVFcn(obj);

            if~isempty(obj.mCodeInfo.RunTimeErrorFcn)
                obj.UVMCodeInfoObj.AddRunTimeErrFcnInfo('FunctionName',obj.mCodeInfo.RunTimeErrorFcn.DPIName,...
                'ArgumentType','chandle','ArgumentIdentifier',obj.ObjHandle,...
                'Severity',obj.mCodeInfo.RunTimeErrorFcn.Severity);
            end
        end

        function str=getImportStopSimFcn(obj)

            str=getImportStopSimFcn@dpig.internal.GetSVFcn(obj);

            if~isempty(obj.mCodeInfo.StopSimFcn)

                obj.UVMCodeInfoObj.AddStopSimFcnInfo('FunctionName',obj.mCodeInfo.StopSimFcn.DPIName,...
                'ArgumentType','chandle','ArgumentIdentifier',obj.ObjHandle)
            end
        end

        function str=getImportSetParamFcn(obj,idx)

            str=getImportSetParamFcn@dpig.internal.GetSVFcn(obj,idx);

            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.FunctionName,{obj.mCodeInfo.SetParamFcn(idx).DPIName},...
            obj.TunablePrmFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentDirections,{'input','input'},...
            obj.TunablePrmFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentTypes,{'chandle',obj.mCodeInfo.ParamStruct.Port(idx).SVDataType},...
            obj.TunablePrmFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentSizes,{1,obj.mCodeInfo.ParamStruct.Port(idx).Dim},...
            obj.TunablePrmFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentIdentifiers,{obj.ObjHandle,obj.mCodeInfo.ParamStruct.Port(idx).FlatName},...
            obj.TunablePrmFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentValues,{nan,obj.mCodeInfo.ParamStruct.Port(idx).ParamValue},...
            obj.TunablePrmFunction);
            obj.UVMCodeInfoObj.SetFcnIfInfo(obj.UVMCompFcnInfo,...
            obj.ArgumentRanges,{struct('Min',[],'Max',[]),obj.mCodeInfo.ParamStruct.Port(idx).ParamRange},...
            obj.TunablePrmFunction);
        end

        function str=getImportCommonTypesPkg(obj)
            str='';
            if(obj.IsStructEnabled()&&obj.existStruct())||obj.existEnum()
                str=dpig.internal.GetSVFcn.getPackageCode('Import',obj.getCommonDpiPkgName());
            end
        end

        function AddGeneratedArtifactInfo(obj,varargin)
            obj.UVMCodeInfoObj.AddGeneratedArtifactInfo(varargin{:});
        end

        function StoreUVMCodeInfo(obj)
            UVMCodeInfo=obj.UVMCodeInfoObj;
            save('UVMCodeInfo','UVMCodeInfo');
        end

        function AddAssertionInfo(obj)
            obj.UVMCodeInfoObj.AddAssertionInfo('AssertionInfoStructDecl',obj.getAssertionInfoStructDeclaration('ExplicitNamespace',true),...
            'AssertionQueryingSVCode',obj.getAssertionQueryingSVCode('ExplicitNamespace',true));
        end

        function AddTSAssertionInfo(obj)


            moduleName=dpigenerator_getvariable('moduleName');
            obj.UVMCodeInfoObj.AddTSAssertionInfo('TSAssertionInfoStructDecl',obj.getTSVerifyInfoStructDeclaration('ExplicitNamespace',true),...
            'TSAssertionQueryingSVCode',obj.getTSVerifyQueryingSVCode('ExplicitNamespace',true),...
            'TSVerifyInfoInstantiation',obj.getTSVerifyInfoInstantiation('ModuleName',moduleName),...
            'TSVerifyInfoReporting',obj.getTSVerifyInfoReporting());
        end

        function AddTimingInfo(obj,varargin)
            obj.UVMCodeInfoObj.AddTimingInfo(varargin{:});
        end

        function AddCompPortInfo(obj)
            obj.UVMCodeInfoObj.AddCompPortInfo('InportInfo',obj.mCodeInfo.InStruct,'OutportInfo',obj.mCodeInfo.OutStruct,...
            'CommonDpiPkgName',obj.getCommonDpiPkgName(),'StructEnabled',obj.IsStructEnabled(),'ScalarizePortsEnabled',obj.IsScalarizePortsEnabled(),'ContainStruct',obj.existStruct(),'ContainEnum',obj.existEnum());
        end

        function name=getCommonDpiPkgName(obj)
            name=obj.CommonDpiPkgName;
        end

        function res=existStruct(obj)

            res=false;

            for idx=1:obj.mCodeInfo.InStruct.NumPorts
                if~isempty(obj.mCodeInfo.InStruct.Port(idx).StructInfo)
                    res=true;
                    return;
                end
            end

            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                if~isempty(obj.mCodeInfo.OutStruct.Port(idx).StructInfo)
                    res=true;
                    return;
                end
            end
        end
        function res=existEnum(obj)

            res=false;
            str=obj.getEnumDeclarations();
            if~isempty(str)
                res=true;
            end
        end
        function str=getDPIFcnName(obj,fcnType)


            validatestring(fcnType,{'ResetFcn','OutputFcn','UpdateFcn'});
            str='';
            if~isempty(obj.mCodeInfo.(fcnType))
                str=obj.mCodeInfo.(fcnType).DPIName;

                if obj.IsStructEnabled()||obj.IsScalarizePortsEnabled()
                    str=str(1:end-2);
                end
            end
        end
    end

    methods(Access=private)
        function cstr=getInputDirections(obj)

            if obj.mCodeInfo.InStruct.NumPorts>0
                if obj.IsStructEnabled()
                    cstr=repmat({'input'},1,obj.mCodeInfo.InStruct.NumPorts);
                else



                    [inputArgList,~]=obj.getInputFcnCallArgs;
                    cstr=repmat({'input'},1,numel(inputArgList));

                end
            else
                cstr=repmat({'input'},1,0);
            end
        end

        function cstr=getOutputDirections(obj)

            if obj.mCodeInfo.OutStruct.NumPorts>0
                if obj.IsStructEnabled()
                    cstr=repmat({'output'},1,obj.mCodeInfo.OutStruct.NumPorts);
                else



                    [outputArgList,~]=obj.getOutputFcnCallArgs;
                    cstr=repmat({'output'},1,numel(outputArgList));

                end
            else
                cstr=repmat({'output'},1,0);
            end
        end

        function cstr=getInputInfo(obj,PortInfoField)
            if obj.mCodeInfo.InStruct.NumPorts~=0
                assert(any(strcmp(PortInfoField,{'SVDataType','Dim','FlatName'})),'Requested information from portinfo is not correct.');
                if strcmp(PortInfoField,'Dim')&&~obj.IsStructEnabled()
                    cstr=num2cell(obj.mCodeInfo.InStruct.FlattenedDimensions);
                else
                    cstr=arrayfun(@(x)l_getPortInfo(x,PortInfoField,obj.IsStructEnabled()),obj.mCodeInfo.InStruct.Port,'UniformOutput',false);
                    cstr=horzcat(cstr{:});
                end
            else
                cstr={};
            end
        end

        function cstr=getOutputInfo(obj,PortInfoField)
            if obj.mCodeInfo.OutStruct.NumPorts~=0
                assert(any(strcmp(PortInfoField,{'SVDataType','Dim','FlatName'})),'Requested information from portinfo is not correct.');
                if strcmp(PortInfoField,'Dim')&&~obj.IsStructEnabled()
                    cstr=num2cell(obj.mCodeInfo.OutStruct.FlattenedDimensions);
                else
                    cstr=arrayfun(@(x)l_getPortInfo(x,PortInfoField,obj.IsStructEnabled()),obj.mCodeInfo.OutStruct.Port,'UniformOutput',false);
                    cstr=horzcat(cstr{:});
                end
            else
                cstr={};
            end
        end

        function portSTList=getInputFcnArgsST(obj)
            if obj.mCodeInfo.InStruct.NumPorts==0
                portSTList={};
            else
                if~obj.IsStructEnabled()

                    portSTList=arrayfun(@(x)repmat({x.SamplePeriod},1,x.FlatNumPorts),obj.mCodeInfo.InStruct.Port,'UniformOutput',false);
                    portSTList=horzcat(portSTList{:});
                else

                    portSTList=arrayfun(@(x)x.SamplePeriod,obj.mCodeInfo.InStruct.Port,'UniformOutput',false);
                end
            end
        end

        function portSTList=getOutputFcnArgsST(obj)
            if obj.mCodeInfo.OutStruct.NumPorts==0
                portSTList={};
            else
                if~obj.IsStructEnabled()

                    portSTList=arrayfun(@(x)repmat({x.SamplePeriod},1,x.FlatNumPorts),obj.mCodeInfo.OutStruct.Port,'UniformOutput',false);
                    portSTList=horzcat(portSTList{:});
                else

                    portSTList=arrayfun(@(x)x.SamplePeriod,obj.mCodeInfo.OutStruct.Port,'UniformOutput',false);
                end
            end
        end
    end


end




function str=l_getPortInfo(x,PortInfoField,isStructEnabled)
    if x.IsComplex&&~isStructEnabled

        if strcmp(PortInfoField,'Dim')

            str={x.(PortInfoField),x.(PortInfoField)};
        else
            str={x.StructInfo('1').(PortInfoField),x.StructInfo('2').(PortInfoField)};
        end
    else
        str={x.(PortInfoField)};
    end
end


