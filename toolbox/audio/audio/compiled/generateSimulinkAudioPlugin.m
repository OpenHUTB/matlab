function generateSimulinkAudioPlugin(myPlugin,varargin)

























    coder.internal.errorIf(~isa(myPlugin,'audioPlugin'),'audio:plugin:NotAnAudioPlugin')

    if nargin==1
        className='audioSimulinkSysObj';
    else
        className=varargin{1};
    end

    nameOrPath=convertStringsToChars(className);
    [filePath,className]=fileparts(nameOrPath);
    coder.internal.errorIf(~isvarname(className),...
    'audio:plugin:InvalidFunctionName')

    if nargin<=2

        openClass=true;
    else
        openClass=varargin{2};
    end

    isExternalPlugin=isa(myPlugin,'externalAudioPlugin')||isa(myPlugin,'externalAudioPluginSource');
    if isExternalPlugin
        myaudioPluginInterface=audio.app.internal.AudioPluginHandler.getExternalPluginInterface(myPlugin);
        pluginName=info(myPlugin).PluginPath;
        cglapfuncname=sprintf('%sPluginLoader',className);
        cglapfuncname=truncateStringToMaxLength(cglapfuncname,'Left');
    else
        if ismember('PluginInterface',properties(myPlugin))
            myaudioPluginInterface=myPlugin.PluginInterface;
        else
            myaudioPluginInterface.PluginName=class(myPlugin);
            myaudioPluginInterface.Parameters=[];
            myaudioPluginInterface.InputChannels=[];
            myaudioPluginInterface.OutputChannels=[];
        end
        pluginName=class(myPlugin);
    end


    classGenerator=sigutils.internal.emission.MatlabClassGenerator(className);
    classGenerator.Name=className;
    classGenerator.Path=filePath;
    H1Line=sprintf('%s\n',myaudioPluginInterface.PluginName);
    t=datetime('now','TimeZone','local','Format','dd-MMM-yyyy HH:mm:ss ZZZZ');
    H1Line=sprintf('%s\n %%\tCreated by generateSimulinkAudioPlugin on %s\n',H1Line,string(t));
    classGenerator.H1Line=H1Line;
    classGenerator.RCSRevisionAndDate=false;
    classGenerator.TimeStampInHeader=false;
    isSource=isa(myPlugin,'audioPluginSource')||isa(myPlugin,'externalAudioPluginSource');
    if isSource
        classGenerator.SuperClasses={'matlab.System'};
    else
        classGenerator.SuperClasses={'audio.internal.SampleRateEngine'};
    end

    pluginParameters=myaudioPluginInterface.Parameters;


    if~isempty(pluginParameters)
        pluginPropNames=fieldnames(pluginParameters);
    else
        pluginPropNames=[];
    end


    isEnumProperty=zeros(1,length(pluginPropNames));
    skipTunablePort=zeros(1,length(pluginPropNames));
    skipProperty=zeros(1,length(pluginPropNames));

    if isExternalPlugin
        paramsInfo=getParameterAnalysis(myPlugin);
    end

    for index=1:length(pluginPropNames)
        propName=pluginPropNames{index};
        enums=pluginParameters.(propName).Enums;
        isEnumProperty(index)=~isempty(enums);

        if(isEnumProperty(index)&&length(enums)==1&&isempty(enums{:}))||(isExternalPlugin&&(~paramsInfo(index).Monotonicity&&paramsInfo(index).IsNumeric))

            skipProperty(index)=1;
            continue
        end

        if isEnumProperty(index)
            skipTunablePort(index)=(~isenum(myPlugin.(propName))&&~islogical(myPlugin.(propName)));
        end
    end



    classGenerator=addPluginParametersAsProperties(classGenerator,...
    myPlugin,...
    myaudioPluginInterface,...
    isExternalPlugin,...
    pluginPropNames,...
    pluginParameters,...
    isEnumProperty,...
    skipProperty);




    for index=1:length(pluginPropNames)
        if skipTunablePort(index)||skipProperty(index)
            continue;
        end
        propName=pluginPropNames{index};




        tempPropName=[propName,'PortPaceHolder',num2str(index)];
        prop=sigutils.internal.emission.PropertyDef(tempPropName);
        prop.InitValue='false';
        prop.Attributes='Nontunable';
        propDisplay=pluginParameters.(propName).DisplayName;
        prop.H1Line=sprintf('Specify %s from input port',propDisplay);
        classGenerator.addProperty(prop);
    end


    counter=1;
    for index=1:length(pluginPropNames)
        if skipTunablePort(index)||skipProperty(index)
            continue;
        end
        propName=pluginPropNames{index};
        prop=sigutils.internal.emission.PropertyDef([propName,'Set']);
        propVal=sprintf('matlab.system.SourceSet({''PropertyOrInput'',''SystemBlock'',''%s'',%d,''%s''})',[propName,'Port'],counter,propName);
        counter=counter+1;
        prop.InitValue=propVal;
        prop.Attributes={'Constant','Hidden'};
        classGenerator.addProperty(prop);
    end


    if isSource
        prop=sigutils.internal.emission.PropertyDef('SamplesPerFrame');
        prop.InitValue=num2str(getSamplesPerFrame(myPlugin));
        prop.Attributes='Nontunable';
        prop.H1Line=sprintf('Samples per frame');
        classGenerator.addProperty(prop);
    end


    if isSource
        prop=sigutils.internal.emission.PropertyDef('OutputDataType');
        prop.InitValue='''double''';
        prop.Attributes='Nontunable';
        prop.H1Line=sprintf('Output data type');
        classGenerator.addProperty(prop);
    end


    if~isSource

        prop=sigutils.internal.emission.PropertyDef('pSampleRateDialog');
        prop.Attributes='Access = protected';
    else
        prop=sigutils.internal.emission.PropertyDef('SampleRate');
        prop.Attributes='Nontunable';
    end
    prop.InitValue=num2str(getSampleRate(myPlugin));
    prop.H1Line=sprintf('Sample rate (Hz)');
    classGenerator.addProperty(prop);



    prop=sigutils.internal.emission.PropertyDef('privObj');
    prop.Attributes='Access = private';
    classGenerator.addProperty(prop);


    mthd=sigutils.internal.emission.MatlabMethodGenerator(className);
    mthd.OutputArgs={'obj'};
    if isExternalPlugin
        objStr=sprintf('obj.privObj = %s(''%s'');\n',cglapfuncname,pluginName);
    else
        objStr=sprintf('obj.privObj = %s;\n',pluginName);
    end
    mthd.addCode(objStr);
    classGenerator.addMethod(mthd);


    if isSource
        mthd=sigutils.internal.emission.MatlabMethodGenerator('getSampleTimeImpl');
        mthd.InputArgs='obj';
        mthd.OutputArgs='st';
        mthd.Attributes='Access = protected';
        objStr=sprintf('st = createSampleTime(obj,''Type'',''Discrete'',''SampleTime'',obj.SamplesPerFrame/obj.SampleRate);\n');
        mthd.addCode(objStr);
        classGenerator.addMethod(mthd);
    end


    mthd=sigutils.internal.emission.MatlabMethodGenerator('setupImpl');
    if isSource
        mthd.InputArgs='obj';
    else
        mthd.InputArgs={'obj','u'};
    end
    mthd.Attributes='Access = protected';
    if~isSource
        objStr=sprintf('setupImpl@audio.internal.SampleRateEngine(obj,u)\n');
    else
        objStr=sprintf('setSamplesPerFrame(obj.privObj,obj.SamplesPerFrame);\n');
    end
    objStr=sprintf('%ssetSampleRate(obj.privObj,obj.SampleRate);\n',objStr);

    for index=1:length(pluginPropNames)
        if skipProperty(index)
            continue
        end
        prop=pluginPropNames{index};
        if skipTunablePort(index)
            objStr=sprintf('%sobj.privObj.%s = obj.%s;\n',objStr,prop,prop);
        else
            objStr=sprintf('%sif ~(obj.%sPort)\n',objStr,prop);
            if islogical(myPlugin.(prop))
                objStr=sprintf('%s\tif obj.%s == audio.internal.FalseTrueEnum.false\n',objStr,prop);
                objStr=sprintf('%s\t\tobj.privObj.%s = false;\n',objStr,prop);
                objStr=sprintf('%s\telse\n',objStr);
                objStr=sprintf('%s\t\tobj.privObj.%s = true;\n',objStr,prop);
                objStr=sprintf('%s\tend\n',objStr);
            else
                objStr=sprintf('%s\tobj.privObj.%s = obj.%s;\n',objStr,prop,prop);
            end
            objStr=sprintf('%send\n',objStr);
        end
    end
    mthd.addCode(objStr);
    classGenerator.addMethod(mthd);


    if ismember('reset',methods(myPlugin))
        mthd=sigutils.internal.emission.MatlabMethodGenerator('resetImpl');
        mthd.InputArgs='obj';
        mthd.Attributes='Access = protected';
        mthd.addCode(sprintf('reset(obj.privObj)'));
        classGenerator.addMethod(mthd);
    end


    mthd=sigutils.internal.emission.MatlabMethodGenerator('stepImpl');
    mthd.Attributes='Access = protected';
    numInChans=myaudioPluginInterface.InputChannels;
    if isempty(numInChans)
        numInputs=1;
    else
        numInputs=length(numInChans);
    end
    numOutChans=myaudioPluginInterface.OutputChannels;
    if isempty(numOutChans)
        numOutputs=1;
    else
        numOutputs=length(numOutChans);
    end

    if~isExternalPlugin||isSource

        if~isSource
            mthd.InputArgs=repmat({''},1,numInputs+1);
            mthd.InputArgs{1}='obj';
            for index=1:numInputs
                mthd.InputArgs{index+1}=sprintf('u%d',index);
            end
        else
            mthd.InputArgs={'obj'};
        end

        out_str='';
        if numOutputs==1
            mthd.OutputArgs={'y'};
            out_str='y';
        else
            mthd.OutputArgs=repmat({''},1,numOutputs);
            for index=1:numOutputs
                mthd.OutputArgs{index}=sprintf('y%d',index);
                out_str=sprintf('%sy%d, ',out_str,index);
            end
            out_str=['[',out_str(1:end-1),']'];
        end
        if~isSource
            if isa(myPlugin,'matlab.System')
                str=sprintf('%s = step(obj.privObj',out_str);
            else
                str=sprintf('%s = process(obj.privObj',out_str);
                if isExternalPlugin
                    str=sprintf('%s1 = process(obj.privObj',out_str);
                end
            end
            for index=1:numInputs
                str=sprintf('%s, u%d',str,index);
            end
            str=sprintf('%s);\n',str);
            if isExternalPlugin
                for index=1:numInputs
                    str=sprintf('%s %s = %s1(1:size(u%d,1),1:%d);\n',str,out_str,out_str,index,numOutChans);
                end
            end
            mthd.addCode(sprintf(str));
        else
            if isa(myPlugin,'matlab.System')
                str=sprintf('%s = obj.privObj();\n',strrep(out_str,'y','z'));
            else
                str=sprintf('%s = process(obj.privObj);\n',strrep(out_str,'y','z'));
            end


            if numOutputs==1
                str=sprintf('%s y = cast(z(1:obj.SamplesPerFrame,1:%d),obj.OutputDataType);\n',str,numOutChans);
            else
                for index=1:numOutputs
                    str=sprintf('%s y%d = cast(z%d(1:obj.SamplesPerFrame,1:%d),obj.OutputDataType);\n',str,index,index,numOutChans);
                end
            end
            mthd.addCode(sprintf(str));
        end
    else
        mthd=sigutils.internal.emission.MatlabMethodGenerator('stepImpl');
        mthd.Attributes='Access = protected';

        numInChans=myaudioPluginInterface.InputChannels;
        numOutChans=myaudioPluginInterface.OutputChannels;

        mthd.InputArgs={'obj','u1'};
        mthd.OutputArgs={'y'};

        str=sprintf('y1 = process(obj.privObj,u1);\n');
        str=sprintf('%s y = y1(1:size(u1,1),1:%d);',str,numOutChans);
        mthd.addCode(sprintf(str));
    end
    classGenerator.addMethod(mthd);


    if length(pluginPropNames)>=1
        mthd=sigutils.internal.emission.MatlabMethodGenerator('processTunedPropertiesImpl');
        mthd.Attributes='Access = protected';
        mthd.InputArgs='obj';
        if~isSource
            objStr=sprintf('processTunedPropertiesImpl@audio.internal.SampleRateEngine(obj)\n');
        else
            objStr='';
        end
        count=1;
        for index=1:length(pluginPropNames)
            if skipProperty(index)
                continue
            end

            prop=pluginPropNames{index};
            objStr=sprintf('%sval%d = obj.privObj.%s;\n',objStr,count,prop);
            count=count+1;
        end
        count=1;
        for index=1:length(pluginPropNames)
            if skipProperty(index)
                continue
            end
            prop=pluginPropNames{index};
            objStr=sprintf('%s if (val%d ~= obj.%s)\n',objStr,count,prop);
            if islogical(myPlugin.(prop))
                objStr=sprintf('%s\tif obj.%s == audio.internal.FalseTrueEnum.false\n',objStr,prop);
                objStr=sprintf('%s\t\tobj.privObj.%s = false;\n',objStr,prop);
                objStr=sprintf('%s\telse\n',objStr);
                objStr=sprintf('%s\t\tobj.privObj.%s = true;\n',objStr,prop);
                objStr=sprintf('%s\tend\n',objStr);
            else
                objStr=sprintf('%s\tobj.privObj.%s = obj.%s;\n',objStr,prop,prop);
            end
            objStr=sprintf('%send\n',objStr);
            count=count+1;
        end
        mthd.addCode(objStr);
        classGenerator.addMethod(mthd);
    end


    mthd=sigutils.internal.emission.MatlabMethodGenerator('supportsMultipleInstanceImpl');
    mthd.Attributes='Access = protected';
    mthd.InputArgs='~';
    mthd.OutputArgs='f';
    mthd.addCode(sprintf('f = true;\n'));
    classGenerator.addMethod(mthd);


    mthd=sigutils.internal.emission.MatlabMethodGenerator('saveObjectImpl');
    mthd.Attributes='Access = protected';
    mthd.InputArgs='obj';
    mthd.OutputArgs='s';
    if isSource
        mthd.addCode(sprintf('s = saveObjectImpl@matlab.System(obj);'));
    else
        mthd.addCode(sprintf('s = saveObjectImpl@audio.internal.SampleRateEngine(obj);'));
    end
    mthd.addCode(sprintf('if isLocked(obj)'));
    if isa(myPlugin,'matlab.System')
        mthd.addCode(sprintf('  s.privObj = matlab.System.saveObject(obj.privObj);'));
    else
        mthd.addCode(sprintf('  s.privObj = saveobj(obj.privObj);'));
    end
    mthd.addCode(sprintf('end'));
    classGenerator.addMethod(mthd);


    mthd=sigutils.internal.emission.MatlabMethodGenerator('loadObjectImpl');
    mthd.Attributes='Access = protected';
    mthd.InputArgs={'obj','s','wasLocked'};
    mthd.addCode(sprintf('if wasLocked'));
    if isa(myPlugin,'matlab.System')
        mthd.addCode(sprintf('  obj.privObj = matlab.System.loadObject(s.privObj);'));
    else
        mthd.addCode(sprintf('  obj.privObj = %s.loadobj(s.privObj);',class(myPlugin)));
    end
    mthd.addCode(sprintf('end'));
    if isSource
        mthd.addCode(sprintf('loadObjectImpl@matlab.System(obj,s,wasLocked);'));
    else
        mthd.addCode(sprintf('loadObjectImpl@audio.internal.SampleRateEngine(obj,s,wasLocked);'));
    end
    classGenerator.addMethod(mthd);


    mthd=sigutils.internal.emission.MatlabMethodGenerator('isOutputComplexImpl');
    mthd.Attributes='Access = protected';
    mthd.InputArgs='~';
    mthd.OutputArgs='varargout';
    for index=1:numOutputs
        mthd.addCode(sprintf('varargout{%d} = false;\n',index));
    end
    classGenerator.addMethod(mthd);

    if~isSource
        mthd=sigutils.internal.emission.MatlabMethodGenerator('getOutputSizeImpl');
        mthd.Attributes='Access = protected';
        mthd.InputArgs='obj';
        mthd.OutputArgs='varargout';
        if~isempty(numOutChans)
            addInputsizeLine=true;
            for index=1:numOutputs
                if(isempty(numInChans))||(~isempty(numInChans)&&numOutChans(index)~=numInChans(1))
                    if addInputsizeLine
                        mthd.addCode(sprintf('sz0 = propagatedInputSize(obj, 1);\n'));
                        addInputsizeLine=false;
                    end
                    mthd.addCode(sprintf('varargout{%d} = [sz0(1) %d];\n',index,numOutChans(index)));
                else
                    mthd.addCode(sprintf('varargout{%d} = propagatedInputSize(obj, 1);\n',index));
                end
            end
        else
            mthd.addCode(sprintf('varargout{1} = propagatedInputSize(obj, 1);\n'));
        end
        classGenerator.addMethod(mthd);

        mthd=sigutils.internal.emission.MatlabMethodGenerator('getOutputDataTypeImpl');
        mthd.Attributes='Access = protected';
        mthd.InputArgs='obj';
        mthd.OutputArgs='varargout';
        for index=1:numOutputs
            mthd.addCode(sprintf('varargout{%d} = propagatedInputDataType(obj, 1);\n',index));
        end
        classGenerator.addMethod(mthd);

        mthd=sigutils.internal.emission.MatlabMethodGenerator('isOutputFixedSizeImpl');
        mthd.Attributes='Access = protected';
        mthd.InputArgs='obj';
        mthd.OutputArgs='varargout';
        for index=1:numOutputs
            mthd.addCode(sprintf('varargout{%d} = propagatedInputFixedSize(obj, 1);\n',index));
        end
        classGenerator.addMethod(mthd);
    else
        mthd=sigutils.internal.emission.MatlabMethodGenerator('getOutputSizeImpl');
        mthd.Attributes='Access = protected';
        mthd.InputArgs='obj';
        mthd.OutputArgs='varargout';
        if~isempty(numOutChans)
            for index=1:numOutputs
                mthd.addCode(sprintf('varargout{%d} = [obj.SamplesPerFrame %d];\n',index,numOutChans(index)));
            end
        else
            mthd.addCode(sprintf('varargout{1} = [obj.SamplesPerFrame 1];\n'));
        end
        classGenerator.addMethod(mthd);

        mthd=sigutils.internal.emission.MatlabMethodGenerator('isOutputFixedSizeImpl');
        mthd.Attributes='Access = protected';
        mthd.InputArgs='~';
        mthd.OutputArgs='varargout';
        for index=1:numOutputs
            mthd.addCode(sprintf('varargout{%d} = true;\n',index));
        end
        classGenerator.addMethod(mthd);

        mthd=sigutils.internal.emission.MatlabMethodGenerator('getOutputDataTypeImpl');
        mthd.Attributes='Access = protected';
        mthd.InputArgs='obj';
        mthd.OutputArgs='varargout';
        for index=1:numOutputs
            mthd.addCode(sprintf('varargout{%d} = obj.OutputDataType;\n',index));
        end
        classGenerator.addMethod(mthd);
    end


    mthd=sigutils.internal.emission.MatlabMethodGenerator('getOutputNamesImpl');
    mthd.Attributes='Access = protected';
    mthd.InputArgs='~';
    mthd.OutputArgs='varargout';
    if numOutputs==1
        mthd.addCode(sprintf('varargout{1} = '''';\n'));
    else
        for index=1:numOutputs
            mthd.addCode(sprintf('varargout{%d} = ''y%d'';\n',index,index));
        end
    end
    classGenerator.addMethod(mthd);


    if~isSource
        mthd=sigutils.internal.emission.MatlabMethodGenerator('getInputNamesImpl');
        mthd.Attributes='Access = protected';
        if numInputs==1


            condition='';
            for index=1:length(pluginPropNames)
                if~skipTunablePort(index)&&~skipProperty(index)
                    propName=pluginPropNames{index};
                    condition=sprintf('%s obj.%sPort ||',condition,propName);
                end
            end
            if~isempty(condition)
                mthd.InputArgs='obj';
                condition=sprintf('if (%s)',condition(1:end-3));
                mthd.addCode(sprintf('%s\n',condition));
                mthd.addCode(sprintf('\tvarargout{1} = ''x'';'));
                mthd.addCode(sprintf('else\n'));
                mthd.addCode(sprintf('\tvarargout{1} = '''';'));
                mthd.addCode(sprintf('end\n'));
            else
                mthd.InputArgs='~';
                mthd.addCode(sprintf('varargout{1} = '''';'));
            end
        else
            mthd.InputArgs='~';
            for index=1:numInputs
                mthd.addCode(sprintf('varargout{%d} = ''x%d'';\n',index,index));
            end
        end
        mthd.OutputArgs='varargout';
        classGenerator.addMethod(mthd);
    end


    mthd=sigutils.internal.emission.MatlabMethodGenerator('getPropertyGroupsImpl');
    mthd.Attributes='Access = protected, Static';
    mthd.OutputArgs='group';
    str=sprintf('group =  matlab.system.display.Section(...\n');
    str=sprintf('%s''Title'', getString(message(''dsp:system:Shared:Parameters'')), ...\n',str);
    str=sprintf('%s''PropertyList'', {...\n',str);
    for index=1:length(pluginPropNames)
        if skipProperty(index)
            continue
        end
        prop=pluginPropNames{index};
        if~skipTunablePort(index)
            str=sprintf('%s''%s'' ',str,[prop,'Port']);
        end
        str=sprintf('%s''%s'' ',str,prop);
    end
    if isSource
        str=sprintf('%s''%s'' ',str,'SamplesPerFrame');
        str=sprintf('%s''%s'' ',str,'OutputDataType');
        dependentProps='{';
    else
        str=sprintf('%s''%s'' ',str,'InheritSampleRate');
        dependentProps='{''SampleRate''';
    end
    str=sprintf('%s''%s'' ',str,'SampleRate');
    str=sprintf('%s},...\n',str);
    dependentProps=sprintf('%s }',dependentProps);
    str=sprintf('%s''DependOnPrivatePropertyList'',%s);\n',str,dependentProps);
    mthd.addCode(str);
    classGenerator.addMethod(mthd);


    if~isempty(filePath)
        cl=audio.testbench.internal.model.ObjectUnderTestHandler.getPackagedClassName(filePath,className);
    else
        cl=className;
    end
    mthd=sigutils.internal.emission.MatlabMethodGenerator('getHeaderImpl');
    mthd.Attributes='Access = protected, Static';
    mthd.OutputArgs='header';
    str=sprintf('header =  matlab.system.display.Header(''%s'', ...\n',cl);
    str=sprintf('%s''ShowSourceLink'', true, ''Title'',''%s'', ...\n',str,cl);
    description=sprintf('getString(message(''audio:plugin:PluginSimulinkBlockHeaderDesc'', ''%s'',''%s''))',pluginName,cl);
    str=sprintf('%s''Text'', %s);\n ',str,description);
    mthd.addCode(str);
    classGenerator.addMethod(mthd);


    writeFile(classGenerator,0);

    filename=[fullfile(filePath,className),'.m'];
    str=fileread(filename);
    overwrite=false;


    for index=1:length(pluginPropNames)
        if skipTunablePort(index)||skipProperty(index)
            continue;
        end
        propName=pluginPropNames{index};


        oldString=[propName,'PortPaceHolder',num2str(index)];
        newString=sprintf('%sPort (1,1) logical',propName);
        str=strrep(str,oldString,newString);
        overwrite=true;
    end


    [str,overwrite]=replacePlaceholderPropertiesWithActualProperties(str,...
    overwrite,...
    myPlugin,...
    pluginPropNames,...
    pluginParameters,...
    skipProperty,...
    isEnumProperty,...
    skipTunablePort);


    if isSource
        newOutputDataType='OutputDataType (1,:) char {mustBeMember(OutputDataType,{''double'' ''single''})} = ''double''';
        str=strrep(str,'OutputDataType = ''double''',newOutputDataType);
        overwrite=true;
    end

    if overwrite
        writelines(str,filename,'WriteMode','overwrite');
    end

    if openClass
        edit(filename)
    end



    if isExternalPlugin
        cgExtAudioPluginClassName=sprintf('%sInterface',className);
        cgExtAudioPluginClassName=truncateStringToMaxLength(cgExtAudioPluginClassName,'Left');
        jucehostCallerClassName='externalAudioPluginSimulink';
        jucehostCallerMethodName='loadPluginBinary';
        LAPFuncGenerator=sigutils.internal.emission.MatlabFunctionGenerator(cglapfuncname);
        LAPFuncGenerator.Name=cglapfuncname;
        H1Line=sprintf('%s\n',myaudioPluginInterface.PluginName);
        H1Line=sprintf('%s\n %%\tCreated by generateSimulinkAudioPlugin for the generated system object %s on %s\n',H1Line,className,string(t));
        LAPFuncGenerator.H1Line=H1Line;
        LAPFuncGenerator.RCSRevisionAndDate=false;
        LAPFuncGenerator.TimeStampInHeader=false;
        LAPFuncGenerator.Path=filePath;
        LAPFuncGenerator.InputArgs={'pluginPath'};
        LAPFuncGenerator.OutputArgs={'plugin'};
        codeStr=sprintf('coder.allowpcode(''plain'');\n');
        codeStr=sprintf('%s if coder.target("MATLAB")\n',codeStr);
        codeStr=sprintf('%s plugin = loadAudioPlugin(%s);\n',codeStr,LAPFuncGenerator.InputArgs{1});
        codeStr=sprintf('%s else\n',codeStr);
        codeStr=sprintf('%s %s = %s.%s(%s);\n',codeStr,'inst',jucehostCallerClassName,jucehostCallerMethodName,LAPFuncGenerator.InputArgs{1});
        codeStr=sprintf('%s plugin = %s(%s,%s);',codeStr,cgExtAudioPluginClassName,LAPFuncGenerator.InputArgs{1},'inst');
        LAPFuncGenerator.addCode(codeStr);
        writeFile(LAPFuncGenerator);


        pcode(fullfile(classGenerator.Path,cglapfuncname),'-inplace');
        mFileName=fullfile(classGenerator.Path,sprintf('%s.m',cglapfuncname));
        LAPFuncDeleter=onCleanup(@()delete(mFileName));
    end


    if isExternalPlugin
        paramsInfo=getParameterAnalysis(myPlugin);
        pluginTablesFileName=sprintf('%s%s.mat',className,'Tables');
        pluginTablesFileName=truncateStringToMaxLength(pluginTablesFileName,'Left');

        for index=1:numel(pluginPropNames)
            parameterAnalysis=rmfield(paramsInfo(index),'MetaProperty');%#ok: Assigned to 'TablesOf_propertyName' variable
            tableVariableName=sprintf('%sTables',pluginPropNames{index});
            tableVariableName=truncateStringToMaxLength(tableVariableName,'Left');
            eval(sprintf('%s = %s;',tableVariableName,'parameterAnalysis'));
            if index==1
                save(pluginTablesFileName,tableVariableName);
            else
                save(pluginTablesFileName,tableVariableName,'-append');
            end
        end
    end


    if isExternalPlugin
        EAPClassGenerator=sigutils.internal.emission.MatlabClassGenerator(cgExtAudioPluginClassName);
        EAPClassGenerator.Name=cgExtAudioPluginClassName;
        EAPClassGenerator.Path=filePath;
        H1Line=sprintf('%s\n',myaudioPluginInterface.PluginName);
        H1Line=sprintf('%s\n %%\tCreated by generateSimulinkAudioPlugin for the generated system object %s on %s\n',H1Line,className,string(t));
        EAPClassGenerator.H1Line=H1Line;
        EAPClassGenerator.RCSRevisionAndDate=false;
        EAPClassGenerator.TimeStampInHeader=false;

        if isSource
            EAPClassGenerator.SuperClasses={'constantExternalAudioPluginSource'};
        else
            EAPClassGenerator.SuperClasses={'constantExternalAudioPlugin'};
        end


        EAPClassGenerator=addPluginParametersAsProperties(EAPClassGenerator,...
        myPlugin,...
        myaudioPluginInterface,...
        isExternalPlugin,...
        pluginPropNames,...
        pluginParameters,...
        isEnumProperty,...
        skipProperty);


        pluginParameters=myaudioPluginInterface.Parameters;
        if~isempty(pluginParameters)
            pluginPropNames=fieldnames(pluginParameters);
        else
            pluginPropNames=[];
        end
        for index=1:numel(pluginPropNames)
            if skipProperty(index)
                continue;
            end
            tableVariableName=sprintf('%sTables',pluginPropNames{index});
            tableVariableName=truncateStringToMaxLength(tableVariableName,'Left');
            prop=sigutils.internal.emission.PropertyDef(tableVariableName);
            prop.Attributes={'Constant','Hidden'};
            prop.InitValue=sprintf('coder.load(''%s'', ''%s'');',pluginTablesFileName,tableVariableName);
            EAPClassGenerator.addProperty(prop);
        end


        jucehostCallerMethodName='setSimulinkAudioPlugin';
        mthd=sigutils.internal.emission.MatlabMethodGenerator(cgExtAudioPluginClassName);
        mthd.InputArgs={'pluginPath','pluginInstance'};
        mthd.OutputArgs={'plugin'};
        strCode=sprintf('%s.%s(%s,%s,%s);',jucehostCallerClassName,jucehostCallerMethodName,'pluginPath','pluginInstance','plugin');
        mthd.addCode(strCode);
        EAPClassGenerator.addMethod(mthd);


        for index=1:numel(pluginPropNames)
            if skipProperty(index)
                continue;
            end
            mthdName=sprintf('set.%s',pluginPropNames{index});
            mthd=sigutils.internal.emission.MatlabMethodGenerator(mthdName);
            mthd.InputArgs={'plugin','value'};
            jucehostCallerMethodName='setProperty';
            tableVariableName=sprintf('%sTables',pluginPropNames{index});
            tableVariableName=truncateStringToMaxLength(tableVariableName,'Left');
            propTable=sprintf('%s.%s.%s','plugin',tableVariableName,tableVariableName);
            strCode=sprintf('%s.%s(%s,%s,%d,%s);',jucehostCallerClassName,jucehostCallerMethodName,'plugin',propTable,index,'value');
            mthd.addCode(strCode);
            EAPClassGenerator.addMethod(mthd);
        end


        for index=1:numel(pluginPropNames)
            if skipProperty(index)
                continue;
            end
            mthdName=sprintf('get.%s',pluginPropNames{index});
            mthd=sigutils.internal.emission.MatlabMethodGenerator(mthdName);
            mthd.InputArgs={'plugin'};
            mthd.OutputArgs={'paramValue'};
            jucehostCallerMethodName='getPropertyDisplayValue';
            pnum=sprintf('%d',index);
            strCode=sprintf('%s = %s.%s(%s,%s);','paramValue',jucehostCallerClassName,jucehostCallerMethodName,'plugin.PluginInstance',pnum);
            mthd.addCode(strCode);
            EAPClassGenerator.addMethod(mthd);
        end


        writeFile(EAPClassGenerator,0);

        filename=[fullfile(filePath,cgExtAudioPluginClassName),'.m'];
        fileContent=fileread(filename);
        overwrite=false;

        [fileContent,overwrite]=replacePlaceholderPropertiesWithActualProperties(fileContent,...
        overwrite,...
        myPlugin,...
        pluginPropNames,...
        pluginParameters,...
        skipProperty,...
        isEnumProperty,...
        skipTunablePort);
        if overwrite
            writelines(fileContent,filename,'WriteMode','overwrite');
        end
    end
end

function valS=getValueString(obj,prop)

    propVal=obj.(prop);
    if isa(propVal,'char')
        valS=propVal;
        return;
    end
    if isenum(propVal)
        valS=[class(propVal),'.',char(propVal)];
        return;
    end
    if isnumeric(propVal)

        valS=dsp.internal.compactButAccurateMat2Str(propVal);
        return;
    end
    if islogical(propVal)
        if propVal
            valS='true';
        else
            valS='false';
        end
        return;
    end
end

function str=getH1Line(param,isExternalPlugin,myPlugin)
    name=param.DisplayName;
    if isempty(name)
        name=param.Property;
    end
    label=param.Label;

    if~isExternalPlugin
        minVal=param.Min;
        maxVal=param.Max;
    else
        paramsInfo=getParameterAnalysis(myPlugin);
        [~,ind]=intersect({paramsInfo.PropertyName},param.Property);
        p=paramsInfo(ind);
        minVal=p.Min;
        maxVal=p.Max;
    end

    str=name;
    if~isempty(minVal)&&isempty(param.Enums)
        if~isempty(label)
            str_comment=sprintf('Plugin range [%s %s] %s',num2str(minVal),num2str(maxVal),label);
        else
            str_comment=sprintf('Plugin range [%s %s]',num2str(minVal),num2str(maxVal));
        end
    else
        str_comment=label;
    end
    if~isempty(str_comment)
        str=sprintf('%s (%s)',str,str_comment);
    end

end
function classGenerator=addPluginParametersAsProperties(classGenerator,...
    myPlugin,...
    myaudioPluginInterface,...
    isExternalPlugin,...
    pluginPropNames,...
    pluginParameters,...
    isEnumProperty,...
    skipProperty)







    meta=eval(['?',class(myPlugin)]);
    metaProps=meta.PropertyList;

    for index=1:length(pluginPropNames)

        propName=pluginPropNames{index};

        enums=pluginParameters.(propName).Enums;
        isEnumProperty(index)=~isempty(enums);

        if skipProperty(index)
            continue
        end

        h1Line=getH1Line(myaudioPluginInterface.Parameters.(propName),isExternalPlugin,myPlugin);

        if isEnumProperty(index)

            if~isExternalPlugin
                [~,propInd]=intersect({metaProps.Name},propName);
                myMetaProp=metaProps(propInd);
                def=myMetaProp.DefaultValue;
                if isenum(def)&&~isenum(myPlugin.(propName))




                    if ischar(myPlugin.(propName))||isstring(myPlugin.(propName))
                        myPlugin.(propName)=eval(sprintf('%s.%s',class(def),char(myPlugin.(propName))));
                    else
                        enumMeta=eval(sprintf('?%s',class(def)));
                        enumNames={enumMeta.EnumerationMemberList.Name};
                        myPlugin.(propName)=eval(sprintf('%s.%s',class(def),enumNames{myPlugin.(propName)}));
                    end
                end
            end





            propName=[propName,'TempPlaceholder',num2str(index)];%#ok
        end

        prop=sigutils.internal.emission.PropertyDef(propName);
        prop.H1Line=h1Line;

        if isempty(enums)
            prop.InitValue=getValueString(myPlugin,propName);
        end
        classGenerator.addProperty(prop);
    end
end

function[fileContent,...
    overwrite]=replacePlaceholderPropertiesWithActualProperties(fileContent,...
    overwrite,...
    myPlugin,...
    pluginPropNames,...
    pluginParameters,...
    skipProperty,...
    isEnumProperty,...
    skipTunablePort)







    for index=1:length(pluginPropNames)
        if skipProperty(index)||~isEnumProperty(index)
            continue
        end
        prop=pluginPropNames{index};
        oldName=[prop,'TempPlaceholder',num2str(index)];

        enums=pluginParameters.(prop).Enums;

        if~skipTunablePort(index)
            if isenum(myPlugin.(prop))


                newName=sprintf('%s (1,1) %s = %s.%s',prop,class(myPlugin.(prop)),class(myPlugin.(prop)),char(myPlugin.(prop)));
            elseif islogical(myPlugin.(prop))
                if myPlugin.(prop)
                    v='true';
                else
                    v='false';
                end
                newName=sprintf('%s (1,1) audio.internal.FalseTrueEnum = audio.internal.FalseTrueEnum.%s',prop,v);
            end
            fileContent=strrep(fileContent,oldName,newName);
            overwrite=true;
        else


            newName=sprintf('%s (1,:) char {mustBeMember(%s,{',prop,prop);
            for index2=1:size(enums,1)
                val=strtrim(enums(index2,:));
                if iscell(val)
                    val=val{:};
                end
                newName=sprintf('%s''%s'' ',newName,val);
            end
            defaultVal=getValueString(myPlugin,prop);

            if~ismember(defaultVal,enums)
                defaultVal=enums{1};
            end
            newName=sprintf('%s})} = ''%s''',newName,defaultVal);
            fileContent=strrep(fileContent,oldName,newName);
            overwrite=true;
        end
    end
end

function out=truncateStringToMaxLength(in,truncateFrom)
    inputLength=strlength(in);
    maximumPossibleLength=namelengthmax;
    if inputLength>maximumPossibleLength
        out=char(in);
        numOfExtraChars=inputLength-maximumPossibleLength;
        if strcmp(truncateFrom,'Left')==true
            out=sprintf('%s',out(numOfExtraChars+1:end));
        else
            out=sprintf('%s',out(1:maximumPossibleLength));
        end
    else
        out=in;
    end
end


