classdef LabelDefinition<handle&matlab.mixin.SetGet




    properties

        Definition(:,3)table

CurrentIdx

LabelVisible

    end

    properties(Dependent)

Alphamap

Colormap

NumLabels

    end


    properties(Transient,SetAccess=protected,GetAccess=?matlab.unittest.TestCase)

        NextPixelID(1,1)uint16{mustBePositive}=1

DefaultColormap

    end

    events
LabelDefinitionAdded
LabelDefinitionsUpdated
ErrorThrown
    end

    methods

        function self=LabelDefinition()

            self.setupDefaults();

        end


        function new(self)

            [labelName,color,pixelID]=self.getNextLabel();

            variableNames=["Name","LabelColor","PixelLabelID"];

            newRow={labelName,color,pixelID};
            newLabel=cell2table(newRow,'VariableNames',variableNames);

            self.Definition=[self.Definition;newLabel];
            self.LabelVisible=[self.LabelVisible;1];

            self.CurrentIdx=self.NumLabels;

            self.update();

        end


        function add(self,labelDef)

            numEntriesBeforeAdd=self.NumLabels;

            labelName=labelDef.Name;
            color=labelDef.LabelColor;
            pixelID=labelDef.PixelLabelID;
            variableNames=["Name","LabelColor","PixelLabelID"];

            newRow={};

            for i=1:length(labelName)
                newRow(end+1,:)={labelName(i),color(i,:),pixelID(i)};%#ok<AGROW> 
            end

            newLabel=cell2table(newRow,'VariableNames',variableNames);

            newDefinition=[self.Definition;newLabel];
            newDefinition=unique(newDefinition,"stable");
            self.Definition=newDefinition;

            numEntriesAfterAdd=self.NumLabels;

            newLabelVisible=ones(numEntriesAfterAdd-numEntriesBeforeAdd,1);
            self.LabelVisible=[self.LabelVisible;newLabelVisible];

            self.CurrentIdx=self.NumLabels;
            self.update();

        end


        function remove(self,labelName)

            idx=find(self.Definition.Name==labelName);

            if idx==self.CurrentIdx

                if self.CurrentIdx>1


                    self.CurrentIdx=self.CurrentIdx-1;

                elseif height(self.Definition)>1


                    self.CurrentIdx=1;

                else

                    self.CurrentIdx=0;

                end

            end

            self.Definition(idx,:)=[];
            self.LabelVisible(idx)=[];

            self.update();

        end


        function[name,idx,color]=getCurrentLabel(self)

            name=[];
            idx=[];
            color=[];

            if self.CurrentIdx~=0
                name=self.Definition.Name(self.CurrentIdx);
                idx=self.Definition.PixelLabelID(self.CurrentIdx);
                color=self.Definition.LabelColor(self.CurrentIdx,:);
            end

        end


        function setCurrentLabel(self,labelName)
            self.CurrentIdx=find(self.Definition.Name==labelName);
        end


        function changeName(self,labelName,newName)

            idx=self.Definition.Name==labelName;

            self.Definition.Name(idx)=newName;

        end


        function changeColor(self,labelName,newColor)

            idx=self.Definition.Name==labelName;

            self.Definition.LabelColor(idx,:)=newColor;

        end


        function changeVisibility(self,labelName,TF)

            idx=self.Definition.Name==labelName;

            self.LabelVisible(idx)=TF;

        end


        function clear(self)

            self.setupDefaults();

        end

    end

    methods(Access=protected)


        function update(self)

            evt=medical.internal.app.labeler.events.LabelDefinitionEventData(self.Definition.Name,...
            self.Definition.LabelColor,self.Definition.PixelLabelID,self.LabelVisible,self.CurrentIdx);
            self.notify('LabelDefinitionsUpdated',evt);

        end


        function[Name,LabelColor,PixelLabelID]=getNextLabel(self)





            Name=string(['Label',num2str(self.NextPixelID)]);


            LabelColor=self.DefaultColormap(self.NextPixelID+1,:);
            PixelLabelID=self.NextPixelID;

            self.NextPixelID=self.NextPixelID+1;

        end


        function setupDefaults(self)

            self.DefaultColormap=images.internal.app.utilities.colorOrder();

            variableNames=["Name","LabelColor","PixelLabelID"];
            variableTypes=["string","double","uint8"];

            self.Definition=table('Size',[0,length(variableNames)],...
            'VariableNames',variableNames,...
            'VariableTypes',variableTypes);

            self.CurrentIdx=[];
            self.LabelVisible=[];

        end

    end


    methods


        function set.Definition(self,labelDefs)

            try

                medical.labeler.loading.internal.validateLabelDefinition(labelDefs);
                if iscellstr(labelDefs.Name)
                    labelDefs.Name=string(labelDefs.Name);
                end
                self.Definition=labelDefs;

                if~isempty(labelDefs)
                    self.NextPixelID=max(labelDefs.PixelLabelID)+1;%#ok<*MCSUP> 
                else
                    self.NextPixelID=1;
                end

            catch ME

                evt=medical.internal.app.labeler.events.ErrorEventData(ME.message);
                self.notify('ErrorThrown',evt);


                self.update();

            end

        end


        function cmap=get.Colormap(self)

            cmap=self.DefaultColormap;

            if isempty(self.Definition)
                return
            end

            pixelIDs=self.Definition.PixelLabelID;
            colors=self.Definition.LabelColor;



            cmap(pixelIDs+1,:)=colors;

        end


        function amap=get.Alphamap(self)

            amap=zeros(256,1);

            if isempty(self.Definition)
                return
            end

            pixelIDs=self.Definition.PixelLabelID;

            for i=1:height(self.LabelVisible)
                pixId=pixelIDs(i);
                amap(pixId+1)=self.LabelVisible(i);
            end

        end

        function set.Alphamap(self,amap)

            if islogical(amap)
                self.LabelVisible(:)=amap;
            else
                self.LabelVisible=amap;
            end

        end


        function num=get.NumLabels(self)
            num=height(self.Definition);
        end

    end

end