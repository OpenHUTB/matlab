function out=createDefaultFunctionPrototypeFromBlock(blkHandle,varargin)







    constructSmartDefaultIfPossible=false;
    if nargin==2
        constructSmartDefaultIfPossible=varargin{1};
    end

    blk=getfullname(blkHandle);
    modelName=strtok(getfullname(blk),'/');
    hasMapping=...
    coder.mapping.internal.SimulinkFunctionMapping.hasModelMapping(modelName);
    if constructSmartDefaultIfPossible



        try
            [~,~,scalarRetByDefaultIdx]=...
            coder.mapping.internal.SimulinkFunctionMapping.getArgInAndArgOutProperties(blk);
        catch ME
            switch ME.identifier
            case{'RTW:codeGen:UnsetArgumentSpecifications','Simulink:Parameters:BlkParamUndefined'}







                constructSmartDefaultIfPossible=false;
            otherwise
                rethrow(ME)
            end
        end




        constructSmartDefaultIfPossible=...
        constructSmartDefaultIfPossible&&...
        (hasMapping||(scalarRetByDefaultIdx>=0));
    end

    [inArgs,outArgs,fcnName]=...
    coder.mapping.internal.SimulinkFunctionMapping.getSLFcnInOutArgs(blk);

    inOutArgs=intersect(inArgs,outArgs,'stable');




    scalarOutputDefault=false;

    if coder.mapping.internal.SimulinkFunctionMapping.isPublicFcn(blk,fcnName)
        codeFcnName=fcnName;
        renamedArg='';
        pointerForOut='';
    else
        codeFcnName='$N';
        renamedArg=[' ',get_param(modelName,'CustomSymbolStrFcnArg')];
        pointerForOut='*';
    end

    returnOutAsDefaultIdx=-1;
    if constructSmartDefaultIfPossible
        [~,outArgsProp,returnOutAsDefaultIdx]=...
        coder.mapping.internal.SimulinkFunctionMapping.getArgInAndArgOutProperties(blk);

        if(returnOutAsDefaultIdx>=0)||...
            (length(outArgs)==1&&...
            isempty(intersect(inOutArgs,outArgs)))



            if isempty(outArgsProp)
                blkPath=[blk,'/',outArgs{1}];
                dataType=get_param(blkPath,'OutDataTypeStr');
                isBus=~isempty(regexp(dataType,'^Bus:','once'));
                dimensions=slResolve(...
                get_param(blkPath,'PortDimensions'),blkPath);
                isScalar=prod(dimensions)==1;
                isComplex=strcmp(get_param(blkPath,...
                'SignalType'),'complex');
                isImage=false;
            elseif returnOutAsDefaultIdx<0
                isBus=outArgsProp.IsBus;
                isScalar=outArgsProp.IsScalar;
                isComplex=outArgsProp.IsComplex;
                isImage=outArgsProp.IsImage;
            end

            if(returnOutAsDefaultIdx>=0)||...
                (isScalar&&~isComplex&&~isBus&&~isImage)
                if returnOutAsDefaultIdx>=0
                    returnOutArg=outArgs{returnOutAsDefaultIdx};
                else
                    returnOutArg=outArgs{1};
                end
                out=[returnOutArg,'=',codeFcnName,'('];
                scalarOutputDefault=true;
            else
                out=[codeFcnName,'('];
            end
        else
            out=[codeFcnName,'('];
        end
    else
        out=[codeFcnName,'('];
    end


    inArgs=setdiff(inArgs,inOutArgs,'stable');
    comma='';
    for i=1:length(inArgs)
        out=[out,comma,inArgs{i},renamedArg];%#ok<AGROW>
        comma=',';
    end



    if~scalarOutputDefault||returnOutAsDefaultIdx>=0
        for i=1:length(outArgs)
            if returnOutAsDefaultIdx<0||returnOutAsDefaultIdx~=i
                out=[out,comma,pointerForOut,outArgs{i},renamedArg];%#ok<AGROW>
                comma=',';
            end
        end
    end
    out=[out,')'];
end
