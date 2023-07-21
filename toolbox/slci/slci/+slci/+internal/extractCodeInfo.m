



function SLCICodeInfo=extractCodeInfo(codeInfoDir,codeInfoFile,modelName,...
    SLCIfile,verbose,lSystemTargetFile)




    cleanupFcn=coder.internal.infoMATInitializeFromSTF...
    (lSystemTargetFile,modelName);%#ok



    codeInfoFile=fullfile(codeInfoDir,codeInfoFile);
    if~exist(codeInfoFile,'file')
        DAStudio.error('Slci:slci:ERRORS_OPENINFO',codeInfoFile);
    end
    codeDescriptor=coder.internal.getCodeDescriptorInternal(codeInfoFile,247362);
    codeInfo=codeDescriptor.getComponentInterface();
    SLCICodeInfo=slci.CodeInfo;





    io_table=containers.Map;
    for k=1:numel(codeInfo.Inports)
        sid=codeInfo.Inports(k).SID;
        graphicalID=['I',num2str(k-1)];


        key=sid;
        if isKey(io_table,key)
            io_table(key)=[io_table(key),{graphicalID}];
        else
            io_table(key)={graphicalID};
        end
    end
    for k=1:numel(codeInfo.Outports)
        sid=codeInfo.Outports(k).SID;
        graphicalID=['O',num2str(k-1)];
        key=sid;
        if isKey(io_table,key)
            io_table(key)=[io_table(key),{graphicalID}];
        else
            io_table(key)={graphicalID};
        end
    end
    param_table=containers.Map;
    for k=1:numel(codeInfo.Parameters)



        sid=codeInfo.Parameters(k).SID;
        if(strcmp(sid,modelName))
            key=codeInfo.Parameters(k).GraphicalName;
            graphicalID=['M',num2str(k-1)];
            assert(~isKey(param_table,key));
            param_table(key)=graphicalID;
        end
    end


    output_fcn=getOutputFcn(codeInfo);
    for k=1:numel(output_fcn)
        SLCICodeInfo.OutputFunction=...
        [SLCICodeInfo.OutputFunction...
        ,l_slciConvertFunctionInterface(codeInfo,output_fcn(k),io_table,param_table,'Output',k)];
    end


    if numel(codeInfo.ConstructorFunction)==1
        SLCICodeInfo.ConstructorFunction=...
        l_slciConvertFunctionInterface(codeInfo,codeInfo.ConstructorFunction(1),io_table,param_table,'Update',0);
    end


    if numel(codeInfo.UpdateFunctions)==1
        SLCICodeInfo.UpdateFunction=...
        l_slciConvertFunctionInterface(codeInfo,codeInfo.UpdateFunctions(1),io_table,param_table,'Update',0);
    else

    end


    for i=1:numel(codeInfo.InitializeFunctions)
        if codeInfo.InitializeFunctions(i).IsInitializeFunction
            SLCICodeInfo.RegistrationFunction=...
            l_slciConvertFunctionInterface(codeInfo,codeInfo.InitializeFunctions(i),io_table,param_table,'Registration',0);
        elseif codeInfo.InitializeFunctions(i).IsStartFunction
            SLCICodeInfo.StartFunction=...
            l_slciConvertFunctionInterface(codeInfo,codeInfo.InitializeFunctions(i),io_table,param_table,'Start',0);
        end
    end


    if~isempty(codeInfo.SystemInitializeFunction)
        SLCICodeInfo.SystemInitializeFunction=...
        l_slciConvertFunctionInterface(codeInfo,codeInfo.SystemInitializeFunction,io_table,param_table,'SystemInitialize',0);
    end


    if numel(codeInfo.TerminateFunctions)==1
        SLCICodeInfo.TerminateFunction=...
        l_slciConvertFunctionInterface(codeInfo,codeInfo.TerminateFunctions(1),io_table,param_table,'Terminate',0);
    else

    end


    if numel(codeInfo.EnableFunction)==1
        SLCICodeInfo.EnableFunction=...
        l_slciConvertFunctionInterface(codeInfo,codeInfo.EnableFunction,io_table,param_table,'Enable',0);
    else

    end


    if numel(codeInfo.DisableFunction)==1
        SLCICodeInfo.DisableFunction=...
        l_slciConvertFunctionInterface(codeInfo,codeInfo.DisableFunction,io_table,param_table,'Disable',0);
    else

    end


    if numel(codeInfo.SystemResetFunction)==1
        SLCICodeInfo.SystemResetFunction=...
        l_slciConvertFunctionInterface(codeInfo,codeInfo.SystemResetFunction,io_table,param_table,'SystemReset',0);
    end


    for i=1:numel(codeInfo.TimingProperties)
        SLCICodeInfo.TimingProperties=[SLCICodeInfo.TimingProperties,codeInfo.TimingProperties(i).SamplePeriod];
    end

    if verbose
        save(SLCIfile,'SLCICodeInfo');
    end
