
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Stair<matlab.graphics.primitive.Data&matlab.graphics.mixin.DataProperties&matlab.graphics.internal.Legacy&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.Legendable&matlab.graphics.mixin.ColorOrderUser&matlab.graphics.chart.interaction.DataAnnotatable






    properties(Dependent,SetObservable,GetObservable)
        XData=zeros(1,0)
    end

    properties(SetObservable,NeverAmbiguous)
        XDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden)
        XData_I=zeros(1,0)
    end

    properties(Hidden,Dependent,SetAccess=private)
XDataCache
    end

    properties(Dependent)
        XVariable=''
    end

    properties(Hidden,Dependent)
        XVariable_I=''
    end

    methods
        function set.XData(hObj,value)
            hObj.setDataPropertyValue("X",value,false);
        end
        function set.XDataMode(hObj,mode)
            hObj.setDataPropertyMode("X",mode);
        end
        function set.XData_I(hObj,value)
            hObj.setDataPropertyValue("X",value,true);
        end
        function set.XVariable(hObj,value)
            hObj.setVariablePropertyValue("X",value,false);
        end
        function set.XVariable_I(hObj,value)
            hObj.setVariablePropertyValue("X",value,true);
        end
        function value=get.XData(hObj)
            value=hObj.getDataPropertyValue("X",false);
        end
        function mode=get.XDataMode(hObj)
            mode=hObj.getDataPropertyMode("X");
        end
        function value=get.XData_I(hObj)
            value=hObj.getDataPropertyValue("X",true);
        end
        function value=get.XVariable(hObj)
            value=hObj.getVariablePropertyValue("X",false);
        end
        function value=get.XVariable_I(hObj)
            value=hObj.getVariablePropertyValue("X",true);
        end
        function value=get.XDataCache(hObj)
            value=hObj.getDataPropertyNumericValue("X",false);
        end
    end




    properties(Dependent,SetObservable,GetObservable)
        YData=zeros(1,0)
    end

    properties(SetObservable,NeverAmbiguous)
        YDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden)
        YData_I=zeros(1,0)
    end

    properties(Hidden,Dependent,SetAccess=private)
