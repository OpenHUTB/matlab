



classdef loadableAudioPlugin<handle&dynamicprops&matlab.mixin.SetGet

    properties(Access=protected)
        PluginPath=''
        PluginInstance=uint64(0)
        MaxSamplesPerFrame=65536
DisplayNameMap
TabCompletions
ParameterAnalysis
    end

    properties
        DisplayMode(1,:)char{mustBeMember(DisplayMode,{'Parameters','Properties'})}='Properties';
    end

    methods
        function dispParameter(plugin,param)





















            if nargin>2
                error(message('MATLAB:TooManyInputs'));
            end
            inst=plugin.PluginInstance;
            if~inst
                return
            end
            numParams=hostmexif.getnumparams(inst);
            if numParams==0
                return
            end
            if nargin<2
                param=1:numParams;
            end

            param=checkParamStringArg(plugin,param,'dispParameter');

            if ischar(param)
                idx=paramIdxFromDisplayName(plugin,param);
                if isempty(idx)
                    error(message('audio:plugin:ParamIdxNoSuch',param));
                end
                param=idx;
            else
                validateattributes(param,{'numeric'},...
                {'real','finite','integer'...
                ,'>=',1,'<=',numParams},'dispParameter','param');
            end


            value=cell(numel(param),1);
            displayName=cell(numel(param),1);
            label=cell(numel(param),1);
            displayValue=cell(numel(param),1);
            for i=1:numel(param)
                j=param(i);
                [v,paramStrings]=getParameter(plugin,j);
                displayValue{i}=paramStrings.DisplayValue;
                label{i}=paramStrings.Label;
                displayName{i}=paramStrings.DisplayName;
                value{i}=sprintf('%.4f',v);
            end

            valueWidth=6;
            displayNameWidth=max(cellfun(@(x)numel(x),displayName));
            displayNameWidth=max(displayNameWidth,numel('Parameter'));
            displayValueWidth=max(cellfun(@(x)numel(x),displayValue));
            labelWidth=max(cellfun(@(x)numel(x),label));



            isLoose=strcmp(matlab.internal.display.formatSpacing,'loose');
            if isLoose
                fprintf('\n');
            end
            if matlab.internal.display.isHot
                strongBegin='<strong>';
                strongEnd='</strong>';
            else
                strongBegin='';
                strongEnd='';
            end
            fprintf('         %s%*s    Value    Display%s\n',...
            strongBegin,displayNameWidth,'Parameter',strongEnd);
            fprintf('        %s_%s_____________________%s\n',...
            strongBegin,repmat('_',1,displayNameWidth),strongEnd);

            for i=1:numel(param)
                fprintf('   %3d',param(i));
                fprintf('   %*s:',displayNameWidth,displayName{i});
                fprintf('   %*s',valueWidth,value{i});
                fprintf('   %*s',displayValueWidth,displayValue{i});
                fprintf(' %-*s',labelWidth,label{i});
                fprintf('\n');
            end
        end

        function[value,paramStrings]=getParameter(plugin,param)





































            if nargin<2
                error(message('audio:plugin:ParamIdxMissing'));
            elseif nargin>2
                error(message('MATLAB:TooManyInputs'));
            end
            inst=plugin.PluginInstance;
            if~inst
                value=0;
                paramStrings.DisplayName=[];
                paramStrings.DisplayValue=[];
                paramStrings.Label=[];
                return
            end
            param=checkParamArg(inst,plugin,param,'getParameter');
            value=double(hostmexif.getparamvalue(inst,int32(param)));
            if nargout>1
                paramStrings.DisplayName=hostmexif.getparamname(inst,int32(param));
                paramStrings.DisplayValue=hostmexif.getparamdisplay(inst,int32(param));
                paramStrings.Label=hostmexif.getparamlabel(inst,int32(param));
            end
        end

        function setParameter(plugin,param,value)















            if nargin<2
                error(message('audio:plugin:ParamIdxMissing'));
            elseif nargin>3
                error(message('MATLAB:TooManyInputs'));
            end
            inst=plugin.PluginInstance;
            if~inst
                return
            end
            param=checkParamArg(inst,plugin,param,'setParameter');

            validateattributes(value,{'numeric'},...
            {'scalar','real','finite',...
            '>=',0,'<=',1},'setParameter','value');

            hostmexif.setparamvalue(inst,int32(param),single(value));
        end

        function rate=getMaxSamplesPerFrame(plugin)





            rate=plugin.MaxSamplesPerFrame;
        end

        function setMaxSamplesPerFrame(plugin,rate)





            validateattributes(rate,{'numeric'},...
            {'real','scalar','finite','nonnegative','integer'},...
            'setMaxSamplesPerFrame','rate');
            plugin.MaxSamplesPerFrame=double(rate);

        end

        function varargout=set(plugin,varargin)
            if nargin>1
                [varargin{:}]=convertStringsToChars(varargin{:});
            end


            if nargin==2&&ischar(varargin{1})
                prop=varargin{1};
                if strcmp(prop,'DisplayMode')
                    varargout{1}={'Properties';'Parameters'};
                elseif~isempty(plugin.TabCompletions)...
                    &&isfield(plugin.TabCompletions,prop)
                    varargout{1}=plugin.TabCompletions.(prop);
                else
                    varargout{1}={};
                end
            else
                if nargout
                    varargout{1}=set@matlab.mixin.SetGet(plugin,varargin{:});
                else
                    set@matlab.mixin.SetGet(plugin,varargin{:});
                end
            end
        end

    end

    methods(Access=protected)

        function plugin=loadableAudioPlugin(pluginPath,pluginInstance)
            plugin.PluginPath=pluginPath;
            if pluginInstance
                plugin.PluginInstance=pluginInstance;
                doesDbl=hostmexif.supportsdouble(pluginInstance);
                hostmexif.usedouble(pluginInstance,doesDbl);
                addParameterProperties(plugin);
            end
        end

        function delete(plugin)
            if plugin.PluginInstance
                hostmexif.deleteplugininstance(plugin.PluginInstance);
                plugin.PluginInstance=uint64(0);
            end
        end

        function s=getInfo(plugin,varargin)
            inst=plugin.PluginInstance;
            if~inst
                s=[];
                return
            end
            s.PluginName=hostmexif.getpluginname(inst);
            s.Format=hostmexif.getpluginformatname(inst);
            s.InputChannels=double(hostmexif.getnuminputs(inst));
            s.OutputChannels=double(hostmexif.getnumoutputs(inst));
            s.NumParams=double(hostmexif.getnumparams(inst));
            s.PluginPath=plugin.PluginPath;
            s.VendorName=hostmexif.getvendorstring(inst);
            ver=hostmexif.getvendorversion(inst);
            a=sscanf(ver,'%d.%d.%d.%d');
            az=zeros(4,1);az(1:numel(a))=a;
            s.VendorVersion=sprintf('V%d.%d.%d',az(1),az(2),az(3));
            uid=hostmexif.getuniqueid(inst);
            s.UniqueId=char(mod(bitshift(uid,-24:8:0),256));
        end

        function dispKernel(plugin,details,varname)
            inst=plugin.PluginInstance;
            if~inst
                return
            end
            format=hostmexif.getpluginformatname(inst);
            name=hostmexif.getpluginname(inst);
            fprintf('  %s plugin ''%s''  %s',format,name,details);

            if strcmpi(plugin.DisplayMode,'Properties')
                fprintf('\n');
                if~isempty(plugin.TabCompletions)
                    props=fieldnames(plugin.TabCompletions);
                else
                    props={};
                end
                proplen=max(cellfun(@(x)numel(x),props));
                for i=1:numel(props)
                    val=plugin.(props{i});
                    label=hostmexif.getparamlabel(inst,int32(i));
                    if~isempty(label)
                        label=[' ',label];%#ok<AGROW>
                    end
                    if isnumeric(val)
                        fprintf('    %*s: %.5g%s\n',proplen,props{i},val,label);
                    else
                        fprintf('    %*s: ''%s''%s\n',proplen,props{i},val,label);
                    end
                end
            else
                numParams=hostmexif.getnumparams(inst);
                dispParameter(plugin,1:min(numParams,5));
                s='s';
                n=numParams-5;
                if n>0
                    fprintf('   %d parameter%s not displayed.',...
                    n,s(n~=1));
                    if isempty(varname)
                        fprintf(' Use dispParameter to see all %d params.\n',...
                        numParams);
                    elseif matlab.internal.display.isHot
                        fprintf(' <a href = "matlab:dispParameter(%s)">See all %d params.</a>\n',...
                        varname,numParams);
                    else
                        fprintf(' Use dispParameter(%s) to see all %d params.\n',...
                        varname,numParams);
                    end
                end
            end
        end

        function idx=paramIdxFromDisplayName(plugin,name)
            inst=plugin.PluginInstance;
            if~inst
                idx=0;
                return
            end
            map=plugin.DisplayNameMap;
            if isempty(map)
                map=containers.Map;
                numParams=hostmexif.getnumparams(inst);
                for i=1:numParams
                    displayName=hostmexif.getparamname(inst,int32(i));
                    if isKey(map,displayName)
                        map(displayName)=[map(displayName),i];
                    else
                        map(displayName)=i;
                    end
                end
                plugin.DisplayNameMap=map;
            end
            if isKey(plugin.DisplayNameMap,name)
                idx=plugin.DisplayNameMap(name);
            else
                idx=[];
            end
        end

        function addParameterProperties(plugin)

            propNames=makePropNames(plugin);

            pinst=plugin.PluginInstance;
            if~pinst
                return
            end

            format=hostmexif.getpluginformatname(pinst);
            pluginName=hostmexif.getpluginname(pinst);

            for pnum=1:numel(propNames)
                pa=sweepParameter(plugin,pnum);
                pa.PropertyName=propNames{pnum};
                pa.MetaProperty=addprop(plugin,pa.PropertyName);
                parameterAnalysis(pnum)=pa;%#ok<AGROW>

                addGetMethod(pa,pnum);
                addSetMethod(pa,pnum,format,pluginName);

                plugin.TabCompletions.(pa.PropertyName)=getTabCompletions(pa);
            end
            if~isempty(propNames)
                plugin.ParameterAnalysis=parameterAnalysis;
            end
        end

        function propNames=makePropNames(plugin)
            pinst=plugin.PluginInstance;
            if~pinst
                propNames=[];
                return
            end
            nparams=double(hostmexif.getnumparams(pinst));
            propNames=cell(nparams,1);
            for pnum=1:nparams
                propNames{pnum}=hostmexif.getparamname(pinst,int32(pnum));
            end
            propNames=matlab.lang.makeValidName(propNames);
            existingNames=collectExistingNames(plugin);
            propNames=makeUniqueStrings(propNames,existingNames);
        end

        function existingNames=collectExistingNames(plugin)
            magicMethodNames={'permute','transpose','ctranspose','reshape','display'};
            methodNames={metaclass(plugin).MethodList.Name};
            s=warning('off','MATLAB:structOnObject');
            propertyNames=fieldnames(struct(plugin))';
            warning(s);
            existingNames=unique([magicMethodNames,methodNames,propertyNames])';
        end

        function valueStrings=rawSweepParam(plugin,param,sweep)
            pinst=plugin.PluginInstance;
            if~pinst
                valueStrings=cell(0);
                return
            end
            initialValue=hostmexif.getparamvalue(pinst,int32(param));
            oc=onCleanup(@()hostmexif.setparamvalue(pinst,int32(param),initialValue));

            nvalues=numel(sweep);
            valueStrings=cell(nvalues,1);
            for i=1:nvalues
                hostmexif.setparamvalue(pinst,int32(param),single(sweep(i)));
                valueStrings{i}=hostmexif.getparamdisplay(pinst,int32(param));
            end
        end
    end
    methods

        function s=saveobj(obj)
            s.PluginPath=obj.PluginPath;
            s.MaxSamplesPerFrame=obj.MaxSamplesPerFrame;
            s.TabCompletions=obj.TabCompletions;
            s.ParameterAnalysis=obj.ParameterAnalysis;
            s.DisplayMode=obj.DisplayMode;




            dp=[];
            f=setdiff(fieldnames(obj),'DisplayMode','stable');

            cellfun(@(x)assignin('caller','dp',setfield(evalin('caller','dp'),x,obj.(x))),f);
            s.DynamicParameters=dp;
        end
        function obj=reload(obj,s)
            obj.PluginPath=s.PluginPath;
            obj.MaxSamplesPerFrame=s.MaxSamplesPerFrame;
            obj.TabCompletions=s.TabCompletions;
            obj.ParameterAnalysis=s.ParameterAnalysis;
            obj.DisplayMode=s.DisplayMode;
            f=fieldnames(s.DynamicParameters);
            for ii=1:numel(f)
                try
                    obj.(f{ii})=s.DynamicParameters.(f{ii});
                catch me
                    if~strcmp(me.identifier,'audio:plugin:ParameterPropertyNotMonotonic')
                        rethrow(me);
                    end
                end
            end
        end
    end

    methods(Static)
        function obj=loadobj(s)
            if isstruct(s)
                obj=loadableAudioPlugin(plugin.PluginPath,plugin.PluginInstance);
                obj=reload(obj,s);
            end
        end
    end

    methods(Hidden)

        function s=sweepParameter(plugin,param,sweep)
            if nargin<3
                sweep=(0:2^-9:1)';
            end
            if isrow(sweep)
                sweep=sweep';
            end
            valueStrings=rawSweepParam(plugin,param,sweep);
            numbers=str2double(valueStrings);
            s.IsNumeric=~any(isnan(numbers));
            if s.IsNumeric
                [numbers,s.NormalizedValues,deleted]=compressRunsOfValues(numbers,sweep);
                s.ValueStrings=valueStrings(~deleted);
                s.Numbers=numbers;
                s.Min=min(numbers);
                s.Max=max(numbers);
                d=diff(numbers);
                if all(d>0)
                    s.Monotonicity=1;
                elseif all(d<0)
                    s.Monotonicity=-1;
                else
                    s.Monotonicity=0;
                end
            else
                [s.ValueStrings,s.NormalizedValues]=compressRunsOfValues(valueStrings,sweep);
                s.Numbers=[];
                s.Min=0;
                s.Max=0;
                s.Monotonicity=0;
            end
            s.UniqueStrings=(numel(s.ValueStrings)==numel(unique(s.ValueStrings)));
        end

        function s=getParameterAnalysis(plugin)
            s=plugin.ParameterAnalysis;
        end
    end