end

function slciFunctionInterface=l_slciConvertFunctionInterface(rtwCodeInfo,...
    rtwFunctionInterface,io_table,param_table,func_type,func_idx)
    slciFunctionInterface=slci.FunctionInterface;
    slciFunctionInterface.Prototype=slci.CImplementation;
    slciFunctionInterface.Prototype.Name=rtwFunctionInterface.Prototype.Name;
    if~isempty(rtwFunctionInterface.Timing)
        slciFunctionInterface.Prototype.SamplePeriod=rtwFunctionInterface.Timing.SamplePeriod;
        slciFunctionInterface.Prototype.SampleOffset=rtwFunctionInterface.Timing.SampleOffset;
    end
    if~isempty(rtwFunctionInterface.Owner)
        slciFunctionInterface.Prototype.OwnerClass=rtwFunctionInterface.Owner.Type.Identifier;
    end











    if numel(rtwFunctionInterface.Prototype.Arguments)~=numel(rtwFunctionInterface.ActualArgs)
        slciFunctionInterface.Prototype.Arguments=[];
        return;
    end
    for j=1:numel(rtwFunctionInterface.Prototype.Arguments)
        if j==1
            slciFunctionInterface.Prototype.Arguments=...
            l_slciConvertArgument(rtwCodeInfo,rtwFunctionInterface,j,io_table,param_table,func_type,func_idx);
        else
            slciFunctionInterface.Prototype.Arguments(j)=...
            l_slciConvertArgument(rtwCodeInfo,rtwFunctionInterface,j,io_table,param_table,func_type,func_idx);
        end
    end

    if~isempty(rtwFunctionInterface.ActualReturn)
        slciFunctionInterface.Prototype.Return=l_slciConvertReturn(rtwCodeInfo,...
        rtwFunctionInterface,io_table);
    end
end

function slciArgument=l_slciConvertArgument(rtwCodeInfo,rtwFunctionInterface,arg_idx,io_table,param_table,func_type,func_idx)
    slciArgument=slci.CArgument;
    slciArgument.Name=rtwFunctionInterface.Prototype.Arguments(arg_idx).Name;
    slciArgument.PassByPointer=rtwFunctionInterface.Prototype.Arguments(arg_idx).Type.isPointer;
    slciArgument.PassByRef=rtwFunctionInterface.Prototype.Arguments(arg_idx).Type.isReference;

    slciArgument.isInputOutput=...
    rtwFunctionInterface.Prototype.Arguments(arg_idx).isInputOutput;
    if slciArgument.isInputOutput
        slciArgument.ioList=setIOList(rtwCodeInfo,...
        slciArgument.Name);
    end
    sid=rtwFunctionInterface.ActualArgs(arg_idx).SID;
    graphicalName=rtwFunctionInterface.ActualArgs(arg_idx).GraphicalName;
    if isempty(sid)
        switch graphicalName
        case 'localZCE'

            graphicalID='Z';
        case 'localDW'
            graphicalID='DW';
        case 'localB'
            graphicalID='B';
        case 'Block states'
            graphicalID='DW';
        case 'Parameter'
            graphicalID='P';
        case 'Block signals'
            graphicalID='K';
        case 'Zero crossing states'
            graphicalID='Z';
        case 'ExternalInput'
            graphicalID='U';
        case 'ExternalOutput'
            graphicalID='Y';
        case{'Real-time model','RTModel'}
            graphicalID='RTM';
        case 'timingBridge'
            graphicalID='T';
        otherwise
            DAStudio.error('Slci:slci:UnsupportedModelArgument',...
            rtwCodeInfo.GraphicalPath,graphicalName);



        end
        slciArgument.GraphicalID=graphicalID;
    else
        if(isKey(io_table,sid))
            gIds=io_table(sid);
            assert(iscell(gIds),'gIds must be cell');
            if numel(gIds)==1

                graphicalID=gIds{1};
            else
                graphicalID=...
                getArgSrc(rtwCodeInfo.Name,arg_idx,func_type,func_idx);
                if isempty(graphicalID)


                    graphicalID=gIds{1};
                end
                assert(ismember(graphicalID,gIds),...
                'GraphicalID must be in CodeInfo');
            end
            slciArgument.GraphicalID=graphicalID;
            slciArgument.Sid=sid;

            slciArgument.GraphicalName=graphicalName;

        elseif(isKey(param_table,graphicalName))


            slciArgument.GraphicalID=param_table(graphicalName);
            slciArgument.Sid=graphicalName;
        else
            slciArgument.GraphicalID='';
        end

    end
    slciArgument.Dimensions=l_slciGetDim(rtwFunctionInterface.Prototype.Arguments(arg_idx).Type);
    if(slciArgument.PassByRef||slciArgument.PassByPointer)&&isequal(slciArgument.Dimensions,1)
        dim=l_slciGetDim(rtwFunctionInterface.ActualArgs(arg_idx).Type);
        if prod(dim)>1

            slciArgument.Dimensions=prod(dim);
        end
    end

    slciArgument.Type=l_slciGetType(rtwFunctionInterface.Prototype.Arguments(arg_idx).Type);
