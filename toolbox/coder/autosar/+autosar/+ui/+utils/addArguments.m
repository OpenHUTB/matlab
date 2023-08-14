





function addArguments(modelName,serverFcnName,m3iOp)
    argCls='Simulink.metamodel.arplatform.interface.ArgumentData';
    isCaller=false;
    serverFcnBlock=autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(modelName,serverFcnName,isCaller);
    if isempty(serverFcnBlock)

        isCaller=true;
        callerBlock=autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(modelName,serverFcnName,isCaller);
        assert(~isempty(callerBlock),'Did not find caller block');

        callerBlock=callerBlock{1};
        fcnName=get_param(callerBlock,'FunctionPrototype');

        startIndex=strfind(fcnName,'(');
        endIndex=strfind(fcnName,')');
        inargs=strsplit(fcnName(startIndex+1:endIndex-1),',');
        fcnRetPart=fcnName(1:startIndex-1);
        fcnRetPart=strrep(fcnRetPart,'[','');
        fcnRetPart=strrep(fcnRetPart,']','');
        fcnRetPart=strrep(fcnRetPart,'=','');
        fcnRetPart=strrep(fcnRetPart,',',' ');
        outargs=strsplit(fcnRetPart,' ');
        inArgNames={};
        for ii=1:length(inargs)
            if~isempty(inargs{ii})
                inArgNames=[inArgNames,{strtrim(inargs{ii})}];%#ok<AGROW>
            end
        end
        outArgNames={};
        for ii=1:length(outargs)-1
            if~isempty(outargs{ii})
                outArgNames=[outArgNames,{strtrim(outargs{ii})}];%#ok<AGROW>
            end
        end
    else
        assert(~isempty(serverFcnBlock),'Did not find server block');

        outArgNames={};
        outargs=find_system(serverFcnBlock,'FollowLinks','on',...
        'SearchDepth',1,'BlockType','ArgOut');
        for outargindex=1:length(outargs)
            argName=get_param(outargs(outargindex),'ArgumentName');
            outArgNames{end+1}=argName{1};%#ok<AGROW>
        end
        inArgNames={};
        inargs=find_system(serverFcnBlock,'FollowLinks','on',...
        'SearchDepth',1,'BlockType','ArgIn');
        for inargindex=1:length(inargs)
            argName=get_param(inargs(inargindex),'ArgumentName');
            inArgNames{end+1}=argName{1};%#ok<AGROW>
        end
    end
    curOutIndex=1;
    for inargindex=1:length(inArgNames)
        if~any(ismember(outArgNames,inArgNames{inargindex}))
            m3iArg=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iOp,m3iOp.Arguments,...
            inArgNames{inargindex},argCls);
            m3iArg.Direction=Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In;
        end
    end
    for outargindex=curOutIndex:length(outArgNames)
        if any(ismember(inArgNames,outArgNames{outargindex}))
            m3iArg=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iOp,m3iOp.Arguments,...
            outArgNames{outargindex},argCls);
            m3iArg.Direction=Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut;
        else
            m3iArg=...
            autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iOp,m3iOp.Arguments,...
            outArgNames{outargindex},argCls);
            if m3iArg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.CommunicationError||...
                m3iArg.Direction==Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.TimeoutError

            else
                m3iArg.Direction=Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out;
            end
        end
    end
end


