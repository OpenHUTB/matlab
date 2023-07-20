function varargout=cifeature(varargin)







    persistent supportedFeatures;
    persistent featuresInfo;
    persistent featureName2Type;

    if isempty(supportedFeatures)

        featuresDefaultValues={...
        0;...
        0;...
        'CompactWithCount';...
        0;...
        0;...
        0;...
        1;...
        1;...
        1;...
        0;...
        0;...
        };


        featuresInfo={...
        'debug',message('CodeInstrumentation:instrumenter:featureDebugDesc').getString(),featuresDefaultValues{1},'bool';...
        'htmlPrettyPrinter',message('CodeInstrumentation:instrumenter:featureHtmlPrettyPrinterDesc').getString(),featuresDefaultValues{2},'bool';...
        'resultsMode',message('CodeInstrumentation:instrumenter:featureResultsModeDesc').getString(),featuresDefaultValues{3},internal.cxxfe.instrum.InstrumOptions.ResultsKind;...
        'honorCovLogicBlockShortCircuit',message('CodeInstrumentation:instrumenter:featureHonorCovLogicBlockShortCircuitDesc').getString(),featuresDefaultValues{4},'bool';...
        'honorModelFilters',message('CodeInstrumentation:instrumenter:featureHonorModelFilters').getString(),featuresDefaultValues{5},'bool';...
        'useSnifferInSIL',message('CodeInstrumentation:instrumenter:featureUseSnifferInSIL').getString(),featuresDefaultValues{6},'bool';...
        'enableOutcomeFilters','Support for outcome-based justification',featuresDefaultValues{7},'bool';...
        'enableAggregatedTestInfo','Support for aggregated test information',featuresDefaultValues{8},'bool';...
        'enableATSCodeCoverage','Support code coverage for Atomic Subsystem',featuresDefaultValues{9},'bool';...
        'disableErrorRecovery','Do not attempt to recover from unexpected exceptions',featuresDefaultValues{10},'bool';...
        'enableFcnExitInAnnotation','Generate EmbeddedCoderAnnotation entry for function exit coverage',featuresDefaultValues{11},'bool'...
        };

        supportedFeatures=containers.Map(featuresInfo(:,1),featuresInfo(:,2));
        featureName2Type=containers.Map(featuresInfo(:,1),featuresInfo(:,4));

        for ii=1:size(featuresInfo,1)
            setFeatureVal(featuresInfo{ii,1},featuresInfo{ii,3});
        end

    end

    if nargin<1
        error(message('CodeInstrumentation:instrumenter:featureSpecifyName'));
    end

    featureName=varargin{1};
    if strcmpi(featureName,'reset')
        for ii=1:size(featuresInfo,1)
            setFeatureVal(featuresInfo{ii,1},featuresDefaultValues{ii});
        end
        return
    elseif strcmpi(featureName,'initialize')
        for ii=1:size(featuresInfo,1)
            if hasFeatureVal(featuresInfo{ii,1})
                featuresInfo{ii,3}=getFeatureVal(featuresInfo{ii,1});
            end
            setFeatureVal(featuresInfo{ii,1},featuresInfo{ii,3});
        end
        return
    elseif strcmpi(featureName,'list')
        keys=supportedFeatures.keys();
        values=supportedFeatures.values();
        retVal=struct('name',' ','desc',' ','value',false);
        if nargout>0
            for ii=1:numel(keys)
                retVal(ii)=struct(...
                'name',keys{ii},...
                'desc',values{ii},...
                'value',getFeatureVal(keys{ii})...
                );
            end
            varargout{1}=retVal;
        else
            maxChar=max(cellfun(@numel,keys));
            for ii=1:numel(keys)
                val=getFeatureVal(keys{ii});
                if isBoolFeature(keys{ii})
                    if val
                        state='''on''';
                        actLabel='deactivate';
                        actArg='0';
                    else
                        state='''off''';
                        actLabel='activate';
                        actArg='1';
                    end
                    doHyperlink=true;
                elseif isEnumFeature(keys{ii})
                    state=['''',val,''''];
                    allVals=featureName2Type(keys{ii});
                    idx=find(strcmp(allVals,val),1,'first');
                    if idx<numel(allVals)
                        idx=idx+1;
                    else
                        idx=1;
                    end
                    actArg=['''',allVals{idx},''''];
                    actLabel=['change to ',actArg];
                    doHyperlink=true;
                else
                    state=sprintf('%d',val);
                    actLabel='';
                    actArg='';
                    doHyperlink=false;
                end
                if doHyperlink&&desktop('-inuse')
                    hyperLink=sprintf(...
                    '(<a href="matlab: codeinstrumprivate(''feature'', ''%s'', %s, true)">%s</a>)',...
                    keys{ii},actArg,actLabel);
                else
                    hyperLink='';
                end

                fprintf(1,'\t%s%s - %s is %s %s\n',...
                repmat(' ',1,maxChar-numel(keys{ii})),...
                keys{ii},values{ii},state,hyperLink);
            end
        end
        return
    end

    if~supportedFeatures.isKey(featureName)
        codeinstrum.internal.error('CodeInstrumentation:instrumenter:featureInvalidName',featureName);
    end

    if nargout>0
        varargout{1}=getFeatureVal(featureName);
    end

    if nargin>1
        val=varargin{2};
        doList=false;
        if nargin>2
            doList=varargin{3};
        end
        setFeatureVal(featureName,val);
        if doList
            fprintf(1,'\n');
            feature('list');
        end
    end

    function out=hasFeatureVal(name)
        if isBoolFeature(name)
            out=attic('hasBinMode',name);
        else
            out=isfield(attic('atticData'),name);
        end
    end

    function out=getFeatureVal(name)
        if isBoolFeature(name)
            out=attic('getBinMode',name);
        else
            out=attic('atticData',name);
        end
    end

    function setFeatureVal(name,val)
        if isBoolFeature(name)&&(islogical(val)||(isnumeric(val)&&(val==1||val==0)))
            attic('setBinMode',name,val);
        elseif isEnumFeature(name)
            validatestring(val,featureName2Type(name),'feature',name);
            attic('atticData',name,val);
        elseif isNumFeature(name)
            attic('atticData',name,val);
        else
            if~isempty(val)
                codeinstrum.internal.error('CodeInstrumentation:instrumenter:featureSpecifyMode');
            end
        end
    end

    function out=isBoolFeature(name)
        t=featureName2Type(name);
        out=ischar(t)&&strcmp(t,'bool');
    end

    function out=isNumFeature(name)
        t=featureName2Type(name);
        out=ischar(t)&&strcmp(t,'num');
    end

    function out=isEnumFeature(name)
        out=iscell(featureName2Type(name));
    end

end


