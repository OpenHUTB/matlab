classdef ResultsView<handle






    properties(Hidden)

View

ResultsTable


CompareViewBtn


Parent

        HBFlag=0;
BudgetClone
HBData
FriisData
RowNames
TableData
CData
RowPicker
Panel
TablePanel
TableLayout
CompareLayout
RowNamesPanel
RowNamesLayout
RowNamesTable
Layout
Listeners
MainPanel
MainLayout
AntPanel
AntTable
AntLayout
RowNamesAnt
    end

    properties(Constant)
        ResultsLayoutRowHeight={'1x'};
        ResultsLayoutColumnWidth={'1x','1x','8x'}
    end

    properties(Dependent)

TableLayoutRowHeight
TableLayoutColumnWidth
    end

    methods

        function self=ResultsView(view)




            self.View=view;
            self.Parent=self.View.ResultsFig;
            if self.View.UseAppContainer
                f=self.Parent.Figure;
            else
                f=self.Parent;
            end
            clf(f);
            createUIControls(self);
            layoutUIControls(self);
            addlisteners(self);
        end





        function rtn=get.TableLayoutRowHeight(~)
            rtn={'1x','fit','1x'};
        end

        function rtn=get.TableLayoutColumnWidth(self)
            rtn=self.View.Canvas.CascadeColumnWidth;
        end


        function createUIControls(self)


            userData=struct(...
            'Dialog','results',...
            'Stage',1);
            if self.View.UseAppContainer

                f=self.Parent.Figure;

                self.Layout=uigridlayout(...
                'Parent',f,...
                'Scrollable','on',...
                'Tag','resultsLayout',...
                'RowSpacing',3,...
                'ColumnSpacing',0,...
                'RowHeight',self.ResultsLayoutRowHeight,...
                'ColumnWidth',self.ResultsLayoutColumnWidth,...
                'Padding',[0,0,0,0]);

                self.RowPicker=rf.internal.apps.budget.RowPicker(self);

                self.CompareLayout=uigridlayout(...
                'Tag','CompareLayout',...
                'Parent',self.Layout,...
                'Scrollable','on',...
                'RowHeight',{'1x','8x'},...
                'ColumnWidth',{'1x'},...
                'RowSpacing',0,...
                'Padding',[0,0,0,0]);
                self.CompareViewBtn=uicheckbox(...
                'Parent',self.CompareLayout,...
                'Text','Compare View',...
                'Tag','compareViewCheckbox',...
                'Position',[0.7,0.9,0.3,0.1],...
                'Tooltip','View both solver results in succession',...
                'Visible',"on");
                self.CompareViewBtn.Layout.Row=1;
                self.CompareViewBtn.Layout.Column=1;

                self.TableLayout=uigridlayout(...
                'Tag','resultsTableLayout',...
                'Parent',self.Layout,...
                'Scrollable','on',...
                'RowHeight',self.TableLayoutRowHeight,...
                'ColumnWidth',self.TableLayoutColumnWidth,...
                'Padding',[0,0,100,0]);
                self.TableLayout.Layout.Row=1;
                self.TableLayout.Layout.Column=3;

                self.RowNamesTable=uitable(...
                'Parent',self.TableLayout,...
                'RowStriping','on',...
                'BackgroundColor',[0.97,0.97,0.97],...
                'RowName',{},...
                'FontSize',14,...
                'ColumnName',[],...
                'Tag','resultsRowNamesTable');
                self.RowNamesTable.Layout.Row=2;
                self.RowNamesTable.Layout.Column=2;

                self.ResultsTable=uitable(...
                'Parent',self.TableLayout,...
                'Tag','resultsTable',...
                'FontSize',14,...
                'RowStriping','on',...
                'FontUnits','pixels',...
                'RowName',{},...
                'ColumnName',[],...
                'ColumnWidth',{rf.internal.apps.budget.ElementView.IconWidth+20});
                self.ResultsTable.Layout.Row=2;
                self.ResultsTable.Layout.Column=3;


                self.AntTable=uitable(...
                'Parent',self.TableLayout,...
                'RowStriping','on',...
                'BackgroundColor',[0.97,0.97,0.97],...
                'RowName',{},...
                'FontSize',10,...
                'ColumnName',[],...
                'Tag','resultsAntTable',...
                'Visible',"off",...
                'ColumnWidth',{2*(rf.internal.apps.budget.ElementView.IconWidth+20)});
                self.AntTable.Layout.Row=2;
                self.AntTable.Layout.Column=4;

                f.AutoResizeChildren='off';
                f.ResizeFcn=@self.figureAdjusted;
            else

                f=self.Parent;

                self.Panel=uipanel(...
                'Parent',f,...
                'Tag','RowNamesPanel',...
                'BorderType','none',...
                'Visible','off',...
                'Position',[0,0,1,1]);

                self.CompareViewBtn.Visible='off';
                self.CompareViewBtn=uicontrol(f,...
                'Style','checkbox',...
                'Tag','CompareViewCheckbox',...
                'String',...
                'Compare View','units','normalized',...
                'Position',[0.7,0.9,0.3,0.1],...
                'Tooltip',...
                'View both solver results in succession');

                self.TablePanel=uipanel(...
                'Tag','ResultsTablePanel',...
                'Parent',self.Panel,...
                'BorderType','none',...
                'HighlightColor',[0,0,0],...
                'BorderWidth',1);

                self.RowNamesPanel=uipanel(...
                'Tag','RowNamesPanel',...
                'Parent',self.Panel,...
                'BorderType','line',...
                'HighlightColor',[0,0,0],...
                'BorderWidth',1);

                self.RowNamesTable=uitable(self.RowNamesPanel,...
                'RowStriping','on',...
                'BackgroundColor',[0.97,0.97,0.97],...
                'RowName',{},...
                'FontSize',10,'ColumnName',[],...
                'Tag','RowNamesTable');

                self.ResultsTable=uitable(self.TablePanel,...
                'Tag','ResultsTable');
                table=self.ResultsTable;
                table.FontSize=10;
                table.RowStriping='on';
                table.FontUnits='pixels';
                table.RowName={};
                table.ColumnName=[];
                self.RowPicker=rf.internal.apps.budget.RowPicker(self);

                self.AntPanel=uipanel(...
                'Tag','AntPanel',...
                'Parent',self.TablePanel,...
                'BorderType','line',...
                'HighlightColor',[0,0,0],...
                'BorderWidth',1);

                self.AntTable=uitable(self.AntPanel,...
                'RowStriping','on',...
                'BackgroundColor',[0.97,0.97,0.97],...
                'RowName',{},...
                'FontSize',10,'ColumnName',[],...
                'Tag','AntTable');
                f.ResizeFcn=@self.figureAdjusted;
            end
        end


        function layoutUIControls(self)


            if self.View.UseAppContainer
            else

                self.Layout=matlabshared.application.layout.ScrollableGridBagLayout(...
                self.Panel,...
                'VerticalWeights',[0,1],...
                'HorizontalWeights',0);
                layoutResultsTable(self);

                add(...
                self.Layout,...
                self.RowPicker.DropDownBtnPanel,...
                1,[1,2],...
                'MinimumWidth',100,...
                'MinimumHeight',24,...
                'Anchor','NorthWest',...
                'LeftInset',5,...
                'TopInset',5);

                add(...
                self.Layout,...
                self.RowNamesTable,...
                2,1,...
                'MinimumWidth',115,...
                'MinimumHeight',240,...
                'Anchor','NorthEast',...
                'TopInset',3,...
                'BottomInset',20);

                add(...
                self.Layout,...
                self.TablePanel,...
                2,2,...
                'Anchor','NorthWest',...
                'MinimumHeight',240,...
                'BottomInset',20);

                self.CompareViewBtn.Parent=...
                self.RowPicker.DropDownBtnPanel.Parent;
                self.CompareViewBtn.Units='pixels';
                self.CompareViewBtn.Position=...
                self.RowPicker.DropDownBtnPanel.Position;
                self.CompareViewBtn.Position(1)=...
                self.CompareViewBtn.Position(3)+...
                self.CompareViewBtn.Position(1)+4;
            end
        end

        function layoutResultsTable(self)


            if self.View.UseAppContainer
            else

                self.TableLayout=matlabshared.application.layout.ScrollableGridBagLayout(...
                self.TablePanel,...
                'VerticalWeights',0,...
                'HorizontalWeights',0);

                add(...
                self.TableLayout,...
                self.ResultsTable,...
                1,1,...
                'Anchor','North',...
                'TopInset',3);
            end
        end


        function addlisteners(self)


            if self.View.UseAppContainer
            else
                self.Listeners.ScrollbarListener=...
                addlistener(...
                self.View.Canvas.Cascade.Layout.HorizontalScrollbar,...
                'ValueChanged',@self.updateHorizontalScrollbarValue);
                self.Parent.WindowButtonDownFcn=...
                @(src,evt)self.RowPicker.resetDropDown();
                self.Parent.WindowScrollWheelFcn=...
                @(src,evt)self.RowPicker.resetDropDown();
                self.ResultsTable.CellSelectionCallback=...
                @(src,evt)self.RowPicker.resetDropDown();
                self.RowNamesTable.CellSelectionCallback=...
                @(src,evt)self.RowPicker.resetDropDown();
            end
        end

        function enableListeners(self,val)

            self.Listeners.ScrollbarListener.Enable=val;
        end

        function figureAdjusted(self,~,~)

            if self.View.UseAppContainer
            else
                if isempty(self.BudgetClone)||...
                    numel(self.BudgetClone.Elements)==0
                    return;
                end
                RTColumnWidth=82;
                ExtraColumnHeight=25;
                RNColumnWidth=110;
                if isa(self.BudgetClone.Elements(end),'rfantenna')
                    if strcmpi(self.BudgetClone.Elements(end).Type,'Transmitter')
                        ATColumnWidth=110;
                    else
                        ATColumnWidth=0;
                    end
                else
                    ATColumnWidth=0;
                end
                T_TL_Offset=10;
                if self.Parent.Position(3)<...
