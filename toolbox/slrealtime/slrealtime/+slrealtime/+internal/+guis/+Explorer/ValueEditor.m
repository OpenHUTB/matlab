classdef ValueEditor<handle





    properties
VarEditor
VarEditorWksp

CallingApp
BlockPath
ParamName
VarName
ParamValue
TargetObject
    end

    methods

        function obj=ValueEditor(tg,pname,pvalue,blkpath,hCallingApp)
            obj.VarEditorWksp=...
            matlab.internal.datatoolsservices.AppWorkspace;

            varname=strrep(pname,'.','_');
            assignin(obj.VarEditorWksp,varname,pvalue);

            if isa(hCallingApp,'slrealtime.internal.guis.Explorer.AppExplorer')
                window=hCallingApp.App.WindowBounds;
            else
                window=hCallingApp.Position;
            end
            width=400;
            height=300;
            center=window(1)+window(3)/2;
            left=center-width/2;
            center=window(2)+window(4)/2;
            up=center-height/2;

            fig=uifigure('Position',[left,up,width,height]);
            fig.Name=pname;
            g=uigridlayout(fig,[1,1]);
            g.RowHeight={'1x'};
            g.ColumnWidth={'1x'};

            obj.VarEditor=...
            matlab.internal.datatools.uicomponents.uivariableeditor.UIVariableEditor(...
            'Variable',varname,...
            'Workspace',obj.VarEditorWksp,...
            'Parent',g,...
            'DataEditable',true);
            obj.VarEditor.DataEditCallbackFcn=@(eventData)(obj.ValueEditorDataEdit(eventData));

            obj.CallingApp=hCallingApp;
            obj.BlockPath=blkpath;
            obj.ParamName=pname;
            obj.VarName=varname;
            obj.ParamValue=pvalue;
            obj.TargetObject=tg;
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
        end

        function updateParamValueInVarEditor(obj,newValue)
            assignin(obj.VarEditorWksp,obj.VarName,newValue);
            obj.ParamValue=newValue;
        end
    end

    methods(Access=private)
        function ValueEditorDataEdit(obj,eventData)
            originalValue=obj.ParamValue;
            newValue=evalin(obj.VarEditorWksp,obj.VarName);
            obj.ParamValue=newValue;


            tg=obj.TargetObject;
            try
                tg.setparam(obj.BlockPath,obj.ParamName,obj.ParamValue);
            catch ME
                if isa(obj.CallingApp,'slrealtime.internal.guis.Explorer.AppExplorer')

                    fig=obj.CallingApp.ParametersPanel.UIFigure;
                    bringToFront=@()obj.CallingApp.App.bringToFront;
                else


                    fig=obj.CallingApp;
                    bringToFront=@()figure(fig);
                end

                if~isempty(ME.cause)&&strcmp(ME.cause{1}.identifier,'slrealtime:paramtune:paramMinMax')
                    bringToFront();
                    select=uiconfirm(fig,ME.message,...
                    getString(message('slrealtime:explorer:error')),...
                    'Options',{getString(message('slrealtime:explorer:override')),getString(message('slrealtime:explorer:cancel'))},...
                    'DefaultOption',getString(message('slrealtime:explorer:cancel')),...
                    'Icon','error');
                    if isequal(select,getString(message('slrealtime:explorer:override')))

                        try
                            tg.setparam(obj.BlockPath,obj.ParamName,obj.ParamValue,'Force',true);
                        catch ME2
                            uialert(fig,ME2.message,...
                            message('slrealtime:explorer:error').getString(),...
                            'CloseFcn',@(~,~)obj.restoreDataAndBringToFront(originalValue));
                            bringToFront();
                            return;
                        end
                        if isvalid(obj.VarEditor)

                            figure(obj.VarEditor.Parent.Parent);
                        end
                    else


                        obj.restoreDataAndBringToFront(originalValue);
                    end
                else
                    uialert(fig,ME.message,...
                    message('slrealtime:explorer:error').getString(),...
                    'CloseFcn',@(~,~)obj.restoreDataAndBringToFront(originalValue));
                    bringToFront();
                end
            end


            if isa(obj.CallingApp,'slrealtime.internal.guis.Explorer.AppExplorer')
                selectedTargetName=obj.CallingApp.TargetManager.getSelectedTargetName();
                target=obj.CallingApp.TargetManager.getTargetFromMap(selectedTargetName);
                if target.tuning.updatesOnHold
                    target.tuning.paramTableChanged=true;
                    obj.CallingApp.TargetManager.targetMap(selectedTargetName)=target;
                end
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
