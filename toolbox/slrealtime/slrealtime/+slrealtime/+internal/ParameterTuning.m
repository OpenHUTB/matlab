






































classdef ParameterTuning<handle
    properties(Access=public)
        Force=false
        CodeDescriptor=[]
    end
    properties(SetAccess=private)
tgtconn
codeDescDir

setparams
    end

    methods(Access=public)
        function this=ParameterTuning(tgtconn,codeDescDir)
            this.tgtconn=tgtconn;
            this.codeDescDir=codeDescDir;

            this.setparams=[];
        end

        function setParam(this,blockPath,paramName,val)












            locSetparams=[];

            param=this.constructParameterInformation(blockPath,paramName);






            locSetparams=this.setParamWork(param,val,locSetparams);
            this.setparams=[this.setparams,locSetparams];
        end

        function tuneParams(this)
            for i=1:length(this.setparams)
                this.tgtconn.download(this.setparams(i).address,this.setparams(i).bytes);
            end







            this.clearParams();
        end

        function clearParams(this)
            this.setparams=[];
        end

        function val=getParam(this,blockPath,paramName)




            param=this.constructParameterInformation(blockPath,paramName);
            val=this.getParamWork(param);
        end
    end

    methods(Access=private)

        function param=constructParameterInformation(this,blockPath,paramName)




            if isempty(this.CodeDescriptor)
                codeDescriptor=coder.internal.getCodeDescriptorInternal(this.codeDescDir,247362);
            else






                codeDescriptor=this.CodeDescriptor;
            end

            paramNameLevels=split(paramName,'.');
            numParamNameLevels=length(paramNameLevels);



            function[paramNameStr,paramNameDims]=parseForIndex(paramName)
                if contains(paramName,'(')

                    parsedParamName=regexp(paramName,'([^\(])*\(([^\)]*)\)','tokens');
                    if length(parsedParamName)~=1||...
                        length(parsedParamName{1})~=2||...
                        isempty(parsedParamName{1}{1})||...
                        isempty(parsedParamName{1}{2})




                        paramNameStr=paramName;
                        paramNameDims=[];
                    else
                        paramNameStr=parsedParamName{1}{1};
                        paramNameDimsStr=parsedParamName{1}{2};
                        paramNameDims=cellfun(@(x)str2num(x),split(paramNameDimsStr,','))';
                    end
                else

                    paramNameStr=paramName;
                    paramNameDims=[];
                end
            end

            function retParam=adjustForIndex(param,paramNameDims,paramNameStr)
                if~isempty(paramNameDims)
                    if any(paramNameDims<1)
                        this.throwError('slrealtime:paramtune:incorrectIndices',mat2str(paramNameDims),paramNameStr,mat2str(param.typeInfo.dimensions));
                    end

                    if length(param.typeInfo.dimensions)==2&&...
                        any(param.typeInfo.dimensions==1)&&...
                        length(paramNameDims)==1



                        if paramNameDims>param.typeInfo.dimensions(1)&&...
                            paramNameDims>param.typeInfo.dimensions(2)
                            this.throwError('slrealtime:paramtune:incorrectIndices',mat2str(paramNameDims),paramNameStr,mat2str(param.typeInfo.dimensions));
                        end
                    elseif any(size(paramNameDims)~=size(param.typeInfo.dimensions))||...
                        any(paramNameDims>param.typeInfo.dimensions)




                        this.throwError('slrealtime:paramtune:incorrectIndices',mat2str(paramNameDims),paramNameStr,mat2str(param.typeInfo.dimensions));
                    end

                    if length(param.typeInfo.dimensions)==1&&param.typeInfo.dimensions~=1

                        offset=(paramNameDims-1)*param.typeInfo.dataTypeSize;
                    else

                        offset=(paramNameDims(1)-1)*param.typeInfo.dataTypeSize;
                        for n=2:length(paramNameDims)
                            offset=offset+prod(param.typeInfo.dimensions(1:n-1))*param.typeInfo.dataTypeSize*(paramNameDims(n)-1);
                        end
                    end

                    param.targetAddress=param.targetAddress+int64(offset);
                    param.typeInfo.dimensions=[1,1];
                end
                retParam=param;
            end










            [paramNameStr,paramNameDims]=parseForIndex(paramNameLevels{1});
            paramNameLevels{1}=paramNameStr;
            param=this.getParameterInfoFromCodeDescriptor(codeDescriptor,blockPath,paramNameLevels{1});
            param=adjustForIndex(param,paramNameDims,paramNameStr);








            if numParamNameLevels~=1




                for nParamNameLevel=2:numParamNameLevels






                    if prod(param.typeInfo.dimensions)>1&&isempty(paramNameDims)
                        this.throwError('slrealtime:paramtune:nonscalarParameter',strjoin(paramNameLevels(1:nParamNameLevel-1),'.'),mat2str(param.typeInfo.dimensions));
                    end



                    [paramNameStr,paramNameDims]=parseForIndex(paramNameLevels{nParamNameLevel});
                    paramNameLevels{nParamNameLevel}=paramNameStr;

                    elIdx=find(strcmp({param.typeInfo.structElements.structElementName},paramNameLevels{nParamNameLevel}));
                    if isempty(elIdx)
                        this.throwError('slrealtime:paramtune:incorrectStructPath',strjoin(paramNameLevels(1:nParamNameLevel),'.'),paramName);
                    end
                    el=param.typeInfo.structElements(elIdx);
                    param=struct(...
                    'targetAddress',param.targetAddress+int64(el.structElementOffset),...
                    'typeInfo',el);

                    if~isempty(el.structElementMin)||~isempty(el.structElementMax)
                        param.range=struct('min',[],'max',[]);
                        if~isempty(el.structElementMin)
                            param.range.min=str2double(el.structElementMin);
                        end
                        if~isempty(el.structElementMax)
                            param.range.max=str2double(el.structElementMax);
                        end
                    else
                        param.range=[];
                    end

                    param=adjustForIndex(param,paramNameDims,strjoin(paramNameLevels(1:nParamNameLevel),'.'));
                end
            end
        end

        function locSetparams=setParamWork(this,param,val,locSetparams)
            if param.typeInfo.isNVBus






                valDims=size(val);
                if~this.isDimensionsEqual(param.typeInfo.dimensions,valDims)

                    this.throwError('slrealtime:paramtune:incorrectDimensions',num2str(valDims),num2str(param.typeInfo.dimensions));
                end
                expElNames={param.typeInfo.structElements.structElementName};
                actElNames=fieldnames(val)';
                if~isequal(expElNames,actElNames)
                    this.throwError('slrealtime:paramtune:incorrectStructFields',sprintf('\n%s',actElNames{:}),sprintf('\n%s',expElNames{:}));
                end





                for nDimEl=1:prod(param.typeInfo.dimensions)
                    nDimElOffset=(nDimEl-1)*param.typeInfo.dataTypeSize;
                    for nEl=1:length(param.typeInfo.structElements)
                        el=param.typeInfo.structElements(nEl);
                        elParam=struct(...
                        'targetAddress',param.targetAddress+int64(el.structElementOffset)+int64(nDimElOffset),...
                        'typeInfo',el);

                        if~isempty(el.structElementMin)||~isempty(el.structElementMax)
                            elParam.range=struct('min',[],'max',[]);
                            if~isempty(el.structElementMin)
                                elParam.range.min=str2double(el.structElementMin);
                            end
                            if~isempty(el.structElementMax)
                                elParam.range.max=str2double(el.structElementMax);
                            end
                        else
                            elParam.range=[];
                        end

                        locSetparams=this.setParamWork(elParam,val(nDimEl).(el.structElementName),locSetparams);
                    end
                end

            else






                numStrPaddingBytes=0;
                if param.typeInfo.isFixedPoint
                    if~isfi(val)||...
                        param.typeInfo.fxpSlopeAdjFactor~=val.SlopeAdjustmentFactor||...
                        param.typeInfo.fxpFractionLength~=val.FractionLength||...
                        param.typeInfo.fxpBias~=val.Bias||...
                        param.typeInfo.fxpWordLength~=val.WordLength||...
                        param.typeInfo.fxpFixedExponent~=val.FixedExponent||...
                        param.typeInfo.fxpSignedness~=val.Signed
                        this.throwError('slrealtime:paramtune:incorrectDataType');
                    end
                elseif param.typeInfo.isHalf
                    if~isa(val,'half')
                        this.throwError('slrealtime:paramtune:incorrectDataType');
                    end
                elseif param.typeInfo.isEnum
                    if~isenum(val)||...
                        ~strcmp(param.typeInfo.enumClassName,class(val))
                        this.throwError('slrealtime:paramtune:incorrectDataType');
                    end
                elseif param.typeInfo.isString
                    if~isstring(val)
                        this.throwError('slrealtime:paramtune:incorrectDataType');
                    end

                    numStrPaddingBytes=param.typeInfo.dataTypeSize-strlength(val);
                    if numStrPaddingBytes<1
                        this.throwError('slrealtime:paramtune:incorrectDataType');
                    end
                else
                    typename=this.convertDataTypeIDToString(param.typeInfo.dataTypeID);
                    if~strcmp(typename,class(val))
                        this.throwError('slrealtime:paramtune:incorrectDataType');
                    end
                end
                if param.typeInfo.isComplex
                    if~isnumeric(val)
                        this.throwError('slrealtime:paramtune:incorrectDataType');
                    elseif isreal(val)
                        val=complex(val,0);
                    end
                else
                    if isnumeric(val)&&~isreal(val)
                        this.throwError('slrealtime:paramtune:incorrectDataType');
                    end
                end
                valDims=size(val);
                if~this.isDimensionsEqual(param.typeInfo.dimensions,valDims)

                    this.throwError('slrealtime:paramtune:incorrectDimensions',num2str(valDims),num2str(param.typeInfo.dimensions));
                end

                if slrealtime.internal.feature('MinMaxSetParam')
                    if~this.Force&&isnumeric(val)&&~isempty(param.range)
                        try
                            rmax=cast(param.range.max,class(val));
                            rmin=cast(param.range.min,class(val));
                        catch
                            rmax=param.range.max;
                            rmin=param.range.min;
                        end
                        if~isempty(param.range.max)&&~isinf(rmax)&&any(val>rmax,'all')
                            this.throwError('slrealtime:paramtune:paramMinMax',mat2str(val),num2str(rmin),num2str(rmax));
                        end
                        if~isempty(param.range.min)&&~isinf(rmin)&&any(val<rmin,'all')
                            this.throwError('slrealtime:paramtune:paramMinMax',mat2str(val),num2str(rmin),num2str(rmax));
                        end
                    end
                end



                if isfi(val)
                    val=val.simulinkarray;
                elseif isa(val,'half')
                    val=val.storedInteger;
                elseif isenum(val)
                    type=Simulink.data.getEnumTypeInfo(class(val),'StorageType');
                    if strcmp(type,'int')
                        type='int32';
                    end
                    val=cast(val,type);
                elseif islogical(val)
                    val=cast(val,'uint8');
                elseif isstring(val)
                    val=cast(val.char,'int8');
                end



                if isreal(val)
                    bytes=typecast(reshape(val,1,numel(val)),'uint8');
                else
                    reals=reshape(real(val),1,numel(real(val)));
                    imags=reshape(imag(val),1,numel(imag(val)));
                    bytes=[];
                    for i=1:length(reals)
                        bytes=[bytes,typecast(reals(i),'uint8'),typecast(imags(i),'uint8')];%#ok
                    end
                end



                if numStrPaddingBytes
                    bytes=[bytes,uint8(zeros(1,numStrPaddingBytes))];
                end




                locSetparams=[locSetparams,struct('address',param.targetAddress,'bytes',bytes)];
            end
        end

        function val=getParamWork(this,param)
            if param.typeInfo.isNVBus




                valArray=[];
                for nDimEl=1:prod(param.typeInfo.dimensions)
                    nDimElOffset=(nDimEl-1)*param.typeInfo.dataTypeSize;

                    v=struct();
                    for nEl=1:length(param.typeInfo.structElements)
                        el=param.typeInfo.structElements(nEl);
                        elParam=struct(...
                        'targetAddress',param.targetAddress+int64(el.structElementOffset)+int64(nDimElOffset),...
                        'typeInfo',el);
                        v.(el.structElementName)=this.getParamWork(elParam);
                    end

                    valArray=[valArray,v];%#ok
                end

                val=valArray;
                sz=size(param.typeInfo.dimensions);
                if max(sz)>1
                    val=reshape(val,param.typeInfo.dimensions);
                end

            else






                numbytes=prod(param.typeInfo.dimensions)*param.typeInfo.dataTypeSize;
                if param.typeInfo.isComplex
                    numbytes=2*numbytes;
                end
                bytes=uint8(this.tgtconn.upload(param.targetAddress,numbytes));



                typename=this.convertDataTypeIDToString(param.typeInfo.dataTypeID);
                if param.typeInfo.isFixedPoint
                    if param.typeInfo.fxpBias==0
                        fptype=fixdt(param.typeInfo.fxpSignedness,param.typeInfo.fxpWordLength,param.typeInfo.fxpFractionLength);
                    else
                        fptype=fixdt(param.typeInfo.fxpSignedness,param.typeInfo.fxpWordLength,param.typeInfo.fxpSlopeAdjFactor,param.typeInfo.fxpFixedExponent,param.typeInfo.fxpBias);
                    end
                    val=fi(0,fptype);
                    if param.typeInfo.dataTypeSize==1
                        if param.typeInfo.fxpSignedness
                            type='int8';
                        else
                            type='uint8';
                        end
                    elseif param.typeInfo.dataTypeSize==2
                        if param.typeInfo.fxpSignedness
                            type='int16';
                        else
                            type='uint16';
                        end
                    elseif param.typeInfo.dataTypeSize==4
                        if param.typeInfo.fxpSignedness
                            type='int32';
                        else
                            type='uint32';
                        end
                    else
                        if param.typeInfo.fxpSignedness
                            type='int64';
                        else
                            type='uint64';
                        end
                    end
                    val.simulinkarray=typecast(bytes,type)';

                elseif param.typeInfo.isHalf
                    val=half.typecast(typecast(bytes,'uint16'));

                elseif param.typeInfo.isEnum
                    values=typecast(bytes,param.typeInfo.enumClassification);
                    val=feval(param.typeInfo.enumClassName,values);

                elseif strcmp(typename,'logical')
                    val=logical(bytes);

                elseif param.typeInfo.isString
                    val=string(deblank(char(bytes)));

                else

                    val=typecast(bytes,typename);
                end

                if param.typeInfo.isComplex


                    allvals=val;
                    val=val(1);
                    for x=1:prod(param.typeInfo.dimensions)
                        avx=2*x-1;
                        val(x)=complex(allvals(avx),allvals(avx+1));
                    end
                end

                sz=size(param.typeInfo.dimensions);
                if max(sz)>1
                    val=reshape(val,param.typeInfo.dimensions);
                end
            end
        end

    end




    methods(Access=private,Static)
        function throwError(errId,varargin)
            msg=message(errId,varargin{:});
            throwAsCaller(MException(errId,'%s',msg.getString()));
        end
    end

    methods(Static,Access=public)
        function[blockPath,paramName]=checkAndFormatArgs(blockPath,paramName)







            if~isempty(blockPath)
                if iscell(blockPath)
                    blockPath=cellfun(@convertStringsToChars,blockPath,'UniformOutput',false);
                    if any(cellfun(@isempty,blockPath))||~all(cellfun(@ischar,blockPath))
                        slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:invalidArg');
                    end
                    if length(blockPath)==1
                        blockPath=blockPath{1};
                    end
                elseif length(blockPath)>1&&isstring(blockPath(1))
                    blockPath=arrayfun(@convertStringsToChars,blockPath,'UniformOutput',false);
                    if any(cellfun(@isempty,blockPath))||~all(cellfun(@ischar,blockPath))
                        slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:invalidArg');
                    end
                else
                    blockPath=convertStringsToChars(blockPath);
                    if~ischar(blockPath)
                        slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:invalidArg');
                    end
                end
            end


            if isempty(paramName)||...
                iscell(paramName)||...
                (length(paramName)>1&&isstring(paramName(1)))
                slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:invalidArg');
            else
                paramName=convertStringsToChars(paramName);
                if~ischar(paramName)
                    slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:invalidArg');
                end
            end
        end
    end

    methods(Static,Access=private)
        function param=getParameterInfoFromCodeDescriptor(codeDescriptor,blockPath,paramName)



            param=struct;

            dataIntrf=[];
            if(isempty(blockPath))



                dataIntrfs=coder.descriptor.DataInterface.findAllParametersWithSameGraphicalName(codeDescriptor.getMF0Model,paramName);

                if isempty(dataIntrfs)||dataIntrfs(1).AddressOrOffset==-1
                    slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:invalidModelParam',paramName);
                end
                dataIntrf=dataIntrfs(1);
            else
                if iscell(blockPath)



                    modelParamDataInterfaces=codeDescriptor.getDataInterfaces('Parameters');





                    if length(blockPath)==1
                        indices=strfind(strrep(blockPath{1},'//','--'),'/');
                        if~isempty(indices)
                            modelBlockName=extractAfter(blockPath{1},indices(end));
                        else
                            modelBlockName=blockPath{1};
                        end
                        modelArgStr=[modelBlockName,'_',paramName];
                        for x=1:numel(modelParamDataInterfaces)
                            if strcmp(modelArgStr,modelParamDataInterfaces(x).Implementation.ElementIdentifier)
                                dataIntrf=modelParamDataInterfaces(x);
                                break;
                            end
                        end
                    end





                    if isempty(dataIntrf)
                        cd_=codeDescriptor;
                        bhm_=cd_.getBlockHierarchyMap();
                        instArgStr='InstParameterArgument:';
                        for nBlockPathLevel=1:length(blockPath)
                            indices=strfind(strrep(blockPath{nBlockPathLevel},'//','--'),'/');
                            if~isempty(indices)
                                modelBlockName=extractAfter(blockPath{nBlockPathLevel},indices(end));
                            else
                                modelBlockName=blockPath{nBlockPathLevel};
                            end
                            blks=bhm_.getBlocksByName(modelBlockName);
                            if~isempty(blks)
                                for nBlk=1:length(blks)
                                    if strcmp(regexprep(blockPath{nBlockPathLevel},'[\n]',' '),regexprep(blks(nBlk).Path,'[\n]',' '))
                                        if~strcmp(blks(nBlk).Type,'ModelReference')
                                            param=struct;
                                            return;
                                        end
                                        if nBlockPathLevel==1
                                            instArgStr=[instArgStr,blks(nBlk).SID,':'];%#ok
                                        else
                                            instArgStr=[instArgStr,extractAfter(blks(nBlk).SID,':')];%#ok
                                            if nBlockPathLevel~=length(blockPath)
                                                instArgStr=[instArgStr,'.'];%#ok
                                            end
                                        end

                                        if blks(nBlk).IsProtectedModelBlock
                                            param=struct;
                                            return;
                                        end
                                        cd_=codeDescriptor.getReferencedModelCodeDescriptor(blks(nBlk).ReferencedModelName);
                                        bhm_=cd_.getBlockHierarchyMap();

                                        break;
                                    end
                                end
                            end
                        end
                        instArgStr=[instArgStr,'.',paramName];
                        for x=1:numel(modelParamDataInterfaces)
                            if strcmp(instArgStr,modelParamDataInterfaces(x).GraphicalName)
                                dataIntrf=modelParamDataInterfaces(x);
                                break;
                            end
                        end
                    end
                else



                    indices=strfind(strrep(blockPath,'//','--'),'/');
                    if~isempty(indices)
                        blockName=extractAfter(blockPath,indices(end));
                    else
                        blockName=blockPath;
                    end

                    bhm=codeDescriptor.getBlockHierarchyMap();

                    blks=bhm.getBlocksByName(blockName);
                    if isempty(blks)
                        slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:invalidBlock',...
                        blockPath);
                    else
                        for i=1:length(blks)
                            blk=blks(i);
                            if strcmp(regexprep(blockPath,'[\n]',' '),regexprep(blk.Path,'[\n]',' '))
                                blockParams=blk.BlockParameters;
                                for x=1:blockParams.Size()
                                    blockParam=blockParams(x);
                                    if strcmp(blockParam.Name,paramName)
                                        if blockParam.ModelParameters.Size==0
                                            slrealtime.internal.ParameterTuning.throwError(...
                                            'slrealtime:paramtune:paramNotTunable',...
                                            paramName);
                                        end

                                        if blockParam.ModelParameters.Size>1||...
                                            blockParam.ModelParameters(1).WorkspaceVariable
                                            slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:paramNotTunableWkspVars',...
                                            paramName,blockPath);
                                        end

                                        dataIntrf=blockParam.ModelParameters(1).DataInterface;
                                        break;
                                    end
                                end
                                if~isempty(dataIntrf)
                                    break;
                                end
                            end
                        end
                    end

                    if isempty(dataIntrf)
                        slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:invalidBlockParam',...
                        blockPath,paramName);
                    end
                end
            end

            if isempty(dataIntrf)
                slrealtime.internal.ParameterTuning.throwError('slrealtime:paramtune:paramNotTunable',...
                paramName);
            end

            impl=dataIntrf.Implementation;
            if~isempty(impl)&&impl.isDefined
                param.typeInfo=slrealtime.internal.processCodeDescriptorType(dataIntrf.Type,impl.Type);
                param.targetAddress=dataIntrf.AddressOrOffset;
                if isprop(dataIntrf,'Range')&&~isempty(dataIntrf.Range)
                    param.range=struct(...
                    'min',str2double(dataIntrf.Range.Min),...
                    'max',str2double(dataIntrf.Range.Max));
                else
                    param.range=[];
                end
            end
        end

        function typename=convertDataTypeIDToString(id)



            switch(id)
            case 0
                typename='double';
            case 1
                typename='single';
            case 2
                typename='int8';
            case 3
                typename='uint8';
            case 4
                typename='int16';
            case 5
                typename='uint16';
            case 6
                typename='int32';
            case 7
                typename='uint32';
            case 8
                typename='logical';
            otherwise
                typename='';
            end
        end

        function val=isDimensionsEqual(dims1,dims2)
            val=true;%#ok % assume equal

            if length(size(dims1))~=length(size(dims2))


                val=false;
                return;
            end



            dims1ScalarRowOrColumn=length(dims1)==1||(length(dims1)==2&&any(dims1==1));
            dims2ScalarRowOrColumn=length(dims2)==1||(length(dims2)==2&&any(dims2==1));
            if dims1ScalarRowOrColumn&&dims2ScalarRowOrColumn


                val=prod(dims1)==prod(dims2);
                return;
            end


            val=all(dims1==dims2);
        end
    end
end

