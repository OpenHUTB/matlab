

classdef LibraryToolParameterizedLinksSpreadsheet<handle
    properties
        m_Columns;
        m_Children;
        m_modelName;
        m_SelectionCount;
    end

    properties(Hidden=true,Constant=true)
        sModifiedBlockNameColumn=DAStudio.message('Simulink:Libraries:LibraryToolParameterizedBlocksSpreadsheetBlockColumnName');
        sParameterColumn=DAStudio.message('Simulink:Libraries:ParameterizedLinksParametersSpreadsheetParameterColumnName');
        sParameterizedValueColumn='Parameterized Value';
        sLibraryValueColumn='Library Value';

    end

    methods
        function this=LibraryToolParameterizedLinksSpreadsheet(modelName)
            this.m_Columns={LibraryToolParameterizedLinksSpreadsheet.sModifiedBlockNameColumn,...
            LibraryToolParameterizedLinksSpreadsheet.sParameterColumn,...
            LibraryToolParameterizedLinksSpreadsheet.sParameterizedValueColumn,...
            LibraryToolParameterizedLinksSpreadsheet.sLibraryValueColumn};
            this.m_modelName=modelName;
            this.m_Children=this.getChildren();
            this.m_SelectionCount=0;

        end

        function children=getChildren(this)

            if~isempty(this.m_Children)
                children=this.m_Children;
                return;
            else
                children=populateChildren(this,this.m_modelName);
                this.m_Children=children;
            end
        end

        function children=populateChildren(this,model)
            parameterizedData=this.findParameterizedLinksData(model);

            if isempty(parameterizedData)
                children=[];
                return;
            end

            children=repmat(LibraryToolParameterizedLinksSpreadsheetRow(),[1,length(parameterizedData)]);
            for i=1:length(parameterizedData)
                child=parameterizedData{i};
                parameterizedBlockHandle=child.parameterizedBlockHandle;
                linkData=child.linkData;

                totSize=0;
                for k=1:length(linkData)
                    linkDataChild=linkData(k);
                    dialogParameters=linkDataChild.DialogParameters;
                    parameterNames=fieldnames(dialogParameters);
                    totSize=totSize+length(parameterNames);
                end

                subChildren=this.getSubChildren(parameterizedBlockHandle,linkData,totSize);
                parameterizedBlockName=getfullname(parameterizedBlockHandle);
                parameterizedBlockChild=LibraryToolParameterizedLinksSpreadsheetRow(parameterizedBlockHandle,parameterizedBlockName,'',' ',' ',subChildren,'1');
                children(i)=parameterizedBlockChild;
            end
        end

        function subChildren=getSubChildren(~,parameterizedBlockHandle,linkData,totSize)
            children=repmat(LibraryToolParameterizedLinksSpreadsheetRow(),[1,totSize]);
            c=1;

            for j=1:length(linkData)
                linkDataChild=linkData(j);
                modifiedBlock=linkDataChild.BlockName;
                dialogParameters=linkDataChild.DialogParameters;
                parameterNames=fieldnames(dialogParameters);

                blockName=getfullname(parameterizedBlockHandle);
                block=[blockName,'/',modifiedBlock];
                try
                    referenceBlock=get_param(block,'ReferenceBlock');
                catch
                    referenceBlock='';
                end


                if isempty(referenceBlock)
                    try
                        referenceBlock=get_param(blockName,'TemplateBlock');
                    catch
                    end
                end

                libName=strtok(referenceBlock,'/');
                try
                    load_system(libName);
                    libraryFound=true;
                catch
                    libraryFound=false;
                end

                for i=1:length(parameterNames)
                    parameterValue=dialogParameters.(parameterNames{i});
                    if libraryFound
                        try
                            libraryValue=get_param(referenceBlock,parameterNames{i});
                        catch
                            libraryValue='';
                        end
                    else
                        libraryValue=DAStudio.message('Simulink:Libraries:LibFailedToLoadLibrary',libName);
                    end
                    childObj=LibraryToolParameterizedLinksSpreadsheetRow(parameterizedBlockHandle,modifiedBlock,parameterNames{i},parameterValue,libraryValue,[],'0');
                    children(c)=childObj;
                    c=c+1;
                end
            end
            subChildren=children;
        end

        function parameterizedData=findParameterizedLinksData(~,model)

            linkblocks=find_system(model,'IncludeCommented','on',...
            'FollowLinks','on',...
            'LookUnderMasks','on',...
            'MatchFilter',@Simulink.match.isBlockLinked);

            allblocks=linkblocks(:);

            linkdata=get_param(allblocks,'LinkData');
            hasdata=~cellfun('isempty',linkdata);
            parameterized=allblocks(hasdata);
            parameterizedData=cell(size(parameterized));
            for i=1:length(parameterized)
                parameterizedData{i}.parameterizedBlockHandle=get_param(parameterized{i},'Handle');
                parameterizedData{i}.linkData=get_param(parameterized{i},'LinkData');
            end
        end

        function children=ParameterizedSpreadsheetDeleteRow(~,spreadsheetObj,blockName)
            children=spreadsheetObj.m_Children;
            for i=1:length(children)
                child=children(i);
                if strcmp(child.m_ModifiedBlock,blockName)
                    children(i)=[];
                    break;
                end
            end
        end

        function spreadsheetObj=updateSpreadsheetChildren(spreadsheetObj)
            spreadsheetObj.m_Children=[];
            children=spreadsheetObj.getChildren();
            spreadsheetObj.m_Children=children;
            spreadsheetObj.m_SelectionCount=0;

        end

        function updateRow(~,dialogH,ssTag,newRow)
            spreadsheetObj=dialogH.getUserData(ssTag);
            children=spreadsheetObj.m_Children;
            for i=1:length(children)
                child=children(i);
                if strcmp(child.m_ModifiedBlock,newRow.m_ModifiedBlock)==1
                    child=newRow;
                    children(i)=child;
                    break;
                end
            end
            spreadsheetObj.m_Children=children;
            dialogH.setUserData(ssTag,spreadsheetObj);

        end

        function updateSelectionCount(~,dialogH,ssTag,selectionCount)
            spreadsheetObj=dialogH.getUserData(ssTag);
            spreadsheetObj.m_SelectionCount=selectionCount;
            dialogH.setUserData(ssTag,spreadsheetObj);

        end

        function updateUI(~,dialogH,spreadsheetTag)
            ssComp=dialogH.getWidgetInterface(spreadsheetTag);
            ssComp.update(true);
        end
    end
end