classdef PropertyAction




    methods(Static)
        function cmds=insertNumeric(mt,propName)
            code=sprintf('%s = 0',propName);
            cmds=insertProperty(mt,code,...
            'Attributes',{'Nontunable'});
        end

        function cmds=insertTunableNumeric(mt,propName)
            cmds=insertProperty(mt,propName);
        end

        function cmds=insertLogical(mt,propName)



            logicalMCOSValidtor='(1, 1) logical';
            code=sprintf('%s %s = true',propName,logicalMCOSValidtor);
            cmds=insertProperty(mt,code,...
            'SelectExtent',numel(propName),...
            'Attributes',{'Nontunable'});
        end

        function cmds=insertEnumeration(mt,propName,enumName,...
            createNewEnum,defaultValue,setValues)


            if~isvarname(propName)
                error(message('MATLAB:system:Editor:CodeInvalidPropertyName'));
            end


            if~isvarname(enumName)
                error(message('MATLAB:system:Editor:CodeInvalidEnumName'));
            end


            if createNewEnum
                if isempty(setValues)
                    error(message('MATLAB:system:Editor:CodeEmptyEnumValues'));
                end
                for kndx=1:numel(setValues)
                    if~isvarname(setValues{kndx})
                        error(message('MATLAB:system:Editor:CodeInvalidEnumValues',setValues{kndx}));
                    end
                    if strcmp(setValues{kndx},enumName)
                        error(message('MATLAB:system:Editor:CodeEnumValueHasClassName',enumName));
                    end
                end
            end


            if createNewEnum
                enumPropertyCode=sprintf('%s (1, 1) %s = %s.%s',propName,...
                enumName,enumName,defaultValue);
            else
                enumPropertyCode=sprintf('%s (1, 1) %s',propName,enumName);
            end

            cmds=insertProperty(mt,enumPropertyCode,...
            'SelectEndOfCode',true,...
            'Attributes',{'Nontunable'});
        end

        function cmds=insertPositiveInteger(mt,propName)



            positiveIntegerMCOSValidator=...
            '(1, 1) {mustBePositive, mustBeInteger}';
            code=sprintf('%s %s = 1',propName,...
            positiveIntegerMCOSValidator);
            cmds=insertProperty(mt,code,...
            'SelectExtent',numel(propName),...
            'Attributes',{'Nontunable'});
        end

        function cmds=insertDiscreteState(mt,propName)
            cmds=insertProperty(mt,propName,...
            'Attributes',{'DiscreteState'});
        end

        function cmds=insertPrivate(mt,propName)
            cmds=insertProperty(mt,propName,...
            'SetAccess','private',...
            'GetAccess','private');
        end

        function cmds=insertProtected(mt,propName)
            cmds=insertProperty(mt,propName,...
            'SetAccess','protected',...
            'GetAccess','protected');
        end

        function cmds=insertCustom(mt,propName,setAccess,getAccess,attributes)


            attributes=attributes(:);



            if ismember('Nontunable',attributes)
                attributes=['Nontunable';setdiff(attributes,'Nontunable','stable')];
            end

            cmds=insertProperty(mt,propName,...
            'SetAccess',setAccess,...
            'GetAccess',getAccess,...
            'Attributes',attributes);
        end

        function[propertyNames,propertyNodes,stateNames,stateNodes,...
            propertyVisibilities,firstRestrictedProperty,numRestrictedProperties,legacyAttributes]=getPropertyInfo(mt)
            import matlab.internal.lang.capability.Capability

            propertyNames={};
            propertyNodes={};
            propertyVisibilities={};
            stateNames={};
            stateNodes={};
            firstRestrictedProperty='';
            numRestrictedProperties=0;
            legacyAttributes={};
            propertyBlocks=mtfind(mt,'Kind','PROPERTIES');
            ind=indices(propertyBlocks);
            for k=ind
                propertiesBlock=select(propertyBlocks,k);
                [setAccess,getAccess,attributes]=matlab.system.editor.internal.ParseTreeUtils.getPropertyBlockAttributes(propertiesBlock);
                [names,nodes]=matlab.system.editor.internal.ParseTreeUtils.getPropertyBlockProperties(propertiesBlock);

                if isempty(names)
                    continue;
                end


                if nnz(ismember({'PositiveInteger','Logical'},attributes))
                    namesLegacyAttributes=true(1,length(names));
                else
                    namesLegacyAttributes=false(1,length(names));
                end


                if(any(endsWith(names,'Set')))
                    stringSetAttributes=cellfun(@(x)strcmp(tree2str(x.Right.Left),'matlab.system.StringSet'),nodes);




                    namesLegacyAttributes=or(namesLegacyAttributes,stringSetAttributes);
                end
                if ismember('DiscreteState',attributes)
                    stateNames=[stateNames,names];
                    stateNodes=[stateNodes,nodes];
                elseif~isempty(names)
                    if Capability.isSupported(Capability.LocalClient)
                        legacyAttributes=[legacyAttributes,num2cell(namesLegacyAttributes)];
                    else


                        legacyAttributes=[legacyAttributes,num2cell(false(size(namesLegacyAttributes)))];
                    end
                    propertyNames=[propertyNames,names];
                    propertyNodes=[propertyNodes,nodes];
                    vis=cell(size(names));
                    vis(:)={getAccess};
                    propertyVisibilities=[propertyVisibilities,vis];

                    if~strcmp(setAccess,'public')||~strcmp(getAccess,'public')
                        numRestrictedProperties=numRestrictedProperties+numel(names);
                        if isempty(firstRestrictedProperty)
                            firstRestrictedProperty=names{1};
                        end
                    end
                end
            end
        end

        function[publicPropertiesInfo,restrictedPropertiesInfo,stateInfo]=getAnalysisInfo(mt)


            [propertyNames,propertyNodes,stateNames,stateNodes,...
            propertyVisibilities,~,~,LegacyAttributes]=...
            matlab.system.editor.internal.PropertyAction.getPropertyInfo(mt);


            publicPropertiesInfo=struct('Name',{},...
            'Position',{},'Legacy',{});

            restrictedPropertiesInfo=struct('Name',[],...
            'Position',{},'Legacy',{});

            for propInd=1:numel(propertyNodes)
                propNode=propertyNodes{propInd};

                [L,C]=pos2lc(propNode,lefttreepos(propNode));
                tempStruct=struct('Name',propertyNames(propInd),'Position',[L,C],'Legacy',LegacyAttributes{propInd});
                if(strcmp(propertyVisibilities(propInd),'public'))
                    publicPropertiesInfo(end+1)=tempStruct;
                else
                    restrictedPropertiesInfo(end+1)=tempStruct;
                end
            end

            stateInfo=struct('Name',stateNames,'Position',[]);
            numStates=numel(stateNodes);
            for stateInd=1:numStates
                stateNode=stateNodes{stateInd};


                [L,C]=pos2lc(stateNode,lefttreepos(stateNode));
                stateInfo(stateInd).Position=[L,C];

            end
        end
    end
