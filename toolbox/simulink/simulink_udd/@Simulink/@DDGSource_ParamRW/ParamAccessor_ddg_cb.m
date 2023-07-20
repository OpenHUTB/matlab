function varargout=ParamAccessor_ddg_cb(source,action,varargin)



    blkH=varargin{1};

    switch action
    case 'selectionTree'
        paramAccessor=blkH;

        val=varargin{2};
        dlg=varargin{3};

        isDiagRefresh=false;
        newSelection=false;

        treeModel=source.TreeModel;


        if(isempty(treeModel)||...
            (strcmp(treeModel{1}.DisplayLabel,DAStudio.message('Simulink:blocks:ParameterReaderWriterSelectorTreeEmpty'))))
            dlg.enableApplyButton(false);
            return;
        end





        dlg.enableApplyButton(false);
        isValidSelection=isSelectedItemValid(treeModel,val);


        if~isValidSelection
            updateAfterSelection(dlg,newSelection,isDiagRefresh);
            return;
        end

        [paramOwner,paramName,~]=fileparts(val);
        exist_blk=check_block_exists(paramOwner);
        if~exist_blk||~isValidParamOwnerBlock(get_param(paramOwner,'Object'))
            updateAfterSelection(dlg,newSelection,isDiagRefresh);
            return;
        end


        newSelection=true;
        source.SelectedParamOwner=paramOwner;
        source.SelectedParamName=paramName;



        if dlg.isStandAlone
            updateAfterSelection(dlg,newSelection,isDiagRefresh);
            return;
        end


        set_param(paramAccessor,'ParameterOwnerBlock',paramOwner);
        set_param(paramAccessor,'ParameterName',paramName);
        source.TreeSelectedItem=val;
        modelObj=get_param(bdroot(paramAccessor),'Object');
        source.TreeExpandItems=source.getExpandTreeItems(paramOwner,modelObj.Name,0);


        if(slfeature('ParameterWriteToPartialModelArgument')>0)...
            &&source.isParamBusOrStructType(paramOwner,paramName).isBusOrStructType


            if isempty(source.BusTreeSelectedElement)
                source.BusTreeSelectedElement=paramName;
            end
            paramName=regexprep(source.BusTreeSelectedElement,'/','.');
            set_param(paramAccessor,'ParameterName',paramName);
            set_param(paramAccessor,'AccessBusElement','on');
            isDiagRefresh=true;
        else
            set_param(paramAccessor,'AccessBusElement','off');
        end

        if(slfeature('ParameterWriteToPartialModelArgument')>0)...
            &&strcmp(get_param(blkH,'AccessBusElement'),'on')
            isDiagRefresh=true;
        end
        updateAfterSelection(dlg,newSelection,isDiagRefresh);

    case 'selectionBusElement'
        paramAccessor=blkH;
        val=varargin{2};
        dlg=varargin{3};

        indexes=strfind(source.TreeSelectedItem,'/');
        paramName=source.TreeSelectedItem(indexes(end)+1:end);
        source=dlg.getDialogSource;

        source.BusTreeSelectedElement=val;
        source.BusTreeExpandElements=source.getExpandTreeItems(val,paramName,1);
        set_param(paramAccessor,'ParameterName',regexprep(val,'/','.'));
        dlg.enableApplyButton(true);

    case 'hilite'
        blkPath=varargin{2};
        hilite_system(blkPath);
    case 'CheckEmptyParam'
        dlg=varargin{2};
        paramOwner=get_param(blkH,'ParameterOwnerBlock');
        paramName=get_param(blkH,'ParameterName');
        if~isempty(paramOwner)&&isempty(paramName)
            dlg.enableApplyButton(false);
            dp=DAStudio.DialogProvider;
            dp.errordlg(DAStudio.message('Simulink:blocks:ParamWriterParameterNameNotSet',paramOwner),...
            'Error',true);

        end
    otherwise
        assert(false,'Unexpected action');
    end

end




function updateAfterSelection(dlg,newSelection,isDiagRefresh)
    source=dlg.getDialogSource;
    if~isempty(source.SelectedParamOwner)&&~isempty(source.SelectedParamName)
        selectedItem=[source.SelectedParamOwner,'/',source.SelectedParamName];
        dlg.setWidgetValue('tree_SystemHierarchy',selectedItem);

        if(newSelection)
            dlg.enableApplyButton(newSelection);
        end

        if(isDiagRefresh)
            dlg.refresh;
        end
    end
end


function isValid=isSelectedItemValid(treeModel,selTreeNodePath)
    labels=regexp(selTreeNodePath,'/','split');
    assert(~isempty(labels));

    currentNode=treeModel{1};
    isValid=false;
    if~strcmp(currentNode.DisplayLabel,labels(1))
        return;
    end

    i=2;
    while(i<=length(labels))
        children=currentNode.Children;



        found=false;
        for j=1:length(children)
            if(strcmp(children{j}.DisplayLabel,labels(i)))
                currentNode=children{j};
                i=i+1;
                found=true;
                break;
            end
        end
        if(~found)
            return;
        end
    end

    assert(i>length(labels));
    if(isempty(currentNode.Children))
        isValid=true;
    end
end

function exist_blk=check_block_exists(blk)
    modelC=regexp(blk,'(^[^/]*)','tokens');
    model=cell2mat(modelC{1});
    all_blks=find_system(model,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.allVariants);
    exist_blk=~isempty(find(strcmp(all_blks,blk),1));
end

function result=isValidParamOwnerBlock(blkObj)




    result=false;
    try


        blk=blkObj.getFullName;
        if strcmpi(get_param(blk,'IsParamOwnerBlock'),'on')||blkObj.isMasked
            result=true;
        end
    catch
    end
end