end

function paramStr=checkParamStringArg(plugin,paramStr,fcn)%#ok<INUSL>
    if isstring(paramStr)
        validateattributes(paramStr,{'string'},{'scalar'},...
        fcn,'param');
        paramStr=char(paramStr);
    elseif ischar(paramStr)
        validateattributes(paramStr,{'char'},{'row'},...
        fcn,'param');
    end
end

function paramIdx=checkParamArg(inst,plugin,param,fcn)
    numParams=hostmexif.getnumparams(inst);
    if numParams==0
        error(message('audio:plugin:ParamIdxNoParams'));
    end

    param=checkParamStringArg(plugin,param,fcn);

    if ischar(param)
        paramIdx=paramIdxFromDisplayName(plugin,param);
        if isempty(paramIdx)
            error(message('audio:plugin:ParamIdxNoSuch',param));
        elseif numel(paramIdx)>1
            error(message('audio:plugin:ParamIdxNotUnique',param,sprintf(' %d',paramIdx)));
        end
    else
        validateattributes(param,{'numeric'},...
        {'scalar','real','finite','integer'...
        ,'>=',1,'<=',numParams},fcn,'param');
        paramIdx=param;
    end
end

function strings=makeUniqueStrings(strings,exclude)


    allstrings=[strings;exclude];
    count=containers.Map(allstrings,zeros(1,numel(allstrings)));
    for i=1:numel(allstrings)
        count(allstrings{i})=count(allstrings{i})+1;
    end
    for i=1:numel(strings)
        if count(strings{i})>1
            strings{i}=[strings{i},'_',num2str(i)];
        end
    end


    strings=matlab.lang.makeUniqueStrings(strings,exclude);
