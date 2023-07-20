classdef(Sealed)VersionTransformSequence<handle










    properties(Access=private)
        TransformSequences=containers.Map;%#ok<MCHDP>
    end

    methods(Access=private)
        function obj=VersionTransformSequence
        end
    end

    methods(Static,Access=private)
        function obj=getInstance
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=simscape.internal.componentforwarding.VersionTransformSequence;
            end
            obj=localObj;
        end
    end

    methods(Static)
        function transforms=get(componentClass,currentVersion,targetVersion)
            obj=simscape.internal.componentforwarding.VersionTransformSequence.getInstance();
            theKey=[componentClass,currentVersion,targetVersion];
            if obj.TransformSequences.isKey(theKey)
                transforms=obj.TransformSequences(theKey);
            else
                transforms=lGetTransformSequence(componentClass,currentVersion,targetVersion);
                obj.TransformSequences(theKey)=transforms;
            end
        end
    end

end

function TransformSequences=lGetTransformSequence(component,currentVersion,targetVersion)


    TransformSequences=[];
    targetVersion=str2double(regexp(targetVersion,'\.','split'));
    currentVersion=str2double(regexp(currentVersion,'\.','split'));
    while true
        componentSequence=...
        lGetComponentSequence(component,currentVersion,targetVersion);
        if~isempty(componentSequence)

            component=componentSequence(end).TargetClass;
            currentVersion=componentSequence(end).TargetVersion;

            TransformSequences=[TransformSequences,componentSequence];%#ok<AGROW>
        else
            break;
        end
    end

end

function TransformSequences=lGetComponentSequence(componentClass,currentVersion,targetVersion)
    import simscape.internal.componentforwarding.VersionTransforms


    transformations=VersionTransforms.get(componentClass);
    TransformSequences=[];
    if~isempty(transformations)


        nTransforms=numel(transformations);
        xformStart=nan(nTransforms,2);
        xformEnd=nan(nTransforms,2);
        xformTarget=nan(nTransforms,2);

        for idx=1:nTransforms
            xformStart(idx,:)=transformations(idx).StartVersion;
            xformEnd(idx,:)=transformations(idx).EndVersion;
            xformTarget(idx,:)=transformations(idx).TargetVersion;
        end


        [xformStart,i]=sortrows(xformStart);
        xformEnd=xformEnd(i,:);
        xformTarget=xformTarget(i,:);
        transformations=transformations(i);


        nXForms=size(xformStart,1);
        for idx=1:nXForms
            if isVersionInRange(xformStart(idx,:),xformEnd(idx,:),xformTarget(idx,:),currentVersion,targetVersion)


                TransformSequences=[TransformSequences,transformations(idx)];%#ok<AGROW>


                currentVersion=transformations(idx).TargetVersion;


                if~strcmp(componentClass,transformations(idx).TargetClass)
                    break
                end
            end
        end
    end


end

function result=isVersionInRange(xformStart,xformEnd,xformTarget,current,target)
    result=versiongte(current,xformStart)&...
    versionlt(current,xformEnd)&...
    versionlte(xformTarget,target);
end

function result=versiongte(version1,version2)
    result=(version1(1)>version2(1))||...
    ((version1(1)==version2(1))&&(version1(2)>=version2(2)));
end

function result=versionlt(version1,version2)
    result=(version1(1)<version2(1))||...
    ((version1(1)==version2(1))&&(version1(2)<version2(2)));
end

function result=versionlte(version1,version2)
    result=(version1(1)<version2(1))||...
    ((version1(1)==version2(1))&&(version1(2)<=version2(2)));
end
