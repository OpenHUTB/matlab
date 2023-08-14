classdef LibraryLinkToolSpreadsheet<handle
    properties
        m_modelName;
        m_Columns;
        m_Children;
        m_SelectionCount;

    end

    properties(Hidden=true,Constant=true)
        sBlockNameColumn=DAStudio.message('Simulink:Libraries:LibraryLinkToolSpreadSheetBlockColumnName');
        sLibraryNameColumn=DAStudio.message('Simulink:Libraries:LibraryLinkToolSpreadSheetLibraryColumnName');
    end

    methods
        function this=LibraryLinkToolSpreadsheet(modelName)
            this.m_modelName=modelName;
            this.m_Columns={LibraryLinkToolSpreadsheet.sBlockNameColumn,LibraryLinkToolSpreadsheet.sLibraryNameColumn};
            this.m_Children=this.getChildren();
            this.m_SelectionCount=0;

        end

        function children=getChildren(this)

            if~isempty(this.m_Children)
                children=this.m_Children;
                return;
            else
                model=this.m_modelName;
                children=populateChildren(this,model);
                this.m_Children=children;

            end
        end

        function children=populateChildren(this,model)
            load_system(model);

            blocks=getInactiveBlocksList(this,model);
            if isempty(blocks)
                children=[];
                return;
            end

            children=repmat(LibraryLinkToolSpreadsheetRow(),[1,length(blocks)]);
            for i=1:length(blocks)
                childrenArray=DFS(this,blocks{i});
                childObj=LibraryLinkToolSpreadsheetRow(blocks{i},getLibraryPath(this,blocks{i}),childrenArray,model);
                children(i)=childObj;
            end
        end


        function childrenArray=DFS(this,block)

            blocks=getInactiveBlocksList(this,block);

            if length(blocks)<1
                childrenArray=[];
                return;
            end

            childrenArray=repmat(LibraryLinkToolSpreadsheetRow(),[1,length(blocks)]);
            for k=1:length(blocks)
                child=DFS(this,blocks{k});
                childrenArray(k)=LibraryLinkToolSpreadsheetRow(blocks{k},getLibraryPath(this,blocks{k}),child,block);
            end

        end
        function row=disabledSpreadsheetDeleteRow(this,row,deletedBlockName)
            children=row.m_Children;
            if isempty(children)
                return;
            end
            for i=1:length(children)
                child=children(i);
                if strcmp(child.m_BlockName,deletedBlockName)
                    children(i)=[];
                    row.m_Children=children;
                    return;
                else
                    updatedChild=this.disabledSpreadsheetDeleteRow(child,deletedBlockName);
                    children(i)=updatedChild;
                    row.m_Children=children;
                end
            end

        end

        function updateUI(this,dialogH,spreadsheetTag)
            ssComp=dialogH.getWidgetInterface(spreadsheetTag);
            ssComp.update(true);
        end

        function librarypath=getLibraryPath(this,block)
            librarypath=get_param(block,'AncestorBlock');
        end

        function spreadsheetObj=updateSpreadsheetChildren(spreadsheetObj)
            spreadsheetObj.m_Children=[];
            children=spreadsheetObj.getChildren();
            spreadsheetObj.m_Children=children;
            spreadsheetObj.m_SelectionCount=0;
        end
        function updateSelectionCount(this,dialogH,ssTag,selectionCount)
            spreadsheetObj=dialogH.getUserData(ssTag);
            spreadsheetObj.m_SelectionCount=selectionCount;
            dialogH.setUserData(ssTag,spreadsheetObj);

        end

        function row=findAndUpdateRow(this,row,newRow)
            children=row.m_Children;
            if isempty(children)
                return;
            end
            for i=1:length(children)
                child=children(i);
                if strcmp(child.m_BlockName,newRow.m_BlockName)==1
                    children(i)=newRow;
                    row.m_Children=children;
                    return;
                else
                    updatedChild=this.findAndUpdateRow(child,newRow);
                    children(i)=updatedChild;
                    row.m_Children=children;
                end
            end

        end

        function updateRow(this,dialogH,ssTag,newRow)
            spreadsheetObj=dialogH.getUserData(ssTag);
            spreadsheetObj=this.findAndUpdateRow(spreadsheetObj,newRow);
            dialogH.setUserData(ssTag,spreadsheetObj);

        end

        function inactiveBlocks=getInactiveBlocksList(this,model)

            blocks=find_system(model,'IncludeCommented','on','LookUnderMasks','on',...
            'MatchFilter',@Simulink.match.allVariants,'StaticLinkStatus','inactive');
            inactiveBlocks={};

            if isempty(blocks)
                return;
            end
            loopStartingIndex=1;
            if~isempty(strfind(model,'/'))
                if length(blocks)<2
                    return;
                end
                loopStartingIndex=2;
            end

            for i=loopStartingIndex:length(blocks)
                flag=0;
                tokenizedBlock=strsplit(blocks{i},'/');

                if~isempty(inactiveBlocks)
                    for j=1:length(inactiveBlocks)
                        tokenizedInactiveBlock=strsplit(inactiveBlocks{j},'/');
                        anyConflictWithCurrentInactiveBlock=0;
                        if length(tokenizedBlock)~=length(tokenizedInactiveBlock)
                            anyConflictWithCurrentInactiveBlock=1;
                            minLength=min(length(tokenizedInactiveBlock),length(tokenizedBlock));
                            for iterator=1:minLength
                                if~strcmp(tokenizedInactiveBlock{iterator},tokenizedBlock{iterator})
                                    anyConflictWithCurrentInactiveBlock=0;
                                    break;
                                end
                            end
                        end
                        if anyConflictWithCurrentInactiveBlock==1
                            flag=1;
                        end
                    end
                end

                if~flag
                    inactiveBlocks{end+1}=blocks{i};
                end
            end
        end

    end

end
