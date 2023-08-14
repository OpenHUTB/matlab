function iTy=xml2type(featureControl,xIDP,inputName,inputPath,idpTable)






    if exist('idpTable','var')&&isa(idpTable,'com.mathworks.toolbox.coder.plugin.inputtypes.PartialTypePropertyTable')
        xIDP=com.mathworks.toolbox.coder.plugin.inputtypes.IDPUtils.unpackInputDataProperty(xIDP,idpTable);
    end

    constant=booleanTagValue(xIDP,'Constant');
    if constant
        iTy=constant2iTy(xIDP,inputPath);
        iTy.Name=inputName;
        return;
    end

    outputRef=xIDP.getChild('OutputReference');
    if~outputRef.isPresent()
        inputClass=stringTagValue(xIDP,'Class');
        switch inputClass
        case{'single','double',...
            'logical','char',...
            'int8','uint8',...
            'int16','uint16',...
            'int32','uint32',...
            'int64','uint64',...
            'half'}
            iTy=numeric2iTy(xIDP,inputName,inputClass);
        case 'struct'
            iTy=struct2iTy(xIDP,inputName,inputPath);
        case{'fi','embedded.fi'}
            iTy=fi2iTy(xIDP,inputName,inputPath);
        case 'cell'
            iTy=cell2iTy(xIDP,inputName,inputPath);
        otherwise
            iTy=object2iTy(xIDP,inputName,inputPath,inputClass);
        end
    else
        iTy=outputReference2OutputType(outputRef,inputName);
    end

    iTy=getInitialValue(iTy,xIDP);




    function result=propertyValuePairs(xIDP,propTag)
        result='';
        xProp=xIDP.getChild(propTag);
        xpvPair=xProp.getChild([]);
        delim='';
        while xpvPair.isPresent()
            xpvValue=xpvPair.readText();
            if~isempty(xpvValue)
                result=[result,delim...
                ,'''',char(xpvPair.getCurrentElementName()),''','...
                ,char(xpvValue)];%#ok<AGROW>
                delim=',';
            end
            xpvPair=xpvPair.next();
        end
    end



    function result=stringTagValue(xIDP,name)
        result='';
        javaString=xIDP.readText(name);
        if isempty(javaString)
            return;
        end
        result=char(javaString);
    end



    function result=booleanTagValue(xIDP,name)
        javaString=xIDP.readText(name);
        if isempty(javaString)
            result=false;
        else
            result=strcmp('true',char(javaString));
        end
    end



    function result=numericTagValue(xIDP,name)
        javaString=xIDP.readText(name);
        if isempty(javaString)
            result=0;
        else
            result=str2double(char(javaString));
        end
    end



    function ity=numeric2iTy(xIDP,InputName,inputClass)
        ity=coder.newtype(inputClass,...
        'Complex',strcmpi(stringTagValue(xIDP,'Complex'),'true'),...
        'Sparse',strcmpi(stringTagValue(xIDP,'Sparse'),'true'),...
        'Gpu',strcmpi(stringTagValue(xIDP,'Gpu'),'true'));
        ity=getSize(ity,xIDP);
        ity.Name=InputName;
    end



    function ity=fi2iTy(xIDP,InputName,inputPath)
        ntProps=propertyValuePairs(xIDP,'numerictype');
        try
            tempNumericType=eval(['numerictype(',ntProps,')']);
        catch ME
            msgId='Coder:configSet:ProjectNumerictypeInvalid';
            ccdiagnosticid(msgId,inputPath,ME.message);
        end
        fmProps=propertyValuePairs(xIDP,'fimath');
        if~isempty(fmProps)
            try
                tempFimath=eval(['fimath(',fmProps,')']);
            catch ME
                msgId='Coder:configSet:ProjectFimathInvalid';
                ccdiagnosticid(msgId,inputPath,ME.message);
            end
            ity=coder.newtype('embedded.fi',tempNumericType,'fimath',tempFimath,'complex',booleanTagValue(xIDP,'Complex'));
        else
            ity=coder.newtype('embedded.fi',tempNumericType,'complex',booleanTagValue(xIDP,'Complex'));
        end
        ity=getSize(ity,xIDP);
        ity.Name=InputName;
    end



    function[fields,fldName]=fields2iTys(xIDP,inputPath)
        xField=xIDP.getChild('Field');
        nFields=0;
        while xField.isPresent()
            nFields=nFields+1;
            fldName{nFields}=char(xField.readAttribute('Name'));%#ok<AGROW>
            fldPath=[inputPath,'.',fldName{nFields}];
            fields{nFields}=xml2type(featureControl,xField,fldName{nFields},fldPath);%#ok<AGROW>
            xField=xField.next();
        end

        if nFields==0
            fields=[];
            fldName=[];
        end
    end



    function ity=struct2iTy(xIDP,InputName,inputPath)
        [Members,fldNames]=fields2iTys(xIDP,inputPath);
        TempStruct=struct();
        for i=1:numel(Members)
            TempStruct.(fldNames{i})=Members{i};
        end
        ity=coder.newtype('struct',TempStruct);
        ity.TypeName=stringTagValue(xIDP,'TypeName');
        ity.Extern=booleanTagValue(xIDP,'Extern');
        ity.HeaderFile=stringTagValue(xIDP,'HeaderFile');
        fAlignment=numericTagValue(xIDP,'Alignment');
        if fAlignment==0
            ity.Alignment=-1;
        else
            ity.Alignment=fAlignment;
        end
        ity=getSize(ity,xIDP);
        ity.Name=InputName;
    end



    function ity=cell2iTy(xIDP,inputName,inputPath)
        [ity,~]=fields2iTys(xIDP,inputPath);

        isVarargin=strcmp(inputName,'varargin');

        if(isVarargin)
            return;
        end

        if(~isempty(ity))
            ity=coder.typeof(ity);
        else
            ity=coder.typeof({});
        end

        ity=getSize(ity,xIDP);

        if(~booleanTagValue(xIDP,'Homogeneous'))
            if(ity.isHomogeneous())
                ity=ity.makeHeterogeneous();
            end
            customStructName=stringTagValue(xIDP,'TypeName');
            if(~isempty(customStructName))
                ity.TypeName=customStructName;
                ity.Extern=booleanTagValue(xIDP,'Extern');
                ity.HeaderFile=stringTagValue(xIDP,'HeaderFile');
                ity.Alignment=numericTagValue(xIDP,'Alignment');
            end
        end

        ity.Name=inputName;
    end



    function ity=object2iTy(xIDP,InputName,inputPath,inputClass)
        ity=coder.newtype(inputClass);
        if isa(ity,'coder.type.Base')
            ity=ity.getCoderType();
        end
        if isa(ity,'coder.ClassType')
            [fieldTypes,fieldNames]=fields2iTys(xIDP,inputPath);
            if strcmp(ity.ClassName,'string')

                ity.Properties.Value=fieldTypes{1};
            else
                for i=1:length(fieldNames)
                    ity.Properties.(fieldNames{i})=fieldTypes{i};
                end
            end
        elseif isa(ity,'coder.EnumType')
            ity=getSize(ity,xIDP);
        end
        ity.Name=InputName;
    end



    function ity=outputReference2OutputType(xIDP,InputName)
        ity=coder.OutputType(char(xIDP.readAttribute('FunctionName')),str2double(char(xIDP.readAttribute('OutputIndex'))));
        ity.Name=InputName;
    end



    function ity=getSize(ity,xIDP)
        sizeStr=stringTagValue(xIDP,'Size');
        nDims=nnz(sizeStr(:)=='x')+1;
        dims=zeros(1,nDims);
        dimsDynamic=false(1,nDims);
        locX=strfind(sizeStr,'x');
        locColon=strfind(sizeStr,':');
        locInf=[strfind(sizeStr,'Inf'),strfind(sizeStr,'inf')];
        for i=1:numel(locColon)
            dimsDynamic(nnz(locX<locColon(i))+1)=true;
        end
        for i=1:numel(locInf)
            dims(nnz(locX<locInf(i))+1)=Inf;
        end
        sStart=1;
        locX=[locX,(numel(sizeStr)+1)];
        for i=1:nDims
            if dims(i)~=Inf
                sizeStrSection=sizeStr(sStart:locX(i)-1);
                sizeNum=uint8(sizeStrSection);
                dims(i)=str2double(sizeStrSection(sizeNum<58&sizeNum>47));
            end
            sStart=locX(i)+1;
        end


        ity=coder.resize(ity,dims,dimsDynamic);
    end



    function type=getInitialValue(type,xIDP)
        valueConstructor=stringTagValue(xIDP,'InitialValue');
        if~isempty(valueConstructor)

            actualValue=evalin('base',valueConstructor);
            if~isa(actualValue,'coder.Type')
                type.InitialValue=actualValue;
                type.ValueConstructor=valueConstructor;
            end
        else
            blobValue=stringTagValue(xIDP,'Blob');
            if~isempty(blobValue)
                actualValue=codergui.internal.TypeRootXmlBuilder.valueFromEncodedBlob(blobValue);
                if~isa(actualValue,'coder.Type')
                    type.InitialValue=actualValue;
                    try
                        type.ValueConstructor=mat2str(actualValue,'class');
                    catch
                    end
                end
            end
        end
    end



    function type=constant2iTy(xIDP,inputPath)
        blobValue=stringTagValue(xIDP,'Blob');
        valueConstructor=stringTagValue(xIDP,'Value');
        try
            if~isempty(blobValue)
                value=codergui.internal.TypeRootXmlBuilder.valueFromEncodedBlob(blobValue);
                if isempty(valueConstructor)
                    try
                        valueConstructor=mat2str(value,'class');
                    catch
                    end
                end
            else

                if isempty(valueConstructor)
                    valueConstructor=stringTagValue(xIDP,'InitialValue');
                end
                value=evalin('base',valueConstructor);
            end
        catch ME
            msgId='Coder:configSet:ProjectConstantInvalid';
            ccdiagnosticid(msgId,inputPath,ME.message);
        end

        if isa(value,'coder.Type')
            type=value;
        else
            type=coder.newtype('constant',value);
        end
        type.ValueConstructor=valueConstructor;
    end

end