end

function completions=getTabCompletions(pa)
    if pa.IsNumeric
        completions={};
    else
        completions=pa.ValueStrings;
    end
end

function addGetMethod(pa,pnum)
    if pa.IsNumeric
        pa.MetaProperty.GetMethod=@(plugin)str2double(hostmexif.getparamdisplay(plugin.PluginInstance,int32(pnum)));
    else
        pa.MetaProperty.GetMethod=@(plugin)hostmexif.getparamdisplay(plugin.PluginInstance,int32(pnum));
    end
end

function addSetMethod(pa,pnum,format,pluginName)
    errhdr=getString(message('audio:plugin:ParameterPropertySetError',pa.PropertyName,format,pluginName));
    mp=pa.MetaProperty;
    if pa.IsNumeric
        from=pa.Numbers;
        to=pa.NormalizedValues;

        if pa.Monotonicity==0
            mp.SetMethod=@(plugin,val)error(message('audio:plugin:ParameterPropertyNotMonotonic',pa.PropertyName,pnum));
        else
            if pa.Monotonicity<0

                from=flipud(from);
                to=flipud(to);
            end
            if isinf(from(1))
                from(1)=-realmax;
            end
            if isinf(from(end))
                from(end)=realmax;
            end
            if numel(pa.Numbers)==1
                gi=@(x)x;
            else
                gi=griddedInterpolant(from,to,'pchip');
            end
            mp.SetMethod=@(plugin,val)numericSet(plugin,val,errhdr,pnum,pa.Min,pa.Max,gi);
        end
    else
        from=pa.ValueStrings;
        to=pa.NormalizedValues;
        map=containers.Map;
        for i=1:numel(from)
            if isKey(map,from{i})
                map(from{i})=[map(from{i}),to(i)];
            else
                map(from{i})=to(i);
            end
        end
        mp.SetMethod=@(plugin,val)charSet(plugin,val,pnum,map,from,errhdr);
    end