110
                    width=82;
                elseif self.Parent.Position(3)<...
                    numel(self.BudgetClone.Elements)*RTColumnWidth+...
                    ATColumnWidth+...
                    RNColumnWidth+...
                    T_TL_Offset*2
                    width=...
                    self.Parent.Position(3)-...
                    RNColumnWidth-...
                    T_TL_Offset;
                elseif ATColumnWidth>0
                    width=...
                    numel(self.BudgetClone.Elements)*RTColumnWidth+...
                    RNColumnWidth+...
                    T_TL_Offset-16;
                else
                    width=...
                    numel(self.BudgetClone.Elements)*RTColumnWidth+...
                    RNColumnWidth-...
                    RTColumnWidth-...
                    T_TL_Offset-12;
                end
                if isa(self.BudgetClone.Elements(1),'rfantenna')
                    if strcmpi(self.BudgetClone.Elements(1).Type,'Receiver')
                        width=width+14;
                    end
                end
                setConstraints(...
                self.Layout,...
                2,2,...
                'MinimumWidth',width);
                self.RowPicker.adjustDropDownPosition();
                ps=self.RowPicker.DropDownBtnPanel.Position;
                self.CompareViewBtn.Position=[...
                ps(1)+ps(3)+4,...
                ps(2),...
                ps(3),...
                ps(4)];
            end
        end


        function updateResultsTable(self,b)





            warning('off','rf:shared:InputPower')
            self.BudgetClone=clone(b);
            warning('on','rf:shared:InputPower')
            if numel(self.BudgetClone.Elements)==0
                if self.View.UseAppContainer
                    self.Layout.Visible='off';
                    self.RowPicker.DropDownBtnLayout.Visible='off';
                    self.RowPicker.DropDownLayout.Visible='off';
                    return;
                else
                    self.Panel.Visible='off';
                    self.RowPicker.DropDownBtnPanel.Visible='off';
                    self.RowPicker.DropDownBtn.Value=0;
                    self.RowPicker.DropDownPanel.Visible='off';
                    return;
                end
            end
            if strcmpi(self.BudgetClone.Solver,'HarmonicBalance')

                self.HBFlag=1;
                self.CompareViewBtn.Enable='on';
                self.HBData=self.generateData();
                self.BudgetClone.Solver='f';
                computeBudget(self.BudgetClone);
                self.FriisData=self.generateData();
            else

                self.HBFlag=0;
                self.CompareViewBtn.Enable='off';
                self.CompareViewBtn.Value=0;
                self.FriisData=self.generateData();
                self.HBData=[];
            end
            self.updateTableDataAndColors();
            self.updateHorizontalScrollbarValue();
        end

        function updateTableDataAndColors(self)


            if self.HBFlag&&~self.RowPicker.SelectAllCheckBox.Value
                self.RowPicker.OIP2CheckBox.Enable='on';
            else
                self.RowPicker.OIP2CheckBox.Enable='off';
            end
            self.generateTableNamesAndColors();
            self.generateTableDataFromRows();
            self.updateTable();
            if self.View.UseAppContainer
            else
                if self.HBFlag
                    setConstraints(...
                    self.TableLayout,1,1,...
                    'TopInset',1);
                else
                    setConstraints(...
                    self.TableLayout,1,1,...
                    'TopInset',3);
                end
            end
            RTColumnWidth=82;
            ExtraColumnHeight=15;
            RNColumnWidth=110;
            if self.View.UseAppContainer
                if isa(self.BudgetClone.Elements(end),'rfantenna')
                    self.TableLayout.ColumnWidth=self.View.Canvas.Cascade.Layout.ColumnWidth;
                else
                    ATColumnWidth=0;
                    T_TL_Offset=5;
                end
                self.RowNamesTable.ColumnWidth={RNColumnWidth+2};
            else
                if isa(self.BudgetClone.Elements(end),'rfantenna')
                    ATColumnWidth=110;
                    self.ResultsTable.ColumnWidth{end}=100;
                    T_TL_Offset=20;
                    if strcmpi(self.BudgetClone.Elements(end).Type,'TransmitReceive')
                        self.ResultsTable.ColumnWidth{end}=82;
                        ATColumnWidth=0;
                        T_TL_Offset=5;
                    end
                else
                    ATColumnWidth=0;
                    T_TL_Offset=5;
                end
            end
            TL_L_Offset=10;
            RTRowHeight=21;
            nCols=numel(self.ResultsTable.ColumnWidth);
            nRows=size(self.ResultsTable.Data,1);

            if self.View.UseAppContainer
                nCols=size(self.ResultsTable.Data,2);
                self.TableLayout.ColumnWidth(2)={RNColumnWidth+5};
                self.TableLayout.ColumnWidth(3)={'fit'};
                for i=4:3+nCols
                    self.TableLayout.ColumnWidth(i)={RTColumnWidth};
                end
                if nCols==1
                    self.ResultsTable.Layout.Column=4;
                end
            else
                setConstraints(...
                self.TableLayout,...
                1,1,...
                'MinimumWidth',(RTColumnWidth*nCols)+T_TL_Offset,...
                'MinimumHeight',nRows*RTRowHeight);
            end

            if self.View.UseAppContainer
                self.Layout.Visible='on';
                self.RowPicker.DropDownBtnLayout.Visible='on';
                self.CompareViewBtn.ValueChangedFcn=...
                @(src,evt)self.compareClicked(src,evt);
            else
                setConstraints(...
                self.Layout,2,2,...
                'MinimumWidth',RTColumnWidth*nCols+...
                ATColumnWidth+T_TL_Offset+TL_L_Offset,...
                'MinimumHeight',nRows*...
                RTRowHeight+T_TL_Offset+TL_L_Offset+ExtraColumnHeight);


                setConstraints(...
                self.Layout,2,1,...
                'MinimumHeight',nRows*RTRowHeight);...
                self.Panel.Visible='on';
                self.RowPicker.DropDownBtnPanel.Visible='on';
                self.CompareViewBtn.Callback=...
                @(src,evt)self.compareClicked(src,evt);
            end
            if self.View.UseAppContainer
            else
                if~(isempty(self.Layout.HorizontalScrollbar)||...
...
                    strcmpi(self.Layout.HorizontalScrollbar.Visible,'off'))
                    setConstraints(...
                    self.TableLayout,1,1,...
                    'MinimumWidth',RTColumnWidth*...
                    nCols+T_TL_Offset,...
                    'MinimumHeight',nRows*RTRowHeight);
                    setConstraints(...
                    self.Layout,2,2,...
                    'MinimumWidth',RTColumnWidth*...
                    nCols+ATColumnWidth+TL_L_Offset+T_TL_Offset,...
                    'MinimumHeight',...
                    nRows*RTRowHeight+TL_L_Offset+T_TL_Offset+ExtraColumnHeight);
                    setConstraints(...
                    self.Layout,2,1,...
                    'MinimumHeight',nRows*RTRowHeight);
                end
            end
            self.figureAdjusted(-1,-1);
            self.updateHorizontalScrollbarValue(-1,-1);
        end

        function updateTable(self)



            lenval=cell2mat(cellfun(@(x)numel(x),...
            self.TableData(2,:),...
            'UniformOutput',false));
            lenval=max(lenval);
            if lenval<8
                lenval=8;
            end
            fz=self.ResultsTable.FontSize;
            self.ResultsTable.Data=self.TableData;
            self.RowNamesTable.Data=self.RowNames';
            self.RowNamesTable.RowName=[];
            if self.View.UseAppContainer

                self.TableLayout.ColumnWidth=self.View.Canvas.Cascade.Layout.ColumnWidth;
                if length(self.ResultsTable.Data(1,:))>1
                    self.ResultsTable.Layout.Column=[4,4+length(self.ResultsTable.Data(1,:))-1];
                end
            else
                self.RowNamesTable.ColumnWidth={110};
                self.ResultsTable.ColumnWidth=cellfun(@(x)82,...
                cell(1,size(self.TableData,2)),...
                'UniformOutput',false);
            end
            self.RowNamesTable.ColumnName={};
            self.RowNamesTable.BackgroundColor=[0.97,0.97,0.97];
            self.ResultsTable.BackgroundColor=self.CData;
            self.ResultsTable.ColumnFormat=cellfun(@(x)'numeric',...
            cell(1,size(self.TableData,2)),...
            'UniformOutput',false);
            extrawidth=0;
            if self.View.UseAppContainer
                if any(isInScrollView(self.View.Canvas.Cascade.Layout,self.View.Canvas.Cascade.Layout.Children))
                    self.View.Canvas.Cascade.Layout.ScrollableViewportLocation(1)=...
                    self.TableLayout.ScrollableViewportLocation(1);
                    self.View.Canvas.Cascade.Layout.ScrollableViewportLocationChangingFcn=...
                    @(s,e)adjustLoc(self,s,e,self.TableLayout);
                end
            end
        end
        function adjustLoc(~,~,e,layout)
            layout.ScrollableViewportLocation(1)=e.ScrollableViewportLocation(1);
        end

        function compareClicked(self,~,~)

            self.updateTableDataAndColors()
            self.RowPicker.resetDropDown();
        end


        function generateTableNamesAndColors(self)




            CommonData={'Cascade','Fout',''};
            DataName={'Pout','GainT','NF',...
            'OIP2',...
            'OIP3','SNR'};
            Units={'dBm','dB','dB','dBm','dBm','dB'};
            RowNameFriis=cellfun(@(x,y)...
            ['Friis - ',x,' (',y,')'],DataName,Units,...
            'UniformOutput',false);
            if self.HBFlag
                RowNameHB=cellfun(@(x,y)...
                ['HB - ',x,' (',y,')'],DataName,Units,...
                'UniformOutput',false);
            else
                RowNameHB={};
            end
            RowName={};
            cData=[...
            rf.internal.apps.budget.ElementView.BackGround2;...
            1,1,1;...
            1,1,1];
            friisSelection=...
            logical(...
            [self.RowPicker.RowSelectedFlag(1:3);...
            0;...
            self.RowPicker.RowSelectedFlag(5:6)]);
            HBSelection=logical(self.RowPicker.RowSelectedFlag(7:end));
            if~self.HBFlag
                friisCData=rf.internal.apps.budget.ElementView.BackGround2;
                RowName=[CommonData,RowNameFriis(friisSelection)];
                cData=[cData;repmat(friisCData,sum(friisSelection),1)];
                self.RowNames=RowName;
                self.CData=cData;
                self.RowNamesAnt={'EIRP','Directivity'};
                return;
            end
            if self.CompareViewBtn.Value
                for i=1:6
                    if strcmpi(DataName{i},...
                        'OIP2')
                        continue;
                    end
                    if friisSelection(i)==0
                        friisRowname=[];
                        friisCData=[];
                    else
                        friisRowname=RowNameFriis(i);
                        friisCData=rf.internal.apps.budget.ElementView.BackGround2;
                    end
                    if HBSelection(i)==0
                        HBRowName=[];
                        HBCData=[];
                    else
                        HBRowName=RowNameHB(i);
                        HBCData=rf.internal.apps.budget.ElementView.BackGround1;
                    end
                    if isempty(friisRowname)&&isempty(HBRowName)
                        continue;
                    end
                    RowName=[RowName,friisRowname,HBRowName,{''}];%#ok<AGROW>
                    cData=[cData;friisCData;HBCData;[1,1,1]];%#ok<AGROW>
                end
                RowName=[CommonData,RowName,{'HB - OIP2 (dBm)',''}];
                cData=[cData;HBCData];
            else
                friisCData=rf.internal.apps.budget.ElementView.BackGround2;
                HBCData=rf.internal.apps.budget.ElementView.BackGround1;
                RowName=...
                [CommonData,RowNameHB(HBSelection),{''},...
                RowNameFriis(friisSelection)];
                cData=[...
                cData;...
                repmat(HBCData,sum(HBSelection),1);...
                [1,1,1];...
                repmat(friisCData,sum(friisSelection),1)];
            end
            self.RowNames=RowName;
            self.CData=cData;
            self.RowNamesAnt={'EIRP','Directivity'};
        end

        function generateTableDataFromRows(self)



            n=numel(self.BudgetClone.Elements);
            tmpdata=cell(numel(self.RowNames),n);
            dataval=cell(1,n);
            for i=1:numel(self.RowNames)
                strdata=split(self.RowNames{i});
                if numel(strdata)==1&&strcmpi(strdata,'Name')
                    dataval={self.BudgetClone.Elements.Name};
                elseif numel(strdata)==1&&strcmpi(strdata,'Cascade')
                    for j=1:n
                        dataval{j}=[' 1..',num2str(j)];
                        if ismac||...
