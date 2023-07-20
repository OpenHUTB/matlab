classdef DataBrowser<handle



    properties(Dependent)

SelectedEntryID

SelectedIndex

SelectedEntryDraft

SelectedEntryStatus

SelectedEntryMessage

NumberOfEntries

    end

    properties(Access=private)

        Message string=string.empty;

        Draft logical=logical.empty;

        Status logical=logical.empty;

        ID double=[];

    end

    properties(GetAccess=?uitest.factory.Tester)

        Table matlab.ui.control.Table

    end

    events

DataBrowserUpdated

DataBrowserStatusChange

DeleteSelectedEntry

DataBrowserCleared

    end

    methods




        function self=DataBrowser(hfig)
            createDataBrowser(self,hfig);
        end




        function createEntryCard(self,hObj,evtData)

            modelNumber=validateModelName(self,evtData.data.ModelNumber);

            data={modelNumber,evtData.data.NameMessage,'DRAFT','','',''};

            index=self.getCardIndex(modelNumber);

            oldData=self.Table.Data;
            self.Table.Data=[oldData(1:index-1,:);data;oldData(index:end,:)];

            removeCellFocus(self);
            self.Table.Selection=index;

            oldDraft=self.Draft;
            self.Draft=[oldDraft(1:index-1);true;oldDraft(index:end)];

            oldStatus=self.Status;
            self.Status=[oldStatus(1:index-1);true;oldStatus(index:end)];

            oldID=self.ID;
            self.ID=[oldID(1:index-1);evtData.data.ID;oldID(index:end)];

            oldMessage=self.Message;
            if isempty(self.Message)
                self.Message="";
            elseif index==self.NumberOfEntries
                self.Message=[oldMessage;""];
            else
                self.Message=[oldMessage(1:index-1);"";oldMessage(index:end)];
            end

            self.updateEntryCard(hObj,evtData);

        end




        function finalizeEntryCard(self,~,evtData)
            index=find(self.ID==evtData.data.Index,1);
            self.Draft(index)=evtData.data.Draft;
            self.Table.Data{index,3}=num2str(evtData.data.Quality);
            self.Table.Data{index,4}=num2str(evtData.data.Time);
            self.Message(index)=evtData.data.statusMessage;
            notify(self,'DataBrowserStatusChange');
        end




        function updateEntryCard(self,~,evtData)
            index=find(self.ID==evtData.data.ID,1);
            self.Status(index)=evtData.data.Status;
            if any(strcmp(evtData.data.NameMessage,{'SURF','FAST','MSER','BRISK','Harris','MinEigen','KAZE','ORB'}))
                self.Table.Data{index,6}=[num2str(evtData.data.numFixed),', ',num2str(evtData.data.numMoving)];
                self.Table.Data{index,5}=num2str(evtData.data.numMatched);
            end
            self.Message(index)=evtData.data.statusMessage;
            notify(self,'DataBrowserStatusChange');
        end




        function deleteAllEntryCards(self)
            self.Table.Data={};
            self.Table.Selection=[];
            self.Draft=logical.empty;
            self.Status=logical.empty;
            self.Message=string.empty;
            self.ID=[];
        end




        function modelNumber=getChildModelNumber(self)

            previousModel=[];
            parentModel=[self.Table.Data{self.SelectedIndex,1},'.'];
            for ii=1:size(self.Table.Data,1)
                if strncmp(parentModel,self.Table.Data{ii,1},numel(parentModel))
                    previousModel=self.Table.Data{ii,1};
                end
            end
            if isempty(previousModel)
                newval=1;
            else
                previousModel(1:numel(parentModel))=[];
                idx=strfind(previousModel,'.');
                if isempty(idx)
                    newval=str2double(previousModel)+1;
                else
                    newval=str2double(previousModel(1:idx(1)))+1;
                end
            end
            modelNumber=[parentModel,sprintf('%d',newval)];

        end




        function modelName=getModelName(self)

            if isempty(self.Table.Data)

                modelName='';
            else
                modelName=self.Table.Data{self.SelectedIndex,2};
            end

        end

    end

    methods(Access=private)


        function createDataBrowser(self,hfig)

            import images.internal.app.registration.ui.*;

            g=uigridlayout(hfig,[1,1],'Padding',[2,1,2,2]);

            cmenu=uicontextmenu(hfig);
            uimenu(cmenu,'Text',getMessageString('deleteSelected'),'MenuSelectedFcn',@(~,~)deleteSelectedEntry(self));

            self.Table=uitable(...
            'Tag','RegistrationTable',...
            'Parent',g,...
            'FontSize',12,...
            'Enable','on',...
            'ColumnName',{getMessageString('nameHeader'),getMessageString('techniqueHeader'),getMessageString('qualityHeader'),getMessageString('timeHeader'),getMessageString('matchedHeader'),getMessageString('detectedHeader')},...
            'ColumnFormat',{'char','char','char','char','char','char'},...
            'RowName',{},...
            'Visible','on',...
            'ContextMenu',cmenu,...
            'SelectionType','row',...
            'RowStriping','on',...
            'ColumnSortable',true,...
            'ColumnWidth','fit',...
            'ColumnEditable',[true,false,false,false,false,false],...
            'CellEditCallback',@(src,evt)cellEdited(self,evt),...
            'CellSelectionCallback',@(src,evt)selectRow(self,evt));

        end


        function deleteSelectedEntry(self)

            notify(self,'DeleteSelectedEntry');

            if self.NumberOfEntries==1

                deleteAllEntryCards(self);
                notify(self,'DataBrowserCleared');

            else

                idx=self.SelectedIndex;

                oldData=self.Table.Data;
                oldData(idx,:)=[];
                self.Table.Data=oldData;

                if idx>self.NumberOfEntries
                    removeCellFocus(self);
                    self.Table.Selection=self.NumberOfEntries;
                end

                self.Draft(idx)=[];
                self.Status(idx)=[];
                self.ID(idx)=[];
                self.ID(self.ID>idx)=self.ID(self.ID>idx)-1;
                self.Message(idx)=[];

                notify(self,'DataBrowserUpdated');

            end

        end


        function selectRow(self,evt)

            if~isempty(evt.Source.Selection)
                if~isscalar(evt.Source.Selection)
                    evt.Source.Selection=evt.Source.Selection(1);
                end
            else
                removeCellFocus(self);
                evt.Source.Selection=1;
            end

            notify(self,'DataBrowserStatusChange');
            notify(self,'DataBrowserUpdated');

        end


        function cellEdited(~,evt)

            TF=cellfun(@(x)strcmp(x,evt.NewData),evt.Source.Data(:,1));

            if sum(TF)>1
                evt.Source.Data{evt.Indices(1),evt.Indices(2)}=evt.PreviousData;
            end

        end


        function modelNumber=validateModelName(self,modelNumber)

            if isempty(self.Table.Data)
                return;
            end

            TF=cellfun(@(x)strcmp(x,modelNumber),self.Table.Data(:,1));

            while any(TF)

                modelNumber=num2str(str2double(modelNumber)+1);

                TF=cellfun(@(x)strcmp(x,modelNumber),self.Table.Data(:,1));

            end

        end


        function idx=getCardIndex(self,model)
            dotIdx=strfind(model,'.');
            idx=self.NumberOfEntries+1;
            if~isempty(dotIdx)
                maxIdx=max(dotIdx);
                num=str2double(model(maxIdx+1:end));
                if isequal(num,1)
                    searchString=model(1:maxIdx-1);
                else
                    searchString=[model(1:maxIdx),sprintf('%d',num-1)];
                end
                for ii=1:self.NumberOfEntries
                    if strncmp(self.Table.Data{ii,1},searchString,numel(searchString))
                        idx=ii+1;
                    end
                end
            end
        end


        function removeCellFocus(self)



            self.Table.SelectionType='cell';
            self.Table.SelectionType='row';

        end

    end

    methods




        function set.SelectedEntryStatus(self,TF)

            self.Status(self.SelectedIndex)=TF;

        end

        function TF=get.SelectedEntryStatus(self)

            if self.SelectedIndex>0
                TF=self.Draft(self.SelectedIndex)&&...
                self.Status(self.SelectedIndex);
            else
                TF=false;
            end

        end




        function TF=get.SelectedEntryDraft(self)

            if self.SelectedIndex>0
                TF=self.Draft(self.SelectedIndex);
            else
                TF=false;
            end

        end




        function msg=get.SelectedEntryMessage(self)

            if self.SelectedIndex>0
                msg=self.Message(self.SelectedIndex);
            else
                msg='';
            end

        end




        function idx=get.SelectedIndex(self)

            idx=self.Table.Selection;

            if isempty(idx)
                idx=0;
            end

        end

        function set.SelectedIndex(self,idx)

            removeCellFocus(self);
            self.Table.Selection=idx;

        end




        function idx=get.SelectedEntryID(self)

            idx=self.ID(self.SelectedIndex);

        end




        function n=get.NumberOfEntries(self)

            n=size(self.Table.Data,1);

        end

    end

end
