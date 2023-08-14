function newRules=blockToSFunction(obj,...
    blockType,...
    maskType,...
    fcnName,...
    oldRef,...
    setupSFunction,...
    varargin)


















































    p=inputParser;

    p.addRequired('obj',@(x)isa(x,'slexportprevious.internal.PreprocessHelper'));
    p.addRequired('blockType',@ischar);
    p.addRequired('maskType',@ischar);
    p.addRequired('fcnName',@ischar);
    p.addRequired('oldRef',@ischar);
    p.addRequired('setupSFunction',@(x)isa(x,'function_handle'));



    p.addParameter('PreProcessNewBlock',[],@(x)isempty(x)||isa(x,'function_handle'));
    p.addParameter('PostProcessNewBlock',[],@(x)isempty(x)||isa(x,'function_handle'));



    p.addParameter('FindByMaskType',false,@(x)islogical(x));


    p.parse(obj,blockType,maskType,fcnName,oldRef,setupSFunction,varargin{:});
    preproNewBlock=p.Results.PreProcessNewBlock;
    postproNewBlock=p.Results.PostProcessNewBlock;
    findByMaskType=p.Results.FindByMaskType;

    newRules={};






    if findByMaskType
        blocks=find_system(obj.modelName,'LookUnderMasks','on',...
        'IncludeCommented','on',...
        'MaskType',maskType,'BlockType',blockType);
    else
        blocks=slexportprevious.utils.findBlockType(obj.modelName,blockType);
    end

    if(isempty(blocks))
        return;
    end


    lib_mdl=getTempLib(obj);



    lblockname=obj.generateTempName;
    sfuncBlk=[lib_mdl,'/',lblockname];


    add_block('built-in/S-Function',sfuncBlk);


    maskVarNames=setupSFunction(sfuncBlk);


    set_param(sfuncBlk,...
    'Mask','on',...
    'FunctionName',fcnName,...
    'MaskType',maskType...
    );

    save_system(lib_mdl);









    blkParamNames=[{'Orientation','Position'},maskVarNames];
    blkParamValues=cell(size(blkParamNames));

    for i=1:length(blocks)
        blk=blocks{i};


        for j=1:length(blkParamNames)
            blkParamValues{j}=get_param(blk,blkParamNames{j});
        end







        ports=get_param(blk,'Ports');
        numInputPorts=num2str(ports(1));
        numOutputPorts=num2str(ports(2));


        if~isempty(preproNewBlock)&&isa(preproNewBlock,'function_handle')
            [preproParamNames,preproParamValues]=preproNewBlock(blk);
            names=[blkParamNames,preproParamNames];
            values=[blkParamValues,preproParamValues];
            nameValuePairs=[names(:),values(:)]';
        else
            nameValuePairs=[blkParamNames(:),blkParamValues(:)]';
        end


        delete_block(blk);

        add_block(sfuncBlk,blk,...
        'GraphicalNumInputPorts',numInputPorts,...
        'GraphicalNumOutputPorts',numOutputPorts,...
        nameValuePairs{:});


        if~isempty(postproNewBlock)&&isa(postproNewBlock,'function_handle')
            [blkParamNames,blkParamValues]=postproNewBlock(blk,blkParamNames,blkParamValues);
        end

    end



    newRules=['1',slexportprevious.rulefactory.replaceInSourceBlock('SourceBlock',...
    sfuncBlk,oldRef)];

end
