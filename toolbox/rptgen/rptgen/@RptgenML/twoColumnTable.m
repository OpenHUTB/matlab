function dlgStruct=twoColumnTable(this,vectorProp,isVectorProp,varargin)



















    if strncmp(isVectorProp,'-',1)
        dlgStruct=feval(isVectorProp(2:end),this,vectorProp,varargin{:});
        return;
    end

    tableData=get(this,vectorProp);
    if rem(length(tableData),2)>0
        tableData{end+1}='';
    end
    tableData=reshape(tableData(:)',2,[])';

    idxPropName=['Dlg',vectorProp,'Idx'];
    if isempty(findprop(this,idxPropName))
        p=schema.prop(this,idxPropName,'int32');
        p.Visible='off';
        p.AccessFlags.Serialize='off';
        rowIdx=1;
        set(this,idxPropName,rowIdx);
    else
        rowIdx=get(this,idxPropName);
    end



    enableIdx=find(strcmp(varargin,'Enabled'));
    if~isempty(enableIdx)
        specialEnable=varargin{enableIdx+1};
        varargin=varargin([1:enableIdx-1,enableIdx+2:end]);
    else
        specialEnable=true;
    end

    if isempty(isVectorProp)
        p=this.findprop(vectorProp);
        wPrompt=this.dlgText([p.Description,': ']);
        isEditable=specialEnable;
    else
        wPrompt=this.dlgWidget(isVectorProp,...
        'DialogRefresh',true,...
        'Enabled',specialEnable);
        isEditable=get(this,isVectorProp)&&specialEnable;
    end



    dlgStruct=this.dlgContainer({
    this.dlgSet(wPrompt,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);
    struct('Type','pushbutton',...
    'Tag','addRow',...
    'FilePath',fullfile(matlabroot,'toolbox','rptgen','resources','pt_row_insert.png'),...
    'Enabled',isEditable,...
    'MatlabMethod','RptgenML.twoColumnTable',...
    'MatlabArgs',{{this,vectorProp,'-addRow'}},...
    'ToolTip',getString(message('rptgen:RptgenML:addRowLabel')),...
    'DialogRefresh',true,...
    'ColSpan',[2,2],...
    'RowSpan',[1,1])
    struct('Type','pushbutton',...
    'Tag','removeRow',...
    'FilePath',fullfile(matlabroot,'toolbox','rptgen','resources','pt_row_delete.png'),...
    'Enabled',isEditable&&~isempty(tableData),...
    'MatlabMethod','RptgenML.twoColumnTable',...
    'MatlabArgs',{{this,vectorProp,'-removeRow'}},...
    'ToolTip',getString(message('rptgen:RptgenML:removeRowLabel')),...
    'DialogRefresh',true,...
    'ColSpan',[3,3],...
    'RowSpan',[1,1])
    struct('Type','pushbutton',...
    'Tag','moveRowUp',...
    'FilePath',fullfile(matlabroot,'toolbox','rptgen','resources','move_up.png'),...
    'Enabled',isEditable&&~isempty(tableData)&&rowIdx>1,...
    'MatlabMethod','RptgenML.twoColumnTable',...
    'MatlabArgs',{{this,vectorProp,'-moveRowUp'}},...
    'ToolTip',getString(message('rptgen:RptgenML:moveUpLabel')),...
    'DialogRefresh',true,...
    'ColSpan',[4,4],...
    'RowSpan',[1,1])
    struct('Type','pushbutton',...
    'Tag','moveRowDown',...
    'FilePath',fullfile(matlabroot,'toolbox','rptgen','resources','move_down.png'),...
    'Enabled',isEditable&&~isempty(tableData)&&rowIdx<size(tableData,1),...
    'MatlabMethod','RptgenML.twoColumnTable',...
    'MatlabArgs',{{this,vectorProp,'-moveRowDown'}},...
    'ToolTip',getString(message('rptgen:RptgenML:moveDownLabel')),...
    'DialogRefresh',true,...
    'ColSpan',[5,5],...
    'RowSpan',[1,1])
    struct('Tag',vectorProp,...
    'Type','table',...
    'Size',size(tableData),...
    'Grid',true,...
    'HeaderVisibility',[0,1],...
    'ColHeader',{{getString(message('rptgen:RptgenML:propertyNameLabel')),getString(message('rptgen:RptgenML:propertyValueLabel'))}},...
    'ColumnCharacterWidth',[24,24],...
    'Enabled',isEditable,...
    'Editable',isEditable,...
    'ValueChangedCallback',eval(['@onValueChanged',vectorProp]),...
    'CurrentItemChangedCallback',eval(['@onCurrentChanged',vectorProp]),...
    'Data',{tableData},...
    'SelectedRow',rowIdx-1,...
    'RowSpan',[2,2],...
    'ColSpan',[1,5])
    },'',...
    'LayoutGrid',[2,5],...
    'ColStretch',[1,0,0,0,0],...
    'RowStretch',[0,1],...
    varargin{:});












    function onValueChangedFilterTerms(d,r,c,val)
        onValueChanged(d,r,c,val,'FilterTerms');

        function onCurrentChangedFilterTerms(d,r,c)
            onCurrentChanged(d,r,c,'FilterTerms');

            function onValueChangedSFFilterTerms(d,r,c,val)
                onValueChanged(d,r,c,val,'SFFilterTerms');

                function onCurrentChangedSFFilterTerms(d,r,c)
                    onCurrentChanged(d,r,c,'SFFilterTerms');

                    function onValueChangedSimParam(d,r,c,val)
                        onValueChanged(d,r,c,val,'SimParam');

                        function onCurrentChangedSimParam(d,r,c)
                            onCurrentChanged(d,r,c,'SimParam');

                            function onValueChangedSearchTerms(d,r,c,val)
                                onValueChanged(d,r,c,val,'SearchTerms');

                                function onCurrentChangedSearchTerms(d,r,c)
                                    onCurrentChanged(d,r,c,'SearchTerms');



                                    function onValueChanged(d,r,c,val,propName)

                                        this=d.getWidgetSource(propName);
                                        vectorVal=this.(propName);
                                        vectorVal{r*2+c+1}=val;
                                        this.(propName)=vectorVal;


                                        function onCurrentChanged(d,r,c,propName)

                                            idxPropName=['Dlg',propName,'Idx'];
                                            d.selectTableRow(propName,r);
                                            this=d.getWidgetSource(propName);
                                            r=r+1;
                                            set(this,idxPropName,r);

                                            d.setEnabled('moveRowUp',r>1);
                                            d.setEnabled('moveRowDown',r<length(this.(propName))/2);



                                            function out=addRow(this,propName,rowContent)

                                                vectorList=get(this,propName);
                                                vectorList=vectorList(:)';
                                                vectorListLength=length(vectorList);
                                                if rem(vectorListLength,2)>0
                                                    vectorList{end+1}='';
                                                    vectorListLength=vectorListLength+1;
                                                end

                                                idxPropName=['Dlg',propName,'Idx'];
                                                try
                                                    rowIdx=get(this,idxPropName);
                                                catch
                                                    rowIdx=1;
                                                end

                                                if nargin<3
                                                    rowContent={'PropName','SearchValue'};
                                                end

                                                if isempty(vectorList)
                                                    vectorList=rowContent;
                                                    rowIdx=0;
                                                else
                                                    vectorList=[vectorList(1:rowIdx*2),...
                                                    rowContent,...
                                                    vectorList(rowIdx*2+1:end)];
                                                end

                                                this.(propName)=vectorList;

                                                try
                                                    this.(idxPropName)=rowIdx+1;
                                                end

                                                out=[];


                                                function out=removeRow(this,propName)

                                                    [cellTable,rowCount]=locVectorToTable(this.(propName));


                                                    idxPropName=['Dlg',propName,'Idx'];
                                                    try
                                                        rowIdx=get(this,idxPropName);
                                                    catch
                                                        rowIdx=1;
                                                    end

                                                    newIdx=[1:rowIdx-1,rowIdx+1:rowCount];

                                                    this.(propName)=locTableToVector(cellTable(newIdx,:));

                                                    if rowIdx>=rowCount
                                                        rowIdx=rowCount-1;
                                                        try
                                                            set(this,idxPropName,rowIdx);
                                                        end
                                                    end

                                                    out=[];



                                                    function out=moveRowDown(this,propName)

                                                        [cellTable,rowCount]=locVectorToTable(this.(propName));

                                                        idxPropName=['Dlg',propName,'Idx'];
                                                        try
                                                            rowIdx=get(this,idxPropName);
                                                        catch
                                                            rowIdx=1;
                                                        end

                                                        newIdx=[1:rowIdx-1,...
                                                        rowIdx+1,...
                                                        rowIdx,...
                                                        rowIdx+2:rowCount];

                                                        this.(propName)=locTableToVector(cellTable(newIdx,:));

                                                        try this.(idxPropName)=rowIdx+1;end

                                                        out=[];


                                                        function out=moveRowUp(this,propName)

                                                            [cellTable,rowCount]=locVectorToTable(this.(propName));

                                                            idxPropName=['Dlg',propName,'Idx'];
                                                            try
                                                                rowIdx=get(this,idxPropName);
                                                            catch
                                                                rowIdx=1;
                                                            end

                                                            newIdx=[1:rowIdx-2,...
                                                            rowIdx,...
                                                            rowIdx-1,...
                                                            rowIdx+1:rowCount];

                                                            this.(propName)=locTableToVector(cellTable(newIdx,:));

                                                            try this.(idxPropName)=rowIdx-1;end

                                                            out=[];



                                                            function[cellTable,cellLength]=locVectorToTable(cellVector)

                                                                cellLength=length(cellVector);
                                                                if rem(cellLength,2)>0
                                                                    cellVector{end+1}='';
                                                                    cellLength=cellLength+1;
                                                                end
                                                                cellLength=cellLength/2;
                                                                cellTable=reshape(cellVector,2,cellLength)';


                                                                function cellVector=locTableToVector(cellTable)

                                                                    cellTable=cellTable';
                                                                    cellVector=cellTable(:);


                                                                    function dlgStruct=setColHeader(this,dlgStruct,colHeader)

                                                                        dlgStruct.Items{6}.ColHeader=colHeader;


                                                                        function dlgStruct=setDefaultRow(this,dlgStruct,defaultRow)

                                                                            dlgStruct.Items{2}.MatlabArgs{4}=defaultRow;
