function[data]=AssociateDataTypes(obj,log,stateful)



    data=obj.data;

    supportedDataTypes={'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64','char','logical','embedded.fi','struct','coder.Constant','coder.PrimitiveType'};

    data.TopFunctionName=[];
    data.TopFunctionInputs={};
    data.TopFunctionOutputs={};









    rootFunctionID=min(log.inference.RootFunctionIDs);
    data.TopFunctionName=log.inference.Functions(rootFunctionID).FunctionName;
    nInputs=nargin(fullfile(obj.data.fpath,[obj.data.fname,obj.data.fext]));
    coder.internal.errorIf(nInputs<0,'dsp:dspunfold:VarArgIn',data.TopFunctionName);
    for i=1:nInputs
        data.TopFunctionInputs{i}.VarType=[];
        data.TopFunctionInputs{i}.VarName=['in',num2str(i)];
    end
    nOutputs=nargout(fullfile(obj.data.fpath,[obj.data.fname,obj.data.fext]));
    for i=1:nOutputs
        data.TopFunctionOutputs{i}.VarType=[];
    end


    for i=1:numel(data.TopFunctionInputs)
        data.TopFunctionInputs{i}.VarType=FindVariableData(log,data.TopFunctionName,i,true);
    end
    ended=false;
    while~ended
        ended=true;
        for i=1:numel(data.TopFunctionInputs)-1
            if data.TopFunctionInputs{i}.VarType.VarIdx>data.TopFunctionInputs{i+1}.VarType.VarIdx
                tmp=data.TopFunctionInputs{i};
                data.TopFunctionInputs{i}=data.TopFunctionInputs{i+1};
                data.TopFunctionInputs{i+1}=tmp;
                ended=false;
            end
        end
    end
    for i=1:numel(data.TopFunctionInputs)
        data.TopFunctionInputs{i}.VarFrame=obj.data.FrameInputs(i)&&stateful;
        data.TopFunctionInputs{i}.VarName=['in',num2str(i)];
    end


    for i=1:numel(data.TopFunctionOutputs)
        data.TopFunctionOutputs{i}.VarType=FindVariableData(log,data.TopFunctionName,i,false);
    end
    ended=false;
    while~ended
        ended=true;
        for i=1:numel(data.TopFunctionOutputs)-1
            if data.TopFunctionOutputs{i}.VarType.VarIdx>data.TopFunctionOutputs{i+1}.VarType.VarIdx
                tmp=data.TopFunctionOutputs{i};
                data.TopFunctionOutputs{i}=data.TopFunctionOutputs{i+1};
                data.TopFunctionOutputs{i+1}=tmp;
                ended=false;
            end
        end
    end
    for i=1:numel(data.TopFunctionOutputs)
        data.TopFunctionOutputs{i}.VarName=['out',num2str(i)];
    end


    for i=1:numel(data.TopFunctionOutputs)
        for j=1:numel(data.TopFunctionInputs)
            inplaceIOcheck(fullfile(obj.data.fpath,[obj.data.fname,obj.data.fext]),data.TopFunctionOutputs{i}.VarType.VarIdx,data.TopFunctionOutputs{i}.VarType.VarLength,data.TopFunctionInputs{j}.VarType.VarIdx,data.TopFunctionInputs{j}.VarType.VarLength);
        end
    end



    for i=1:numel(data.TopFunctionInputs)

        coder.internal.errorIf(isempty(data.TopFunctionInputs{i}.VarType),...
        'dsp:dspunfold:InternalError');

        coder.internal.errorIf(~isempty(data.TopFunctionInputs{i}.VarType.LogInfo.SizeDynamic),...
        'dsp:dspunfold:VarSizeIn',num2str(i),data.TopFunctionName);

        coder.internal.errorIf((sum(strcmpi(supportedDataTypes,data.TopFunctionInputs{i}.VarType.LogInfo.Class))==0),...
        'dsp:dspunfold:VarTypeIn',num2str(i),data.TopFunctionName,data.TopFunctionInputs{i}.VarType.LogInfo.Class);

        coder.internal.errorIf((sum(strcmpi(supportedDataTypes,class(obj.InputArgs{i})))==0),...
        'dsp:dspunfold:VarTypeIn',num2str(i),class(obj.InputArgs{i}));

        coder.internal.errorIf((strcmp(data.TopFunctionInputs{i}.VarType.LogInfo.Class,'struct')&&(data.TopFunctionInputs{i}.VarFrame)),...
        'dsp:dspunfold:VarTypeInStructAsFrame',num2str(i));

        coder.internal.errorIf((isa(obj.InputArgs{i},'coder.Constant')&&(data.TopFunctionInputs{i}.VarFrame)),...
        'dsp:dspunfold:VarTypeInConstantAsFrame',num2str(i));

        coder.internal.errorIf((obj.StateLength<0)&&isa(obj.InputArgs{i},'coder.PrimitiveType'),...
        'dsp:dspunfold:VarTypeInAutomode',num2str(i),class(obj.InputArgs{i}));
    end

    for i=1:numel(data.TopFunctionOutputs)

        coder.internal.errorIf(isempty(data.TopFunctionOutputs{i}.VarType),...
        'dsp:dspunfold:InternalError');

        coder.internal.errorIf(~isempty(data.TopFunctionOutputs{i}.VarType.LogInfo.SizeDynamic),...
        'dsp:dspunfold:VarSizeOut',num2str(i),data.TopFunctionName);

        coder.internal.errorIf((sum(strcmpi(supportedDataTypes,data.TopFunctionOutputs{i}.VarType.LogInfo.Class))==0),...
        'dsp:dspunfold:VarTypeOut',num2str(i),data.TopFunctionName,data.TopFunctionOutputs{i}.VarType.LogInfo.Class);
    end


    if obj.NonBlockingOutput
        data.Latency=obj.Threads*obj.Repetition*2;
    else
        data.Latency=obj.Threads*obj.Repetition;
    end


    buldinfomat=fullfile(obj.data.workdirectory,'codegen',[obj.data.tempname,'original'],'buildInfo.mat');
    data.includes='';
    if exist(buldinfomat,'file')
        b=load(buldinfomat);
        includes=b.buildInfo.getIncludePaths(true);

        for i=1:numel(includes)
            data.includes=[data.includes,' -I"',includes{i},'" '];
        end
    end
    if isunix
        data.includes=[data.includes,' -lm -ldl -liomp5 -L"',fullfile(matlabroot,'sys','os',computer('arch')),'" '];
    elseif ismac
        data.includes=[data.includes,' -lm -ldl -L"',fullfile(matlabroot,'sys','os',computer('arch')),'" '];
    end

