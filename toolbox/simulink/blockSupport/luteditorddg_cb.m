function luteditorddg_cb(dlgH,blkHdl)







    blockStrings=struct(...
    'BlockType',{'Lookup',...
    'PreLookup',...
    'Interpolation_n-D',...
    'Lookup_n-D',...
    'Lookup2D',...
    'LookupNDDirect'},...
    'TestParam',{{'InputValues','OutputValues'},...
    {'BreakpointsData'},...
    {'Table'},...
    {'Table','BreakpointsForDimension1'},...
    {'OutputValues','RowIndex','ColumnIndex'},...
    {'Table'}}...
    );

    blockIdx=find(strcmp(blkHdl.BlockType,{blockStrings(:).BlockType}));
    if isempty(blockIdx)
        return;
    end

    thisBlock=blockStrings(blockIdx);



    dlgSrc=dlgH.getSource;
    [dialogOK,errmsg]=dlgSrc.preApplyCallback(dlgH);

    if(~dialogOK)
        ME=MException('Simulink:tools:LUTEditorPreApplyCallbackError',...
        errmsg);
        throw(ME);
    end


    dlgH.apply;

    if dialogOK&&~isempty(thisBlock.TestParam)



        if(strcmp(thisBlock.BlockType,'PreLookup')...
            &&strcmp(get(blkHdl,'BreakpointsSpecification'),'Breakpoint object'))
            thisBlock.TestParam={'BreakpointObject'};
        end

        if(strcmp(thisBlock.BlockType,'Lookup_n-D')...
            &&strcmp(get(blkHdl,'DataSpecification'),'Lookup table object'))
            thisBlock.TestParam={'LookupTableObject'};
        end

        if(strcmp(thisBlock.BlockType,'Interpolation_n-D')&&...
            strcmp(get(blkHdl,'TableSpecification'),'Lookup table object'))
            thisBlock.TestParam={'LookupTableObject'};
        end

        for paramIdx=1:length(thisBlock.TestParam)
            oneParam=thisBlock.TestParam{paramIdx};
            try
                try
                    data=evalin('base',get_param(blkHdl.getFullName,sl('deblankall',oneParam)));%#ok<NASGU>
                catch %#ok<CTCH>
                    data=slResolve(get_param(blkHdl.getFullName,sl('deblankall',oneParam)),blkHdl.getFullName);%#ok<NASGU>
                end
            catch anError


                DAStudio.error('Simulink:tools:LUTEditorNoUndefinedExpressions',oneParam,blkHdl.getFullName);
            end
        end
    end


    if dialogOK
        sltbledit('create',blkHdl.getFullName);
    end

