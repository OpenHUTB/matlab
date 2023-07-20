function[inArgsProp,outArgsProp,ScalarOutReturnAsDefaultIdx]=getArgInAndArgOutProperties(blk)







    ScalarOutReturnAsDefaultIdx=-1;
    isPublicSLFcn=coder.mapping.internal.isPublicSimulinkFunction(blk);
    numOfScalarOutputs=0;

    if(strcmp(get_param(blk,'BlockType'),'SubSystem')&&...
        strcmp(get_param(blk,'IsSimulinkFunction'),'on'))

        inArgs=find_system(blk,'SearchDepth',1,...
        'FollowLinks','on','LookUnderMasks','all',...
        'BlockType','ArgIn');
        outArgs=find_system(blk,'SearchDepth',1,...
        'FollowLinks','on','LookUnderMasks','all',...
        'BlockType','ArgOut');

        inArgsProp=struct([]);
        outArgsProp=struct([]);

        inArgNames=cell(1,length(inArgs));
        outArgNames=cell(1,length(outArgs));

        numOfScalarOutputs=0;

        for inIdx=1:length(inArgs)
            inArgsProp(inIdx).Name=get_param(inArgs{inIdx},...
            'ArgumentName');
            dataType=get_param(inArgs{inIdx},'OutDataTypeStr');
            inArgsProp(inIdx).IsBus=...
            ~isempty(regexp(dataType,'^Bus:','once'));
            inArgsProp(inIdx).IsImage=false;
            dimensions=slResolve(...
            get_param(inArgs{inIdx},'PortDimensions'),inArgs{inIdx});
            inArgsProp(inIdx).IsScalar=prod(dimensions)==1;
            inArgsProp(inIdx).IsComplex=strcmp(get_param(inArgs{inIdx},...
            'SignalType'),'complex');

            inArgNames{inIdx}=inArgsProp(inIdx).Name;
        end

        for outIdx=1:length(outArgs)
            outArgsProp(outIdx).Name=get_param(outArgs{outIdx},...
            'ArgumentName');
            dataType=get_param(outArgs{outIdx},'OutDataTypeStr');
            outArgsProp(outIdx).IsBus=...
            ~isempty(regexp(dataType,'^Bus:','once'));
            outArgsProp(outIdx).IsImage=false;
            dimensions=slResolve(...
            get_param(outArgs{outIdx},'PortDimensions'),outArgs{outIdx});
            outArgsProp(outIdx).IsScalar=prod(dimensions)==1;
            outArgsProp(outIdx).IsComplex=strcmp(get_param(outArgs{outIdx},...
            'SignalType'),'complex');

            outArgNames{outIdx}=outArgsProp(outIdx).Name;

            if~outArgsProp(outIdx).IsBus&&outArgsProp(outIdx).IsScalar&&...
                ~outArgsProp(outIdx).IsComplex
                numOfScalarOutputs=numOfScalarOutputs+1;
                ScalarOutReturnAsDefaultIdx=outIdx;
            end
        end

    elseif strcmp(get_param(blk,'BlockType'),'FunctionCaller')

        [inArgs,outArgs,~]=...
        coder.mapping.internal.SimulinkFunctionMapping.getSLFcnInOutArgs(blk);

        inArgSpecs=get_param(blk,'InputArgumentSpecifications');
        outArgSpecs=get_param(blk,'OutputArgumentSpecifications');
        inArgsProp=struct([]);
        outArgsProp=struct([]);
        inArgNames=cell(1,length(inArgs));
        outArgNames=cell(1,length(outArgs));

        numOfScalarOutputs=0;





        isPublicCallerInSeparateModel=codermapping.internal.simulinkfunction.suppressConfigureFunctionInterface(get_param(blk,'Handle'));
        if isPublicCallerInSeparateModel
            return;
        end





        if~isempty(inArgs)
            if strcmp(inArgSpecs,'<Enter example>')||...
                strcmp(inArgSpecs,'')
                DAStudio.error('RTW:codeGen:UnsetArgumentSpecifications',...
                blk);
            end
            inArgsPropInfo=codermapping.internal.simulinkfunction.parseArgumentSpecifications(...
            get_param(blk,'Handle'),...
            'InputArgumentSpecifications',inArgSpecs,length(inArgs));
            for inIdx=1:length(inArgs)
                inArgsProp(inIdx).Name=inArgs{inIdx};
                inArgsProp(inIdx).IsBus=inArgsPropInfo(inIdx).IsBus;
                inArgsProp(inIdx).IsImage=inArgsPropInfo(inIdx).IsImage;
                inArgsProp(inIdx).IsScalar=inArgsPropInfo(inIdx).IsScalar;
                inArgsProp(inIdx).IsComplex=inArgsPropInfo(inIdx).IsComplex;

                inArgNames{inIdx}=inArgsProp(inIdx).Name;
            end
        end
        if~isempty(outArgs)
            if strcmp(outArgSpecs,'<Enter example>')||...
                strcmp(outArgSpecs,'')
                DAStudio.error('RTW:codeGen:UnsetArgumentSpecifications',...
                blk);
            end
            outArgsPropInfo=codermapping.internal.simulinkfunction.parseArgumentSpecifications(...
            get_param(blk,'Handle'),...
            'OutputArgumentSpecifications',outArgSpecs,length(outArgs));
            for outIdx=1:length(outArgs)
                outArgsProp(outIdx).Name=outArgs{outIdx};
                outArgsProp(outIdx).IsBus=outArgsPropInfo(outIdx).IsBus;
                outArgsProp(outIdx).IsImage=outArgsPropInfo(outIdx).IsImage;
                outArgsProp(outIdx).IsScalar=outArgsPropInfo(outIdx).IsScalar;
                outArgsProp(outIdx).IsComplex=outArgsPropInfo(outIdx).IsComplex;

                outArgNames{outIdx}=outArgsProp(outIdx).Name;

                if~outArgsProp(outIdx).IsBus&&outArgsProp(outIdx).IsScalar&&...
                    ~outArgsProp(outIdx).IsComplex&&~outArgsProp(outIdx).IsImage
                    numOfScalarOutputs=numOfScalarOutputs+1;
                    ScalarOutReturnAsDefaultIdx=outIdx;
                end
            end
        end
    else
        assert(false,'Block must be a Simulink Function or a Caller block');
    end

    inOutArgs=intersect(inArgNames,outArgNames,'stable');

    if~isPublicSLFcn||(numOfScalarOutputs~=1)||...
        ~isempty(intersect(inOutArgs,outArgNames))
        ScalarOutReturnAsDefaultIdx=-1;
    end
end