end

function cmds=insertProperty(mt,propertyCode,varargin)

    p=inputParser;
    p.addParameter('SetAccess','public',@ischar);
    p.addParameter('GetAccess','public',@ischar);
    p.addParameter('Attributes',{},@iscellstr);
    p.addParameter('Select',true,@islogical);
    p.addParameter('SelectExtent',[],@isnumeric);
    p.addParameter('SelectEndOfCode',false,@islogical);
    p.parse(varargin{:});
    results=p.Results;



    propertyBlocks=mtfind(mt,'Kind','PROPERTIES');
    if isempty(propertyBlocks)
        classDefNode=mtfind(mt,'Kind','CLASSDEF');
        cmds=insertPropertyInClassWithNoPropertyBlocks(classDefNode,propertyCode,results);
    else
        [propertyBlock,insertCmd]=getPropertyBlockForInsertion(propertyBlocks,results);

        switch(insertCmd)
        case 'before'
            cmds=insertPropertyBeforePropertyBlock(propertyBlock,propertyCode,results);
        case 'after'
            cmds=insertPropertyAfterPropertyBlock(propertyBlock,propertyCode,results);
        case 'in'
            cmds=insertPropertyInPropertyBlock(propertyBlock,propertyCode,results);
        end
    end
end

function cmds=insertPropertyInClassWithNoPropertyBlocks(classDefNode,propertyCode,args)

    defaultSpacesPerIndent=matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
    code=matlab.system.editor.internal.CodeTemplate.getNewPropertyBlockCode(defaultSpacesPerIndent,propertyCode,args);

    if isnull(classDefNode.Body)

        L=pos2lc(classDefNode,righttreepos(classDefNode));
    else

        bodyNode=matlab.system.editor.internal.ParseTreeUtils.getNextNonCommentNode(...
        classDefNode.Cexpr,classDefNode.Body);
        if isnull(bodyNode)

            L=pos2lc(classDefNode,righttreepos(classDefNode));
        else

            L=pos2lc(bodyNode,lefttreepos(bodyNode));
            code=[code,newline];
        end
    end

    propertyCodeIndentSpaces=defaultSpacesPerIndent+defaultSpacesPerIndent;
    propertyCodeSpaces=numel(propertyCode);
    cmds=createCmds(code,L,L+1,propertyCodeIndentSpaces,propertyCodeSpaces,args);
