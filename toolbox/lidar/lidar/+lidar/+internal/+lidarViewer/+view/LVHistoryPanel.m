












classdef LVHistoryPanel<handle

    properties(Access=private)

        MainFigure matlab.ui.Figure
MainGrid
BottomGrid


        ListPanel matlab.ui.container.Panel


        ButtonPanel matlab.ui.container.Panel


        DiscardEditButton matlab.ui.control.Button


        GenerateMacroButton matlab.ui.control.Button


        EntryList={};


DefaultText

    end

    properties(Constant,Hidden)


        UNITHEIGHT=20.75;
    end

    properties(Dependent)

NumEntries
    end

    events

RequestToDiscardAllEdits


RequestToGenerateMacro
    end

    methods



        function this=LVHistoryPanel(figure)
            this.MainFigure=figure;
            this.MainGrid=figure.UserData{1};
            this.MainGrid.RowHeight=repmat("fit",1,1000);
            this.MainGrid.ColumnWidth={"1x"};
            this.MainGrid.Padding=[1,1,1,1];
            this.MainGrid.RowSpacing=1;
            this.MainGrid.Scrollable='on';
            this.BottomGrid=figure.UserData{2};
            this.setUp();
        end


        function append(this,edits,toUpdateButtons)






            if this.NumEntries>=0&&toUpdateButtons

                this.setButtons(true);
                if~isempty(this.DefaultText)
                    delete(this.MainGrid.Children);
                    this.DefaultText=[];
                end
            end

            for i=1:numel(edits)
                textToDisplay=this.getTextToDisplay(edits{i});
                this.createAndAddEntry(textToDisplay);
            end
        end


        function reset(this)



            if this.NumEntries==0
                return;
            end

            delete(this.MainGrid.Children());
            this.EntryList=[];
            addDefaultTextToHistoryPanel(this);

            this.setButtons(false);
        end


        function discardLastEntry(this)


            if this.NumEntries==0
                return;
            end

            delete(this.EntryList{end});
            this.EntryList(end)=[];

            if this.NumEntries==0
                this.setButtons(false);
                addDefaultTextToHistoryPanel(this);
            end
        end


        function setOptions(this,TF)

            this.setButtons(TF);
        end
    end




    methods

        function numEntries=get.NumEntries(this)

            numEntries=numel(this.EntryList);
        end
    end




    methods(Access=private)
        function setUp(this)


            addDefaultTextToHistoryPanel(this);

            this.createButtons();
        end


        function createButtons(this)



            this.DiscardEditButton=uibutton('Parent',this.BottomGrid,...
            'Text',getString(message('lidar:lidarViewer:DiscardEditOperations')),...
            'ButtonPushedFcn',@(~,~)notify(this,'RequestToDiscardAllEdits'),...
            'Tooltip',getString(message('lidar:lidarViewer:DiscardEditOperationsToolTip')),...
            'Tag','discardEditButton',"WordWrap","on");
            this.DiscardEditButton.Layout.Row=1;
            this.DiscardEditButton.Layout.Column=1;


            this.GenerateMacroButton=uibutton('Parent',this.BottomGrid,...
            'Text',getString(message('lidar:lidarViewer:ExportEditsToFunction')),...
            'ButtonPushedFcn',@(~,~)notify(this,'RequestToGenerateMacro'),...
            'Tooltip',getString(message('lidar:lidarViewer:ExportEditsToFunctionToolTip')),...
            'Tag','macroEditButton',"WordWrap","on");
            this.GenerateMacroButton.Layout.Row=1;
            this.GenerateMacroButton.Layout.Column=3;

            this.setButtons(false);
        end
    end




    methods(Access=private)
        function textToDisplay=getTextToDisplay(this,editInfo)



            textToDisplay={};

            textToDisplay{1}=editInfo.Name;

            try



                fieldNames=fieldnames(editInfo.AlgoParams);
                paramValues=struct2cell(editInfo.AlgoParams);

                if strcmp(editInfo.Name,getString(message('lidar:lidarViewer:Crop')))





                    textToDisplay{end+1}=...
                    this.generatePramText(fieldNames{1},...
                    paramValues{1});

                    for i=1:numel(paramValues{2})
                        textToDisplay{end+1}=['Cuboid',num2str(i),':'];
                        for j=2:4
                            paramText=[fieldNames{j},' :  [',sprintf('%.2f   ',paramValues{j}{i})];
                            paramText=paramText(1:length(paramText)-3);
                            paramText=[paramText,']'];
                            textToDisplay{end+1}=paramText;
                        end
                    end
                else


                    for i=1:numel(fieldNames)
                        textToDisplay{end+1}=...
                        this.generatePramText(fieldNames{i},...
                        paramValues{i});
                    end
                end
            catch


            end
        end


        function createAndAddEntry(this,textToDisplay)


            this.EntryList{end+1}=uitextarea(...
            'Parent',this.MainGrid,...
            'Editable','off',...
            'Value',textToDisplay,...
            'BackgroundColor',[1,1,1]*.74,...
            'Tag',['histPanelEntry_',int2str(numel(this.EntryList))]);

        end



        function setButtons(this,TF)

            this.GenerateMacroButton.Enable=TF;
            this.DiscardEditButton.Enable=TF;
        end


        function addDefaultTextToHistoryPanel(this)


            this.DefaultText=uilabel('Parent',this.MainGrid,...
            'WordWrap','on','Visible',true,...
            'Text',getString(message('lidar:lidarViewer:HistoryPanelDefaultText')),...
            'FontColor',[0.45,0.45,0.45]);
            this.DefaultText.Layout.Row=1;
            this.DefaultText.Layout.Column=1;

        end
    end




    methods(Static,Access=private)

        function paramText=generatePramText(paramName,paramValue)



            if isnumeric(paramValue)


                if isequal(size(paramValue),[1,1])

                    paramText=[paramName,' : ',num2str(paramValue)];
                elseif isequal(size(paramValue,1),1)

                    paramText=[paramName,' : [',num2str(paramValue),']'];
                elseif isequal(size(paramValue,2),1)

                    paramText=[paramName,' : [',num2str(paramValue'),']'];
                else

                    paramText=[paramName,' : '];
                end

            elseif ischar(paramValue)

                paramText=[paramName,' : ',paramValue];
            end

        end
    end
end