end


function ioList=setIOList(rtwCodeInfo,argName)
    ioList=[];
    modelName=rtwCodeInfo.Name;

    rtwFuncProto=get_param(modelName,'RTWFcnClass');
    isFuncProtoControlEnabled=~isempty(rtwFuncProto)...
    &&isa(rtwFuncProto,'RTW.ModelSpecificCPrototype');

    ioListTmp={};
    if isFuncProtoControlEnabled
        codeInfoInports=rtwCodeInfo.Inports;
        for i=1:numel(codeInfoInports)
            funcProtoArgName=rtwFuncProto.getArgName(codeInfoInports(i).GraphicalName);

            if strcmpi(argName,funcProtoArgName)
                ioListTmp{end+1}=codeInfoInports(i).SID;%#ok
            end
        end
    end

    model_classObj=RTW.getEncapsulationInterfaceSpecification(modelName);
    if~isempty(model_classObj)
        ioData=model_classObj.Data;
        for i=1:numel(ioData)
            data=ioData(i);
            if strcmpi(data.SLObjectType,'Inport')...
                &&strcmpi(argName,data.Argname)
                blockSID=getInportBlockSID(rtwCodeInfo,data.SLObjectName);
                if~isempty(blockSID)
                    ioListTmp{end+1}=blockSID;%#ok
                end
            end
        end
    end

    if~isempty(ioListTmp)
        ioList=sprintf('%s,',ioListTmp{:});
        ioList=ioList(1:end-1);
    end
end


function sid=getInportBlockSID(rtwCodeInfo,graphicName)
    sid='';
    codeInfoInports=rtwCodeInfo.Inports;
    for j=1:numel(codeInfoInports)
        if strcmpi(codeInfoInports(j).GraphicalName,graphicName)
            sid=codeInfoInports(j).SID;
            return;
        end
    end
end

function slciArgument=l_slciConvertReturn(rtwCodeInfo,rtwFunctionInterface,io_table)

    slciArgument=slci.CArgument;
    assert(~isempty(rtwFunctionInterface.ActualReturn));
    slciArgument.Name=rtwFunctionInterface.Prototype.Return.Name;
    slciArgument.PassByPointer=rtwFunctionInterface.Prototype.Return.Type.isPointer;
    slciArgument.PassByRef=rtwFunctionInterface.Prototype.Return.Type.isReference;
    sid=rtwFunctionInterface.ActualReturn.SID;
    if isempty(sid)
        DAStudio.error('Slci:slci:UnsupportedReturn',...
        rtwCodeInfo.GraphicalPath,rtwFunctionInterface.Prototype.Name);
    else
        slciArgument.Sid=sid;
        if isKey(io_table,sid)
            graphicIds=io_table(sid);


            assert(numel(graphicIds)==1,...
            'return arg could not have multiple sid');
            slciArgument.GraphicalID=graphicIds{1};
        else
            DAStudio.error('Slci:slci:UnsupportedReturn',...
            rtwCodeInfo.GraphicalPath,rtwFunctionInterface.Prototype.Name);
        end
    end
    slciArgument.Dimensions=l_slciGetDim(rtwFunctionInterface.ActualReturn.Type);
    slciArgument.Type=l_slciGetType(rtwFunctionInterface.ActualReturn.Type);
