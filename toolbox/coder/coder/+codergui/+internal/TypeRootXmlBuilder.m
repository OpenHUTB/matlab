

classdef TypeRootXmlBuilder<handle
    properties
        File char=''
        FunctionName char=''
        NumOutputs double{mustBeGreaterThanOrEqual(NumOutputs,0)}
        GlobalNames cell={}
        Types cell={}
        HasInputTypes logical=false
        ValueExpressionLimit uint32=500
        BlobLimit uint32=10e6
    end

    properties(SetAccess=immutable)
        Mode char
        ValueErrorHandler function_handle
    end

    properties(Access=private)
        TypeSerializer;
    end

    methods
        function this=TypeRootXmlBuilder(mode,valueErrorHandler)
            this.TypeSerializer=coder.internal.TypeSerializerStrategy.create();

            if nargin==0
                this.Mode='inputTypes';
            else
                this.Mode=validatestring(mode,{'inputTypes','globals'});
            end
            if nargin>=2&&~isempty(valueErrorHandler)
                this.ValueErrorHandler=valueErrorHandler;
            end
        end

        function xml=toXml(this)
            globalMode=this.Mode=="globals";

            if globalMode
                rootTag='Globals';
            else
                rootTag='Inputs';
            end
            xmlDoc=this.TypeSerializer.createXMLDocument(rootTag);
            xmlRoot=this.TypeSerializer.getXMLRootNode();
            typeRoot=this.TypeSerializer.createXMLNode('idpTable');
            blobSize=0;

            varargStart=inf;
            varargRoot=[];
            if~globalMode
                [itcNames,varargStart,outCount]=getInputNames(this.File,this.Types);
                shouldEncodeNargout=~isempty(this.NumOutputs)&&...
                (outCount<0||outCount~=this.NumOutputs);

                [~,filename,ext]=fileparts(this.File);
                this.TypeSerializer.setXMLNodeAttribute(xmlRoot,'fileName',[filename,ext]);
                this.TypeSerializer.setXMLNodeAttribute(xmlRoot,'functionName',filename);
                if shouldEncodeNargout
                    this.TypeSerializer.setXMLNodeAttribute(xmlRoot,'nargout',num2str(this.NumOutputs));
                end
            else
                itcNames=this.GlobalNames;
            end
            typeId=0;

            isVararg=false;
            for i=1:numel(this.Types)
                itcName=itcNames{i};
                type=this.Types{i};

                if i==varargStart

                    varargRoot=createInputRoot();
                    varargType=coder.typeof(cell(1));
                    varargType.Cells={};
                    appendType(i,varargRoot,'varargin',varargType);
                    this.TypeSerializer.appendXMLNodeChild(xmlRoot,varargRoot);
                    isVararg=true;
                end

                if isVararg
                    inputEl=this.TypeSerializer.createXMLNode('Field');
                    this.TypeSerializer.appendXMLNodeChild(varargRoot,inputEl);
                else
                    inputEl=createInputRoot();
                    this.TypeSerializer.appendXMLNodeChild(xmlRoot,inputEl);
                end

                appendType(i,inputEl,itcName,type);
            end

            this.TypeSerializer.appendXMLNodeChild(xmlRoot,typeRoot);
            xml=this.TypeSerializer.writeXML();


            function appendType(idx,node,name,type)
                emlcprivate('type2xml',type,true,name,xmlDoc,node);

                if globalMode||isa(type,'coder.Constant')
                    if globalMode
                        value=type.InitialValue;
                        valueTag='InitialValue';
                    else
                        value=type;
                        valueTag='Value';
                    end
                    if isa(value,'coder.Constant')
                        appendValueNode(node,'Constant','true');
                    end
                    valueExpr=this.getValueExpression(value);
                    if~isempty(valueExpr)
                        appendValueNode(node,valueTag,valueExpr);
                    else
                        blob=this.valueToEncodedBlob(type,true);
                        if~isempty(blob)
                            blobSize=blobSize+numel(blob);
                            if blobSize<=this.BlobLimit
                                appendValueNode(node,'Blob',blob);
                            else
                                feval(this.ValueErrorHandler,'blobLimitExceeded',idx,name,type);
                            end
                        elseif~isempty(this.ValueErrorHandler)
                            feval(this.ValueErrorHandler,'blobFailure',idx,name,type);
                        end
                    end
                end

                curTypeId=num2str(typeId);
                typeId=typeId+1;
                typeEl=this.TypeSerializer.createXMLNode('type');
                this.TypeSerializer.setXMLNodeAttribute(typeEl,'typeId',curTypeId);
                this.TypeSerializer.appendXMLNodeChild(typeRoot,typeEl);
            end


            function inputRoot=createInputRoot()
                inputRoot=this.TypeSerializer.createXMLNode('Input');
                if~globalMode&&shouldEncodeNargout
                    this.TypeSerializer.setXMLNodeAttribute(inputRoot,'nargout',num2str(this.NumOutputs));
                end
            end


            function appendValueNode(parent,tag,strVal)
                child=this.TypeSerializer.createXMLNode(tag);
                this.TypeSerializer.setXMLNodeTextContent(child,strVal);
                this.TypeSerializer.appendXMLNodeChild(parent,child);
            end
        end
    end

    methods(Access=private)
        function expr=getValueExpression(this,value)
            if isa(value,'coder.Type')
                value=valueFromType(value);
            end
            expr=coderapp.internal.value.valueToExpression(value,this.ValueExpressionLimit,true);
        end
    end

    methods(Static)
        function blob=valueToEncodedBlob(value,compress,useJava)
            if nargin<2
                compress=true;
            end
            if nargin<3
                useJava=true;
            end
            if isa(value,'coder.Type')
                value=valueFromType(value);
            end
            blob=getByteStreamFromArray(value);
            if compress
                if isempty(javachk('jvm'))&&useJava
                    bos=java.io.ByteArrayOutputStream();
                    gzos=java.util.zip.GZIPOutputStream(bos);
                    gzos.write(typecast(blob,'int8'));
                    gzos.flush();
                    gzos.close();
                    blob=typecast(bos.toByteArray(),'uint8');
                else
                    blob=coderapp.internal.util.foundation.compress(typecast(blob,'int8'));
                end
            end

            if usejava('jvm')&&useJava
                blob=char(java.util.Base64.getEncoder.encodeToString(blob));
            else
                blob=matlab.net.base64encode(blob);
            end
        end

        function value=valueFromEncodedBlob(encoded,compressed,useJava)
            if nargin<2
                compressed=true;
            end
            if nargin<3
                useJava=true;
            end
            decoded=matlab.net.base64decode(encoded);
            if compressed
                if isempty(javachk('jvm'))&&useJava
                    bis=java.io.ByteArrayInputStream(typecast(decoded,'int8'));
                    gzis=java.util.zip.GZIPInputStream(bis);
                    decoded=typecast(org.apache.commons.io.IOUtils.toByteArray(gzis),'uint8');
                    value=getArrayFromByteStream(decoded);
                else
                    bis=typecast(decoded,'int8');
                    value=coderapp.internal.util.foundation.decompress(bis);
                end
            else
                value=getArrayFromByteStream(decoded);
            end
        end
    end
