classdef SysMex<handle

    properties(Hidden,Access=private)

mexFile

files

props
    end

    methods



        function output=SM_get(obj,name)
            index=find(strcmp(name,obj.props.propNames));
            if isempty(index)
                error('matlab:system:genericError','Undefined property: %s',name);
            else
                if~obj.props.gettableProps(index)
                    error('matlab:system:genericError','No permissions to get property: %s',name);
                end
                output=feval(obj.mexFile,obj.files.get{index});
            end
        end


        function SM_set(obj,name,value)
            index=find(strcmp(name,obj.props.propNames));
            if isempty(index)
                error('matlab:system:genericError','Undefined property: %s',name);
            else
                if~obj.props.settableProps(index)
                    error('matlab:system:genericError','No permissions to set property: %s',name);
                end
                feval(obj.mexFile,obj.files.set{index},value);
            end
        end

        function setupMex(obj,sysObj,varargin)

            obj.props=getProps(obj,sysObj);
            for p=1:length(obj.props.propNames)
                obj.props.propValues{end+1}=sysObj.(obj.props.propNames{p});
            end



            obj.files=getFileNames(obj,sysObj,obj.props,varargin);
            mexedFile=fullfile(obj.files.mexDir,[obj.files.mexFile,'.',mexext]);
            classFile=which(class(sysObj));

            try
                addpath(obj.files.mexDir,'-END');



                if~exist(mexedFile,'file')||...
                    matlab.system.SysMex.isNewer(classFile,mexedFile)
                    methodlist=generateFiles(obj,sysObj,obj.files,obj.props,varargin{:});
                    compile(obj,obj.files,methodlist);
                end



                obj.mexFile=str2func(obj.files.mexFile);
            catch err
                rmpath(obj.files.mexDir);
                rethrow(err);
            end
            rmpath(obj.files.mexDir);


            feval(obj.mexFile,obj.files.setup);
        end

        function varargout=stepMex(obj,varargin)
            [varargout{1:nargout}]=feval(obj.mexFile,obj.files.step,varargin{:});
        end

        function resetMex(obj)
            feval(obj.mexFile,obj.files.reset);
        end

        function releaseMex(obj)

            feval(obj.mexFile,obj.files.release);

            clear(obj.files.mexFile);

            obj.mexFile=[];
        end

        function s=getDiscreteStateMex(obj)
            s=feval(obj.mexFile,obj.files.getDiscreteState);
        end

        function setDiscreteStateMex(obj,s)
            feval(obj.mexFile,obj.files.setDiscreteState,s);
        end

        function validatePropertiesMex(obj)
            feval(obj.mexFile,obj.files.validateProperties);
        end

        function flag=isDoneMex(obj)
            flag=feval(obj.mexFile,obj.files.isDone);
        end

        function varargout=outputMex(obj,varargin)
            [varargout{1:nargout}]=feval(obj.mexFile,obj.files.output,varargin{:});
        end

        function updateMex(obj,varargin)
            feval(obj.mexFile,obj.files.update,varargin{:});
        end
    end

    methods(Access=protected)
        function props=getProps(~,sysObj)

            classname=class(sysObj);
            props.numProps=0;
            props.propNames={};
            props.numTunableProps=0;
            props.tunableProps=[];
            props.numGettableProps=0;
            props.gettableProps=[];
            props.numSettableProps=0;
            props.settableProps=[];
            props.state=[];
            ignoreList={'Description','props','files'};
            mc=meta.class.fromName(classname);
            mps=mc.Properties;
            for ii=1:length(mps)
                mp=mps{ii};
                if(isa(mp,'matlab.system.CustomMetaProp')&&...
                    ~ismember(mp.Name,ignoreList)&&...
                    ~iscell(mp.GetAccess)&&strcmp(mp.GetAccess,'public')&&...
                    ~strcmp(mp.Name,'isInMATLABSystemBlock'))
                    props.propNames{end+1}=mp.Name;
                    props.tunableProps(end+1)=~mp.Nontunable;
                    props.state(end+1)=mp.DiscreteState||mp.ContinuousState;
                    if~iscell(mp.SetAccess)&&strcmp(mp.SetAccess,'public')&&...
                        ~props.state(end)
                        props.settableProps(end+1)=true;
                        props.numSettableProps=props.numSettableProps+1;
                    else
                        props.settableProps(end+1)=false;
                    end
                    if~iscell(mp.GetAccess)&&strcmp(mp.GetAccess,'public')&&~strcmp(mp.Name,'GraphNode')
                        props.gettableProps(end+1)=true;
                        props.numGettableProps=props.numGettableProps+1;
                    else
                        props.gettableProps(end+1)=false;
                    end
                end
            end
            props.numProps=length(props.propNames);
            props.numTunableProps=sum(props.tunableProps);
            props.propStr='';
            props.pvStr='';
            props.propValues={};
            for p=1:length(props.propNames)
                if props.settableProps(p)
                    if~isempty(props.propStr)
                        props.propStr=[props.propStr,','];
                        props.pvStr=[props.pvStr,','];
                    end
                    props.propStr=[props.propStr,props.propNames{p}];
                    props.pvStr=[props.pvStr,'''',props.propNames{p},''',','varargin{',sprintf('%d',p),'}'];
                end
            end
        end

        function files=getFileNames(~,sysObj,props,inputs)


            classname=class(sysObj);
            outputs={};
            valuesFile=matlab.system.SysMex.signatureHash(classname,outputs,inputs);
            foundMatch=false;
            files.mexValuesFile=[valuesFile,'.mat'];
            val=struct([]);
            if exist(fullfile(matlab.system.SysMex.getMexDir,files.mexValuesFile),'file')
                [~,inMemMexes]=inmem;

                cnt=load(fullfile(matlab.system.SysMex.getMexDir,files.mexValuesFile),'val');
                val=cnt.val;
                foundMatch=false;
                for match=1:length(val)

                    foundMatch=true;
                    if~all(cellfun(@(x)isempty(x),strfind(inMemMexes,val(match).SysMexFilename)));
                        foundMatch=false;
                        continue
                    end
                    for p=1:props.numProps
                        if~props.tunableProps(p)
                            continue
                        end
                        if~isequal(props.propValues{p},val(match).(props.propNames{p}))
                            foundMatch=false;
                            break
                        end
                    end

                    break
                end
            end
            if foundMatch

                file=val(match).SysMexFilename;
                tmpdir=fullfile(matlab.system.SysMex.getMexDir,file);
            else


                tmpdir=tempname(matlab.system.SysMex.getMexDir);
                mkdir(tmpdir);
                matlab.system.internal.FileDeleter.addDirs(tmpdir);
                [~,file]=fileparts(tmpdir);
                val(end+1).SysMexFilename=file;
                for p=1:props.numProps
                    if~props.tunableProps(p)
                        continue
                    end
                    val(end).(props.propNames{p})=props.propValues{p};
                end
                save(fullfile(matlab.system.SysMex.getMexDir,files.mexValuesFile),'val');
            end

            files.mexDir=tmpdir;
            files.mexSource=file;
            files.mexFile=[file,'_mex'];
            files.setup=[file,'_setup'];
            files.step=[file,'_step'];
            files.reset=[file,'_reset'];
            files.release=[file,'_release'];
            files.get={};
            files.set={};
            for p=1:props.numProps
                if props.gettableProps(p)
                    files.get{end+1}=[file,'_get_',props.propNames{p}];
                end
                if props.settableProps(p)
                    files.set{end+1}=[file,'_set_',props.propNames{p}];
                end
            end
            files.getDiscreteState=[file,'_getDiscreteState'];
            files.setDiscreteState=[file,'_setDiscreteState'];
            files.validateProperties=[file,'_validateProperties'];
            files.processTunedProperties=[file,'_processTunedProperties'];
            files.validateInputs=[file,'_validateInputs'];
            files.processInputSizeChange=[file,'_processInputSizeChange'];
            files.isDone=[file,'_isDone'];
            files.output=[file,'_output'];
            files.update=[file,'_update'];

            filesToDelete={...
            fullfile(matlab.system.SysMex.getMexDir,files.mexValuesFile),...
            fullfile(files.mexDir,[files.mexSource,'.m']),...
            fullfile(files.mexDir,[files.setup,'.m']),...
            fullfile(files.mexDir,[files.reset,'.m']),...
            fullfile(files.mexDir,[files.step,'.m']),...
            fullfile(files.mexDir,[files.release,'.m']),...
            fullfile(files.mexDir,[files.mexFile,'.',mexext]),...
            fullfile(files.mexDir,[files.mexValuesFile]),...
            fullfile(files.mexDir,[files.getDiscreteState,'.m']),...
            fullfile(files.mexDir,[files.setDiscreteState,'.m']),...
            fullfile(files.mexDir,[files.validateProperties,'.m']),...
            fullfile(files.mexDir,[files.isDone,'.m']),...
            fullfile(files.mexDir,[files.output,'.m']),...
            fullfile(files.mexDir,[files.update,'.m'])};
            for f=1:length(files.get)
                filesToDelete{end+1}=fullfile(files.mexDir,[files.get{f},'.m']);
            end
            for f=1:length(files.set)
                filesToDelete{end+1}=fullfile(files.mexDir,[files.set{f},'.m']);
            end
            matlab.system.internal.FileDeleter.addFiles(filesToDelete);
        end

        function methodlist=generateFiles(~,sysObj,files,props,varargin)

            if sysObj.getNumInputs
                inputComma=', ';
            else
                inputComma='';
            end
            if props.numSettableProps&&sysObj.getNumInputs
                propInputComma=', ';
            else
                propInputComma='';
            end


            inputStr='';
            for in=1:sysObj.getNumInputs
                inputStr=[inputStr,'uuu',int2str(in)];%#ok<*AGROW>
                if in~=sysObj.getNumInputs
                    inputStr=[inputStr,', '];
                end
            end
            constInputStr=strrep(inputStr,'uuu','ccc');


            outputStr='';
            for out=1:sysObj.getNumOutputs
                outputStr=[outputStr,'y',int2str(out)];
                if out~=sysObj.getNumOutputs
                    outputStr=[outputStr,', '];
                end
            end

            startOfSetupArgs=props.numSettableProps+1;
            endOfSetupArgs=props.numSettableProps+sysObj.getNumInputs;
            startOfFcnArgs=props.numSettableProps+sysObj.getNumInputs+1;
            endOfFcnArgs=props.numSettableProps+2*sysObj.getNumInputs;


            lines={};
            lines{end+1}=sprintf('function varargout = %s(action, varargin) %%#codegen',files.mexSource);
            lines{end+1}='persistent h';
            lines{end+1}='if isempty(h)';
            lines{end+1}=sprintf('    h = %s(%s);',class(sysObj),props.pvStr);
            lines{end+1}=sprintf('    setup(h, varargin{%d:%d});',startOfSetupArgs,endOfSetupArgs);
            lines{end+1}=sprintf('    reset(h);');
            lines{end+1}='end';
            lines{end+1}='';
            lines{end+1}='switch action';
            lines{end+1}='case ''get''';
            lines{end+1}=sprintf('  varargout{1} = get(h, varargin{%d});',startOfFcnArgs);
            lines{end+1}='case ''set''';
            lines{end+1}=sprintf('  set(h, varargin{%d}, varargin{%d});',startOfFcnArgs,startOfFcnArgs+1);
            lines{end+1}='case ''setup''';
            lines{end+1}=sprintf('  %%Setup has already been called at this point.');
            lines{end+1}='case ''step''';
            lines{end+1}=sprintf('  [varargout{1:nargout}] = step(h, varargin{%d:%d});',startOfFcnArgs,endOfFcnArgs);
            lines{end+1}='case ''reset''';
            lines{end+1}='  reset(h);';
            lines{end+1}='case ''release''';
            lines{end+1}='  release(h);';
            lines{end+1}='case ''getDiscreteState''';
            lines{end+1}='  varargout{1} = getDiscreteState(h);';
            lines{end+1}='case ''setDiscreteState''';
            lines{end+1}=sprintf('  setDiscreteState(h, varargin{%d});',startOfFcnArgs);
            lines{end+1}='case ''validateProperties''';
            lines{end+1}='  validateProperties(h);';
            lines{end+1}='case ''isDone''';
            lines{end+1}='  varargout{1} = isDone(h);';
            lines{end+1}='case ''output''';
            lines{end+1}=sprintf('  [varargout{1:nargout}] = output(h, varargin{%d:%d});',startOfFcnArgs,endOfFcnArgs);
            lines{end+1}='case ''update''';
            lines{end+1}=sprintf('  update(h, varargin{%d:%d});',startOfFcnArgs,endOfFcnArgs);
            lines{end+1}='otherwise';
            lines{end+1}='  error(''An unknown function was called.'');';
            lines{end+1}='end';
            printFile(files.mexDir,[files.mexSource,'.m'],lines);


            commonInputs=sprintf('%s%s%s',props.propStr,propInputComma,constInputStr);
            if isempty(commonInputs)
                commonComma='';
            else
                commonComma=', ';
            end


            lines={};
            lines{end+1}=sprintf('function %s(%s)',files.setup,commonInputs);
            lines{end+1}=sprintf('%s(''setup''%s);',files.mexSource,[commonComma,commonInputs]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.setup,'.m'],lines);


            lines={};
            if sysObj.getNumOutputs>0
                outStr=['[',outputStr,'] = '];
            else
                outStr='';
            end
            lines{end+1}=sprintf('function %s%s(%s%s)',outStr,files.step,commonInputs,[inputComma,inputStr]);
            lines{end+1}=sprintf('%s%s(''step''%s%s);',outStr,files.mexSource,[commonComma,commonInputs],[inputComma,inputStr]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.step,'.m'],lines);


            lines={};
            lines{end+1}=sprintf('function %s(%s)',files.reset,commonInputs);
            lines{end+1}=sprintf('%s(''reset''%s);',files.mexSource,[commonComma,commonInputs]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.reset,'.m'],lines);


            lines={};
            lines{end+1}=sprintf('function %s(%s)',files.release,commonInputs);
            lines{end+1}=sprintf('%s(''release''%s);',files.mexSource,[commonComma,commonInputs]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.release,'.m'],lines);


            getIndex=0;
            setIndex=0;
            for p=1:props.numProps
                if props.gettableProps(p)

                    getIndex=getIndex+1;
                    lines={};
                    lines{end+1}=sprintf('function value = %s(%s)',files.get{getIndex},commonInputs);
                    lines{end+1}=sprintf('  value = %s(''get'', %s''%s'');',files.mexSource,[commonInputs,commonComma],props.propNames{p});
                    lines{end+1}='end';
                    printFile(files.mexDir,[files.get{getIndex},'.m'],lines);
                end
                if props.settableProps(p)&&props.tunableProps(p)

                    setIndex=setIndex+1;
                    lines={};
                    lines{end+1}=sprintf('function %s(%svalue)',files.set{setIndex},[commonInputs,commonComma]);
                    lines{end+1}=sprintf('  %s(''set'', %s''%s'', value);',files.mexSource,[commonInputs,commonComma],props.propNames{p});
                    lines{end+1}='end';
                    printFile(files.mexDir,[files.set{setIndex},'.m'],lines);
                end
            end


            lines={};
            lines{end+1}=sprintf('function s = %s(%s)',files.getDiscreteState,commonInputs);
            lines{end+1}=sprintf('s = %s(''getDiscreteState''%s);',files.mexSource,[commonComma,commonInputs]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.getDiscreteState,'.m'],lines);

            lines={};
            lines{end+1}=sprintf('function %s(%s s)',files.setDiscreteState,[commonInputs,commonComma]);
            lines{end+1}=sprintf('%s(''setDiscreteState''%s, s);',files.mexSource,[commonComma,commonInputs]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.setDiscreteState,'.m'],lines);

            lines={};
            lines{end+1}=sprintf('function %s(%s)',files.validateProperties,commonInputs);
            lines{end+1}=sprintf('%s(''validateProperties''%s);',files.mexSource,[commonComma,commonInputs]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.validateProperties,'.m'],lines);

            lines={};
            lines{end+1}=sprintf('function d = %s(%s)',files.isDone,commonInputs);
            lines{end+1}=sprintf('d = %s(''isDone''%s);',files.mexSource,[commonComma,commonInputs]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.isDone,'.m'],lines);

            lines={};
            lines{end+1}=sprintf('function %s%s(%s%s)',outStr,files.output,commonInputs,[inputComma,inputStr]);
            lines{end+1}=sprintf('%s%s(''output''%s%s);',outStr,files.mexSource,[commonComma,commonInputs],[inputComma,inputStr]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.output,'.m'],lines);

            lines={};
            lines{end+1}=sprintf('function %s(%s%s)',files.update,commonInputs,[inputComma,inputStr]);
            lines{end+1}=sprintf('%s(''update''%s%s);',files.mexSource,[commonComma,commonInputs],[inputComma,inputStr]);
            lines{end+1}='end';
            printFile(files.mexDir,[files.update,'.m'],lines);


            constPropValues={};
            for p=1:length(props.propValues)
                if props.settableProps(p)
                    constPropValues{end+1}=coder.Constant(props.propValues{p});
                end
            end


            varS=logical([]);
            for v=1:length(varargin)
                varS(v)=sysObj.isInputSizeMutable(v);
            end


            inputTypes=getCoderTypes(varargin,varS,false);
            constInputTypes=getCoderTypes(varargin,varS,true);
            commonArgs=[constPropValues(:);constInputTypes(:)];


            h=clone(sysObj);
            h.accelerate(false);
            setup(h,varargin{:});
            reset(h);
            stateType=getCoderTypes({getDiscreteState(h)},false,false);
            clear('h');

            methodlist={...
            files.setup,'-args',commonArgs,...
            files.reset,'-args',commonArgs,...
            files.step,'-args',[commonArgs(:);inputTypes(:)],...
            files.release,'-args',commonArgs,...
            files.getDiscreteState,'-args',commonArgs,...
            files.setDiscreteState,'-args',[commonArgs(:);stateType(:)],...
            files.validateProperties,'-args',commonArgs...
            };


            if isa(sysObj,'matlab.system.mixin.FiniteSource')
                methodlist(end+1:end+3)={files.isDone,'-args',commonArgs};
            end
            if metaclass(sysObj).IsOutputUpdate
                methodlist(end+1:end+3)={files.output,'-args',[commonArgs(:);inputTypes(:)]};
                methodlist(end+1:end+3)={files.update,'-args',[commonArgs(:);inputTypes(:)]};
            end


            numGet=0;
            numSet=0;
            for p=1:props.numProps
                if props.gettableProps(p)
                    numGet=numGet+1;
                    methodlist(end+1:end+3)={files.get{numGet},'-args',commonArgs(:)};
                end
                if props.settableProps(p)&&props.tunableProps(p)
                    numSet=numSet+1;
                    methodlist(end+1:end+3)={files.set{numSet},'-args',[commonArgs(:);props.propValues{p}]};
                end
            end


            function printFile(path,filename,lines)
                pathname=fullfile(path,filename);
                fid=fopen(pathname,'w');
                if(fid<0)
                    error('matlab:system:genericError','Cannot open file for writing...');
                end
                try
                    for j=1:length(lines)
                        line=lines{j};
                        fprintf(fid,'%s\n',line);
                    end
                catch err
                    rethrow(err);
                end
                fclose(fid);
            end


            function output=getCoderTypes(input,varS,const)
                if isempty(input)
                    if iscell(input)
                        output={};
                    else
                        output={coder.typeof(input)};
                    end
                else
                    if nargin<2
                        varS=true(size(input()));
                    end
                    for arg=1:length(input)
                        if const
                            output{arg}=coder.Constant(input{arg});
                        else
                            output{arg}=coder.typeof(input{arg});
                            if varS(arg)
                                if isa(output{arg},'coder.PrimitiveType')
                                    output{arg}=coder.resize(output{arg},inf);
                                else
                                    warning('matlab:system:genericError','Variable dimension struct types are not supported.');
                                end
                            end
                        end
                    end
                end
            end

        end

        function compile(~,files,methodlist)

            try
                codegen(methodlist{:},...
                '-config',matlab.system.SysMex.getCoderConfig(),...
                '-d',matlab.system.SysMex.getCodegenDir(),...
                '-o',fullfile(files.mexDir,files.mexFile));
            catch err
                fprintf('System accelerator compilation Failed.\n');
                rethrow(err);
            end
        end
    end

    methods(Static)
        function[file,path]=signatureHash(fcnName,outputs,inputs,mexDir)

            persistent cache cacheFile

            if nargin<4
                mexDir=matlab.system.SysMex.getMexDir;
            end

            if isempty(cache)
                cacheFile=fullfile(mexDir,[computer('arch'),'_sysmex_map.mat']);
                if exist(cacheFile,'file')
                    s=load(cacheFile);
                    cache=s.cache;
                else
                    cache=containers.Map;
                end
            end


            try
                parsing='output';
                outputStr=getArgListString(outputs);
                parsing='input';
                inputStr=getArgListString(inputs);
            catch err
                exception=MException('matlab:system:genericError','Error found when parsing %s arguments',parsing);
                err=addCause(err,exception);
                throw(err);
            end
            key=sprintf('(%s)%s(%s)',outputStr,fcnName,inputStr);

            if~cache.isKey(key)
                cache(key)=tempname(mexDir);
                save(cacheFile,'cache');
            end
            matlab.system.internal.FileDeleter.addFiles(cacheFile);
            path=cache(key);
            [~,file,~]=fileparts(path);


            function str=getArgListString(argList)


                str='';
                for arg=1:length(argList)
                    name=getNameForType(argList{arg});
                    str=sprintf('%s%s',str,name);
                    if arg<length(argList)
                        str(end+1)=':';%#ok<*AGROW>
                    end
                end
            end

            function name=getNameForType(value)

                name=class(value);
                switch name
                case{'int64','uint64','int32','uint32','int16','uint16','int8','uint8'...
                    ,'double','single','char'}


                    if isreal(value);
                        cplx='_r';
                    else
                        cplx='_c';
                    end
                    name=sprintf('%s%s',name,cplx);
                case{'struct'}
                    fns=fieldnames(value);
                    name=[name,'.('];
                    for fn=1:length(fns)
                        name=getNameForType(value.(fns{fn}));
                        if fn<length(fns)
                            name=[name,','];
                        end
                    end
                    name=[name,')'];
                otherwise
                    error('matlab:system:genericError','Unsupported datatype: %s',name);
                end
            end
        end

        function value=isNewer(fn1,fn2)

            d1=dir(fn1);
            d2=dir(fn2);
            value=(d1.datenum>d2.datenum);
        end

        function mc=getCoderConfig()
            mc=coder.config('mex');
            mc.IntegrityChecks=true;
            mc.ResponsivenessChecks=true;
            mc.SaturateOnIntegerOverflow=true;
            mc.ConstantInputs='Remove';
            mc.EnableVariableSizing=true;
        end

        function value=canGenerateMex()
            value=(exist('codegen','file')~=0);
        end

        function mexDir=getMexDir()
            mexDir=fullfile(tempdir,'MathWorks','SysMex');

            if exist(mexDir,'dir')~=7
                mkdir(mexDir);
            end
        end

        function d=getCodegenDir()
            d=fullfile(matlab.system.SysMex.getMexDir,'codegen');
            matlab.system.internal.FileDeleter.addDirs(d);
        end
    end

end


