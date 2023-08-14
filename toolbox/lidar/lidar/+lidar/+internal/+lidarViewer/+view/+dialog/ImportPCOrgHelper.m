




classdef ImportPCOrgHelper<lidar.internal.lidarViewer.view.dialog.helper.OkCanceDialog
    properties
VariableSelected

        IsSuccess(1,1)logical=false
    end

    properties(Access=private)
InstructionTextPos
InstructionText
DataTablePos
DataTable

SelectedItem
    end

    methods



        function this=ImportPCOrgHelper()
            title=getString(message('lidar:lidarViewer:ImportFromWorkspace'));
            this=this@lidar.internal.lidarViewer.view.dialog.helper.OkCanceDialog(title,[350,400]);


            this.calculatePosition();


            this.createUI();
        end

        function userAction=getUserAction(this)
            userAction.IsSuccess=this.IsSuccess;
            if this.IsSuccess
                userAction.VariableSelected=evalin('base',this.VariableSelected{1});
            else
                userAction.VariableSelected=[];
            end
        end
    end


    methods(Access=private)
        function calculatePosition(this)

            parentWidth=this.MainFigure.Position(3);

            this.InstructionTextPos=...
            [20,370,parentWidth-40,20];
            this.DataTablePos=...
            [20,90,parentWidth-40,270];
        end


        function createUI(this)

            this.addInstructionText();

            this.addDataTable();
        end


        function addInstructionText(this)

            this.InstructionText=uilabel(this.MainFigure,...
            'Position',this.InstructionTextPos,...
            'Text',getString(message('lidar:lidarViewer:Variables')),...
            'FontSize',14);
        end


        function addDataTable(this)

            varname=getValidWSVarName(this);

            this.DataTable=uitable(this.MainFigure,...
            'Position',this.DataTablePos,...
            'Data',varname,...
            'Tag','workspaceVarTable',...
            'SelectionType','row',...
            'CellSelectionCallback',@(~,evt)userSelectedVariable(this,evt));

            this.DataTable.RowName='';
            this.DataTable.ColumnName={getString(message('lidar:lidarViewer:Name'));...
            getString(message('lidar:lidarViewer:Class'));getString(message('lidar:lidarViewer:Size'))};
        end


        function varList=getValidWSVarName(this)

            varList=[];

            ws_vars=evalin('base','whos');

            validVars=strcmp({ws_vars.class},'double');
            ws_vars=ws_vars(validVars);
            for i=1:numel(ws_vars)
                workspace_values=evalin('base',ws_vars(i).name);
                if isrow(workspace_values)&&...
                    issorted(workspace_values,'descend')
                    if workspace_values(1)<=90&&workspace_values(end)>=-90
                        s=size(evalin('base',ws_vars(i).name));
                        varList=[varList;...
                        {ws_vars(i).name,class(evalin('base',ws_vars(i).name)),...
                        [num2str(s(1)),' x ',num2str(s(2))]}];
                    end
                end
            end
        end


        function userSelectedVariable(this,evt)
            this.IsSuccess=true;
            this.VariableSelected=this.DataTable.Data(evt.Indices(1));
        end
    end

    methods(Access=protected)

        function cancelClicked(this)

            this.close();
            this.IsSuccess=false;
        end
    end
end