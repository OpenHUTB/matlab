function rtwHighlightInReport(blockId,scriptId,color,varargin)
























    error(javachk('swing'));


    [sid,chartId,objectId,blockHandle]=describeBlock(blockId);
    scriptId=normalizeScriptIdentifier(scriptId,sid);
    intervals=processRangeArguments(varargin{:});
    if~isempty(intervals)
        color=validateColor(color);
    end





    [spec,~]=computeSpec(chartId,blockHandle);
    sfOutput=sfprivate('eml_report_manager','open',chartId,blockHandle);
    if~any(strcmp(spec,{sfOutput{:,3}}))%#ok<CCAT1>
        [spec,~]=computeSpec(chartId,blockHandle);
    end
    [r,~]=size(sfOutput);
    report=[];
    for i=1:r
        if chartId==sfOutput{i,1}
            if~strcmp(spec,sfOutput{i,3})
                sfprivate('eml_report_manager','close_single',sfOutput{i,1},sfOutput{i,3});
            else
                report=sfOutput{i,2};
            end
        else
            sfOutput{i,2}.clearHighlights();
        end
    end

    assert(~isempty(report));


    report.integrateRtwTraceability(objectId);


    report.setProperty('sid',sid);
    report.setProperty('chartId',chartId);
    report.setProperty('objectId',objectId);
    report.setProperty('handle',blockHandle);


    if~isempty(intervals)
        report.highlight(scriptId,color,intervals);
    else

        report.clearHighlights();
    end
end




function[sid,chartId,objectId,slHandle]=describeBlock(blockId)
    if ischar(blockId)

        if~Simulink.ID.isValid(blockId)

            blockId=Simulink.ID.getSID(blockId);
        end
        assert(Simulink.ID.isValid(blockId),'''%s'' is not a valid SID',blockId);

        sid=blockId;
        objHandle=Simulink.ID.getHandle(sid);

        if isa(objHandle,'Stateflow.Object')
            objectId=objHandle.Id;
            chartId=sf('get',objectId,'state.chart');
            slHandle=0;
        else
            assert(isnumeric(objHandle));
            slHandle=objHandle;
            deriveStateflowContext();
        end
    elseif isnumeric(blockId)

        validateattributes(blockId,{'double'},{'scalar','nonnegative'},...
        'rtwHighlightInReport','blockId');

        slHandle=blockId;
        sid=Simulink.ID.getSID(slHandle);
        deriveStateflowContext();
    else

        validateattributes(blockId,{'DAStudio.Object'},{'scalar','nonempty'},...
        'rtwHighlightInReport','blockId');
        if isa(blockId,'Simulink.Object')
            sid=Simulink.ID.getSID(blockId);
            slHandle=get_param(sid,'Handle');
            deriveStateflowContext();
        elseif isa(blockId,'Stateflow.Object')
            direct=isa(blockId,'Stateflow.EMChart');

            if direct

                chartId=blockId.Id;
                deriveObjectIdFromFunctions();
            else

                objectId=blockId.Id;
                chartId=sf('get',objectId,'state.chart');
            end

            chartSlHandle=sfprivate('chart2block',chartId);
            sid=Simulink.ID.getStateflowSID(blockId,chartSlHandle);

            if direct

                slHandle=chartSlHandle;
            else

                slHandle=0;
            end
        else
            error('Unsupported DAStudio.Object subclass ''%s''',class(blockId));
        end
    end

    function deriveStateflowContext()
        chartId=sfprivate('block2chart',sid);
        deriveObjectIdFromFunctions();
    end

    function deriveObjectIdFromFunctions()
        functions=sfprivate('eml_based_fcns_in',chartId);
        assert(~isempty(functions),'Could not find function IDs for chart %d',chartId);
        objectId=functions(1);
    end
end


function flattened=processRangeArguments(varargin)
    if nargin==1
        pairs=varargin{1};
    else
        pairs=cell2mat(varargin);
    end

    if~isempty(pairs)
        index=1;
        if~isvector(pairs)

            pairs=varargin{1};
            validateattributes(pairs,{'numeric'},{});
            flattened=zeros(numel(pairs),1);

            for pair=pairs'
                validateInterval(pair(:));
            end
        else
            assert(~mod(numel(pairs),2),'Ranges must be specified in start-end pairs');
            flattened=zeros(numel(pairs),1);

            for i=1:2:numel(pairs)
                validateInterval(pairs(i:i+1));
            end
        end
    else
        flattened=[];
    end


    flattened=int32(flattened);

    function validateInterval(pair)
        validateattributes(pair,{'numeric'},{'numel',2,'increasing'},...
        'rtwHighlightInReport','varargin');
        flattened(index:index+1)=pair;
        index=index+2;
    end
end


function scriptId=normalizeScriptIdentifier(scriptArg,sid)
    if~ischar(scriptArg)
        assert(isempty(scriptArg),'Script identifier should either be char or empty.');
    end

    if isempty(scriptArg)
        scriptId=['#',sid];
    else
        scriptId=scriptArg;
    end
end


function color=validateColor(colorArg)
    if isnumeric(colorArg)
        validateattributes(colorArg,{'numeric'},{'integer',...
        'vector','>=',0,'<=',255},'rtwHighlightInReport','color');
        assert(numel(colorArg)==3||numel(colorArg)==4,...
        'Colors should be specified as RGB or RGBA vectors');


        colorArg=uint8(colorArg);

        if numel(colorArg)==3

            color=java.awt.Color(colorArg(1),colorArg(2),colorArg(3));
        else

            color=java.awt.Color(colorArg(1),colorArg(2),colorArg(3),colorArg(4));
        end
    elseif ischar(colorArg)
        color=colorArg;
    else
        error('Unsupported color format');
    end
end

function[spec,hBlk]=computeSpec(chartId,blockHandle)
    if blockHandle~=0
        hBlk=blockHandle;
    else
        hBlk=computeBlockHandle(chartId);
    end
    spec=sf('SFunctionSpecialization',chartId,hBlk,true);
    if isempty(spec)





        spec=sf('MD5AsString',getfullname(hBlk));
    end
end

function hBlk=computeBlockHandle(chartId)
    hBlk=sfprivate('chart2block',chartId);
    if sfprivate('model_is_a_library',bdroot(hBlk))
        hBlk=sf('get',chartId,'chart.activeInstance');
    end
end
