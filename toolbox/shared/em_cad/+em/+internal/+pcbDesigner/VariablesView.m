classdef VariablesView<cad.View




    properties
        VariablesManager=cad.VariablesManager;
Table
Figure
AddBtn
DeleteBtn
Layout
MapView
MapFigure
DeleteView
DeleteFigure
ShowMapBtn
        DeleteIconLocation=fullfile(matlabroot,"toolbox","shared","em_cad",...
        "+em","+internal","+pcbDesigner","+src","delete.svg");
        AddIconLocation=fullfile(matlabroot,"toolbox","shared","em_cad",...
        "+em","+internal","+pcbDesigner","+src","add.svg");
        AdditionalCallback=@()1;
        DeleteCallback=@(src,evt)1;
    end

    methods
        function self=VariablesView(f)
            self.Figure=f;
            self.DeleteCallback=@(evt)self.notify('DeleteVariable',evt);
            createUIControls(self);
        end

        function createUIControls(self)
            self.Layout=uigridlayout(self.Figure,[5,5],...
            RowHeight={25,'1x','1x','1x',25},...
            ColumnWidth={75,50,'1x',25,25});

            self.AddBtn=uibutton(self.Layout,Icon=self.AddIconLocation,Text='',...
            ButtonPushedFcn=@(src,evt)self.AddBtnCallback(src,evt),Tag="AddBtn",...
            Tooltip=getString(message("antenna:pcbantennadesigner:AddVariableTooltip")));
            self.DeleteBtn=uibutton(self.Layout,Icon=self.DeleteIconLocation,Text='',...
            ButtonPushedFcn=@(src,evt)self.DeleteBtnCallback(src,evt),...
            Enable="off",Tag="DeleteBtn",Tooltip=getString(message("antenna:pcbantennadesigner:DeleteVariableTooltip")));
            setLayout(self,self.AddBtn,1,4);
            setLayout(self,self.DeleteBtn,1,5);
            self.Table=uitable(self.Layout,ColumnFormat={'logical','char','numeric','char'},...
            ColumnEditable=[true,true,true,false],ColumnName={'','Name','Set Value/Expression','Derived Value'}...
            ,CellEditCallback=@(src,evt)tableCallback(self,src,evt),RowName='',Tag="VariablesTable",...
            ColumnWidth={25,'auto','auto',150});

            setLayout(self,self.Table,[2,5],[1,5]);

            self.ShowMapBtn=uibutton(self.Layout,Text="Show Dependencies",...
            ButtonPushedFcn=@(src,evt)self.ShowMapBtnCallback(src,evt),...
            Enable="off",Tag="ShowMapBtn",Tooltip=getString(message("antenna:pcbantennadesigner:ShowDependenciesTooltip")));
            setLayout(self,self.ShowMapBtn,1,[1,2]);


        end

        function ShowMapBtnCallback(self,src,evt)
            if~isempty(self.MapFigure)
                self.MapFigure.delete;
                self.MapView.delete;
            end
            self.MapFigure=uifigure('Visible','off');
            self.MapView=em.internal.pcbDesigner.MapView(self.MapFigure,1,'info');
            self.MapView.AdditionalCallback=self.AdditionalCallback;
            selectedIndices=cell2mat([self.Table.Data(:,1)]);
            varnames=self.Table.Data(logical(selectedIndices),2);
            self.MapView.updateView(self.VariablesManager,varnames);
            self.MapView.showDialog();
        end

        function AddBtnCallback(self,src,evt)
            varname=self.genNewName();
            evt=cad.events.VariableEventData(varname,1);
            self.notify('AddVariable',evt);
        end

        function name=genNewName(self)
            numvar=numel(self.VariablesManager.Variables);
            name=['VarName',num2str(numvar+1)];
            try
                error=0;
                self.VariablesManager.verifyName(name);
            catch
                error=1;
            end
            indx=1;
            newname=name;
            while error
                newname=[name,'_',num2str(indx)];
                try
                    error=0;
                    self.VariablesManager.verifyName(newname);
                catch
                    error=1;
                    indx=indx+1;
                end
            end

            name=newname;
        end

        function DeleteBtnCallback(self,src,evt)
            if~isempty(self.DeleteFigure)
                self.DeleteFigure.delete;
                self.DeleteView.delete;
            end
            self.DeleteFigure=uifigure('Visible','off');
            self.DeleteFigure.Position=self.DeleteFigure.Position+[-150,-150,0,0];
            self.DeleteView=em.internal.pcbDesigner.DeleteVariablesView(self.DeleteFigure);
            self.DeleteView.AdditionalCallback=self.AdditionalCallback;
            self.DeleteView.DeleteVariablesCallback=self.DeleteCallback;

            selectedIndices=cell2mat([self.Table.Data(:,1)]);
            varnames=self.Table.Data(logical(selectedIndices),2);
            retval=self.DeleteView.updateView(self.VariablesManager,varnames);
            if~retval
                value=self.Table.Data(logical(selectedIndices),3);
                evt=cad.events.VariableEventData(varnames,value);
                self.notify('DeleteVariable',evt);
                self.DeleteFigure.delete;
            else
                self.DeleteView.showDialog();
            end

        end

        function tableCallback(self,src,evt)
            if evt.Indices(2)==1

                enableDisableDeleteBtn(self)

            elseif evt.Indices(2)==2

                name=evt.NewData;
                try
                    self.VariablesManager.verifyName(name);
                    self.notify('ChangeVariable',cad.events.VariableEventData(...
                    evt.PreviousData,self.Table.Data{evt.Indices(1),3},evt));
                catch me
                    errordlg(me.message);


                    self.Table.Data{evt.Indices(1),evt.Indices(2)}=evt.PreviousData;
                end
            elseif evt.Indices(2)==3

                value=evt.NewData;
                try
                    [funchandle,depvars,opvalue]=self.VariablesManager.parseExpression(value);
                    varname=self.Table.Data{evt.Indices(1),2};
                    allvarnames=self.VariablesManager.getVarNames();
                    indx=strcmpi(allvarnames,varname);
                    varobj=self.VariablesManager.Variables(indx);
                    varobj.verifyValue(opvalue);

                    for i=1:numel(depvars)
                        verifyParentVariableNotEqual(self.VariablesManager,depvars(i),varobj)
                    end


                    self.notify('ChangeVariable',cad.events.VariableEventData(...
                    varname,evt.PreviousData,evt));
                catch me
                    errordlg(me.message);
                    self.Table.Data{evt.Indices(1),evt.Indices(2)}=evt.PreviousData;
                end
            end
        end

        function enableDisableDeleteBtn(self)
            if~isvalid(self.VariablesManager)||isempty(self.VariablesManager.Variables)
                self.DeleteBtn.Enable='off';
                self.ShowMapBtn.Enable='off';
                return;
            end
            selectedIndices=cell2mat([self.Table.Data(:,1)]);
            if any(selectedIndices)
                self.DeleteBtn.Enable='on';
                self.ShowMapBtn.Enable='on';
            else
                self.DeleteBtn.Enable='off';
                self.ShowMapBtn.Enable='off';
            end
        end

        function updateView(self,vm)

            data=genTableData(self);
            self.Table.Data=data;
            enableDisableDeleteBtn(self);
        end

        function data=genTableData(self)
            if~isvalid(self.VariablesManager)||isempty(self.VariablesManager.Variables)
                data=[];
                return;
            end
            names={self.VariablesManager.Variables.Name};
            value={self.VariablesManager.Variables.Value};
            for i=1:numel(value)
                if isa(value{i},'function_handle')
                    value{i}=self.VariablesManager.getExpressionWithoutInputs(value{i});
                else
                    if numel(value{i})>1
                        value{i}=mat2str(value{i});
                    else
                        value{i}=num2str(value{i});
                    end
                end
            end
            numericValue=arrayfun(@(x)x.getValue(),self.VariablesManager.Variables,'UniformOutput',false);
            for i=1:numel(numericValue)
                if(~(isa(self.VariablesManager.Variables(i).Value,'function_handle')))
                    numericValue{i}='-';
                    continue;
                end
                if numel(numericValue)>1
                    numericValue{i}=mat2str(numericValue{i});
                else
                    numericValue{i}=num2str(numericValue{i});
                end
            end
            select=cellfun(@(x)false,names,'UniformOutput',false);
            data=[select',names',value',numericValue];

        end

        function setModel(self,model)
            controller=cad.VariablesController(self,model);
            controller.addListeners();


        end

        function delete(self)
            if~isempty(self.MapFigure)
                self.MapFigure.delete;
                self.MapView.delete;

            end
            if~isempty(self.DeleteFigure)
                self.DeleteFigure.delete;
                self.DeleteView.delete;
            end
        end
    end

    events
AddVariable
DeleteVariable
ChangeVariable
    end
end
