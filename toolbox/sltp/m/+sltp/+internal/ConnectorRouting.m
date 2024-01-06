classdef ConnectorRouting

    methods(Static=true)
        function path=computePath(sourceSID,targetSID)

            path=struct('source',{},...
            'target',{});

            if isequal(sourceSID,targetSID)
                return;
            end
            sourcePath=Simulink.ID.getFullName(sourceSID);
            targetPath=Simulink.ID.getFullName(targetSID);

            sourceParent=get_param(sourcePath,'Parent');
            if strcmp(targetPath,sourceParent)
                segment.source=sourcePath;
                segment.target=targetPath;
                path(1)=segment;
                return;
            end

            targetParent=get_param(targetPath,'Parent');
            if strcmp(sourcePath,targetParent)
                segment.source=sourcePath;
                segment.target=targetPath;
                path(1)=segment;
                return;
            end


            sourceTokens=string(strsplit(sourcePath,'/'));
            targetTokens=string(strsplit(targetPath,'/'));
            numTokens=min(sourceTokens.length,targetTokens.length);
            compareSourceTokens=sourceTokens(1:numTokens);
            compareTargetTokens=targetTokens(1:numTokens);
            compare=compareSourceTokens==compareTargetTokens;
            diverge=find(compare==0,1);

            numSourceHops=sourceTokens.length-diverge;
            numTargetHops=targetTokens.length-diverge;
            numSegments=numSourceHops+numTargetHops+1;
            path=repmat(struct('source','','target',''),numSegments,1);

            for hop=1:numSourceHops
                hopPath=strjoin(sourceTokens(1:diverge+hop),'/');
                segment.source=hopPath.char;
                segment.target=get_param(hopPath,'Parent');
                path(hop)=segment;
            end

            newSourcePath=strjoin(sourceTokens(1:diverge),'/');
            newTargetPath=strjoin(targetTokens(1:diverge),'/');
            segment.source=newSourcePath.char;
            segment.target=newTargetPath.char;
            path(numSourceHops+1)=segment;

            for hop=1:numTargetHops
                hopPath=strjoin(targetTokens(1:diverge+hop),'/');
                segment.source=get_param(hopPath,'Parent');
                segment.target=hopPath.char;
                path(numSourceHops+1+hop)=segment;
            end
        end
    end
end
