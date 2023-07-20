function varargout=feature(s,version)



    persistent featureMap
    persistent featureVersion


    if nargin<2
        if isempty(featureVersion)
            version=1;
        else
            version=featureVersion;
        end
    end

    if isempty(featureMap)||isempty(featureVersion)||(featureVersion~=version&&nargin==2)
        featureVersion=version;
        featureMap=containers.Map('keytype','char','valuetype','double');



        featureMap('SCInSLStudio')=0;
        featureMap('SubsystemFlexiblePortPlacement')=1;
        featureMap('FlexiblePortPlacementInfrastructure')=1;
        featureMap('LoadLinksInOldMode')=0;
    end


    featureNames=featureMap.keys;
    for idx=1:length(featureNames)
        aFeature=featureNames{idx};
        out.(aFeature)=slfeature(aFeature);
    end
    if nargout>1
        varargout{1}=out;
    end

    if nargin<1
        varargout{1}=out;
        return;
    elseif(ischar(s)||isStringScalar(s))
        varargout{1}=out;
        if strcmpi(s,'on')
            cellfun(@(x)slfeature(x,featureMap(x)),featureNames);
        elseif strcmpi(s,'off')
            cellfun(@(x)slfeature(x,0),featureNames);
        else
            error('Input must be a char (''on'' or ''off'') or numeric or structure.');
        end
    elseif isnumeric(s)
        varargout{1}=out;
        if s==1
            cellfun(@(x)slfeature(x,featureMap(x)),featureNames);
        elseif s==0
            cellfun(@(x)slfeature(x,0),featureNames);
        else
            error('Input must be a char (''on'' or ''off'') or numeric or structure.');
        end
    elseif isstruct(s)
        varargout{1}=out;
        cellfun(@(x)slfeature(x,s.(x)),featureNames);
    else
        error('Input must be a char (''on'' or ''off'') or numeric or structure.');
    end
end