end

function slciType=l_slciGetType(rtwType)
    if rtwType.isPointer||rtwType.isReference
        slciType=l_slciGetType(rtwType.BaseType);
    elseif rtwType.isNumeric
        if rtwType.isDouble
            slciType='double';
        elseif rtwType.isSingle
            slciType='single';
        elseif rtwType.isBoolean
            slciType='boolean';
        elseif rtwType.isInteger||rtwType.isFixed
            if(rtwType.isFixed&&~strcmp(rtwType.DataTypeMode,...
                'Fixed-point: binary point scaling'))
                slciType=rtwType.Identifier;
                return;
            end

            if rtwType.Signedness
                Signedness='int';
            else
                Signedness='uint';
            end
            WordLength=num2str(rtwType.WordLength);
            slciType=strcat(Signedness,WordLength);
        else
            slciType=rtwType.Identifier;
        end
    elseif rtwType.isMatrix
        slciType=l_slciGetType(rtwType.BaseType);
    else
        slciType=rtwType.Identifier;
    end
end

function slciDim=l_slciGetDim(rtwType)
    if~isempty(rtwType)&&rtwType.isMatrix
        slciDim=rtwType.Dimensions;
    else
        slciDim=1;
    end
end







function output_fcn=getOutputFcn(codeInfo)
    output_fcn=[];
    num_fcn=numel(codeInfo.OutputFunctions);


    if(num_fcn==1)
        output_fcn=codeInfo.OutputFunctions(1);
    elseif(num_fcn>1)


        for i=1:num_fcn
            curr_fcn=codeInfo.OutputFunctions(i);
            curr_fcn_name=curr_fcn.Prototype.Name;
            is_server=false;


            for k=1:numel(codeInfo.ServerCallPoints)
                curr_server_fcn_name=codeInfo.ServerCallPoints(k).Prototype.Name;
                if strcmp(curr_server_fcn_name,curr_fcn_name)
                    is_server=true;
                    break;
                end
            end
            if(~is_server)
                output_fcn=[output_fcn,curr_fcn];%#ok
            end
        end
    end
end






function out=getArgSrc(mdl_name,arg_idx,func_type,func_idx)
    try
        binfo=coder.internal.infoMATFileMgr(...
        'load','binfo',mdl_name,'RTW');

        func_name='';
        if strcmp(func_type,'Output')||strcmp(func_type,'Update')
            if binfo.modelInterface.SingleTasking
                func_name='OutputUpdateFcn';
            else
                mdl_handle=get_param(mdl_name,'Handle');
                sample_table=slci.internal.getModelSampleTimes(mdl_handle);
                assert(func_idx<=numel(sample_table));

                sample_time=slci.internal.SampleTime(sample_table{func_idx});
                tid=slci.internal.tsToTid(sample_time,sample_table);
                if(tid>=0)
                    func_name=['OutputUpdateTID',num2str(tid),'Fcn'];
                else


                    func_name=['OutputUpdateTIDFcn'];
                end
            end
        elseif strcmp(func_type,'Registration')
            func_name='RegistrationFcn';
        elseif strcmp(func_type,'Start')
            func_name='StartFcn';
        elseif strcmp(func_type,'InitConditions')
            func_name='InitializeFcn';
        elseif strcmp(func_type,'SystemInitialize')
            func_name='SystemInitializeFcn';
        elseif strcmp(func_type,'SystemReset')
            func_name='SystemResetFcn';
        elseif strcmp(func_type,'Disable')
            func_name='DisableFcn';
        elseif strcmp(func_type,'Enable')
            func_name='EnableFcn';
        end

        assert(~isempty(func_name),'function name cannot be empty');
        assert(isfield(binfo.modelInterface,func_name),...
        'function name must be field of modelInterface');
        funcinfo=eval(['binfo.modelInterface.',func_name]);
        arg_src=funcinfo.ArgSource;
        arg_sz=size(arg_src);
        assert((numel(arg_sz)==2)&&(arg_idx<=arg_sz(1)));
        src=arg_src(arg_idx,:);
        assert(ischar(src));

        out=strrep(src,char(0),'');
    catch
        out='';
    end
end

