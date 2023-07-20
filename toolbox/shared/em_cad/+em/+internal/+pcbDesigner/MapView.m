classdef MapView<cad.View
    properties
Parent
ObjectDepTable
VariablesDependentTable
Layout
Height
DepObjectName
DepVariableName
AddCloseBtn
CloseBtn
        WarnMessage=@(x)getString(message("antenna:pcbantennadesigner:DepVariablesExist",x));
        NegativeMessage=@(x)getString(message("antenna:pcbantennadesigner:NoDepVariables",x));
Type
WarnIcon
WarnMessageUI
        WarnFileLocation=fullfile(matlabroot,"toolbox","shared","em_cad",...
        "+em","+internal","+pcbDesigner","+src","warn_24.png");
        InfoFileLocation=fullfile(matlabroot,"toolbox","shared","em_cad",...
        "+em","+internal","+pcbDesigner","+src","info_24.png");
        AdditionalCallback=@()1;
    end

    properties(Hidden=true)
        HeightVal={25,'1x','1x','1x','1x','1x'};
        NoHeightVal={0,0,0,0,0,0};
        DescriptionHeightVal={25,25};
    end
    methods
        function self=MapView(Parent,AddCloseBtn,Type)
            self.Parent=Parent;
            self.AddCloseBtn=AddCloseBtn;
            self.Type=Type;
            createUiControls(self);

        end

        function createUiControls(self)
            if self.AddCloseBtn
                rows=9;
            else
                rows=8;
            end
            if isprop(self.Parent,'CloseRequestFcn')
                clf(self.Parent);
                self.Parent.CloseRequestFcn=@self.closeCallback;
                self.Parent.Name="Design Variable Dependencies";
                self.Parent.WindowStyle='modal';
            else
                if(strcmpi(self.Parent.Type,'uipanel'))
                    self.Parent.BorderType='none';
                end
            end
            self.Layout=uigridlayout(self.Parent,[rows,4]);
            if strcmpi(self.Type,'warn')
                self.WarnIcon=uiimage(self.Layout,"ImageSource",self.WarnFileLocation,Tag="Icon",ScaleMethod='none');
            else
                self.WarnIcon=uiimage(self.Layout,"ImageSource",self.InfoFileLocation,Tag="Icon",ScaleMethod='none');
            end
            setLayout(self,self.WarnIcon,[1,2],1);
            self.WarnMessageUI=uilabel(self.Layout,'Text',self.NegativeMessage('.'),'WordWrap','on',Tag="MapMessage");
            setLayout(self,self.WarnMessageUI,[1,2],[2,3]);
            self.DepObjectName=uilabel(self.Layout,'Text','Dependant Objects',FontWeight="bold",Tag="DepObjectTitle");
            self.setLayout(self.DepObjectName,3,[2,3]);
            self.ObjectDepTable=uitable(self.Layout,'RowName','','ColumnName',{'Variable Name','Stackup Dependencies','Variable Dependencies'},Tag="DepObjectTable");
            self.setLayout(self.ObjectDepTable,[4,8],[2,3]);





            if self.AddCloseBtn
                self.CloseBtn=uibutton(self.Layout,'Text','Close','ButtonPushedFcn',@(src,evt)closeCallback(self,src,evt),Tag="CloseBtn");
                self.setLayout(self.CloseBtn,9,4);
                self.Layout.RowHeight=[self.DescriptionHeightVal,self.HeightVal,{25}];
                self.Layout.ColumnWidth={50,'1x','1x',50};
            else
                self.Layout.RowHeight=[self.DescriptionHeightVal,self.HeightVal];
                self.Layout.ColumnWidth={50,'1x','1x',50};
            end
            self.Parent.Tag="VariableMapView";


        end

        function closeCallback(self,src,evt)
            self.Parent.delete;
            self.AdditionalCallback();
        end

        function showDialog(self)
            self.Parent.Visible='on';
        end

        function retVal=updateView(self,vm,vars)
            [data,usedvars]=genData(self,vm,vars);
            self.ObjectDepTable.Data=data;


            self.Height=0;
            if~isempty(data)
                objEmpty=1;
                self.Height=self.Height+150;
                depObjHeightVal=self.HeightVal;
                self.DepObjectName.Visible=1;
                self.ObjectDepTable.Visible=1;
            else
                objEmpty=0;
                depObjHeightVal=self.NoHeightVal;
                self.DepObjectName.Visible=0;
                self.ObjectDepTable.Visible=0;
            end

            retVal=~isempty(data);
            if retVal
                if isempty(usedvars)
                    self.WarnMessageUI.Text=self.NegativeMessage(strjoin(vars,','));
                    setParentHeight(self,370);
                else

                    if numel(usedvars)~=numel(vars)
                        notusedvars=setdiff(vars,usedvars);
                        self.WarnMessageUI.Text=[self.WarnMessage(strjoin(usedvars,',')),...
                        newline,newline,...
                        self.NegativeMessage(strjoin(notusedvars,','))];
                        setParentHeight(self,370);
                    else
                        self.WarnMessageUI.Text=self.WarnMessage(strjoin(usedvars,','));
                        setParentHeight(self,370);
                    end
                end
            else
                self.WarnMessageUI.Text=self.NegativeMessage(strjoin(vars,','));
                setParentHeight(self,370);
            end

            retVal=~isempty(usedvars);
            if self.AddCloseBtn
                self.Layout.RowHeight=[self.DescriptionHeightVal,depObjHeightVal,{25}];
            else
                self.Layout.RowHeight=[self.DescriptionHeightVal,depObjHeightVal];
            end

        end

        function setParentHeight(self,height)
            if strcmpi(self.Parent.Type,'figure')
                self.Parent.Position(4)=height;
            end
        end

        function[Data,usedvars]=genData(self,vm,vars)
            notused=zeros(numel(vars),1);
            Data=cell(numel(vars),3);
            Data(:,1)=vars(:);
            for i=1:numel(vars)
                tmpVarArr=[];
                tmpobjArr={};
                mapObjForDepObj=[];
                varObj=vm.getVarObj(vars{i});
                for j=1:numel(varObj.VariableMap)
                    if isa(varObj.VariableMap(j).DependentObject,'cad.Variable')
                        tmpVarArr=[tmpVarArr;varObj.VariableMap(j).DependentObject];
                    else









                        tmpobjArr=[tmpobjArr;{varObj.VariableMap(j).DependentObject}];
                        mapObjForDepObj=[mapObjForDepObj;varObj.VariableMap(j)];
                    end
                end

                [varArrNames]=arrayfun(@(x)x.Name,unique(tmpVarArr),'UniformOutput',false);

                objArrNames={};
                for k=1:numel(tmpobjArr)
                    objArrNames{k}=getName(self,tmpobjArr{k},mapObjForDepObj(k));
                end
                [varArrNames,idxvar]=sort(varArrNames);
                [objArrNames,idxobj]=sort(objArrNames);
                tmpVarArr=tmpVarArr(idxvar);
                tmpobjArr=tmpobjArr(idxobj);
                Data{i,2}=strjoin(objArrNames,',');
                Data{i,3}=strjoin(varArrNames,',');
                notused(i)=isempty(tmpobjArr)&&isempty(tmpVarArr);
                if isempty(tmpobjArr)
                    Data{i,2}='-';
                end

                if isempty(tmpVarArr)
                    Data{i,3}='-';
                end
            end

            usedvars=vars(~notused);
        end
        function x=getName(self,obj,map)
            if isa(obj,'em.internal.pcbDesigner.VarProperties')
                if strcmpi(map.PropertyName,'FeedDiameter')
                    x='Feed';
                elseif strcmpi(map.PropertyName,'ViaDiameter')
                    x='Via';
                end
            else
                x=obj.Name;
            end
        end



    end
end