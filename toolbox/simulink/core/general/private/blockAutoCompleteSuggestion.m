function[suggestions,expressionData]=blockAutoCompleteSuggestion(varargin)














    acPos=zeros(1,4);
    expressionData={'',''};
    suggestions={};
    if(nargin<3)
        return;
    end

    text=varargin{1};
    propertyName=varargin{2};
    src=varargin{3};
    curPos=varargin{4};

    [parent,blockFullName,dlgSrc,searchLoc]=getBlockInformationFromSource(src,propertyName);

    if isempty(blockFullName)||isempty(parent)
        return;
    else
        try
            if isa(dlgSrc,'Simulink.Line')
                blkHandle=0;
            else
                blkHandle=dlgSrc.Handle;
            end
            mdl_name='';
            ssref_block_with_dd=slprivate('getNearestSSRefBlockWithDDAttached',blockFullName);
            if~isempty(ssref_block_with_dd)
                mdl_name=get_param(ssref_block_with_dd,'ReferencedSubsystem');
            end
            if isempty(mdl_name)
                bdRoot=parent;
                while~isa(bdRoot,'Simulink.BlockDiagram')
                    bdRoot=bdRoot.getParent;
                end
                mdl_name=bdRoot.getFullName;
            end
            if isempty(mdl_name)
                return;
            end


            if~(src.hasPropertyActions(propertyName))

                if contains(propertyName,'Unit','IgnoreCase',true)

                    suggestions=Simulink.UnitPrmWidget.getUnitSuggestions(text,blkHandle);
                end
            else

                classSuggestion=dlgSrc.getClassSuggestion(propertyName);
                blkCtrlr=Simulink.BlockEditTimeController;
                if(isempty(searchLoc))

                    searchLoc='startAboveMask';
                end
                [rawList,expressionData]=blkCtrlr.getAutoCompleteSuggestions(text,propertyName,blkHandle,mdl_name,classSuggestion,searchLoc,curPos);
                suggestions=(rawList(~cellfun('isempty',rawList)))';
                expressionData=expressionData';
            end
        catch err

        end
    end
