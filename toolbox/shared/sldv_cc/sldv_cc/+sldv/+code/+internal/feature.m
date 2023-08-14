



function varargout=feature(varargin)



    narginchk(1,nargin);


    mlock();


    persistent featureDefaultValues;
    persistent featureName2Desc;
    persistent featureInfo;
    persistent featureName2Value;
    if isempty(featureName2Desc)

        featureDefaultValues={...
        false;...
        true;...
        false;...
        false;...
        false;...
        false;...
        true;...
        true;...
        true;...
        false;...
        true;...
        false;...
        true;...
        false;...
        };


        featureInfo={...
        'debug','Debug mode for SLDV S-Function support',featureDefaultValues{1};...
        'sfunctionRTE','Runtime-Error detection on S-functions',featureDefaultValues{2};...
        'randoms','Generate list of locations generating randoms during the analysis',featureDefaultValues{3};...
        'warnRmdir','Warn when a directory cannot be removed',featureDefaultValues{4};...
        'collectSmlCov','Collect Sml coverage if available',featureDefaultValues{5};...
        'verbose','Display more information in case of analysis error',featureDefaultValues{6};...
        'forceTestGen4UnknownCovId','Force test generation for an unknown coverage ID',featureDefaultValues{7};...
        'fullCustomCodeIR','Only stub custom-code functions instead of providing full IR information',featureDefaultValues{8};...
        'customCodeRTE','Runtime-Error detection on custom-code',featureDefaultValues{9};...
        'storeIRinSLDD','Store code IR information in the old SLDD format',featureDefaultValues{10};...
        'sfSizeof','Handle stateflow sizeof expressions',featureDefaultValues{11};...
        'disableErrorRecovery','Do not attempt to recover from unexpected exceptions',featureDefaultValues{12};...
        'supportATS','Support for Atomic Subsystem',featureDefaultValues{13};...
        'keepXilMainFile','Keep the generated XIL main file',featureDefaultValues{14};...
        };


        featureName2Desc=containers.Map(featureInfo(:,1),featureInfo(:,2));



        featureName2Value=containers.Map('KeyType','char','ValueType','any');
        for ii=1:size(featureInfo,1)
            featureName2Value(featureInfo{ii,1})=featureInfo{ii,3};
        end
    end


    featureName=varargin{1};

    if strcmpi(featureName,'reset')

        for ii=1:size(featureInfo,1)
            featureName2Value(featureInfo{ii,1})=featureDefaultValues{ii};
        end
        return

    elseif strcmpi(featureName,'list')

        keys=featureName2Desc.keys();
        values=featureName2Desc.values();

        if nargout>0

            retVal=repmat(struct('name',' ','desc',' ','value',false),numel(keys),1);
            for ii=1:numel(keys)
                retVal(ii)=struct(...
                'name',keys{ii},...
                'desc',values{ii},...
                'value',featureName2Value(keys{ii})...
                );
            end
            varargout{1}=retVal;

        else

            maxChar=max(cellfun(@numel,keys));
            for ii=1:numel(keys)
                if featureName2Value(keys{ii})
                    state='''on''';
                else
                    state='''off''';
                end

                fprintf(1,'\t%s%s - %s is %s\n',repmat(' ',1,maxChar-numel(keys{ii})),...
                keys{ii},values{ii},state);
            end
        end
        return
    end


    featureName=validatestring(featureName,featureInfo(:,1),1);


    if nargout>0
        varargout{1}=featureName2Value(featureName);
    end


    if nargin>1
        validateattributes(varargin{2},{'logical'},{'scalar'});
        featureName2Value(featureName)=varargin{2};


        if nargin>2&&varargin{3}
            fprintf(1,'\n');
            sldv.code.internal.feature('list');
        end
    end


