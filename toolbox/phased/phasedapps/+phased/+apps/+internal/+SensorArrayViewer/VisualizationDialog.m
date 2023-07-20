


classdef VisualizationDialog<dialogmgr.DCTableForm


    properties(SetObservable)
        ViewTypeIndex=1
        ShowNormals=false
        ShowIndex=false
        AD2DDropNameIndex=1
        AD3DDropNameIndex=1
        AzCutValue=0
        ElCutValue=0
        ShowGeometry=false
    end

    properties

Application

    end

    properties(SetAccess=private)
ViewTypeNames
AD2DDropNames
AD3DDropNames
    end

    properties(Access=private)


ViewDropDown
    end

    methods
        function obj=VisualizationDialog(SAV,name)
            if nargin<2
                name=getString(message('phased:apps:arrayapp:VisualizationSettings'));
            end
            if nargin<1



                obj.Name='Unknown';
                obj.Application=phased.apps.internal.SensorArrayViewer.SensorArrayViewer;
                return;
            end
            obj.Name=name;
            obj.Application=SAV;

        end

        function updateVisuals(obj)


            curAT=obj.Application.Settings.getCurArrayType();
            if curAT.CanPlotGratingLobe
                set(obj.ViewDropDown,'String',obj.ViewTypeNames);
            else
                set(obj.ViewDropDown,'String',obj.ViewTypeNames(1:3));
            end

            if~obj.Application.Settings.getCurArrayType().CanPlotGratingLobe&&...
                obj.getCurViewType()==phased.apps.internal.SensorArrayViewer.ViewType.GratingLobe



                obj.ViewTypeIndex=1;

            end
        end
    end

    methods(Access=protected)
        function initTable(obj)


            obj.ViewTypeNames=arrayfun(@(a)a.Name,enumeration('phased.apps.internal.SensorArrayViewer.ViewType'),'UniformOutput',false);
            obj.AD2DDropNames=arrayfun(@(a)a.Name,enumeration('phased.apps.internal.SensorArrayViewer.ArrayDir2dOps'),'UniformOutput',false);
            obj.AD3DDropNames=arrayfun(@(a)a.Name,enumeration('phased.apps.internal.SensorArrayViewer.ArrayDir3dOps'),'UniformOutput',false);


            obj.ViewDropDown=uipopup(obj,obj.ViewTypeNames,'label',[getString(message('phased:apps:arrayapp:ViewLabel')),':']);
            obj.ViewDropDown.Tag='ViewDDTag';
            connectRowVisToControl(obj,{'ShowNormalsTag','ShowIndexTag'},...
            obj.ViewDropDown,phased.apps.internal.SensorArrayViewer.ViewType.ArrayGeometry.Name,true);
            connectRowVisToControl(obj,{'AD2dDropdownTag'},...
            obj.ViewDropDown,phased.apps.internal.SensorArrayViewer.ViewType.ArrayDirectivity2D.Name,true);
            connectRowVisToControl(obj,{'AD3dDropdownTag'},...
            obj.ViewDropDown,phased.apps.internal.SensorArrayViewer.ViewType.ArrayDirectivity3D.Name,true);
            connectPropertyAndControl(obj,'ViewTypeIndex',obj.ViewDropDown,'value');
            obj.newrow


            uitext(obj,[getString(message('phased:apps:arrayapp:ShowNormals')),':']);
            c=uicheckbox(obj);
            c.Tag='ShowNormalsTag';
            connectPropertyAndControl(obj,'ShowNormals',c);
            obj.newrow


            uitext(obj,[getString(message('phased:apps:arrayapp:ShowIndex')),':']);
            c=uicheckbox(obj);
            c.Tag='ShowIndexTag';
            connectPropertyAndControl(obj,'ShowIndex',c);
            obj.newrow


            c=uipopup(obj,obj.AD2DDropNames,'Label',[getString(message('phased:apps:arrayapp:CutType')),':']);
            c.Tag='AD2dDropdownTag';
            setVisibilityOnState(obj,{'ViewTypeIndex','AD2DDropNameIndex'},{2,1:2},'AzCutValueTag',1)
            setVisibilityOnState(obj,{'ViewTypeIndex','AD2DDropNameIndex'},{2,3:4},'ElCutValueTag',1)
            connectPropertyAndControl(obj,'AD2DDropNameIndex',c,'value');
            obj.newrow


            c=uieditv(obj,'label',getString(message('phased:apps:arrayapp:CutValue')));
            c.Tag='AzCutValueTag';
            c.ValidAttributes={'real','scalar','>=',-90,'<=',90};
            connectPropertyAndControl(obj,'AzCutValue',c);
            uitext(obj,getString(message('phased:apps:arrayapp:degrees')));
            obj.newrow;


            c=uieditv(obj,'label',getString(message('phased:apps:arrayapp:CutValue')));
            c.Tag='ElCutValueTag';
            c.ValidAttributes={'real','scalar','>=',-180,'<=',180};
            connectPropertyAndControl(obj,'ElCutValue',c);
            uitext(obj,getString(message('phased:apps:arrayapp:degrees')));
            obj.newrow;


            c=uipopup(obj,obj.AD3DDropNames,'Label',[getString(message('phased:apps:arrayapp:Option')),':']);
            c.Tag='AD3dDropdownTag';
            connectPropertyAndControl(obj,'AD3DDropNameIndex',c,'value');
            setVisibilityOnState(obj,{'ViewTypeIndex','AD3DDropNameIndex'},{3,1},'ShowGeometryTag',1);
            obj.newrow


            c=uitext(obj,[getString(message('phased:apps:arrayapp:ShowGeometry')),':'],'Visible','off');
            c.Tag='ShowGeometryLabelTag';
            c=uicheckbox(obj);
            c.Tag='ShowGeometryTag';
            connectPropertyAndControl(obj,'ShowGeometry',c);
            obj.skipcol;
            obj.newrow

            obj.InterColumnSpacing=2;
            obj.InterRowSpacing=2;
            obj.InnerBorderSpacing=4;


            obj.ColumnWidths={140,'max',45};
            obj.HorizontalAlignment={'right','left','left'};

        end

    end

    methods(Access=public)

        function vt=getCurViewType(obj)
            vt=phased.apps.internal.SensorArrayViewer.ViewType.getViewTypeAtPosition(obj.ViewTypeIndex);
        end

        function op2d=getCur2DOption(obj)
            op2d=phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.getOpAtPosition(obj.AD2DDropNameIndex);
        end

        function op3d=getCur3DOption(obj)
            op3d=phased.apps.internal.SensorArrayViewer.ArrayDir3dOps.getOpAtPosition(obj.AD3DDropNameIndex);
        end
    end

end
