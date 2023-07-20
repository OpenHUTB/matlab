function lookupNdBlocks(obj)






    blkType='Lookup_n-D';

    if isR2016aOrEarlier(obj.ver)

        LookupNdBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if(~isempty(LookupNdBlks))


            for i=1:length(LookupNdBlks)
                blk=LookupNdBlks{i};

                if strcmp(get_param(blk,'DataSpecification'),'Lookup table object')


                    obj.replaceWithEmptySubsystem(blk);
                end
            end
        end
    end

    if isR2015aOrEarlier(obj.ver)

        LookupNdBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if(~isempty(LookupNdBlks))


            for i=1:length(LookupNdBlks)
                blk=LookupNdBlks{i};

                if strcmp(get_param(blk,'BreakpointsSpecification'),'Explicit values')
                    continue;
                end

                obj.replaceWithEmptySubsystem(blk);
            end
        end
    end

    if isR2007aOrEarlier(obj.ver)


        maskType='LookupNDInterp';
        fcnName='sfun_lookupnd';
        refRule='simulink/Lookup\nTables/Lookup\nTable (n-D)';
        setFcn=@setupLookupNdBlock;
        preFcn=@preproLookupNdBlock;

        pre2007aRules=blockToSFunction(obj,blkType,...
        maskType,...
        fcnName,...
        refRule,...
        setFcn,...
        'PreProcessNewBlock',preFcn);

        obj.appendRules(pre2007aRules);

    end

end


function maskVarNames=setupLookupNdBlock(sfcn)


    set_param(sfcn,...
    'Parameters','numDims,tableData,bp1,bp2,bp3,bp4,bpcell,searchMode,cacheBpFlag,vectorInputFlag,interpMethod,extrapMethod,rangeErrorMode',...
    'MaskVariables','numDimsPopupSelect=@1;bp1=@2;bp2=@3;bp3=@4;bp4=@5;bpcell=@6;explicitNumDims=@7;searchMode=@8;cacheBpFlag=@9;vectorInputFlag=@10;tableData=@11;interpMethod=@12;extrapMethod=@13;rangeErrorMode=@14',...
    'MaskPromptString','Number of table dimensions:|First input (row) breakpoint set:|Second (column) input breakpoint set:|Third input breakpoint set:|Fourth input breakpoint set:|Fifth..Nth breakpoint sets (cell array):|Explicit number of dimensions:|Index search method:|Begin index searches using previous index results|Use one (vector) input port instead of N ports|Table data:|Interpolation method:|Extrapolation method:|Action for out of range input:',...
    'MaskStyleString','popup(   1   |   2   |   3   |   4   |More...),edit,edit,edit,edit,edit,edit,popup(Evenly Spaced Points|Linear Search|Binary Search),checkbox,checkbox,edit,popup(None - Flat|Linear|Cubic Spline),popup(None - Clip|Linear|Cubic Spline),popup(None|Warning|Error)',...
    'MaskTunableValueString','off,on,on,on,on,on,off,on,on,off,on,on,on,on',...
    'MaskCallbackString','ndlookico|||||||||||||',...
    'MaskEnableString','on,on,on,on,on,on,on,on,on,on,on,on,on,on',...
    'MaskVisibilityString','on,on,on,off,off,off,off,on,on,on,on,on,on,on',...
    'MaskToolTipString','on,on,on,on,on,on,on,on,on,on,on,on,on,on',...
    'MaskVarAliasString',',,,,,,,,,,,,,',...
    'MaskVariables','numDimsPopupSelect=@1;bp1=@2;bp2=@3;bp3=@4;bp4=@5;bpcell=@6;explicitNumDims=@7;searchMode=@8;cacheBpFlag=@9;vectorInputFlag=@10;tableData=@11;interpMethod=@12;extrapMethod=@13;rangeErrorMode=@14;',...
    'MaskSelfModifiable','on',...
    'MaskIconFrame','on',...
    'MaskIconOpaque','on',...
    'MaskIconRotate','none',...
    'MaskIconUnits','normalized',...
    'MaskValueString','   2   |[10,22,31]|[10,22,31]|[1:3]|[1:3]|{ [1:3], [1:3] }|2|Binary Search|off|off|[4 5 6;16 19 20;10 18 23]|Linear|Linear|None',...
    'MaskCapabilities','slmaskedcaps(gcbh)',...
    'MaskTabNameString',',,,,,,,,,,,,,'...
    );

    maskVarNames={
    'numDimsPopupSelect',...
    'bp1',...
    'bp2',...
    'bp3',...
    'bp4',...
    'cacheBpFlag',...
    'vectorInputFlag',...
    'tableData',...
    'rangeErrorMode'};

end


function[paramNames,paramValues]=preproLookupNdBlock(blk)
    bpcell=get_param(blk,'bpcell');
    explicitNumDims=get_param(blk,'explicitNumDims');
    searchMode=get_param(blk,'searchMode');
    interpMethod=get_param(blk,'interpMethod');
    extrapMethod=get_param(blk,'extrapMethod');

    totalDim=str2double(explicitNumDims);
    if(totalDim>4)
        bp5=get_param(blk,'bp5');
        bpcell=['{',bp5];
        for dim=6:totalDim
            bpcell=[bpcell,', ',get_param(blk,['bp',int2str(dim)])];%#ok<AGROW>
        end
        bpcell=[bpcell,'}'];
    end


    switch searchMode
    case 'Evenly spaced points'
        searchMode='Evenly Spaced Points';
    case 'Linear search'
        searchMode='Linear Search';
    case 'Binary search'
        searchMode='Binary Search';
    otherwise
    end

    if~any(strcmpi(interpMethod,{'Linear','Cubic spline'}))
        interpMethod='None - Flat';
    end

    if strcmp(interpMethod,'Cubic spline')
        interpMethod='Cubic Spline';
    end

    if strcmp(extrapMethod,'Cubic spline')
        extrapMethod='Cubic Spline';
    end

    if strcmp(extrapMethod,'Clip')
        extrapMethod='None - Clip';
    end

    paramNames={'bpcell','explicitNumDims','searchMode','interpMethod','extrapMethod'};
    paramValues={bpcell,explicitNumDims,searchMode,interpMethod,extrapMethod};

end
