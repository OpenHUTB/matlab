function varargout=feature(varargin)





    narginchk(1,nargin);


    mlock();


    persistent featureDefaultValues;
    persistent featureName2Desc;
    persistent featureInfo;
    persistent featureName2Value;
    if isempty(featureName2Desc)

        featureDefaultValues={...
        1;...
        };


        featureInfo={...
        'useKnownCompilers','use the list of known compilers instead of creating a new compiler description',featureDefaultValues{1};...
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
                    actLabel='deactivate';
                    actArg='0';
                else
                    state='''off''';
                    actLabel='activate';
                    actArg='1';
                end


                hyperLink='';
                if desktop('-inuse')
                    hyperLink=sprintf(...
                    '(<a href="matlab:polyspace.internal.sniffer.feature(''%s'', %s, true)">%s</a>)',...
                    keys{ii},actArg,actLabel);
                end

                fprintf(1,'\t%s%s - %s is %s %s\n',repmat(' ',1,maxChar-numel(keys{ii})),...
                keys{ii},values{ii},state,hyperLink);
            end
        end
        return
    end


    featureName=validatestring(featureName,featureInfo(:,1),1);


    if nargout>0
        varargout{1}=featureName2Value(featureName);
    end


    if nargin>1
        featureName2Value(featureName)=varargin{2};


        if nargin>2&&varargin{3}
            fprintf(1,'\n');
            polyspace.internal.sniffer.feature('list');
        end
    end