end


function[names,varargStart,outCount]=getInputNames(file,itys)
    varargStart=Inf;
    try
        assert(endsWith(lower(file),{'.m','.mlx'}));
        code=matlab.internal.getCode(file);
    catch
        names=cellfun(@(v)v.Name,itys,'UniformOutput',false);
        outCount=0;
        return;
    end

    mt=mtree(code);

    if mt.iskind('ERR')

        try
            builtin('_mcheck',file);
        catch ME
            msgstruct=struct('identifier',ME.identifier,'message',ME.message);
            error(msgstruct);
        end
    end

    names={};
    paramList=mt.root.Ins;

    while~isempty(paramList)
        if paramList.kind()=="NOT"
            names{end+1}='~';%#ok<AGROW>
        else
            names{end+1}=paramList.string();%#ok<AGROW>
        end
        paramList=paramList.Next;
    end

    trailingUnnamedInputCount=0;
    for i=numel(names):-1:1
        if names{i}=="~"||names{i}=="varargin"
            trailingUnnamedInputCount=trailingUnnamedInputCount+1;
            continue;
        end
        break;
    end

    varargStart=Inf;
    providedInputCount=numel(itys);
    expectedInputCount=numel(names);
    [~,filename,~]=fileparts(file);
    if providedInputCount>=expectedInputCount
        if~isempty(names)
            if names{end}=="varargin"
                varargStart=expectedInputCount;
                j=0;
                for i=expectedInputCount:providedInputCount
                    j=j+1;
                    names{i}=sprintf('varargin{%d}',j);%#ok<AGROW>
                end
            elseif providedInputCount>expectedInputCount
                emlcprivate('ccdiagnosticid','Coder:builtins:IDPCountMismatch',filename,expectedInputCount,providedInputCount);
            end
        end
    else
        requiredInputCount=expectedInputCount-trailingUnnamedInputCount;
        if requiredInputCount~=providedInputCount
            emlcprivate('ccwarningid','Coder:common:CliToAppInputCountMismatch',requiredInputCount,filename,providedInputCount);
        end
        names=names(1:providedInputCount);
    end

    outList=mt.root.Outs;
    outCount=0;
    while~isempty(outList)
        outCount=outCount+1;
        if outList.string()=="varargout"
            outCount=outCount*-1;
            break;
        else
            outList=outList.Next;
        end
    end
end


function value=valueFromType(type)
    if isa(type,'coder.Constant')
        value=type.Value;
    else
        value=type.InitialValue;
    end
end
