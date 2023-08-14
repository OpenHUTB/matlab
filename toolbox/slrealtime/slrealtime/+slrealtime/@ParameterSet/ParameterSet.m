classdef ParameterSet<handle





    properties
        filename;
    end

    properties(Hidden)
        pageChecksum;
    end

    properties(Hidden,Access={?slrealtime.internal.paramSet.ParameterTable})
        importSource;
        metadata;
        paramsForDisplay;
        ptable;
    end

    methods(Access=public)



        function obj=ParameterSet(filename)

            obj.filename=filename;
            str=fileread(fullfile([filename,'.json']));
            obj.metadata=jsondecode(str);
            obj.importSource=obj.metadata.source;
            if strcmp(obj.importSource,'target')
                obj.pageChecksum=str2double(obj.metadata.page_checksum);
            end

            if~isempty(obj.metadata.parameters)
                obj.metadata.parameters=obj.formatMetadata(obj.metadata.parameters);

                obj.formatParamsForDisplay();
            end

            obj.ptable=[];
        end



        function delete(obj)
            if~isempty(obj.ptable)
                delete(obj.ptable);
                obj.ptable=[];
            end
        end



        function explorer(obj)

            if isempty(obj.ptable)
                obj.ptable=slrealtime.internal.paramSet.ParameterTable(obj);
            else
                if isgraphics(obj.ptable.UIFigure)
                    obj.ptable.bringToFront();
                else
                    delete(obj.ptable);
                    obj.ptable=slrealtime.internal.paramSet.ParameterTable(obj);
                end
            end
        end




        function set(obj,blkPath,paramName,newVal)

            narginchk(4,4);
            valueChanged=false;


            if~ischar(paramName)&&~isstring(paramName)&&...
                ~ischar(blkPath)&&~isstring(blkPath)
                slrealtime.internal.throw.Error('slrealtime:paramSet:paramNameNotValid');
            end


            if isempty(blkPath)
                fullName=paramName;
            else
                fullName=[blkPath,'/',paramName];
            end



            index=find(strcmp({obj.metadata.parameters.Name},fullName),1);
            if isempty(index)


                index=find(strcmp({obj.metadata.parameters.Name},regexprep(fullName,'\n','\\n')),1);
            end
            if isempty(index)

                index=find(strcmp({obj.metadata.parameters.Name},regexprep(fullName,' ',newline)),1);
            end

            if isempty(index)
                slrealtime.internal.throw.Error('slrealtime:paramSet:paramNameNotExist',fullName);
            end


            min=str2double(obj.metadata.parameters(index).Min);
            max=str2double(obj.metadata.parameters(index).Max);
            if~isnan(min)&&~isnan(max)
                if(newVal<min)||(newVal>max)
                    slrealtime.internal.throw.Error('slrealtime:paramSet:paramMinMax',newVal,min,max);
                end
            end

            if strcmp(obj.paramsForDisplay{index,3},'struct')

                obj.checkStructInputValue(obj.metadata.parameters(index).Elements,newVal);
                obj.paramsForDisplay{index,4}={newVal};
                valueChanged=true;
            elseif strcmp(obj.paramsForDisplay{index,3},'char')


                if isstring(newVal)


                    newVal=convertStringsToChars(newVal);
                end

                if ischar(newVal)

                    newVal=strip(newVal,'"');

                    newVal=strip(newVal,'''');

                    [~,len]=size(newVal);
                    if len<obj.metadata.parameters(index).Dimensions(2)
                        newVal=pad(newVal,obj.metadata.parameters(index).Dimensions(2));
                        obj.paramsForDisplay{index,4}={newVal};
                        valueChanged=true;
                    else


                        slrealtime.internal.throw.Error('slrealtime:paramSet:dimensionsNotMatch');
                    end
                else
                    slrealtime.internal.throw.Error('slrealtime:paramSet:typeNotMatch');
                end
            elseif(obj.metadata.parameters(index).isFixedPoint)
                if~isfi(newVal)||...
                    obj.metadata.parameters(index).fxpSlopeAdjFactor~=newVal.SlopeAdjustmentFactor||...
                    obj.metadata.parameters(index).fxpFractionLength~=newVal.FractionLength||...
                    obj.metadata.parameters(index).fxpBias~=newVal.Bias||...
                    obj.metadata.parameters(index).fxpWordLength~=newVal.WordLength||...
                    obj.metadata.parameters(index).fxpFixedExponent~=newVal.FixedExponent||...
                    obj.metadata.parameters(index).fxpSignedness~=newVal.Signed
                    slrealtime.internal.throw.Error('slrealtime:paramSet:typeNotMatch');
                end


                if isequal(size(newVal),obj.metadata.parameters(index).Dimensions)
                    obj.metadata.parameters(index).Value=newVal;
                    obj.paramsForDisplay{index,4}={mat2str(newVal)};
                    valueChanged=true;
                else
                    slrealtime.internal.throw.Error('slrealtime:paramSet:dimensionsNotMatch');
                end
            elseif strcmp(obj.metadata.parameters(index).DataType,'logical')||strcmp(obj.metadata.parameters(index).DataType,'boolean')
                if~islogical(newVal)
                    slrealtime.internal.throw.Error('slrealtime:paramSet:typeNotMatch');
                end

                if isequal(size(newVal),obj.metadata.parameters(index).Dimensions)
                    obj.paramsForDisplay{index,4}={mat2str(newVal)};
                    valueChanged=true;
                else
                    slrealtime.internal.throw.Error('slrealtime:paramSet:dimensionsNotMatch');
                end
            elseif(obj.metadata.parameters(index).isEnum)
                if~strcmp(class(newVal),obj.metadata.parameters(index).enumClassName)
                    slrealtime.internal.throw.Error('slrealtime:paramSet:typeNotMatch');
                end

                if isequal(size(newVal),obj.metadata.parameters(index).Dimensions)
                    obj.paramsForDisplay{index,4}={mat2str(newVal)};
                    valueChanged=true;
                else
                    slrealtime.internal.throw.Error('slrealtime:paramSet:dimensionsNotMatch');
                end
            elseif(obj.metadata.parameters(index).isComplex)

                if~contains(obj.metadata.parameters(index).DataType,class(newVal))
                    slrealtime.internal.throw.Error('slrealtime:paramSet:typeNotMatch');
                end


                if isequal(size(newVal),obj.metadata.parameters(index).Dimensions)
                    obj.paramsForDisplay{index,4}={mat2str(newVal)};
                    valueChanged=true;
                else
                    slrealtime.internal.throw.Error('slrealtime:paramSet:dimensionsNotMatch');
                end
            else

                if~isreal(newVal)||~strcmp(class(newVal),obj.metadata.parameters(index).DataType)
                    slrealtime.internal.throw.Error('slrealtime:paramSet:typeNotMatch');
                end


                if isequal(size(newVal),obj.metadata.parameters(index).Dimensions)
                    if numel(obj.metadata.parameters(index).Dimensions)<=2
                        obj.paramsForDisplay{index,4}={mat2str(newVal)};
                    else
                        obj.paramsForDisplay{index,4}={newVal};
                    end
                    valueChanged=true;
                else
                    slrealtime.internal.throw.Error('slrealtime:paramSet:dimensionsNotMatch');
                end
            end


            if valueChanged&&~isempty(obj.ptable)
                if isgraphics(obj.ptable.UIFigure)
                    obj.ptable.UITable.Data=obj.paramsForDisplay;
                end
            end

        end




        function exportToModel(obj,modelName)

            obj.updateMetadata();


            try
                open_system(modelName,'force');
            catch ME
                throw(ME);
            end

            for i=1:length(obj.metadata.parameters)
                idx=strfind(obj.metadata.parameters(i).Name,'/');
                if~isempty(idx)

                    blkPath=char(extractBetween(obj.metadata.parameters(i).Name,1,idx(end)-1));
                    paramName=char(extractBetween(obj.metadata.parameters(i).Name,idx(end)+1,length(obj.metadata.parameters(i).Name)));

                    dp=get_param(blkPath,'DialogParameters');
                    if~isfield(dp,paramName)


                        continue;
                    end

                    if strcmp(obj.metadata.parameters(i).DataType,'char')
                        set_param(blkPath,paramName,['"',strtrim(obj.metadata.parameters(i).Value),'"']);
                    else
                        newVal=char(obj.paramsForDisplay.value(i));

                        if obj.metadata.parameters(i).isFixedPoint
                            if strcmp(obj.metadata.parameters(i).fxpBias,'false')
                                newVal=['fi(',newVal,',',num2str(obj.metadata.parameters(i).fxpSignedness),',',num2str(obj.metadata.parameters(i).fxpWordLength),',',num2str(obj.metadata.parameters(i).fxpFractionLength),')'];
                            else
                                newVal=['fi(',newVal,',',num2str(obj.metadata.parameters(i).fxpSignedness),',',num2str(obj.metadata.parameters(i).fxpWordLength),',',num2str(obj.metadata.parameters(i).fxpSlopeAdjFactor),',',num2str(obj.metadata.parameters(i).fxpFixedExponent),',',num2str(obj.metadata.parameters(i).fxpBias),')'];
                            end
                        elseif obj.metadata.parameters(i).isComplex
                            type=char(obj.metadata.parameters(i).DataType);
                            pos=strfind(type,'_');
                            type=char(extractBetween(type,pos+1,length(type)));
                            newVal=[type,'(',newVal,')'];
                        elseif obj.metadata.parameters(i).isEnum
                            set_param(blkPath,paramName,newVal);
                            continue;
                        else
                            newVal=[char(obj.metadata.parameters(i).DataType),'(',newVal,')'];
                        end

                        set_param(blkPath,paramName,newVal);
                    end

                else

                    if obj.metadata.parameters(i).IsStruct
                        els=obj.paramsForDisplay.value(i);
                        els=els{1,1};
                        Simulink.data.assigninGlobal(modelName,obj.metadata.parameters(i).Name,els);
                    else
                        Simulink.data.assigninGlobal(modelName,obj.metadata.parameters(i).Name,obj.metadata.parameters(i).Value);
                    end

                end
            end
        end








        function syncWithApp(obj,app)

            if(nargin<2)||isempty(app)
                slrealtime.internal.throw.Error('slrealtime:paramSet:emptyAppName');
            end
            validateattributes(app,{'char','string'},{'scalartext'});
            app=convertStringsToChars(app);

            [appPath,appName,appExt]=fileparts(app);
            if isempty(appExt)
                appExt='.mldatx';
            end
            appNameWithExt=strcat(appName,appExt);

            if isempty(appPath)
                appFile=which(appNameWithExt);
            else
                appFile=fullfile(appPath,appNameWithExt);
            end



            if~isfile(appFile)
                slrealtime.internal.throw.Error('slrealtime:target:appDoesNotExist');
                return;
            end



            obj.updateMetadata();




            appObj=slrealtime.Application(appFile);
            appObj.extract('/paramSet/paramInfo.json');
            str=fileread(fullfile(appObj.getWorkingDir,'/paramSet/paramInfo.json'));
            newData=jsondecode(str);

            orig_data=obj.metadata;
            obj.metadata=[];
            obj.metadata.model_checksum=uint32(newData.model_checksum);
            obj.metadata.parameters=newData.parameters;
            obj.metadata.parameters=obj.formatMetadata(obj.metadata.parameters);
            for i=1:length(obj.metadata.parameters)
                obj.metadata.parameters(i).Address=int64(obj.metadata.parameters(i).Address);
            end

            orig_names=extractNames(orig_data.parameters);
            new_names=extractNames(obj.metadata.parameters);

            paramInBoth=intersect(new_names,orig_names);
            if~isempty(paramInBoth)
                for i=1:length(paramInBoth)
                    indexOrig=find(strcmp(orig_names,paramInBoth(i)));
                    indexNew=find(strcmp(new_names,paramInBoth(i)));
                    obj.metadata.parameters(indexNew).Value=orig_data.parameters(indexOrig).Value;
                    obj.metadata.parameters(indexNew).Elements=orig_data.parameters(indexOrig).Elements;
                end
            end

            obj.metadata.parameters=obj.formatMetadata(obj.metadata.parameters);
            obj.formatParamsForDisplay();


            if~isempty(obj.ptable)
                if isgraphics(obj.ptable.UIFigure)
                    obj.ptable.UITable.Data=obj.paramsForDisplay;
                end
            end
        end

    end

    methods(Hidden,Access=public)
        function[Data,formatData]=getData(obj)
            Data=obj.metadata;
            formatData=obj.paramsForDisplay;
        end

        function[blockPath,paramName,val]=getParamValueChangedEventNotifyList(obj,tg)
            blockPath=cell(length(obj.metadata.parameters),1);
            paramName=cell(length(obj.metadata.parameters),1);
            val=cell(length(obj.metadata.parameters),1);
            for i=1:length(obj.metadata.parameters)
                idx=strfind(obj.metadata.parameters(i).Name,'/');
                if~isempty(idx)

                    if~isempty(obj.metadata.parameters(i).PathForGetParam)

                        tmpParamName=char(extractBetween(obj.metadata.parameters(i).Name,idx(end)+1,length(obj.metadata.parameters(i).Name)));
                        tmpBlockPath=strsplit(obj.metadata.parameters(i).PathForGetParam,':');
                        tmpValue=obj.metadata.parameters(i).Value;
                    else

                        tmpBlockPath=char(extractBetween(obj.metadata.parameters(i).Name,1,idx(end)-1));
                        tmpParamName=char(extractBetween(obj.metadata.parameters(i).Name,idx(end)+1,length(obj.metadata.parameters(i).Name)));
                        tmpValue=obj.metadata.parameters(i).Value;
                    end
                else

                    tmpBlockPath='';
                    tmpParamName=obj.metadata.parameters(i).Name;
                    if obj.metadata.parameters(i).IsStruct
                        tmpValue=obj.paramsForDisplay.value(i);
                        tmpValue=tmpValue{1,1};
                    else
                        tmpValue=obj.metadata.parameters(i).Value;
                    end
                end

                if strcmp(obj.metadata.parameters(i).DataType,'char')
                    tmpValue=strtrim(tmpValue);
                end

                blockPath{i}=tmpBlockPath;
                paramName{i}=tmpParamName;
                val{i}=tmpValue;
            end
        end
    end

    methods(Access={?slrealtime.Target,?slrealtime.Application})



        function srcFile=saveAsJSON(obj,tmpDir,fileName)
            obj.updateMetadata();


            for i=1:numel(obj.metadata.parameters)
                obj.metadata.parameters(i).Name=regexprep(obj.metadata.parameters(i).Name,'\n','\\n');
            end
            obj.metadata.source='host';

            srcFile=strcat(tmpDir,filesep,fileName,'.json');
            paramJSON=jsonencode(obj.metadata);

            f=fopen(srcFile,'w');
            fprintf(f,paramJSON);
            fclose(f);
        end
    end

    methods(Access=private)






        function metadata=formatMetadata(obj,metadata)


            for i=1:length(metadata)

                if iscell(metadata(i).Dimensions)
                    metadata(i).Dimensions=reshape(str2double(metadata(i).Dimensions),1,[]);
                end

                if iscolumn(metadata(i).Dimensions)
                    metadata(i).Dimensions=metadata(i).Dimensions';
                end

                if ischar(metadata(i).DataTypeSize)
                    metadata(i).DataTypeSize=str2num(metadata(i).DataTypeSize);
                end

                if ischar(metadata(i).IsStruct)
                    if strcmp(metadata(i).IsStruct,'false')
                        metadata(i).IsStruct=false;
                    else
                        metadata(i).IsStruct=true;
                    end
                end

                if ischar(metadata(i).fxpBias)
                    metadata(i).fxpBias=str2num(metadata(i).fxpBias);
                end

                if ischar(metadata(i).fxpSignedness)
                    if strcmp(metadata(i).fxpSignedness,'false')
                        metadata(i).fxpSignedness=0;
                    else
                        metadata(i).fxpSignedness=1;
                    end
                end

                if ischar(metadata(i).fxpWordLength)
                    metadata(i).fxpWordLength=str2num(metadata(i).fxpWordLength);
                end

                if ischar(metadata(i).fxpFractionLength)
                    metadata(i).fxpFractionLength=str2num(metadata(i).fxpFractionLength);
                end

                if ischar(metadata(i).fxpSlopeAdjFactor)
                    metadata(i).fxpSlopeAdjFactor=str2num(metadata(i).fxpSlopeAdjFactor);
                end

                if ischar(metadata(i).fxpFixedExponent)
                    metadata(i).fxpFixedExponent=str2num(metadata(i).fxpFixedExponent);
                end

                if ischar(metadata(i).isComplex)
                    if strcmp(metadata(i).isComplex,'false')
                        metadata(i).isComplex=0;
                    else
                        metadata(i).isComplex=1;
                    end
                end

                if ischar(metadata(i).isFixedPoint)
                    if strcmp(metadata(i).isFixedPoint,'false')
                        metadata(i).isFixedPoint=0;
                    else
                        metadata(i).isFixedPoint=1;
                    end
                end

                if ischar(metadata(i).isEnum)
                    if strcmp(metadata(i).isEnum,'false')
                        metadata(i).isEnum=0;
                    else
                        metadata(i).isEnum=1;
                    end
                end

                if(metadata(i).IsStruct)


                    metadata(i).Elements=obj.formatMetadata(metadata(i).Elements);
                else
                    if isempty(metadata(i).Value)
                        continue;
                    end



                    if strcmp(metadata(i).DataType,'char')
                        metadata(i).Value=char(metadata(i).Value)';
                    else
                        if iscell(metadata(i).Value)
                            metadata(i).Value=cellfun(@(x)str2num(x),metadata(i).Value);
                        end
                        if ischar(metadata(i).Value)
                            metadata(i).Value=str2num(metadata(i).Value);
                        end
                    end


                    if(metadata(i).isComplex)
                        val=zeros(prod(metadata(i).Dimensions),1);
                        for x=1:prod(metadata(i).Dimensions)
                            avx=2*x-1;
                            val(x,1)=complex(metadata(i).Value(avx,1),metadata(i).Value(avx+1,1));
                        end

                        if any(metadata(i).Dimensions>1)
                            val=reshape(val,metadata(i).Dimensions);
                        end
                        metadata(i).Value=val;

                    elseif strcmp(metadata(i).DataType,'half')
                        metadata(i).Value=half.typecast(uint16(metadata(i).Value));
                        metadata(i).Value=reshape(metadata(i).Value,metadata(i).Dimensions);

                    elseif(metadata(i).isFixedPoint)
                        if strcmp(metadata(i).fxpBias,'false')
                            fptype=fixdt(metadata(i).fxpSignedness,metadata(i).fxpWordLength,metadata(i).fxpFractionLength);
                        else
                            fptype=fixdt(metadata(i).fxpSignedness,metadata(i).fxpWordLength,metadata(i).fxpSlopeAdjFactor,metadata(i).fxpFixedExponent,metadata(i).fxpBias);
                        end
                        val=fi(0,fptype);
                        if metadata(i).DataTypeSize==1
                            if metadata(i).fxpSignedness
                                type='int8';
                                metadata(i).Value=int8(metadata(i).Value);
                            else
                                type='uint8';
                                metadata(i).Value=uint8(metadata(i).Value);
                            end
                        elseif metadata(i).DataTypeSize==2
                            if metadata(i).fxpSignedness
                                type='int16';
                                metadata(i).Value=int16(metadata(i).Value);
                            else
                                type='uint16';
                                metadata(i).Value=uint16(metadata(i).Value);
                            end
                        elseif metadata(i).DataTypeSize==4
                            if metadata(i).fxpSignedness
                                type='int32';
                                metadata(i).Value=int32(metadata(i).Value);
                            else
                                type='uint32';
                                metadata(i).Value=uint32(metadata(i).Value);
                            end
                        elseif metadata(i).DataTypeSize==8
                            if metadata(i).fxpSignedness
                                type='int64';
                                metadata(i).Value=int64(metadata(i).Value);
                            else
                                type='uint64';
                                metadata(i).Value=uint64(metadata(i).Value);
                            end
                        elseif metadata(i).DataTypeSize==16
                            if metadata(i).fxpSignedness
                                type='int64';
                                metadata(i).Value=int64(metadata(i).Value);
                            else
                                type='uint64';
                                metadata(i).Value=uint64(metadata(i).Value);
                            end
                        end

                        [r,c]=size(metadata(i).Value);
                        if r>c
                            val.simulinkarray=typecast(metadata(i).Value,type);
                        else
                            val.simulinkarray=typecast(metadata(i).Value,type)';
                        end

                        if any(metadata(i).Dimensions>1)
                            val=reshape(val,metadata(i).Dimensions);
                        end
                        metadata(i).Value=val;
                    elseif(metadata(i).isEnum)
                        val=feval(metadata(i).enumClassName,metadata(i).Value);
                        if any(metadata(i).Dimensions>1)
                            val=reshape(val,metadata(i).Dimensions);
                        end
                        metadata(i).Value=val;
                    else


                        metadata(i).Value=reshape(metadata(i).Value,metadata(i).Dimensions);
                    end

                end
            end
        end



        function var=formatStruct(obj,var)

            if var.IsStruct
                totalNumOfElements=length(var.Elements);
                numOfElementsInStruct=totalNumOfElements/var.Dimensions(2);
                val=[];
                for j=1:var.Dimensions(2)
                    field={};
                    value={};
                    for x=1:numOfElementsInStruct
                        idx=(j-1)*numOfElementsInStruct+x;
                        if var.Elements(idx).IsStruct
                            var.Elements(idx)=obj.formatStruct(var.Elements(idx));
                        end
                        field(end+1)={var.Elements(idx).Name};
                        value(end+1)={var.Elements(idx).Value};
                    end
                    tmp=[];
                    for q=1:length(field)
                        tmp.(field{q})=cell2mat(value(q));
                    end
                    val=[val,tmp];
                end
                var.Value=val;
            else
                return;
            end
        end




        function metadata=formatStructInMetadata(obj,metadata)

            if length(metadata)==1
                if metadata.IsStruct
                    metadata=obj.formatStruct(metadata);
                end
            else
                for i=1:length(metadata)
                    if metadata(i).IsStruct
                        metadata(i)=obj.formatStruct(metadata(i));
                    end
                end
            end

        end




        function formatParamsForDisplay(obj)


            obj.paramsForDisplay=obj.metadata.parameters;
            obj.paramsForDisplay=obj.formatStructInMetadata(obj.paramsForDisplay);
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'Dimensions');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'Address');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'DataTypeSize');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'Min');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'Max');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'isComplex');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'isFixedPoint');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'fxpBias');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'fxpSignedness');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'fxpWordLength');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'fxpFractionLength');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'fxpSlopeAdjFactor');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'fxpFixedExponent');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'isEnum');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'enumClassName');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'Elements');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'IsStruct');
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'PathForGetParam');

            for i=1:length(obj.metadata.parameters)
                obj.paramsForDisplay(i).Size=num2str(obj.metadata.parameters(i).Dimensions);
            end

            for i=1:length(obj.paramsForDisplay)

                idx=strfind(obj.metadata.parameters(i).Name,'/');
                if~isempty(idx)

                    obj.paramsForDisplay(i).blkPath=char(extractBetween(obj.metadata.parameters(i).Name,1,idx(end)-1));
                    obj.paramsForDisplay(i).paramName=char(extractBetween(obj.metadata.parameters(i).Name,idx(end)+1,length(obj.metadata.parameters(i).Name)));
                else

                    obj.paramsForDisplay(i).blkPath='';
                    obj.paramsForDisplay(i).paramName=obj.paramsForDisplay(i).Name;
                end
                obj.paramsForDisplay(i).DataType=obj.paramsForDisplay(i).DataType;
                obj.paramsForDisplay(i).Size=obj.paramsForDisplay(i).Size;
                if isstruct(obj.paramsForDisplay(i).Value)&&length(obj.paramsForDisplay)==1
                    obj.paramsForDisplay(i).Value=obj.paramsForDisplay(i).Value;
                    continue;
                end

                if length(obj.paramsForDisplay)==1
                    if all(obj.metadata.parameters(i).Dimensions==1)
                        obj.paramsForDisplay(i).Value=mat2str(obj.paramsForDisplay(i).Value);
                    else
                        if numel(obj.metadata.parameters(i).Dimensions)<=2

                            obj.paramsForDisplay(i).Value=mat2str(obj.paramsForDisplay(i).Value);
                        end
                    end
                    continue;
                end

                if~ischar(obj.paramsForDisplay(i).Value)&&~isstruct(obj.paramsForDisplay(i).Value)&&...
                    numel(obj.metadata.parameters(i).Dimensions)<=2
                    obj.paramsForDisplay(i).Value=mat2str(obj.paramsForDisplay(i).Value);
                end
            end
            obj.paramsForDisplay=rmfield(obj.paramsForDisplay,'Name');
            blkPath={obj.paramsForDisplay.blkPath}';
            paramName={obj.paramsForDisplay.paramName}';
            dataType={obj.paramsForDisplay.DataType}';
            value={obj.paramsForDisplay.Value}';
            size={obj.paramsForDisplay.Size}';
            obj.paramsForDisplay=table(blkPath,paramName,dataType,value,size);
        end




        function flat=convertNestedStructToFlat(obj,nested,flat)

            idxInFlat=1;
            for j=1:length(nested)
                el=nested(j);

                FieldNames=fieldnames(el);
                numfields=numel(fieldnames(el));
                for x=1:numfields
                    if flat(idxInFlat).IsStruct
                        flat(idxInFlat).Value='';
                        flat(idxInFlat).Elements=obj.convertNestedStructToFlat(getfield(el,FieldNames{x}),flat(idxInFlat).Elements);
                    else
                        flat(idxInFlat).Value=getfield(el,FieldNames{x});
                        flat(idxInFlat)=obj.castValueIntoCorrectType(flat(idxInFlat).Value,flat(idxInFlat));
                    end
                    idxInFlat=idxInFlat+1;
                end
            end
        end




        function updateMetadata(obj)


            for i=1:length(obj.metadata.parameters)
                if strcmp(obj.metadata.parameters(i).DataType,'struct')
                    els=obj.paramsForDisplay.value(i);
                    els=els{1,1};
                    obj.metadata.parameters(i).Elements=obj.convertNestedStructToFlat(els,obj.metadata.parameters(i).Elements);
                else
                    obj.metadata.parameters(i)=obj.castValueIntoCorrectType(obj.paramsForDisplay.value(i),obj.metadata.parameters(i));
                end
            end
        end





        function parameter=castValueIntoCorrectType(obj,newValue,parameter)
            if strcmp(parameter.DataType,'char')
                parameter.Value=char(newValue);
            else

                tmp=newValue;
                if iscell(tmp)
                    tmp=tmp{1,1};
                end

                if ischar(tmp)


                    tmp=str2num(tmp);
                end

                if strcmp(parameter.DataType,'half')

                    tmp=reshape(tmp,1,[]);
                    tmp=half(tmp);
                    tmp=tmp.storedInteger;
                elseif(parameter.isComplex)

                    tmp=reshape(tmp,1,[]);
                    val=zeros(1,prod(parameter.Dimensions)*2);
                    for x=1:prod(parameter.Dimensions)
                        avx=2*x-1;
                        val(1,avx)=real(tmp(1,x));
                        val(1,avx+1)=imag(tmp(1,x));
                    end
                    tmp=val;
                elseif(parameter.isFixedPoint)

                    if strcmp(parameter.fxpBias,'false')
                        fptype=fixdt(parameter.fxpSignedness,parameter.fxpWordLength,parameter.fxpFractionLength);
                    else
                        fptype=fixdt(parameter.fxpSignedness,parameter.fxpWordLength,parameter.fxpSlopeAdjFactor,parameter.fxpFixedExponent,parameter.fxpBias);
                    end
                    val=fi(tmp,fptype);

                    if parameter.DataTypeSize==1
                        if parameter.fxpSignedness
                            type='int8';
                        else
                            type='uint8';
                        end
                    elseif parameter.DataTypeSize==2
                        if parameter.fxpSignedness
                            type='int16';
                        else
                            type='uint16';
                        end
                    elseif parameter.DataTypeSize==4
                        if parameter.fxpSignedness
                            type='int32';
                        else
                            type='uint32';
                        end
                    else
                        if parameter.fxpSignedness
                            type='int64';
                        else
                            type='uint64';
                        end
                    end
                    [r,c]=size(val.simulinkarray);
                    tmp=[];
                    for x=1:c
                        tmp=[tmp;typecast(val.simulinkarray(:,x),type)];
                    end
                elseif(parameter.isEnum)
                    type=Simulink.data.getEnumTypeInfo(class(tmp),'StorageType');
                    if strcmp(type,'int')
                        type='int32';
                    end
                    tmp=cast(tmp,type);
                    tmp=reshape(tmp,1,[]);
                else

                    tmp=reshape(tmp,1,[]);
                end

                parameter.Value=tmp;
            end
        end






        function checkStructInputValue(obj,oldValue,newValue)

            newFieldnames=fieldnames(newValue)';
            oldFieldnames={oldValue.Name};

            newValueAsCell=struct2cell(newValue);
            for i=1:numel(newFieldnames)

                fieldname=char(newFieldnames(i));
                index=find(strcmp(oldFieldnames,fieldname));
                if isempty(index)
                    error(message('slrealtime:paramSet:structFieldMismatch'));
                end


                if isstruct(newValueAsCell{i})

                    for j=1:numel(newValueAsCell{i})
                        n=numel(oldValue(index).Elements)/oldValue(index).Dimensions(2);
                        obj.checkStructInputValue(oldValue(index).Elements(n*(j-1)+1:n*j),newValueAsCell{i}(j));
                    end
                end


                min=str2double(oldValue(i).Min);
                max=str2double(oldValue(i).Max);
                if~isnan(min)&&~isnan(max)
                    if all(newValueAsCell{i}<min)||all(newValueAsCell{i}>max)
                        error(message('slrealtime:paramSet:paramMinMax',oldValue(i).Name,oldValue(i).Min,oldValue(i).Max));
                    end
                end
            end

        end

    end
end

function res=extractNames(data)

    res=[];
    for i=1:length(data)
        res=[res;{data(i).Name}];
    end
end