end

function numericSet(plugin,value,errhdr,paramn,minm,maxm,gi)
    try

        mustBeNumeric(value);
        mustBeNonNan(value);
        mustBeReal(value);
        validateattributes(value,{'numeric'},{'scalar'});
        mustBeGreaterThanOrEqual(value,minm);
        mustBeLessThanOrEqual(value,maxm);
    catch me
        me2=MException(me.identifier,'%s\n%s',errhdr,me.message);
        throwAsCaller(me2);
    end
    setParameter(plugin,paramn,gi(double(value)));
end

function charSet(plugin,value,paramn,map,keys,errhdr)
    try

        validateattributes(value,{'char','string'},{});
        value=char(value);
        mustBeMember(value,keys);
    catch me
        me2=MException(me.identifier,'%s\n%s',errhdr,me.message);
        throwAsCaller(me2);
    end
    norm=map(value);
    if~isscalar(norm)
        warning(message('audio:plugin:ParameterPropertyAmbiguousSetValue',...
        value,num2str(norm),num2str(norm(1))));
    end
    setParameter(plugin,paramn,norm(1));
end

function[from,to,deleted]=compressRunsOfValues(from,to)
    runs=findRunsOfValues(from);
    deleted=false(size(to));
    for r=1:size(runs,1)
        first=runs(r,1);
        last=runs(r,2);

        if first==1
            deleted(first+1:last)=true;
        elseif last==numel(to)
            deleted(first:last-1)=true;
        else
            to(first)=median(to(first:last));
            deleted(first+1:last)=true;
        end
    end
    from(deleted)=[];
    to(deleted)=[];
end


function runs=findRunsOfValues(v)
    runs=[];
    N=numel(v);
    runlength=1;
    for i=1:N
        if i<N&&isequal(v(i),v(i+1))

            runlength=runlength+1;
        elseif runlength>1

            runs(end+1,:)=[i-runlength+1,i];%#ok<AGROW>
            runlength=1;
        end
    end
end

