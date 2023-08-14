function coderScriptName=projectToScript(projectFileName,scriptName,extraCmdLineArg,client)




    if nargin<4



        client='codegen';
    end

    maxVariableLength=63;
    varExceedingLength=1;
    originalDir=pwd;
    restoreDir=onCleanup(@()cd(originalDir));
    CC=coder.internal.CompilationContext(client);

    if coderapp.internal.globalconfig('JavaFreePrjParser')
        prj=coderapp.project.import(projectFileName);
        coderapp.project.copyToCompilationContext(prj,CC);
    else
        emlcprivate('loadProjectFile',CC,projectFileName,'projectToScript');
    end

    [coderScriptName,f2fScriptName,scriptFolder]=determineScriptLocation();

    if isGpuCoderProject()
        rootConfigFactory='coder.gpuConfig';
    else
        rootConfigFactory='coder.config';
    end


    buffers={''};
    bufferIdx=1;

    blobVarName='allValues';
    blobs={};
    nestedArgNameId=1;


    if isCoderProject()
        metaIndex=coderapp.internal.coderconfig.ConfigMetadataIndex(ForProject=true);
        emitStdCode(coderScriptName);
        writeScript(coderScriptName);
    end




    if(isCoderProject()&&~isempty(CC.FixptData))||isFixedPointConverterProject()


        if isFixedPointConverterProject()
            cfg=CC.ConfigInfo;
        else
            assert(~isempty(CC.FixptData));
            cfg=CC.FixptData;
        end
        if isFixedPointConverterProject()


            entryPoints=CC.Project.EntryPoints;
        else
            assert(numel(CC.FixptState.OrigEntryPoints)==numel(CC.Project.EntryPoints));
            entryPoints=CC.FixptState.OrigEntryPoints;
        end

        emitF2FCode(f2fScriptName,cfg,entryPoints);
        writeScript(f2fScriptName);
    end


    function res=isCoderProject()
        res=isCoderClient(CC.ClientType);
    end


    function res=isFixedPointConverterProject()
        res=isFixedPointConverterClient(CC.ClientType);
    end


    function res=isGpuCoderProject()
        res=isprop(CC.ConfigInfo,'GpuConfig')&&~isempty(CC.ConfigInfo.GpuConfig);
    end


    function res=isCoderClient(client)
        res=strcmpi(client,'codegen');
    end


    function res=isFixedPointConverterClient(client)
        res=strcmpi(client,'fiaccel');
    end


    function[bool]=isSinglesConversionEnabled()
        bool=~isempty(CC.ConfigInfo.F2FConfig)&&CC.ConfigInfo.F2FConfig.DoubleToSingle;
    end


    function[coderScriptName,f2fScriptName,folder]=determineScriptLocation()
        scriptNameIsRelative=~isempty(scriptName)&&~codergui.internal.util.isAbsolute(scriptName);

        if scriptNameIsRelative
            coderScriptName=fullfile(originalDir,scriptName);
        else
            coderScriptName=scriptName;
        end

        if isCoderProject()&&~isempty(CC.FixptData)
            f2fScriptName=getF2FScriptName(coderScriptName);
        else
            f2fScriptName=coderScriptName;
        end

        if~isempty(scriptName)
            [folder,~,~]=fileparts(coderScriptName);
        else
            folder=pwd();
        end


        if~isempty(coderScriptName)&&~endsWith(coderScriptName,'.m')
            coderScriptName=[coderScriptName,'.m'];
        end
    end


    function fixptScriptName=getF2FScriptName(scriptName)
        if isempty(scriptName)
            fixptScriptName=[];
        else
            [p,fName,ext]=fileparts(scriptName);
            fixptScriptName=fullfile(p,[fName,CC.FixptData.FixPtFileNameSuffix,ext]);
        end
    end


    function emitStdCode(coderScriptName)
        resetBuffer();


        emitProlog(coderScriptName);
        emitConfiguration();
        newBuffer();

        emitInputDefinitions();
        emitGlobalDefinitions();

        emitBlobStoreIfNeeded(bufferIdx-1,coderScriptName);

        emitCompilerCommand();
    end








    function emitF2FCode(fixptScriptName,cfg,entryPoints)
        resetBuffer();


        emitF2FProlog(fixptScriptName);
        emitF2FConfiguration(cfg);
        newBuffer();

        emitF2FInputDefinitions(entryPoints);
        emitGlobalDefinitions();

        emitBlobStoreIfNeeded(bufferIdx-1,f2fScriptName);

        emitF2FCompilerCommand(entryPoints);
    end


    function newBuffer()
        bufferIdx=bufferIdx+1;
        buffers{end+1}='';
    end


    function resetBuffer()
        buffers={''};
        bufferIdx=1;
    end


    function emit(fmt,varargin)
        buffers{bufferIdx}=sprintf(['%s',fmt],buffers{bufferIdx},varargin{:});
    end


    function writeScript(filePath)
        fid=openFile(filePath);
        fprintf(fid,'%s\n',strjoin(buffers,''));
        if fid~=1
            fclose(fid);
        end
    end


    function[fid]=openFile(filePath)
        if~isempty(filePath)
            [fid,fopenMsg]=fopen(filePath,'W');
            if fid==-1
                error(message('Coder:configSet:CannotOpenProjectTocodeScript',filePath,fopenMsg));
            end
            if~isempty(filePath)
                clear(filePath);
            end
        else
            fid=1;
        end
    end


    function emitF2FProlog(scriptName)
        name='Untitled';
        if~isempty(scriptName)
            [~,name,~]=fileparts(scriptName);
        end
        if isempty(name)
            name='Untitled';
        end
        inputFiles='';
        for epIndex=1:numel(CC.Project.EntryPoints)
            entryPoint=CC.Project.EntryPoints(epIndex);
            if isempty(inputFiles)
                inputFile=entryPoint.Name;
            else
                inputFile=[', ',entryPoint.Name];
            end
            inputFiles=[inputFiles,inputFile];%#ok<AGROW>
        end
        titleID='Coder:configSet:FixedPointConversionProjectTocodeTitle';
        title=message(titleID,upper(name),inputFiles);
        emit('%% ');
        emitComment(title,true);

        [~,name,ext]=fileparts(projectFileName);
        prolog=message('Coder:configSet:ProjectTocodeProlog',[name,ext],date());
        emit('%% \n%% ');
        emitComment(prolog,true);

        emit('%% \n%% ');
        if isFixedPointConverterProject()
            epilog=message('Coder:configSet:FixedPointConverterProjectTocodeEpilog');
        else
            epilog=message('Coder:configSet:ProjectTocodeEpilog');
        end
        emitComment(epilog,true);
        emit('\n');
    end


    function emitProlog(scriptName)
        name='Untitled';
        if~isempty(scriptName)
            [~,name,~]=fileparts(scriptName);
        end
        if isempty(name)
            name='Untitled';
        end
        outputfile=CC.Options.outputfile;
        inputFiles='';
        for epIndex=1:numel(CC.Project.EntryPoints)
            entryPoint=CC.Project.EntryPoints(epIndex);
            if isempty(inputFiles)
                inputFile=entryPoint.Name;
            else
                inputFile=[', ',entryPoint.Name];
            end
            inputFiles=[inputFiles,inputFile];%#ok<AGROW>
        end
        titleID='';
        switch class(CC.ConfigInfo)
        case{'coder.CodeConfig','coder.EmbeddedCodeConfig'}
            switch upper(CC.ConfigInfo.OutputType)
            case 'LIB'
                titleID='Coder:configSet:ProjectTocodeLIBTitle';
            case 'DLL'
                titleID='Coder:configSet:ProjectTocodeDLLTitle';
            case 'EXE'
                titleID='Coder:configSet:ProjectTocodeEXETitle';
            end
        otherwise
        end
        if isempty(titleID)
            titleID='Coder:configSet:ProjectTocodeMEXTitle';
        end
        title=message(titleID,upper(name),outputfile,inputFiles);
        emit('%% ');
        emitComment(title,true);

        [~,name,ext]=fileparts(projectFileName);
        prolog=message('Coder:configSet:ProjectTocodeProlog',[name,ext],date());
        emit('%% \n%% ');
        emitComment(prolog,true);

        emit('%% \n%% ');
        epilog=message('Coder:configSet:ProjectTocodeEpilog');
        emitComment(epilog,true);
        emit('\n');
    end


    function emitComment(msg,continuation)
        if nargin<2
            continuation=false;
        end
        if~continuation
            emit('%s ','%%');
        end

        comment=sprintf('%s',msg.getString());
        lineWidth=80-2;
        nextBreak=lineWidth;
        lastPrinted=1;
        [s,e]=regexp(comment,'\S+');
        for i2=1:numel(s)
            if e(i2)>nextBreak&&(e(i2)-s(i2)<lineWidth)
                emit('\n%%  %s',comment(s(i2):e(i2)));
                nextBreak=nextBreak+lineWidth;
            else
                emit('%s',comment(lastPrinted:e(i2)));
            end
            lastPrinted=e(i2)+1;
        end
        emit('\n');
    end


    function result=cellPropToString(prop)
        result=cell(1,numel(prop));
        for i=1:numel(prop)
            result{i}=propToString(prop{i});
        end
    end


    function string=propToString(prop)
        switch class(prop)
        case 'char'
            meta={'%','\\','\n','\t',''''};
            if~all(cellfun('isempty',regexp(prop,meta,'once')))
                safe={'%%','\\\\','\\n','\\t',''''''};
                string=regexprep(prop,meta,safe);
                string=sprintf('sprintf(''%s'')',string);
            else
                string=sprintf('''%s''',prop);
            end
        case 'logical'
            if prop
                string='true';
            else
                string='false';
            end
        case 'cell'
            string=cellPropToString(prop);
        case 'string'
            string=mat2str(prop);
        otherwise
            string=num2str(prop);
        end
    end


    function emitprop(path,propName,propValue)
        if any(strcmp(propName,{'CustomInclude','CustomSource','CustomLibrary'}))



            propValue=cellstr(split(propValue,newline));
            propValue=strip(propValue,'"');
        end
        dispValue=propToString(propValue);
        lhs=sprintf('%s.%s',path,propName);
        if~iscell(dispValue)
            emit('%s = %s;\n',lhs,dispValue);
        else
            N=numel(dispValue);
            indent=repmat(' ',1,numel(lhs)+4);
            for i=1:N
                string=dispValue{i};
                if i==1
                    emit('%s = { %s',lhs,string);
                else
                    emit('%s %s',indent,string);
                end

                if i==N
                    emit(' };\n');
                else
                    emit(', ...\n');
                end
            end
        end
    end


    function emitConfigurationObject(path,cfgActual,cfgRootDefault)
        if isempty(cfgRootDefault)
            coderConfigFactory=rootConfigFactory;
        else
            coderConfigFactory='coder.config';
        end
        extraProps={};

        switch class(cfgActual)
        case 'coder.MexCodeConfig'
            if coderapp.internal.globalconfig('JavaFreePrjParser')
                unconvertable=strcmp(CC.Project.CodingTarget,'mex');
            else
                artifact=CC.JavaConfig.getParamAsString('param.artifact');
                unconvertable=strcmp(artifact,'option.target.artifact.mex.instrumented');
            end
            if unconvertable
                error(message('Coder:configSet:CannotConvertProjectType',class(cfgActual)));
            end
            emit('%s = %s(''mex'');\n',path,coderConfigFactory);
            cfgDefault=feval(coderConfigFactory,'mex');%#ok<FVAL>
            metaSubIndex=metaIndex.Main;
        case 'coder.CodeConfig'
            outputType=lower(cfgActual.OutputType);
            emit('%s = %s(''%s'',''ecoder'',false);\n',path,coderConfigFactory,outputType);
            cfgDefault=feval(coderConfigFactory,outputType,'ecoder',false);%#ok<FVAL>
            metaSubIndex=metaIndex.Main;
            extraProps={'Hardware'};
        case 'coder.EmbeddedCodeConfig'
            outputType=lower(cfgActual.OutputType);
            emit('%s = %s(''%s'',''ecoder'',true);\n',path,coderConfigFactory,outputType);
            cfgDefault=feval(coderConfigFactory,outputType,'ecoder',true);%#ok<FVAL>
            metaSubIndex=metaIndex.Main;
            extraProps={'Hardware'};

            if~isempty(cfgActual.Hardware)


                if isa(cfgActual.Hardware,'coder.Hardware')||...
                    isa(cfgActual.Hardware,'coder.internal.Hardware')

                    cfgDefault.Hardware=emlcprivate('projectCoderHardware',cfgActual.Hardware.Name);
                else
                    cfgDefault.Hardware=cfgActual.Hardware;
                end
            end
        case 'coder.GpuCodeConfig'
            if~isempty(cfgRootDefault)&&isprop(cfgRootDefault,'GpuConfig')&&~isempty(cfgRootDefault.GpuConfig)



                cfgDefault=cfgRootDefault.GpuConfig;
            else
                emit('\n%%%% Create configuration object of class ''coder.GpuCodeConfig''.\n');
                emit('%s = coder.GpuCodeConfig;\n',path);
                cfgDefault=coder.GpuCodeConfig;
            end
            metaSubIndex=metaIndex.Gpu;
        case 'coder.HardwareImplementation'
            shouldEmit=true;
            if~isempty(cfgRootDefault)&&isprop(cfgRootDefault,'HardwareImplementation')
                cfgDefault=cfgRootDefault.HardwareImplementation;
                if~isempty(cfgRootDefault.HardwareImplementation)



                    shouldEmit=false;
                end
            else
                cfgDefault=coder.HardwareImplementation;
            end
            metaSubIndex=metaIndex.HardwareImpl;

            if shouldEmit
                emit('%s = coder.HardwareImplementation;\n',path);
            end




            if~cfgActual.ProdEqTarget
                emitprop(path,'ProdEqTarget',false);
                cfgDefault.ProdEqTarget=false;
            end
            if~strcmp(cfgDefault.ProdHWDeviceType,cfgActual.ProdHWDeviceType)
                emitprop(path,'ProdHWDeviceType',cfgActual.ProdHWDeviceType);
                cfgDefault.ProdHWDeviceType=cfgActual.ProdHWDeviceType;
            end
            if~strcmp(cfgDefault.TargetHWDeviceType,cfgActual.TargetHWDeviceType)
                emitprop(path,'TargetHWDeviceType',cfgActual.TargetHWDeviceType);
                cfgDefault.TargetHWDeviceType=cfgActual.TargetHWDeviceType;
            end
        case 'coder.HdlConfig'
            emit('%s = coder.config(''hdl'');\n',path);
            cfgDefault=coder.config('hdl');
            metaSubIndex=[];
        case 'coder.ReplacementTypes'
            cfgDefault=cfgRootDefault.ReplacementTypes;
            metaSubIndex=metaIndex.ReplacementTypes;
        otherwise
            if isa(cfgActual,'coder.DeepLearningConfigBase')
                emit(sprintf('\n%%%% Create a configuration object of class ''%s''.\n',class(cfgActual)));
                emit('%s = coder.DeepLearningConfig(''TargetLibrary'', ''%s'');\n',path,cfgActual.TargetLibrary);
                cfgDefault=coder.DeepLearningConfig('TargetLibrary',cfgActual.TargetLibrary);
                metaSubIndex=metaIndex.DeepLearning;
            else
                error(message('Coder:configSet:CannotConvertProjectType',class(cfgActual)));
            end
        end

        if isempty(cfgRootDefault)
            cfgRootDefault=cfgDefault;
        end
        if~isempty(metaSubIndex)

            propsToPrint=cellfun(@(key)metaSubIndex.oldKeyToProp(key),metaSubIndex.OrderedOldKeys,UniformOutput=false);


            subObjProps=cellfun(@metaSubIndex.newKeyToProp,vertcat({},metaSubIndex.SubObjects.ProductionKey),UniformOutput=false);
            propsToPrint=[
            reshape(extraProps,[],1)
            subObjProps(~cellfun('isempty',subObjProps))
propsToPrint
            ];


            propsToPrint=intersect(propsToPrint,...
            metaIndex.getMutablePublicProperties(cfgActual),'stable');
        else


            propsToPrint=properties(cfgActual);
        end

        for i=1:numel(propsToPrint)
            propName=propsToPrint{i};
            actual=cfgActual.(propName);
            default=cfgDefault.(propName);

            shouldPrint=~isequal(actual,default)||(strcmp(propName,'Hardware')&&isa(actual,'coder.HardwareBase'));
            if shouldPrint
                if isa(actual,'coder.HardwareImplementation')||isa(actual,'coder.DeepLearningConfigBase')||isa(actual,'coder.ReplacementTypes')
                    innerPath=[path,'.',propName];
                    if~isempty(actual)
                        emitConfigurationObject(innerPath,actual,cfgRootDefault);
                    elseif strcmp(propName,'DeepLearningConfig')
                        emit('%s = coder.DeepLearningConfigBase.empty();\n',innerPath);
                    end
                elseif isa(actual,'coder.HardwareBase')
                    innerPath=[path,'.',propName];
                    emitTargetHardwareObject(innerPath,actual);
                elseif isa(actual,'coder.GpuCodeConfig')&&~isempty(actual)
                    innerPath=[path,'.',propName];
                    emitConfigurationObject(innerPath,actual,cfgRootDefault);
                else
                    emitprop(path,propName,actual);
                end
            end
        end

        if isprop(cfgActual,'GpuConfig')&&...
            isempty(find(strcmp(properties(cfgActual),'GpuConfig'),1))&&...
            ~isempty(cfgActual.GpuConfig)&&...
            cfgActual.GpuConfig.Enabled
            innerPath=[path,'.GpuConfig'];
            emitConfigurationObject(innerPath,cfgActual.GpuConfig,cfgRootDefault);
        end
    end


    function emitF2FConfiguration(cfg)
        emitComment(message('Coder:configSet:ProjectTocodeConfig',class(cfg)));
        emit('%s',coder.internal.fixptConfigToScript(cfg));
        emit('\n');
    end


    function emitConfiguration()
        emitConfigurationScript(CC.ConfigInfo);
    end


    function emitConfigurationScript(cfg)
        emitComment(message('Coder:configSet:ProjectTocodeConfig',class(cfg)));
        emitConfigurationObject('cfg',cfg,[]);
        emit('\n');
    end


    function emitInputDefinitions()
        emitInputDefinitionsScript(CC.Project.EntryPoints);
    end


    function emitF2FInputDefinitions(entryPoints)
        emitInputDefinitionsScript(entryPoints);
    end


    function emitInputDefinitionsScript(entryPoints)
        haveArgs=false;
        for epIndex=1:numel(entryPoints)
            entryPoint=entryPoints(epIndex);
            niTc=numel(entryPoint.InputTypes);
            if niTc>0
                emitComment(message('Coder:configSet:ProjectTocodeArgs',entryPoint.Name));
                if~haveArgs
                    emit('ARGS = cell(%d,1);\n',numel(entryPoints));
                    haveArgs=true;
                end
                emit('ARGS{%d} = cell(%d,1);\n',epIndex,niTc);
                emitEntryPointInputDefinitions(epIndex,entryPoint.InputTypes);
                emit('\n');
            end
        end
    end


    function emitEntryPointInputDefinitions(epIndex,epInputTypes)
        for itcIndex=1:numel(epInputTypes)
            itc=epInputTypes{itcIndex};
            path=sprintf('ARGS{%d}{%d}',epIndex,itcIndex);
            emitInputDefinition(path,itc);
        end
    end


    function emitInputDefinition(path,itc)
        if isa(itc,'coder.Constant')
            emitConstantCos(path,itc);
        else
            emitCommonDefinition(path,itc);
        end
    end


    function emitCommonDefinition(path,itc)
        switch class(itc)
        case 'coder.PrimitiveType'
            emitPrimitiveTypeCos(path,itc);
        case 'coder.StructType'
            emitStructTypeCos(path,itc);
        case 'coder.CellType'
            emitCellTypeCos(path,itc);
        case 'coder.FiType'
            emitFiTypeCos(path,itc);
        case 'coder.EnumType'
            emitEnumTypeCos(path,itc);
        case 'coder.ClassType'
            emitClassTypeCos(path,itc);
        case 'coder.StringType'
            emitStringTypeCos(path,itc);
        case 'coder.OutputType'
            emitOutputTypeCos(path,itc);
        otherwise
            assert(false);
        end
    end


    function emitGlobalDefinitions()
        nGdp=numel(CC.Project.InitialGlobalValues);
        if nGdp>0
            emitComment(message('Coder:configSet:ProjectTocodeGlobals'));
            emit('GLOBALS = cell(%d,2);\n',nGdp);
            for gdpIndex=1:nGdp

                path=sprintf('GLOBALS{%d,1}',gdpIndex);
                gType=CC.Project.InitialGlobalValues{gdpIndex};
                K=gType.InitialValue;
                if~isempty(K)&&isa(K,'coder.Constant')
                    emitConstantCos(path,K);
                else
                    emitCommonDefinition(path,gType);
                end

                valueExpr=getValueExpression(gType);
                if~isempty(valueExpr)||~isempty(gType.Value)
                    path=sprintf('GLOBALS{%d,2}',gdpIndex);
                    emit('%s = %s;\n',path,valueExpr);
                end
            end
            emit('\n');
        end
    end


    function emitWorkingFolderCmd()
        if isempty(CC.Project.OutDirectory)
            return;
        end
        if~strcmp(scriptFolder,CC.Project.OutDirectory)
            workingFolder=CC.Project.OutDirectory;
            emit('cd(''%s'');\n',workingFolder);
        end
    end


    function is=isSimpleScalar(itc)
        is=false;
        if nnz(itc.VariableDims)
            return;
        end
        if numel(itc.SizeVector)~=2
            return;
        end
        is=(itc.SizeVector(1)==1)&&(itc.SizeVector(2)==1);
    end


    function sizeStr=sizeToString(itc)
        function y=normalize(u)
            y=regexprep(u,old,new);
        end
        old={'  ',num2str(intmax('int32'))};
        new={' ','Inf'};
        sizeStr=normalize(['[',num2str(itc.SizeVector),']']);
        if any(itc.VariableDims)
            sizeDynamic=normalize(['[',num2str(itc.VariableDims),']']);
            sizeStr=sprintf('%s,%s',sizeStr,sizeDynamic);
        end
    end


    function emitWithSize(path,itc,type)
        isGpu='';
        if isprop(itc,'Gpu')&&itc.Gpu
            isGpu=',''Gpu'',true';
        end
        if isSimpleScalar(itc)
            typeof=sprintf('coder.typeof(%s%s)',type,isGpu);
        else
            sizeStr=sizeToString(itc);
            typeof=sprintf('coder.typeof(%s,%s%s)',type,sizeStr,isGpu);
        end
        emit('%s = %s;\n',path,typeof);
    end


    function emitConstantCos(path,itc)
        type='';
        if~isempty(itc.ValueConstructor)
            value=evalin('base',itc.ValueConstructor);
            if isa(value,'coder.Type')
                type=itc.ValueConstructor;
            end
        end
        if isempty(type)
            type=sprintf('coder.Constant(%s)',getValueExpression(itc));
        end
        emit('%s = %s;\n',path,type);
    end


    function emitPrimitiveTypeCos(path,itc)
        if itc.Complex
            zero='1i';
        else
            zero='0';
        end
        if strcmp(itc.ClassName,'logical')
            type=sprintf('false');
        elseif strcmp(itc.ClassName,'char')
            type=sprintf('''X''');
        elseif strcmp(itc.ClassName,'double')
            type=sprintf('%s',zero);
        else
            type=sprintf('%s(%s)',itc.ClassName,zero);
        end
        if itc.Sparse
            type=sprintf('sparse(%s)',type);
        end
        emitWithSize(path,itc,type);
    end


    function emitCellTypeCos(path,itc)
        if itc.isHomogeneous()
            h=itc.makeHomogeneous();
            if isempty(h.Cells)
                T=coder.typeof([]);
            else
                T=h.Cells{1};
            end




            argName=['ARG_',num2str(nestedArgNameId)];
            nestedArgNameId=nestedArgNameId+1;

            emitInputDefinition(argName,T);
            emit(['%s = coder.typeof({',argName,'}, %s);\n'],path,sizeToString(itc));
        else
            proxyName=convertPathToIdentifier(path);
            emit('%s = cell(%s);\n',proxyName,sizeToString(itc));
            for cellIndex=1:numel(itc.Cells)
                cellItc=itc.Cells{cellIndex};
                cellPath=sprintf('%s{%d}',proxyName,cellIndex);
                emitInputDefinition(cellPath,cellItc);
            end
            emitWithSize(path,itc,proxyName);
            emit('%s = %s.makeHeterogeneous();\n',path,path);
            emitCStructName(path,itc);
        end
    end


    function emitStructTypeCos(path,itc)
        proxyName=convertPathToIdentifier(path);
        emit('%s = struct;\n',proxyName);
        fieldNames=fieldnames(itc.Fields);
        for fldIndex=1:numel(fieldNames)
            fldItc=itc.Fields.(fieldNames{fldIndex});
            fldPath=sprintf('%s.%s',proxyName,fieldNames{fldIndex});
            emitInputDefinition(fldPath,fldItc);
        end
        emitWithSize(path,itc,proxyName);
        emitCStructName(path,itc);
    end

    function[str]=convertPathToIdentifier(path)
        str=regexprep(path,'}{','_');
        str=regexprep(str,'[{,\.]','_');
        str=regexprep(str,'(\d+)}','$1');



        if(strlength(str)>maxVariableLength)
            oldStr=extractBetween(str,maxVariableLength-4,strlength(str));
            newStr='_'+string(varExceedingLength);
            str=replace(str,oldStr,newStr);
            str=regexprep(str,'__','_');
            varExceedingLength=varExceedingLength+1;
        end
    end


    function emitCStructName(path,itc)
        function appendCStructName(what)
            if~isempty(cStructName)
                cStructName=[cStructName,','];
            end
            cStructName=[cStructName,what];
        end


        cStructName='';
        if~isempty(itc.TypeName)
            appendCStructName(propToString(itc.TypeName));
        end
        if itc.Extern
            appendCStructName('''extern''');
        end
        if~isempty(itc.HeaderFile)
            appendCStructName('''HeaderFile''');
            appendCStructName(propToString(itc.HeaderFile));
        end
        if itc.Alignment~=-1
            appendCStructName('''Alignment''');
            appendCStructName(propToString(itc.Alignment));
        end
        if~isempty(cStructName)
            emit('%s = coder.cstructname(%s,%s);\n',path,path,cStructName);
        end
    end


    function emitFiTypeCos(path,itc)
        T=itc.NumericType.tostring;
        if itc.Complex
            zero='1i';
        else
            zero='0';
        end
        if isa(itc.Fimath,'embedded.fimath')
            indent=repmat(' ',1,numel(path)+3);
            F=itc.Fimath.tostring;
            F=regexprep(F,'\n',['\n',indent]);
            type=sprintf('fi(%s,%s,%s)',zero,T,F);
        else
            type=sprintf('fi(%s,%s)',zero,T);
        end
        emitWithSize(path,itc,type);
    end


    function emitEnumTypeCos(path,itc)
        e=eval(sprintf('?%s',itc.ClassName));
        if~isempty(e)&&~isempty(e.EnumerationMemberList)
            eName=e.EnumerationMemberList(1).Name;
            type=sprintf('%s.%s',itc.ClassName,eName);
            emitWithSize(path,itc,type);
        else
            type=sprintf('''%s''',itc.ClassName);
            if isSimpleScalar(itc)
                typeof=sprintf('coder.newtype(%s)',type);
            else
                sizeStr=sizeToString(itc);
                typeof=sprintf('coder.newtype(%s,%s)',type,sizeStr);
            end
            emit('%s = %s;\n',path,typeof);
        end
    end


    function emitClassTypeCos(path,itc)
        className=sprintf('''%s''',itc.ClassName);
        newtype=sprintf('coder.newtype(%s)',className);




        if coder.type.Base.hasCustomCoderType(itc.ClassName)
            fmt='%s = %s.getCoderType();\n';
        else
            fmt='%s = %s;\n';
        end

        emit(fmt,path,newtype);

        propNames=fieldnames(itc.Properties);
        for i=1:length(propNames)
            propPath=sprintf('%s.Properties.%s',path,propNames{i});
            propItc=itc.Properties.(propNames{i});
            emitInputDefinition(propPath,propItc);
        end
    end



    function emitStringTypeCos(path,itc)
        newtype=sprintf('coder.newtype(''%s'')','string');

        emit('%s = %s;\n',path,newtype);
        emit('%s.StringLength = %d;\n',path,itc.Properties.Value.SizeVector(2));
        emit('%s.VariableStringLength = %d;\n',path,itc.Properties.Value.VariableDims(2));
    end


    function emitOutputTypeCos(path,itc)
        emit('%s = coder.OutputType(''%s'', %d);\n',path,itc.FunctionName,itc.OutputIndex);
    end


    function globals=constructGlobalsArg()
        globals='';
        nGdp=numel(CC.Project.InitialGlobalValues);
        if nGdp>0
            globals='-globals {';
            for gdpIndex=1:nGdp
                if gdpIndex>1
                    globals=sprintf('%s, ',globals);
                end
                gdp=CC.Project.InitialGlobalValues{gdpIndex};
                if~isempty(gdp.ValueConstructor)
                    globals=sprintf('%s''%s'',GLOBALS(%d,:)',...
                    globals,gdp.Name,gdpIndex);
                else
                    globals=sprintf('%s''%s'',GLOBALS{%d,1}',...
                    globals,gdp.Name,gdpIndex);
                end
            end
            globals=[globals,'}'];
        end
    end


    function outputFile=constructOutputFileArg()
        outputFile='';
        if~isempty(CC.Options.outputfile)
            if isa(CC.ConfigInfo,'coder.MexConfig')
                entryPointNames=cell(numel(CC.Project.EntryPoints),1);
                for i=1:numel(CC.Project.EntryPoints)
                    entryPointNames{i}=CC.Project.EntryPoints(i).Name;
                end
                entryPointNames=unique(entryPointNames);
                defaultName=[entryPointNames{1},'_mex'];
            else
                defaultName=CC.Project.EntryPoints(1).Name;
            end
            if~strcmp(defaultName,CC.Options.outputfile)
                outputFile=CC.Options.outputfile;
            end
        end
    end


    function outputDir=constructOutputDirArg()
        outputDir='';
        if~isempty(CC.Options.LogDirectory)
            defaultDir=CC.nameLogDir(CC.Options.ProjectRoot);
            if~strcmp(CC.Options.LogDirectory,defaultDir)
                outputDir=CC.Options.LogDirectory;
                if contains(outputDir,' ')
                    outputDir=['''',outputDir,''''];
                end
            end
        end
    end


    function outputDir=constructF2FOutputDirArg()
        outputDir='';
        if CC.codingHDL()



            if~strcmp(CC.Options.defaultCodegenFolder,CC.Options.actualCodegenFolder)
                outputDir=CC.Options.actualCodegenFolder;
            end
        else
            outputDir=constructOutputDirArg();
        end
    end


    function includeDirs=constructIncludeDirsArg()
        searchPaths=CC.Project.SearchPath;
        includeDirs=textscan(searchPaths,'%s','Delimiter',pathsep);
        if~isempty(includeDirs)

            workingFolder=CC.Project.OutDirectory;
            includeDirs=includeDirs{1};
            for i=1:numel(includeDirs)
                includeDir=includeDirs{i};
                if strcmp(includeDir,workingFolder)
                    includeDirs{i}=[];
                elseif contains(includeDir,' ')
                    includeDirs{i}=sprintf('''%s''',includeDir);
                end
            end
            includeDirs=includeDirs(~cellfun(@isempty,includeDirs));
            includeDirs=unique(includeDirs,'stable');
        end
    end


    function entryPointsStr=constructEntryPointsArg(entryPoints)
        entryPointsStr='';
        for epIndex=1:numel(entryPoints)
            if~isempty(entryPointsStr)
                entryPointsStr=[entryPointsStr,' '];%#ok<AGROW>
            end
            entryPoint=entryPoints(epIndex);
            if numel(entryPoint.InputTypes)>0
                entryPointsStr=sprintf('%s%s -args ARGS{%d}',...
                entryPointsStr,entryPoint.Name,epIndex);
            else
                entryPointsStr=sprintf('%s%s',entryPointsStr,entryPoint.Name);
            end

            if entryPoint.HasUserNumOutputs
                entryPointsStr=sprintf('%s -nargout %d',entryPointsStr,entryPoint.UserNumOutputs);
            end
        end
    end


    function emitCompilerCommand()
        emitComment(message('Coder:configSet:ProjectTocodeInvokeCompiler'));


        emitWorkingFolderCmd();


        entryPointsStr=constructEntryPointsArg(CC.Project.EntryPoints);

        emitCommand(entryPointsStr);
    end


    function emitF2FCompilerCommand(entryPoints)
        emitComment(message('Coder:configSet:ProjectTocodeInvokeF2FCompiler'));


        emitWorkingFolderCmd();


        entryPointsStr=constructEntryPointsArg(entryPoints);

        emitF2FCommand(entryPointsStr);
    end


    function emitF2FCommand(entryPoints)

        globals=constructGlobalsArg();


        outputDir=constructF2FOutputDirArg();


        includeDirs=constructIncludeDirsArg();


        if strcmpi(CC.ClientType,'fiaccel')
            emit('fiaccel ');
        else
            emit('codegen ');
        end
        if~isempty(extraCmdLineArg)
            emit('%s ',extraCmdLineArg);
        end
        emit('-float2fixed cfg ');
        if~isempty(globals)
            emit('%s ',globals);
        end
        if~isempty(outputDir)
            emit('-d %s ',outputDir);
        end
        if~isempty(includeDirs)
            for i=1:numel(includeDirs)
                emit('-I %s ',includeDirs{i});
            end
        end
        emit('%s\n',entryPoints);
    end


    function emitCommand(entryPoints)

        globals=constructGlobalsArg();


        outputFile=constructOutputFileArg();


        outputDir=constructOutputDirArg();


        includeDirs=constructIncludeDirsArg();


        emit('codegen ');
        if~isempty(extraCmdLineArg)
            emit('%s ',extraCmdLineArg);
        end
        emit('-config cfg ');
        if(isSinglesConversionEnabled())
            emit('-singleC ');
        end
        if~isempty(globals)
            emit('%s ',globals);
        end
        if~isempty(outputFile)
            emit('-o %s ',outputFile);
        end
        if~isempty(outputDir)
            emit('-d %s ',outputDir);
        end
        if~isempty(includeDirs)
            for i=1:numel(includeDirs)
                emit('-I %s ',includeDirs{i});
            end
        end
        emit('%s\n',entryPoints);
    end


    function emitTargetHardwareObject(path,cfgActual)
        schema=emlcprivate('copyProjectTargetSettings','tocode',cfgActual,CC.JavaConfig);
        emit('%s = coder.hardware(''%s'');\n',path,schema.Name);
        cellfun(@(prop)emitprop(path,prop,schema.Settings(prop)),schema.Settings.keys());
    end


    function emitBlobStoreIfNeeded(insertionIdx,owningScriptName)
        if isempty(blobs)
            return;
        end

        if nargin<2||isempty(owningScriptName)
            blobFileName='values.mat';
        else
            [~,owningScriptName]=fileparts(owningScriptName);
            blobFileName=[owningScriptName,'_values.mat'];
        end

        blobFile=fullfile(scriptFolder,blobFileName);
        count=0;
        while isfile(blobFile)
            count=count+1;
            blobFile=fullfile(scriptFolder,sprintf('%s%d.mat',blobFileName,count));
        end
        allValues=blobs;
        save(blobFile,'allValues');

        [~,blobFile,ext]=fileparts(blobFile);
        blobFile=[blobFile,ext];

        curBufIdx=bufferIdx;
        bufferIdx=insertionIdx;
        emitComment(message('Coder:common:CliToAppScriptBlobDesc'));
        emit('assert(isfile(''%s''), ...\n%s''%s'');\n',blobFile,repmat(' ',1,4),...
        message('Coder:common:CliToAppScriptBlobAssert',blobFile).getString());
        emit('load(''%s'', ''%s'');\n\n',blobFile,blobVarName);
        bufferIdx=curBufIdx;
    end


    function valueExpr=getValueExpression(ity)
        if~isempty(ity.ValueConstructor)
            valueExpr=ity.ValueConstructor;
            if numel(valueExpr)<600
                return;
            end
        end

        if isa(ity,'coder.Constant')
            blobs{end+1}=ity.Value;
        else
            blobs{end+1}=ity.InitialValue;
        end
        valueExpr=sprintf('%s{%d}',blobVarName,numel(blobs));
    end
end
