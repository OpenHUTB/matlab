function isCompatible=isInstructionSetCompatibleWithLibrary(varargin)




    narginchk(1,2);
    instructionSetName=varargin{1};
    if nargin==2
        stricEqualCheck=varargin{2};
    else
        stricEqualCheck=false;
    end

    import targetrepository.query.where
    import targetrepository.query.is

    intrinsicSet=target.internal.get('InstructionSet',where('Name',is(instructionSetName)));
    crlTable=loc_getCrlTable(instructionSetName);

    unfoundLhs={};%#ok<NASGU>
    unfoundRhs={};
    if isempty(intrinsicSet)||isempty(crlTable)
        isCompatible=false;
    else
        intrinsicVector=...
        RTW.InstructionSetChecker.generateInstructionsFromSimdTable(crlTable);
        if stricEqualCheck
            [isCompatible,unfoundLhs,unfoundRhs]=RTW.InstructionSetChecker.isInstructionSetEqual(...
            intrinsicSet.Instructions,...
            intrinsicVector);
        else


            [isCompatible,unfoundLhs]=RTW.InstructionSetChecker.isInstructionSetEqualOrSubset(...
            intrinsicSet.Instructions,...
            intrinsicVector);
        end
        displayErrorIfNecessary(unfoundLhs,unfoundRhs);
    end
end

function hTflTable=loc_getCrlTable(instructionSetName)
    hTflTable=[];
    switch(instructionSetName)
    case 'SSE'
        load('inline_intel_sse_crl_table.mat','hTflTable');
    case 'SSE2'
        load('inline_intel_sse2_crl_table.mat','hTflTable');
    case 'SSE4.1'
        load('inline_intel_sse41_crl_table.mat','hTflTable');
    case 'AVX'
        load('inline_intel_avx_crl_table.mat','hTflTable');
    case 'AVX2'
        load('inline_intel_avx2_crl_table.mat','hTflTable');
    case 'FMA'
        load('inline_intel_fma_crl_table.mat','hTflTable');
    case 'AVX512F'
        load('inline_intel_avx512f_crl_table.mat','hTflTable');
    otherwise
    end
end

function displayErrorIfNecessary(unfoundLhs,unfoundRhs)
    if~isempty(unfoundLhs)
        displayError('Instructions from target not found in Table:',unfoundLhs);
    end

    if~isempty(unfoundRhs)
        displayError('Instructions generated from Crl Table not found in target:',unfoundRhs);
    end
end

function displayError(errorTitle,unfoundInstructions)
    disp(errorTitle)
    for i=1:length(unfoundInstructions)
        disp([unfoundInstructions{i}.Intrinsic,' ,'...
        ,unfoundInstructions{i}.BaseType,' ,'...
        ,int2str(unfoundInstructions{i}.Width)]);
    end
end
