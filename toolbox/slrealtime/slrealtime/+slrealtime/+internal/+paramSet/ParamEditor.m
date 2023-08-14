classdef ParamEditor<handle





    properties
VarEditor
VarEditorWksp

CallingApp
ParamValue
ParamName
BlockPath
FullName
ParameterSet
row
valueEditorFig
    end

    methods

        function obj=ParamEditor(blkpath,pname,pvalue,paramset,row,fig)

            obj.CallingApp=fig;
            obj.ParamName=pname;
            obj.BlockPath=blkpath;
            if isempty(blkpath)
                obj.FullName=pname;
            else
                obj.FullName=[blkpath,'/',pname];
            end
            obj.ParamValue=pvalue;
            obj.ParameterSet=paramset;
            obj.row=row;

            obj.VarEditorWksp=...
            matlab.internal.datatoolsservices.AppWorkspace;

            assignin(obj.VarEditorWksp,obj.FullName,pvalue);

            window=obj.CallingApp.Position;
            width=400;
            height=300;
            center=window(1)+window(3)/2;
            left=center-width/2;
            center=window(2)+window(4)/2;
            up=center+height/2;

            obj.valueEditorFig=uifigure('position',[left,up,width,height]);
            obj.valueEditorFig.Name=pname;
            g=uigridlayout(obj.valueEditorFig,[1,1]);
            g.RowHeight={'1x'};
            g.ColumnWidth={'1x'};

            obj.VarEditor=...
            matlab.internal.datatools.uicomponents.uivariableeditor.UIVariableEditor(...
            'Variable',obj.FullName,...
            'Workspace',obj.VarEditorWksp,...
            'Parent',g,...
            'DataEditable',true);
            obj.VarEditor.DataEditCallbackFcn=@(eventData)(obj.ValueEditorDataEdit(eventData));
        end


        function delete(obj)
            if~isempty(obj.VarEditorWksp)
                delete(obj.VarEditorWksp);
                obj.VarEditorWksp=[];
            end
            if~isempty(obj.VarEditor)
                if isvalid(obj.VarEditor)


                    delete(obj.VarEditor.Parent.Parent);
                end
                obj.VarEditor=[];
            end
            if~isempty(obj.valueEditorFig)
                delete(obj.valueEditorFig);
                obj.valueEditorFig=[];
            end
        end

        function updateParamValueInVarEditor(obj,newValue)
            assignin(obj.VarEditorWksp,obj.FullName,newValue);
            obj.ParamValue=newValue;
        end
    end

    methods(Access=private)
        function ValueEditorDataEdit(obj,eventData)
            originalValue=obj.ParamValue;
            newValue=evalin(obj.VarEditorWksp,obj.FullName);
            obj.ParamValue=newValue;


            try
                obj.ParameterSet.set(obj.BlockPath,obj.ParamName,newValue);
            catch ME
                if strcmp(ME.identifier,'slrealtime:paramSet:structFieldMismatch')
                    obj.restoreDataAndBringToFront(originalValue)
                    return;
                end

                fig=obj.valueEditorFig;
                uialert(fig,ME.message,...
                message('slrealtime:paramSet:error').getString(),...
                'CloseFcn',@(~,~)obj.restoreDataAndBringToFront(originalValue));
            end
        end

        function restoreDataAndBringToFront(obj,data)


            if isvalid(obj.VarEditor)

                obj.updateParamValueInVarEditor(data);

                figure(obj.VarEditor.Parent.Parent);
            end
        end
    end

end