YDataCache
    end

    properties(Dependent)
        YVariable=''
    end

    properties(Hidden,Dependent)
        YVariable_I=''
    end

    methods
        function set.YData(hObj,value)
            hObj.setDataPropertyValue("Y",value,false);
        end
        function set.YDataMode(hObj,mode)
            hObj.setDataPropertyMode("Y",mode);
        end
        function set.YData_I(hObj,value)
            hObj.setDataPropertyValue("Y",value,true);
        end
        function set.YVariable(hObj,value)
            hObj.setVariablePropertyValue("Y",value,false);
        end
        function set.YVariable_I(hObj,value)
            hObj.setVariablePropertyValue("Y",value,true);
        end
        function value=get.YData(hObj)
            value=hObj.getDataPropertyValue("Y",false);
        end
        function mode=get.YDataMode(hObj)
            mode=hObj.getDataPropertyMode("Y");
        end
        function value=get.YData_I(hObj)
            value=hObj.getDataPropertyValue("Y",true);
        end
        function value=get.YVariable(hObj)
            value=hObj.getVariablePropertyValue("Y",false);
        end
        function value=get.YVariable_I(hObj)
            value=hObj.getVariablePropertyValue("Y",true);
        end
        function value=get.YDataCache(hObj)
            value=hObj.getDataPropertyNumericValue("Y",false);
        end
    end



    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.XDataSource(hObj)


            valueToCaller=hObj.XDataSource_I;

        end

        function set.XDataSource(hObj,newValue)



            hObj.XDataSourceMode='manual';


            hObj.XDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XDataSourceMode(hObj)
            storedValue=hObj.XDataSourceMode;
        end

        function set.XDataSourceMode(hObj,newValue)

            oldValue=hObj.XDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.XDataSource_I(hObj)
            storedValue=hObj.XDataSource_I;
        end

        function set.XDataSource_I(hObj,newValue)



            hObj.XDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.YDataSource(hObj)


            valueToCaller=hObj.YDataSource_I;

        end

        function set.YDataSource(hObj,newValue)



            hObj.YDataSourceMode='manual';


            hObj.YDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YDataSourceMode(hObj)
            storedValue=hObj.YDataSourceMode;
        end

        function set.YDataSourceMode(hObj,newValue)

            oldValue=hObj.YDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.YDataSource_I(hObj)
            storedValue=hObj.YDataSource_I;
        end

        function set.YDataSource_I(hObj,newValue)



            hObj.YDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Edge matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Edge(hObj)


            valueToCaller=hObj.Edge_I;

        end

        function set.Edge(hObj,newValue)



            hObj.EdgeMode='manual';


            hObj.Edge_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        EdgeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeMode(hObj)
            storedValue=hObj.EdgeMode;
        end

        function set.EdgeMode(hObj,newValue)

            oldValue=hObj.EdgeMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        Edge_I;
    end

    methods
        function set.Edge_I(hObj,newValue)
            hObj.Edge_I=newValue;
            try
                hObj.setEdge_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        MarkerHandle matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.MarkerHandle(hObj)


            valueToCaller=hObj.MarkerHandle_I;

        end

        function set.MarkerHandle(hObj,newValue)



            hObj.MarkerHandleMode='manual';


            hObj.MarkerHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerHandleMode(hObj)
            storedValue=hObj.MarkerHandleMode;
        end

        function set.MarkerHandleMode(hObj,newValue)

            oldValue=hObj.MarkerHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,DeepCopy=true)

        MarkerHandle_I;
    end

    methods
        function set.MarkerHandle_I(hObj,newValue)
            hObj.MarkerHandle_I=newValue;
            try
                hObj.setMarkerHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Color matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function valueToCaller=get.Color(hObj)

            if strcmpi(get(hObj,'ColorMode'),'auto')
                forceFullUpdate(hObj,'all','Color');
            end


            valueToCaller=hObj.Color_I;

        end

        function set.Color(hObj,newValue)



            hObj.ColorMode='manual';


            hObj.Color_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        ColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ColorMode(hObj)
            storedValue=hObj.ColorMode;
        end

        function set.ColorMode(hObj,newValue)

            oldValue=hObj.ColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Color_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,0];
    end

    methods
        function storedValue=get.Color_I(hObj)
            storedValue=hObj.Color_I;
        end

        function set.Color_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('RGBAColorToGeometryPrimitive',fanChild,newValue);
            end
            hObj.Color_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
    end

    methods
        function valueToCaller=get.LineStyle(hObj)

            if strcmpi(get(hObj,'LineStyleMode'),'auto')
                forceFullUpdate(hObj,'all','LineStyle');
            end


            valueToCaller=hObj.LineStyle_I;

        end

        function set.LineStyle(hObj,newValue)



            hObj.LineStyleMode='manual';


            hObj.LineStyle_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        LineStyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineStyleMode(hObj)
            storedValue=hObj.LineStyleMode;
        end

        function set.LineStyleMode(hObj,newValue)

            oldValue=hObj.LineStyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineStyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
    end

    methods
        function storedValue=get.LineStyle_I(hObj)
            storedValue=hObj.LineStyle_I;
        end

        function set.LineStyle_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('LineStyleToPrimLineStyle',fanChild,newValue);
            end
            hObj.LineStyle_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
    end

    methods
        function valueToCaller=get.LineWidth(hObj)


            valueToCaller=hObj.LineWidth_I;

        end

        function set.LineWidth(hObj,newValue)



            hObj.LineWidthMode='manual';


            hObj.LineWidth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineWidthMode(hObj)
            storedValue=hObj.LineWidthMode;
        end

        function set.LineWidthMode(hObj,newValue)

            oldValue=hObj.LineWidthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineWidthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=0.5;
    end

    methods
        function storedValue=get.LineWidth_I(hObj)
            storedValue=hObj.LineWidth_I;
        end

        function set.LineWidth_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Marker matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
    end

    methods
        function valueToCaller=get.Marker(hObj)

            if strcmpi(get(hObj,'MarkerMode'),'auto')
                forceFullUpdate(hObj,'all','Marker');
            end


            valueToCaller=hObj.Marker_I;

        end

        function set.Marker(hObj,newValue)



            hObj.MarkerMode='manual';


            hObj.Marker_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        MarkerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerMode(hObj)
            storedValue=hObj.MarkerMode;
        end

        function set.MarkerMode(hObj,newValue)

            oldValue=hObj.MarkerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Marker_I matlab.internal.datatype.matlab.graphics.datatype.MarkerStyle='none';
    end

    methods
        function storedValue=get.Marker_I(hObj)
            storedValue=hObj.Marker_I;
        end

        function set.Marker_I(hObj,newValue)



            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                hgfilter('MarkerStyleToPrimMarkerStyle',fanChild,newValue);
            end
            hObj.Marker_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end

    methods
        function storedValue=get.MarkerSize(hObj)




            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end


            storedValue=passObj.Size;
        end

        function set.MarkerSize(hObj,newValue)






            hObj.MarkerSizeMode='manual';
            hObj.MarkerSize_I=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerSizeMode(hObj)
            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.SizeMode;
        end

        function set.MarkerSizeMode(hObj,newValue)


            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.SizeMode=newValue;
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerSize_I matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end

    methods
        function storedValue=get.MarkerSize_I(hObj)
            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                storedValue=[];
                return;
            end

            storedValue=passObj.Size_I;
        end

        function set.MarkerSize_I(hObj,newValue)


            passObj=hObj.MarkerHandle;
            if isempty(passObj)||~isvalid(passObj)
                return;
            end

            passObj.Size_I=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
    end

    methods
        function valueToCaller=get.MarkerEdgeColor(hObj)


            valueToCaller=hObj.MarkerEdgeColor_I;

        end

        function set.MarkerEdgeColor(hObj,newValue)



            hObj.MarkerEdgeColorMode='manual';


            hObj.MarkerEdgeColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerEdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerEdgeColorMode(hObj)
            storedValue=hObj.MarkerEdgeColorMode;
        end

        function set.MarkerEdgeColorMode(hObj,newValue)

            oldValue=hObj.MarkerEdgeColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerEdgeColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto';
    end

    methods
        function storedValue=get.MarkerEdgeColor_I(hObj)
            storedValue=hObj.MarkerEdgeColor_I;
        end

        function set.MarkerEdgeColor_I(hObj,newValue)



            hObj.MarkerEdgeColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        MarkerFaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
    end

    methods
        function valueToCaller=get.MarkerFaceColor(hObj)


            valueToCaller=hObj.MarkerFaceColor_I;

        end

        function set.MarkerFaceColor(hObj,newValue)



            hObj.MarkerFaceColorMode='manual';


            hObj.MarkerFaceColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerFaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerFaceColorMode(hObj)
            storedValue=hObj.MarkerFaceColorMode;
        end

        function set.MarkerFaceColorMode(hObj,newValue)

            oldValue=hObj.MarkerFaceColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerFaceColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        MarkerFaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
    end

    methods
        function storedValue=get.MarkerFaceColor_I(hObj)
            storedValue=hObj.MarkerFaceColor_I;
        end

        function set.MarkerFaceColor_I(hObj,newValue)



            hObj.MarkerFaceColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        BrushData matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix;
    end

    methods
        function valueToCaller=get.BrushData(hObj)



            valueToCaller=hObj.getBrushDataImpl(hObj.BrushData_I);


        end

        function set.BrushData(hObj,newValue)



            hObj.BrushDataMode='manual';



            reallyDoCopy=~isequal(hObj.BrushData_I,newValue);

            if reallyDoCopy
                hObj.BrushData_I=hObj.setBrushDataImpl(newValue);
            end



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BrushDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BrushDataMode(hObj)
            storedValue=hObj.BrushDataMode;
        end

        function set.BrushDataMode(hObj,newValue)

            oldValue=hObj.BrushDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BrushDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,NonCopyable=true,Transient=true)

        BrushData_I matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix;
    end

    methods





    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        BrushHandles matlab.graphics.Graphics;
    end

    methods
        function storedValue=get.BrushHandles(hObj)
            storedValue=hObj.BrushHandles;
        end

        function set.BrushHandles(hObj,newValue)



            hObj.BrushHandles=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        BrushStairHandles;
    end

    methods
        function storedValue=get.BrushStairHandles(hObj)
            storedValue=hObj.BrushStairHandles;
        end

        function set.BrushStairHandles(hObj,newValue)



            hObj.BrushStairHandles=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        SelectionHandle matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.SelectionHandle(hObj)


            valueToCaller=hObj.SelectionHandle_I;

        end

        function set.SelectionHandle(hObj,newValue)



            hObj.SelectionHandleMode='manual';


            hObj.SelectionHandle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        SelectionHandleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.SelectionHandleMode(hObj)
            storedValue=hObj.SelectionHandleMode;
        end

        function set.SelectionHandleMode(hObj,newValue)

            oldValue=hObj.SelectionHandleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.SelectionHandleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        SelectionHandle_I;
    end

    methods
        function set.SelectionHandle_I(hObj,newValue)
            hObj.SelectionHandle_I=newValue;
            try
                hObj.setSelectionHandle_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function valueToCaller=get.Clipping(hObj)


            valueToCaller=hObj.Clipping_I;

        end

        function set.Clipping(hObj,newValue)



            hObj.ClippingMode='manual';


            hObj.Clipping_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ClippingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ClippingMode(hObj)
            storedValue=hObj.ClippingMode;
        end

        function set.ClippingMode(hObj,newValue)

            oldValue=hObj.ClippingMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ClippingMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Clipping_I matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end

    methods
        function storedValue=get.Clipping_I(hObj)
            storedValue=hObj.Clipping_I;
        end

        function set.Clipping_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.SelectionHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            hObj.Clipping_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'Edge')
                b=true;
                return;
            end
            if strcmp(name,'Edge_I')
                b=true;
                return;
            end
            if strcmp(name,'MarkerHandle')
                b=true;
                return;
            end
            if strcmp(name,'MarkerHandle_I')
                b=true;
                return;
            end
            if strcmp(name,'SelectionHandle')
                b=true;
                return;
            end
            if strcmp(name,'SelectionHandle_I')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.primitive.Data(obj,name);
            return;
            b=false;
        end
    end








    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doIncrementIndex(hObj,index,direction,interpolationStep)
    end



    methods
        function hObj=Stair(varargin)






            hObj.Edge_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Edge,'Description_I','Stair Edge');

            set(hObj.Edge,'Internal',true);

            hObj.MarkerHandle_I=matlab.graphics.primitive.world.Marker;

            set(hObj.MarkerHandle,'Description_I','Stair MarkerHandle');

            set(hObj.MarkerHandle,'Internal',true);


            hObj.MarkerSize_I=6;


            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setEdge_IFanoutProps(hObj)

            hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge,hObj.Color_I);


            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,hObj.LineStyle_I);


            try
                mode=hObj.Edge.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Edge,'LineWidth_I',hObj.LineWidth_I);
            end


            try
                mode=hObj.Edge.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Edge,'Clipping_I',hObj.Clipping_I);
            end

        end
    end
    methods(Access=private)
        function setMarkerHandle_IFanoutProps(hObj)

            try
                mode=hObj.MarkerHandle.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.MarkerHandle,'LineWidth_I',hObj.LineWidth_I);
            end


            hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker_I);


            try
                mode=hObj.MarkerHandle.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.MarkerHandle,'Clipping_I',hObj.Clipping_I);
            end

        end
    end


    methods(Access='public',Hidden=true)

        varargout=getHints(hObj)
    end
    methods(Access={?matlab.graphics.mixin.Legendable,?matlab.graphics.illustration.Legend,?matlab.unittest.TestCase},Hidden=true)

        updateDisplayNameBasedOnLabelHints(hObj,channelNamesStruct)
    end
    methods(Access='public',Hidden=true)

        varargout=getXYZDataExtents(hObj,transform,constraints)
    end
    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='stair';



            hObj.linkDataPropertyToChannel('XData','X','Y');
            hObj.linkDataPropertyToChannel('YData','Y');


            addDependencyConsumed(hObj,{'colororder_linestyleorder'});
        end
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='public',Hidden=true)

        varargout=getBrushPrimitivesForTesting(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=getLegendGraphic(hObj)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetDataDescriptors(hObj,index,~)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetNearestIndex(hObj,index)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetNearestPoint(hObj,position)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetEnclosedPoints(hObj,polygon)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetDisplayAnchorPoint(hObj,index,~)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetReportedPosition(hObj,index,~)
    end
    methods(Access='protected',Hidden=true)
        function doBrushing(hObj)

            if~isempty(hObj.BrushHandles)
                hObj.BrushHandles.MarkDirty('all');
            else
                hObj.BrushHandles=matlab.graphics.chart.primitive.stair.StairBrushing;
                hObj.addNode(hObj.BrushHandles);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getBrushDataImpl(hObj,storedValue)


            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setBrushDataImpl(hObj,newValue)


            varargout{1}=newValue;
            hObj.doBrushing;
        end
    end
    methods(Access='public',Static=true,Hidden=true)
        function varargout=doloadobj(hObj)


            matlab.graphics.chart.internal.deleteNonPrimitiveChildren(hObj);
            varargout{1}=hObj;
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            dnames=hObj.DimensionNames(1:2);
            suffix={'Data','Variable'};
            dnames{1}=sprintf('%s%s',dnames{1},suffix{1+hObj.isDataComingFromDataSource('X')});
            dnames{2}=sprintf('%s%s',dnames{2},suffix{1+hObj.isDataComingFromDataSource('Y')});

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            [{'Color','LineStyle','LineWidth','Marker',...
            'MarkerSize','MarkerFaceColor'},dnames]);
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getDescriptiveLabelForDisplay(hObj)

            if~isempty(hObj.Tag)
                varargout{1}=hObj.Tag;
            else
                varargout{1}=hObj.DisplayName;
            end
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=prepareDataToSave(hObj)

            varargout{1}=prepareDataToSave@matlab.graphics.mixin.DataProperties(hObj);



            if isfield(varargout{1},'DataPropertyValues')
                varargout{1}=rmfield(varargout{1},'DataPropertyValues');
            end
        end
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end




end