isunix
                            dataval{j}=dataval{j}(2:end);
                        end
                    end
                elseif numel(strdata)==1&&strcmpi(strdata,'Fout')
                    [numval,~,unitsval]=...
                    engunits(self.FriisData.('OutputFrequency'));
                    dataval=num2cell(numval);
                    self.RowNames{i}=[self.RowNames{i},' (',unitsval,'Hz)'];
                elseif numel(strdata)==4
                    if strcmpi(strdata{3},'Pout')
                        stringval='OutputPower';
                    elseif strcmpi(strdata{3},'GainT')
                        stringval='TransducerGain';
                    else
                        stringval=strdata{3};
                    end
                    if strcmpi(strdata{1},'Friis')
                        datastruct=self.FriisData;
                    else
                        datastruct=self.HBData;
                    end
                    data=round(datastruct.(stringval),4);
                    if isempty(data)
                        dataval=cellfun(@(x)'',cell(1,n),...
                        'UniformOutput',false);
                    else
                        dataval=num2cell(data);
                    end
                elseif isempty(strdata{1})
                    dataval=cellfun(@(x)'',cell(1,n),...
                    'UniformOutput',false);
                end
                tmpdata(i,:)=dataval;
                if numel(strdata)==4
                    self.RowNames{i}=...
                    strjoin([strdata(1:3);{' '};strdata{4}],'');
                elseif~strcmpi(strdata{1},'Fout')
                    self.RowNames{i}=strjoin(strdata,'');
                end
                self.RowNames{i}=[' ',self.RowNames{i}];
            end
            self.RowNamesAnt{1}=[self.RowNamesAnt{1},':'...
            ,num2str(self.BudgetClone.EIRP)];
            self.RowNamesAnt{2}=[self.RowNamesAnt{2},':'...
            ,num2str(self.BudgetClone.Directivity,4)];
            ant=zeros(1,length(self.BudgetClone.Elements));
            for i=1:length(self.BudgetClone.Elements)
                ant(i)=isa(self.BudgetClone.Elements(i),'rfantenna');
            end
            index=find(ant==1);
            if any(ant)
                if strcmpi(self.BudgetClone.Elements(index).Type,'Transmitter')
                    tmpdata{1,index+1}=self.RowNamesAnt{1};
                    tmpdata{2,index+1}=self.RowNamesAnt{2};
                elseif strcmpi(self.BudgetClone.Elements(index).Type,'TransmitReceive')
                    tmpdata{6,index}=[];
                    tmpdata{7,index}=[];
                    if self.HBFlag
                        tmpdata{8,index}=[];
                        tmpdata{13,index}=[];
                        tmpdata{14,index}=[];
                    end
                end
            end
            self.TableData=tmpdata;
        end

        function updateHorizontalScrollbarValue(self,~,~)


            if self.View.UseAppContainer
            else
                if isempty(self.TableLayout.HorizontalScrollbar)||...
                    isempty(self.View.Canvas.Cascade.Layout.HorizontalScrollbar)||...
                    ~self.View.Canvas.Cascade.Layout.HorizontalScrollbar.Visible
                    return;
                end
                self.TableLayout.HorizontalScrollbar.Value=...
                self.View.Canvas.Cascade.Layout.HorizontalScrollbar.Value;
            end
        end

        function data=generateData(self)


            b=self.BudgetClone;
            data.OutputFrequency=b.OutputFrequency;
            data.OutputPower=b.OutputPower;
            data.TransducerGain=b.TransducerGain;
            data.NF=b.NF;
            data.OIP2=b.OIP2;
            data.OIP3=b.OIP3;
            data.SNR=b.SNR;
        end
    end
end