end

function cmds=insertPropertyBeforePropertyBlock(propertyBlock,propertyCode,args)

    [L,C]=matlab.system.editor.internal.ParseTreeUtils.getCodePreInsertionPosition(propertyBlock);
    initialIndentSpaces=C-1;

    code=matlab.system.editor.internal.CodeTemplate.getNewPropertyBlockCode(initialIndentSpaces,propertyCode,args);
    code=[code,newline];

    propertyCodeIndentSpaces=initialIndentSpaces+matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
    propertyCodeSpaces=numel(propertyCode);
    cmds=createCmds(code,L,L+1,propertyCodeIndentSpaces,propertyCodeSpaces,args);
end

function cmds=insertPropertyAfterPropertyBlock(propertyBlock,propertyCode,args)


    [L,C]=pos2lc(propertyBlock,righttreepos(propertyBlock));
    initialIndentSpaces=C-3;

    code=matlab.system.editor.internal.CodeTemplate.getNewPropertyBlockCode(initialIndentSpaces,propertyCode,args);
    code=[newline,code];

    L=L+1;
    propertyCodeIndentSpaces=initialIndentSpaces+matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
    propertyCodeSpaces=numel(propertyCode);
    cmds=createCmds(code,L,L+2,propertyCodeIndentSpaces,propertyCodeSpaces,args);
end

function cmds=insertPropertyInPropertyBlock(propertyBlock,propertyCode,args)


    lastNode=propertyBlock.Body;
    while~isnull(lastNode.Next)
        lastNode=lastNode.Next;
    end

    if isnull(lastNode)


        [~,C]=pos2lc(propertyBlock,lefttreepos(propertyBlock));
        propertyCodeIndentSpaces=C-1+matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
        attributesNode=propertyBlock.Attr;
        if isnull(attributesNode)
            L=pos2lc(propertyBlock,lefttreepos(propertyBlock));
        else
            L=pos2lc(attributesNode,righttreepos(attributesNode));
        end
    else


        if strcmp(lastNode.kind,'COMMENT')&&~isnull(lastNode.previous)
            propertyNode=lastNode.previous;
            while~strcmp(propertyNode.kind,'EQUALS')&&~isnull(propertyNode.previous)
                propertyNode=propertyNode.previous;
            end



            if strcmp(propertyNode.kind,'EQUALS')
                L=pos2lc(lastNode,lefttreepos(lastNode));
                Lprev=pos2lc(propertyNode,righttreepos(propertyNode));
                if Lprev>=L
                    lastNode=propertyNode;
                end
            end
        end



        [~,C]=pos2lc(lastNode,lefttreepos(lastNode));
        propertyCodeIndentSpaces=C-1;
        L=pos2lc(lastNode,righttreepos(lastNode));
    end

    initialIndent=repmat(' ',1,propertyCodeIndentSpaces);
    code=sprintf('%s%s',initialIndent,propertyCode);





    L=L+1;
    Lend=pos2lc(propertyBlock,righttreepos(propertyBlock));
    if(Lend==L)
        code=[code,newline];
    end

    propertyCodeSpaces=numel(propertyCode);
    cmds=createCmds(code,L,L,propertyCodeIndentSpaces,propertyCodeSpaces,args);
end