end



function varinfo=FindVariableData(log,functionName,variableIdx,input)
    varinfo=[];
    indexFcn=-1;
    for i=1:numel(log.inference.Functions)
        if strcmp(log.inference.Functions(i).FunctionName,functionName)


            coder.internal.errorIf(indexFcn~=-1,'dsp:dspunfold:InternalError');
            indexFcn=i;
        end
    end


    coder.internal.errorIf(indexFcn==-1,'dsp:dspunfold:InternalError');

    indexVar=0;
    for i=1:numel(log.inference.Functions(indexFcn).MxInfoLocations)
        if(input)&&strcmp(log.inference.Functions(indexFcn).MxInfoLocations(i).NodeTypeName,'inputVar')
            indexVar=indexVar+1;
        end
        if(~input)&&strcmp(log.inference.Functions(indexFcn).MxInfoLocations(i).NodeTypeName,'outputVar')
            indexVar=indexVar+1;
        end

        if(indexVar==variableIdx)
            varinfo.LogInfo.Class='';
            varinfo.LogInfo.Complex=false;
            varinfo.LogInfo.SizeDynamic=[];
            varinfo.LogInfo.Size=[];
            varinfo.VarIdx=log.inference.Functions(indexFcn).MxInfoLocations(i).TextStart;
            varinfo.VarLength=log.inference.Functions(indexFcn).MxInfoLocations(i).TextLength;
            mxInfo=log.inference.MxInfos{log.inference.Functions(indexFcn).MxInfoLocations(i).MxInfoID};
            if sum(strcmp(fieldnames(mxInfo),'Class'))
                varinfo.LogInfo.Class=mxInfo.Class;
            end
            if sum(strcmp(fieldnames(mxInfo),'Complex'))
                varinfo.LogInfo.Complex=mxInfo.Complex;
            end
            if sum(strcmp(fieldnames(mxInfo),'SizeDynamic'))
                varinfo.LogInfo.SizeDynamic=mxInfo.SizeDynamic;
            end
            if sum(strcmp(fieldnames(mxInfo),'Size'))
                varinfo.LogInfo.Size=mxInfo.Size;
            end
            break;
        end
    end

end

function inplaceIOcheck(filename,oStart,oLength,iStart,iLength)
    pStrFile=StringWriter();
    readfile(pStrFile,filename);
    hfile=pStrFile.char;
    coder.internal.errorIf(strcmp(hfile(iStart+1:iStart+iLength),hfile(oStart+1:oStart+oLength)),...
    'dsp:dspunfold:ErrorInplaceIO',hfile(iStart+1:iStart+iLength));
end



