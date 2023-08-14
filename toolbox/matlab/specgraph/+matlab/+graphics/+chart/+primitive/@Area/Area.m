
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Area<matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Legendable&matlab.graphics.mixin.ColorOrderUser&matlab.graphics.mixin.Chartable2D&matlab.graphics.chart.interaction.DataAnnotatable&matlab.graphics.mixin.BaselineUser





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        Face matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.Face(hObj)


            valueToCaller=hObj.Face_I;

        end

        function set.Face(hObj,newValue)



            hObj.FaceMode='manual';


            hObj.Face_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        FaceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceMode(hObj)
            storedValue=hObj.FaceMode;
        end

        function set.FaceMode(hObj,newValue)

            oldValue=hObj.FaceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Face_I;
    end

    methods
        function set.Face_I(hObj,newValue)
            hObj.Face_I=newValue;
            try
                hObj.setFace_IFanoutProps();
            catch
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

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
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

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

    properties(InternalComponent,AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        AlignVertexCenters matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function valueToCaller=get.AlignVertexCenters(hObj)


            valueToCaller=hObj.AlignVertexCenters_I;

        end

        function set.AlignVertexCenters(hObj,newValue)



            hObj.AlignVertexCentersMode='manual';


            hObj.AlignVertexCenters_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AlignVertexCentersMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AlignVertexCentersMode(hObj)
            storedValue=hObj.AlignVertexCentersMode;
        end

        function set.AlignVertexCentersMode(hObj,newValue)

            oldValue=hObj.AlignVertexCentersMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AlignVertexCentersMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        AlignVertexCenters_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.AlignVertexCenters_I(hObj)
            storedValue=hObj.AlignVertexCenters_I;
        end

        function set.AlignVertexCenters_I(hObj,newValue)



            fanChild=hObj.Edge;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'AlignVertexCentersMode'),'auto')
                    set(fanChild,'AlignVertexCenters_I',newValue);
                end
            end
            hObj.AlignVertexCenters_I=newValue;

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
            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-';
    end

    methods
        function valueToCaller=get.LineStyle(hObj)


            valueToCaller=hObj.LineStyle_I;

        end

        function set.LineStyle(hObj,newValue)



            hObj.LineStyleMode='manual';


            hObj.LineStyle_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

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

        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor=[0,0,0];
    end

    methods
        function valueToCaller=get.EdgeColor(hObj)


            valueToCaller=hObj.EdgeColor_I;

        end

        function set.EdgeColor(hObj,newValue)



            hObj.EdgeColorMode='manual';


            hObj.EdgeColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        EdgeColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeColorMode(hObj)
            storedValue=hObj.EdgeColorMode;
        end

        function set.EdgeColorMode(hObj,newValue)

            oldValue=hObj.EdgeColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor=[0,0,0];
    end

    methods
        function storedValue=get.EdgeColor_I(hObj)
            storedValue=hObj.EdgeColor_I;
        end

        function set.EdgeColor_I(hObj,newValue)



            hObj.EdgeColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        EdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1;
    end

    methods
        function valueToCaller=get.EdgeAlpha(hObj)


            valueToCaller=hObj.EdgeAlpha_I;

        end

        function set.EdgeAlpha(hObj,newValue)



            hObj.EdgeAlphaMode='manual';


            hObj.EdgeAlpha_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        EdgeAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeAlphaMode(hObj)
            storedValue=hObj.EdgeAlphaMode;
        end

        function set.EdgeAlphaMode(hObj,newValue)

            oldValue=hObj.EdgeAlphaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeAlphaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        EdgeAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1;
    end

    methods
        function storedValue=get.EdgeAlpha_I(hObj)
            storedValue=hObj.EdgeAlpha_I;
        end

        function set.EdgeAlpha_I(hObj,newValue)



            hObj.EdgeAlpha_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor='flat';
    end

    methods
        function valueToCaller=get.FaceColor(hObj)

            if strcmpi(get(hObj,'FaceColorMode'),'auto')
                forceFullUpdate(hObj,'all','FaceColor');
            end


            valueToCaller=hObj.FaceColor_I;

        end

        function set.FaceColor(hObj,newValue)



            hObj.FaceColorMode='manual';


            hObj.FaceColor_I=newValue;

        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        FaceColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceColorMode(hObj)
            storedValue=hObj.FaceColorMode;
        end

        function set.FaceColorMode(hObj,newValue)

            oldValue=hObj.FaceColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor='flat';
    end

    methods
        function storedValue=get.FaceColor_I(hObj)
            storedValue=hObj.FaceColor_I;
        end

        function set.FaceColor_I(hObj,newValue)



            hObj.FaceColor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1;
    end

    methods
        function valueToCaller=get.FaceAlpha(hObj)


            valueToCaller=hObj.FaceAlpha_I;

        end

        function set.FaceAlpha(hObj,newValue)



            hObj.FaceAlphaMode='manual';


            hObj.FaceAlpha_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FaceAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceAlphaMode(hObj)
            storedValue=hObj.FaceAlphaMode;
        end

        function set.FaceAlphaMode(hObj,newValue)

            oldValue=hObj.FaceAlphaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceAlphaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FaceAlpha_I matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1;
    end

    methods
        function storedValue=get.FaceAlpha_I(hObj)
            storedValue=hObj.FaceAlpha_I;
        end

        function set.FaceAlpha_I(hObj,newValue)



            hObj.FaceAlpha_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        CDataMapping matlab.internal.datatype.matlab.graphics.datatype.CDataMapping='scaled';
    end

    methods
        function valueToCaller=get.CDataMapping(hObj)


            valueToCaller=hObj.CDataMapping_I;

        end

        function set.CDataMapping(hObj,newValue)



            hObj.CDataMappingMode='manual';


            hObj.CDataMapping_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CDataMappingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CDataMappingMode(hObj)
            storedValue=hObj.CDataMappingMode;
        end

        function set.CDataMappingMode(hObj,newValue)

            oldValue=hObj.CDataMappingMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CDataMappingMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        CDataMapping_I matlab.internal.datatype.matlab.graphics.datatype.CDataMapping='scaled';
    end

    methods
        function storedValue=get.CDataMapping_I(hObj)
            storedValue=hObj.CDataMapping_I;
        end

        function set.CDataMapping_I(hObj,newValue)



            hObj.CDataMapping_I=newValue;

        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess={?tArea},Dependent=false,Hidden=true)

        XCoords_I matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix;
    end

    methods
        function storedValue=get.XCoords_I(hObj)
            storedValue=hObj.XCoords_I;
        end

        function set.XCoords_I(hObj,newValue)



            hObj.XCoords_I=newValue;

        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess={?tArea},Dependent=false,Hidden=true)

        YCoords_I matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix;
    end

    methods
        function storedValue=get.YCoords_I(hObj)
            storedValue=hObj.YCoords_I;
        end

        function set.YCoords_I(hObj,newValue)



            hObj.YCoords_I=newValue;

        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess={?tArea},Dependent=false,Hidden=true)

        CCoords_I matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix;
    end

    methods
        function storedValue=get.CCoords_I(hObj)
            storedValue=hObj.CCoords_I;
        end

        function set.CCoords_I(hObj,newValue)



            hObj.CCoords_I=newValue;

        end
    end

    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        CData(1,1)double;
    end

    methods
        function valueToCaller=get.CData(hObj)


            valueToCaller=hObj.CData_I;

        end

        function set.CData(hObj,newValue)



            hObj.CDataMode='manual';


            hObj.CData_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CDataMode(hObj)
            storedValue=hObj.CDataMode;
        end

        function set.CDataMode(hObj,newValue)

            oldValue=hObj.CDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        CData_I(1,1)double;
    end

    methods
        function storedValue=get.CData_I(hObj)
            storedValue=hObj.CData_I;
        end

        function set.CData_I(hObj,newValue)



            hObj.CData_I=newValue;

        end
    end


    properties(SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true)

        BaseArea(1,1)logical=true;
    end

    methods
        function storedValue=get.BaseArea(hObj)
            storedValue=hObj.BaseArea;
        end

        function set.BaseArea(hObj,newValue)



            hObj.BaseArea=newValue;

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



            fanChild=hObj.Face;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.Edge;

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


    properties(SetObservable=false,SetAccess='private',GetAccess={?tArea},Dependent=false,Hidden=true,Transient=true)

        PrepWasAlreadyRun logical=false;
    end

    methods
        function storedValue=get.PrepWasAlreadyRun(hObj)
            storedValue=hObj.PrepWasAlreadyRun;
        end

        function set.PrepWasAlreadyRun(hObj,newValue)



            hObj.PrepWasAlreadyRun=newValue;

        end
    end


    properties(SetObservable=false,SetAccess={?tArea_computeLayout,?tArea_createAreaVertexData,?tArea_doUpdate,?tArea},GetAccess={?tArea_computeLayout,?tArea_createAreaVertexData,?tArea_doUpdate,?tArea},Dependent=false,Hidden=true,Transient=true)

        AreaLayoutData struct;
    end

    methods
        function storedValue=get.AreaLayoutData(hObj)
            storedValue=hObj.AreaLayoutData;
        end

        function set.AreaLayoutData(hObj,newValue)



            hObj.AreaLayoutData=newValue;

        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        AreaPeerID(1,1)double=0;
    end

    methods
        function storedValue=get.AreaPeerID(hObj)
            storedValue=hObj.AreaPeerID;
        end

        function set.AreaPeerID(hObj,newValue)



            hObj.AreaPeerID=newValue;

        end
    end

    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        AreaPeers matlab.graphics.chart.primitive.Area;
    end

    methods
        function valueToCaller=get.AreaPeers(hObj)



            valueToCaller=hObj.getAreaPeersImpl(hObj.AreaPeers_I);


        end

        function set.AreaPeers(hObj,newValue)



            hObj.AreaPeersMode='manual';



            reallyDoCopy=~isequal(hObj.AreaPeers_I,newValue);

            if reallyDoCopy
                hObj.AreaPeers_I=hObj.setAreaPeersImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        AreaPeersMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AreaPeersMode(hObj)
            storedValue=hObj.AreaPeersMode;
        end

        function set.AreaPeersMode(hObj,newValue)

            oldValue=hObj.AreaPeersMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AreaPeersMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        AreaPeers_I matlab.graphics.chart.primitive.Area;
    end

    methods





    end


    properties(AffectsObject,SetObservable=false,SetAccess={?tArea},GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        NumPeers(1,1)double;
    end

    methods
        function storedValue=get.NumPeers(hObj)
            storedValue=hObj.NumPeers;
        end

        function set.NumPeers(hObj,newValue)



            hObj.NumPeers=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=false,Transient=true)

        BaseLine matlab.graphics.Graphics;
    end

    methods
        function valueToCaller=get.BaseLine(hObj)



            valueToCaller=hObj.getBaseLineImpl(hObj.BaseLine_I);


        end

        function set.BaseLine(hObj,newValue)



            hObj.BaseLineMode='manual';



            reallyDoCopy=~isequal(hObj.BaseLine_I,newValue);

            if reallyDoCopy
                hObj.BaseLine_I=hObj.setBaseLineImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BaseLineMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BaseLineMode(hObj)
            storedValue=hObj.BaseLineMode;
        end

        function set.BaseLineMode(hObj,newValue)

            oldValue=hObj.BaseLineMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BaseLineMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        BaseLine_I matlab.graphics.Graphics;
    end

    methods





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

        BrushHandles;
    end

    methods
        function storedValue=get.BrushHandles(hObj)
            storedValue=hObj.BrushHandles;
        end

        function set.BrushHandles(hObj,newValue)



            hObj.BrushHandles=newValue;

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


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'Face')
                b=true;
                return;
            end
            if strcmp(name,'Face_I')
                b=true;
                return;
            end
            if strcmp(name,'Edge')
                b=true;
                return;
            end
            if strcmp(name,'Edge_I')
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








    methods(Access='public',Static=true)
        [peerID]=groupAreas(hObj,peerID)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doIncrementIndex(hObj,index,direction,interpolationStep)
    end






    methods(Access='public')
        [xCoords,yCoords]=patchVertexData(hObj,adjustBase)
    end






    methods(Access={?matlab.graphics.chart.primitive.area.AreaBrushing,?tArea_createAreaVertexData})
        [faceVertices,faceStripData,edgeVertices,edgeStripData]=createAreaVertexData(hObj,hDataSpace,baseValue,selected)
    end






    methods(Access={?tArea,?tAreaBrushing})
        []=updateLayout(hObj)
    end



    methods
        function hObj=Area(varargin)






            hObj.Face_I=matlab.graphics.primitive.world.TriangleStrip;

            set(hObj.Face,'Description_I','Area Face');

            set(hObj.Face,'Internal',true);

            hObj.Edge_I=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Edge,'Description_I','Area Edge');

            set(hObj.Edge,'Internal',true);



            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setFace_IFanoutProps(hObj)

            try
                mode=hObj.Face.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Face,'Clipping_I',hObj.Clipping_I);
            end

        end
    end
    methods(Access=private)
        function setEdge_IFanoutProps(hObj)

            try
                mode=hObj.Edge.AlignVertexCentersMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Edge,'AlignVertexCenters_I',hObj.AlignVertexCenters_I);
            end


            try
                mode=hObj.Edge.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.Edge,'LineWidth_I',hObj.LineWidth_I);
            end


            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,hObj.LineStyle_I);


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


    methods(Access='private',Hidden=true)
        function varargout=getAreaPeersImpl(hObj,~)

            parent=hObj.NodeParent;
            if~isempty(parent)
                allAreas=findall(parent.NodeChildren,'flat','-class','matlab.graphics.chart.primitive.Area',...
                '-and','AreaPeerID',hObj.AreaPeerID);

                if~isempty(allAreas)&&any([allAreas.NumPeers]~=numel(allAreas))
                    set(allAreas,'NumPeers',numel(allAreas));
                end

                varargout{1}=flipud(allAreas(isvalid(allAreas)));
            else
                varargout{1}=matlab.graphics.chart.primitive.Area.empty;
            end
        end
    end
    methods(Access='private',Hidden=true)

        markSeriesDirty(hObj)
    end
    methods(Access='public',Hidden=true)
        function delete(hObj)


            parent=hObj.Parent;
            if~isscalar(parent)||(isprop(parent,'BeingDeleted')&&parent.BeingDeleted=="on")
                return
            end

            hPeers=hObj.AreaPeers;


            if isempty(hPeers)
                return;
            end



            if strcmp(hObj.CDataMode,'auto')
                for a=1:numel(hPeers)
                    if strcmp(hPeers(a).CDataMode,'auto')
                        hPeers(a).CData_I=a;
                    end
                end
            end


            for a=1:numel(hPeers)
                hPeers(a).NumPeers=numel(hPeers);
            end
        end
    end
    methods(Access='public',Hidden=true)

        varargout=getXYZDataExtents(hObj,transform,constraints)
    end
    methods(Access='public',Hidden=true)

        varargout=getColorAlphaDataExtents(hObj)
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='area';


            hObj.NumPeers=1;


            hObj.AreaLayoutData=struct('XData',zeros(0,1),'YData',zeros(0,2),'Order',zeros(0,1));


            addDependencyConsumed(hObj,{'figurecolormap','colorspace','baseline','dataspace','colororder_linestyleorder'});



            addlistener(hObj,{'XData','YData'},'PostSet',@(obj,evd)(hObj.sendDataChangedEvent));
        end
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
    methods(Access='public',Hidden=true)

        varargout=createDefaultDataTipRows(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=createCoordinateData(hObj,valueSource,dataIndex,~)
    end
    methods(Access='public',Hidden=true)

        varargout=getAllValidValueSources(hObj)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetNearestIndex(hObj,index)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetNearestPoint(hObj,position)
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetBaselineAxis(hObj)

            varargout{1}=1;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getBaseLineImpl(hObj,storedValue)

            varargout{1}=hObj.doGetBaseLine();
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetBaseLine(hObj)
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
    methods(Access='public',Hidden=true)
        function varargout=saveobj(hObj)




            setappdata(hObj,'NumPeers',hObj.NumPeers);
            [hObj.XCoords_I,hObj.YCoords_I]=patchVertexData(hObj,false);
            hObj.CCoords_I=hObj.CData;

            varargout{1}=hObj;
        end
    end
    methods(Access='public',Static=true,Hidden=true)

        varargout=doloadobj(hObj)
    end
    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden=true)

        varargout=copyElement(hObj)
    end
    methods(Access='private',Hidden=true)
        function varargout=getBrushDataImpl(hObj,storedValue)


            varargout{1}=storedValue;
        end
    end
    methods(Access='protected',Hidden=true)
        function doBrushing(hObj)

            if~isempty(hObj.BrushHandles)
                hObj.BrushHandles.MarkDirty('all');
            else
                hObj.BrushHandles=matlab.graphics.chart.primitive.area.AreaBrushing;
                hObj.addNode(hObj.BrushHandles);
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setBrushDataImpl(hObj,newValue)


            varargout{1}=newValue;
            hObj.doBrushing;
        end
    end
    methods(Access='public',Static=true,Hidden=true)

        computeLayout(hObjs)
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'FaceColor','EdgeColor','LineStyle',...
            'LineWidth','BaseValue','XData','YData'});
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
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end




end