function[insertionBlock,insertCmd]=getPropertyBlockForInsertion(propertyBlocks,args)


    ind=indices(propertyBlocks);
    propertyBlocksInfo={};
    for propertiesBlockIndex=flip(ind)
        propertyBlock=select(propertyBlocks,propertiesBlockIndex);

        [setAccess,getAccess,attributes]=...
        matlab.system.editor.internal.ParseTreeUtils.getPropertyBlockAttributes(propertyBlock);
        if ismember('Constant',attributes)
            isAccessMatch=strcmp(args.GetAccess,getAccess);
        elseif ismember('DiscreteState',attributes)
            isAccessMatch=strcmp(args.SetAccess,setAccess);
        else
            isAccessMatch=strcmp(args.SetAccess,setAccess)&&strcmp(args.GetAccess,getAccess);
        end
        if isAccessMatch&&isempty(setxor(args.Attributes,attributes))
            insertionBlock=propertyBlock;
            insertCmd='in';
            return;
        else

            blockInfo=struct('SetAccess',setAccess,'GetAccess',getAccess);
            blockInfo.Attributes=attributes;
            blockInfo.Node=propertyBlock;
            propertyBlocksInfo{end+1}=blockInfo;%#ok<*AGROW>
        end
    end


    newBlockAccessScore=getAccessScore(args);
    matchingAccessBlocksInfo=findPropertyBlocks(propertyBlocksInfo,@getAccessScore,newBlockAccessScore);
    if isempty(matchingAccessBlocksInfo)

        [insertionBlock,insertCmd]=getPropertyBlockForInsertionByScore(...
        propertyBlocksInfo,@getAccessScore,newBlockAccessScore);
    else

        newBlockTypeScore=getTypeScore(args);
        matchingTypeBlocksInfo=findPropertyBlocks(matchingAccessBlocksInfo,@getTypeScore,newBlockTypeScore);

        if isempty(matchingTypeBlocksInfo)

            [insertionBlock,insertCmd]=getPropertyBlockForInsertionByScore(...
            matchingAccessBlocksInfo,@getTypeScore,newBlockTypeScore);
        else

            newBlockTunabilityScore=getTunabilityScore(args);
            matchingTunabilityBlocksInfo=findPropertyBlocks(matchingTypeBlocksInfo,@getTunabilityScore,newBlockTunabilityScore);

            if isempty(matchingTunabilityBlocksInfo)

                [insertionBlock,insertCmd]=getPropertyBlockForInsertionByScore(...
                matchingTypeBlocksInfo,@getTunabilityScore,newBlockTunabilityScore);
            else


                insertionBlock=matchingTunabilityBlocksInfo{1}.Node;
                insertCmd='after';
            end
        end
    end
end

function matchingBlocksInfo=findPropertyBlocks(propertyBlocksInfo,scoreFcn,newBlockTypeScore)


    matchingBlocksInfo={};
    for k=1:numel(propertyBlocksInfo)
        blockInfo=propertyBlocksInfo{k};
        if newBlockTypeScore==scoreFcn(blockInfo)
            matchingBlocksInfo{end+1}=blockInfo;
        end
    end
end

function[insertionBlock,insertCmd]=getPropertyBlockForInsertionByScore(propertyBlocksInfo,scoreFcn,newBlockScore)








    for k=1:numel(propertyBlocksInfo)
        blockInfo=propertyBlocksInfo{k};
        if scoreFcn(blockInfo)<newBlockScore
            insertionBlock=blockInfo.Node;
            insertCmd='after';
            return;
        end
    end
    insertionBlock=propertyBlocksInfo{end}.Node;
    insertCmd='before';
end

function score=getAccessScore(blockInfo)


    switch blockInfo.GetAccess
    case 'public'
        score=0;
    case 'protected'
        score=7;
    case 'friends'
        score=14;
    case 'private'
        score=21;
    end



    impliedSetAccess=blockInfo.SetAccess;
    if ismember('Constant',blockInfo.Attributes)
        impliedSetAccess='constant';
    elseif ismember('DiscreteState',blockInfo.Attributes)
        impliedSetAccess='discretestate';
    end

    switch impliedSetAccess
    case 'public'
        score=score+0;
    case 'immutable'
        score=score+1;
    case 'protected'
        score=score+2;
    case 'friends'
        score=score+3;
    case 'private'
        score=score+4;
    case 'discretestate'
        score=score+5;
    case 'constant'
        score=score+6;
    end
end

function score=getTypeScore(blockInfo)


    attributes=blockInfo.Attributes;
    if ismember('Logical',attributes)
        score=0;
    elseif isfield(blockInfo,'IsStringSet')&&blockInfo.IsStringSet


        score=1;
    elseif ismember('PositiveInteger',attributes)
        score=2;
    else
        score=3;
    end
end

function score=getTunabilityScore(blockInfo)


    if ismember('Nontunable',blockInfo.Attributes)
        score=1;
    else
        score=0;
    end
end

function cmds=createCmds(allCode,Linsert,Lselect,propertyCodeIndentSpaces,propertyCodeSpaces,args)

    insertCmd=struct('Action','insert',...
    'Text',allCode,'Line',Linsert,'Column',1);
    cmds={insertCmd};
    if args.Select
        if isempty(args.SelectExtent)
            CselectEnd=propertyCodeIndentSpaces+propertyCodeSpaces+1;
        else
            CselectEnd=propertyCodeIndentSpaces+args.SelectExtent+1;
        end

        if args.SelectEndOfCode
            CselectStart=CselectEnd;
        else
            CselectStart=propertyCodeIndentSpaces+1;
        end
        selectCmd=struct('Action','select',...
        'StartLine',Lselect,'StartColumn',CselectStart,...
        'EndLine',Lselect,'EndColumn',CselectEnd);
        cmds{end+1}=selectCmd;
    end
end
