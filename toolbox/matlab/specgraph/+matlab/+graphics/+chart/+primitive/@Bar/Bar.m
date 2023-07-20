
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Bar<matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.Legendable&matlab.graphics.mixin.ColorOrderUser&matlab.graphics.mixin.Chartable2D&matlab.graphics.chart.interaction.DataAnnotatable&matlab.graphics.mixin.BaselineUser





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        BarLayout matlab.internal.datatype.matlab.graphics.chart.datatype.BarLayoutType='grouped';
    end

    methods
        function valueToCaller=get.BarLayout(hObj)


            valueToCaller=hObj.BarLayout_I;

        end

        function set.BarLayout(hObj,newValue)



            hObj.BarLayoutMode='manual';


            hObj.BarLayout_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BarLayoutMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BarLayoutMode(hObj)
            storedValue=hObj.BarLayoutMode;
        end

        function set.BarLayoutMode(hObj,newValue)

            oldValue=hObj.BarLayoutMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BarLayoutMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        BarLayout_I matlab.internal.datatype.matlab.graphics.chart.datatype.BarLayoutType='grouped';
    end

    methods
        function storedValue=get.BarLayout_I(hObj)
            storedValue=hObj.BarLayout_I;
        end

        function set.BarLayout_I(hObj,newValue)



            hObj.BarLayout_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        BarWidth(1,1)double=.8;
    end

    methods
        function valueToCaller=get.BarWidth(hObj)


            valueToCaller=hObj.BarWidth_I;

        end

        function set.BarWidth(hObj,newValue)



            hObj.BarWidthMode='manual';


            hObj.BarWidth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BarWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BarWidthMode(hObj)
            storedValue=hObj.BarWidthMode;
        end

        function set.BarWidthMode(hObj,newValue)

            oldValue=hObj.BarWidthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BarWidthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        BarWidth_I(1,1)double=.8;
    end

    methods
        function storedValue=get.BarWidth_I(hObj)
            storedValue=hObj.BarWidth_I;
        end

        function set.BarWidth_I(hObj,newValue)



            hObj.BarWidth_I=newValue;

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

    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        BarPeers matlab.graphics.chart.primitive.Bar;
    end

    methods
        function valueToCaller=get.BarPeers(hObj)



            valueToCaller=hObj.getBarPeersImpl(hObj.BarPeers_I);


        end

        function set.BarPeers(hObj,newValue)



            hObj.BarPeersMode='manual';



            reallyDoCopy=~isequal(hObj.BarPeers_I,newValue);

            if reallyDoCopy
                hObj.BarPeers_I=hObj.setBarPeersImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BarPeersMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BarPeersMode(hObj)
            storedValue=hObj.BarPeersMode;
        end

        function set.BarPeersMode(hObj,newValue)

            oldValue=hObj.BarPeersMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BarPeersMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        BarPeers_I matlab.graphics.chart.primitive.Bar;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        NumPeers(1,1)double=1;
    end

    methods
        function valueToCaller=get.NumPeers(hObj)


            valueToCaller=hObj.NumPeers_I;

        end

        function set.NumPeers(hObj,newValue)



            hObj.NumPeersMode='manual';


            hObj.NumPeers_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        NumPeersMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.NumPeersMode(hObj)
            storedValue=hObj.NumPeersMode;
        end

        function set.NumPeersMode(hObj,newValue)

            oldValue=hObj.NumPeersMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.NumPeersMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        NumPeers_I(1,1)double=1;
    end

    methods
        function storedValue=get.NumPeers_I(hObj)
            storedValue=hObj.NumPeers_I;
        end

        function set.NumPeers_I(hObj,newValue)



            hObj.NumPeers_I=newValue;

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


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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

        CData matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=nan;
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

        CData_I matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=nan;
    end

    methods
        function storedValue=get.CData_I(hObj)
            storedValue=hObj.CData_I;
        end

        function set.CData_I(hObj,newValue)



            hObj.CData_I=newValue;

        end
    end

    properties(SetObservable=false,SetAccess='public',GetAccess='private',Dependent=true,Hidden=true,Transient=true)

        FaceColorIndex(1,1)double=1;
    end

    methods
        function valueToCaller=get.FaceColorIndex(hObj)


            valueToCaller=hObj.FaceColorIndex_I;

        end

        function set.FaceColorIndex(hObj,newValue)



            hObj.FaceColorIndexMode='manual';


            hObj.FaceColorIndex_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        FaceColorIndexMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FaceColorIndexMode(hObj)
            storedValue=hObj.FaceColorIndexMode;
        end

        function set.FaceColorIndexMode(hObj,newValue)

            oldValue=hObj.FaceColorIndexMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FaceColorIndexMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='private',Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        FaceColorIndex_I(1,1)double=1;
    end

    methods
        function storedValue=get.FaceColorIndex_I(hObj)
            storedValue=hObj.FaceColorIndex_I;
        end

        function set.FaceColorIndex_I(hObj,newValue)



            hObj.FaceColorIndex_I=newValue;

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Horizontal matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function valueToCaller=get.Horizontal(hObj)



            valueToCaller=hObj.getHorizontalImpl(hObj.Horizontal_I);


        end

        function set.Horizontal(hObj,newValue)



            hObj.HorizontalMode='manual';



            reallyDoCopy=~isequal(hObj.Horizontal_I,newValue);

            if reallyDoCopy
                hObj.Horizontal_I=hObj.setHorizontalImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        HorizontalMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.HorizontalMode(hObj)
            storedValue=hObj.HorizontalMode;
        end

        function set.HorizontalMode(hObj,newValue)

            oldValue=hObj.HorizontalMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.HorizontalMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Horizontal_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods





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

        LineWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=.5;
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

        LineWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=.5;
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        WidthScaleFactor(1,1)double=1;
    end

    methods
        function valueToCaller=get.WidthScaleFactor(hObj)


            valueToCaller=hObj.WidthScaleFactor_I;

        end

        function set.WidthScaleFactor(hObj,newValue)



            hObj.WidthScaleFactorMode='manual';


            hObj.WidthScaleFactor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        WidthScaleFactorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.WidthScaleFactorMode(hObj)
            storedValue=hObj.WidthScaleFactorMode;
        end

        function set.WidthScaleFactorMode(hObj,newValue)

            oldValue=hObj.WidthScaleFactorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.WidthScaleFactorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        WidthScaleFactor_I(1,1)double=1;
    end

    methods
        function storedValue=get.WidthScaleFactor_I(hObj)
            storedValue=hObj.WidthScaleFactor_I;
        end

        function set.WidthScaleFactor_I(hObj,newValue)



            hObj.WidthScaleFactor_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        XOffset(1,1)double=0;
    end

    methods
        function valueToCaller=get.XOffset(hObj)


            valueToCaller=hObj.XOffset_I;

        end

        function set.XOffset(hObj,newValue)



            hObj.XOffsetMode='manual';


            hObj.XOffset_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XOffsetMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XOffsetMode(hObj)
            storedValue=hObj.XOffsetMode;
        end

        function set.XOffsetMode(hObj,newValue)

            oldValue=hObj.XOffsetMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XOffsetMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XOffset_I(1,1)double=0;
    end

    methods
        function storedValue=get.XOffset_I(hObj)
            storedValue=hObj.XOffset_I;
        end

        function set.XOffset_I(hObj,newValue)



            hObj.XOffset_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        YOffset matlab.internal.datatype.matlab.graphics.datatype.VectorData=zeros(1,0);
    end

    methods
        function valueToCaller=get.YOffset(hObj)


            valueToCaller=hObj.YOffset_I;

        end

        function set.YOffset(hObj,newValue)



            hObj.YOffsetMode='manual';


            hObj.YOffset_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YOffsetMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YOffsetMode(hObj)
            storedValue=hObj.YOffsetMode;
        end

        function set.YOffsetMode(hObj,newValue)

            oldValue=hObj.YOffsetMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YOffsetMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YOffset_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=zeros(1,0);
    end

    methods
        function storedValue=get.YOffset_I(hObj)
            storedValue=hObj.YOffset_I;
        end

        function set.YOffset_I(hObj,newValue)



            hObj.YOffset_I=newValue;

        end
    end

    properties(SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=false,Transient=true)

        XEndPoints matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function valueToCaller=get.XEndPoints(hObj)



            valueToCaller=hObj.getXEndPointsImpl(hObj.XEndPoints_I);


        end

        function set.XEndPoints(hObj,newValue)



            hObj.XEndPointsMode='manual';



            reallyDoCopy=~isequal(hObj.XEndPoints_I,newValue);

            if reallyDoCopy
                hObj.XEndPoints_I=hObj.setXEndPointsImpl(newValue);
            end



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        XEndPointsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XEndPointsMode(hObj)
            storedValue=hObj.XEndPointsMode;
        end

        function set.XEndPointsMode(hObj,newValue)

            oldValue=hObj.XEndPointsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XEndPointsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        XEndPoints_I matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods





    end

    properties(SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=false,Transient=true)

        YEndPoints matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods
        function valueToCaller=get.YEndPoints(hObj)



            valueToCaller=hObj.getYEndPointsImpl(hObj.YEndPoints_I);


        end

        function set.YEndPoints(hObj,newValue)



            hObj.YEndPointsMode='manual';



            reallyDoCopy=~isequal(hObj.YEndPoints_I,newValue);

            if reallyDoCopy
                hObj.YEndPoints_I=hObj.setYEndPointsImpl(newValue);
            end



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        YEndPointsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YEndPointsMode(hObj)
            storedValue=hObj.YEndPointsMode;
        end

        function set.YEndPointsMode(hObj,newValue)

            oldValue=hObj.YEndPointsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YEndPointsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        YEndPoints_I matlab.internal.datatype.matlab.graphics.datatype.AnyData=zeros(1,0);
    end

    methods





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


    properties(AffectsObject,SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        BarPeerID(1,1)double=0;
    end

    methods
        function storedValue=get.BarPeerID(hObj)
            storedValue=hObj.BarPeerID;
        end

        function set.BarPeerID(hObj,newValue)



            hObj.BarPeerID=newValue;

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


    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

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


    properties(SetObservable=false,SetAccess='private',GetAccess={?matlab.graphics.chart.primitive.bar.BarBrushing},Dependent=false,Hidden=true,Transient=true)

        BarOrder matlab.internal.datatype.matlab.graphics.datatype.VectorData=zeros(1,0);
    end

    methods
        function storedValue=get.BarOrder(hObj)
            storedValue=hObj.BarOrder;
        end

        function set.BarOrder(hObj,newValue)



            hObj.BarOrder=newValue;

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








    methods(Access={?tBar_createBarVertexData})
        [verts,indices,selectionVerts]=createBarVertexData(hObj,xData,xDataLeft,xDataRight,yDataBottom,yDataTop)
    end






    methods(Access={?tBar_createBarVertexData})
        [xData,xDataLeft,xDataRight,yDataBottom,yDataTop,order]=calculateBarRectangleData(hObj,BaseValues)
    end






    methods(Access='public')
        [x,y]=getSingleBarExtentsArray(hObj,constraints)
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
        [faces,vertices]=patchVertexData(hObj)
    end



    methods
        function hObj=Bar(varargin)






            hObj.Face_I=matlab.graphics.primitive.world.Quadrilateral;

            set(hObj.Face,'Description_I','Bar Face');

            set(hObj.Face,'Internal',true);

            hObj.Edge_I=matlab.graphics.primitive.world.LineLoop;

            set(hObj.Edge,'Description_I','Bar Edge');

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


    methods(Access='private',Hidden=true)
        function varargout=getBarPeersImpl(hObj,~)

            parent=hObj.NodeParent;
            if~isempty(parent)
                hPeers=findobj(parent.NodeChildren,'flat','-class','matlab.graphics.chart.primitive.Bar',...
                '-and','BarPeerID',hObj.BarPeerID);

                if~isempty(hPeers)&&any([hPeers.NumPeers]~=numel(hPeers))
                    set(hPeers,'NumPeers',numel(hPeers));
                end

                varargout{1}=hPeers;
            else
                varargout{1}=matlab.graphics.chart.primitive.Bar.empty;
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getXEndPointsImpl(hObj,~)


            forceFullUpdate(hObj,'all','XEndPoints');


            varargout{1}=hObj.XDataCache+hObj.XOffset;


            [ruler,yruler]=matlab.graphics.internal.getRulersForChild(hObj);
            if strcmpi(hObj.Horizontal,'on')
                ruler=yruler;
            end
            if~isempty(ruler)&&...
                ~isa(ruler,'matlab.graphics.axis.decorator.NumericRuler')&&...
                ~isa(ruler,'matlab.graphics.axis.decorator.CategoricalRuler')

                varargout{1}=ruler.makeNonNumeric(varargout{1});
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getYEndPointsImpl(hObj,~)


            forceFullUpdate(hObj,'all','YEndPoints');


            yEndPoints=hObj.YDataCache;
            if numel(hObj.YOffset)==numel(yEndPoints)
                yEndPoints=yEndPoints+hObj.YOffset;
            end


            xData=hObj.XDataCache;
            if numel(hObj.XData)==numel(yEndPoints)

                yEndPoints(~isfinite(xData))=NaN;
            else

                yEndPoints=NaN(size(yEndPoints));
            end


            [xruler,ruler]=matlab.graphics.internal.getRulersForChild(hObj);
            if strcmpi(hObj.Horizontal,'on')
                ruler=xruler;
            end
            if~isempty(ruler)&&...
                ~isa(ruler,'matlab.graphics.axis.decorator.NumericRuler')&&...
                ~isa(ruler,'matlab.graphics.axis.decorator.CategoricalRuler')

                yEndPoints=ruler.makeNonNumeric(yEndPoints);
            end
            varargout{1}=yEndPoints;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getBaseLineImpl(hObj,~)

            varargout{1}=hObj.doGetBaseLine();
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetBaseLine(hObj)
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetBaselineAxis(hObj)

            if strcmpi(hObj.Horizontal,'on')
                varargout{1}=0;
            else
                varargout{1}=1;
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getHorizontalImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setHorizontalImpl(hObj,newValue)


            varargout{1}=newValue;
            if strcmp(newValue,hObj.Horizontal)
                return;
            end
            xdata=hObj.XData;
            [swapped,err]=matlab.graphics.internal.swapNonNumericXYRulers(hObj);
            if~isempty(err)
                error(message(['MATLAB:bar:NonNumericHorizontal',err]));
            end

            ax=ancestor(hObj,'axes');
            matlab.graphics.chart.primitive.bar.internal.tickCallback(ax,xdata,newValue);

            if~swapped
                hPeers=matlab.graphics.chart.primitive.bar.internal.getBarPeers(hObj);
                for i=1:numel(hPeers)
                    hPeers(i).ExchangeXY=newValue;
                    hPeers(i).Horizontal_I=newValue;
                    hPeers(i).MarkDirty('limits');
                end
            end
        end
    end
    methods(Access='public',Hidden=true)
        function reactToXYRulerSwap(hObj)

            val=hObj.Horizontal_I;
            if strcmp(val,'on')
                hObj.Horizontal_I='off';
            else
                hObj.Horizontal_I='on';
            end
            hObj.ExchangeXY=hObj.Horizontal_I;
            hObj.MarkDirty('limits');
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
    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='bar';

            addDependencyConsumed(hObj,{'figurecolormap','colorspace','baseline','dataspace','colororder_linestyleorder'});
        end
    end
    methods(Access='public',Hidden=true)
        function doPostSetup(hObj,peerid)

            hObj.BarPeerID=peerid;

            hObj.addBarListeners;
        end
    end
    methods(Access='private',Hidden=true)
        function addBarListeners(hObj)

            addlistener(hObj,{'BarLayout'},'PostSet',@(obj,evd)(hObj.updatePeersAndMarkAllSeriesDirty(obj,evd)));
            addlistener(hObj,{'XData','YData','XDataMode'},'PostSet',@(~,~)hObj.markAllSeriesDirty);



            addlistener(hObj,'BarWidth','PostSet',@matlab.graphics.chart.primitive.bar.internal.updatePeers);
            addlistener(hObj,'ObjectBeingDestroyed',@hObj.deleteBar);



            addlistener(hObj,{'XData','YData','XDataMode'},'PostSet',@(~,~)matlab.graphics.chart.primitive.bar.internal.tickCallback(ancestor(hObj,'axes'),hObj.XData,hObj.Horizontal));



            addlistener(hObj,{'XData','YData','BarLayout','Horizontal'},'PostSet',@(~,~)hObj.sendDataChangedEvent);
        end
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='public',Hidden=true)

        varargout=getXYZDataExtents(hObj,transform,constraints)
    end
    methods(Access='public',Hidden=true)

        varargout=getBrushPrimitivesForTesting(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=getColorAlphaDataExtents(hObj)
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
        function varargout=doGetNearestIndex(hObj,index)



            numPoints=numel(hObj.XData);


            if numPoints>0
                index=max(1,min(index,numPoints));
            end
            varargout{1}=index;
        end
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
        function varargout=doGetReportedPosition(hObj,index,~)


            pt=doGetDisplayAnchorPoint(hObj,index,0);
            pt.Is2D=true;
            varargout{1}=pt;
        end
    end
    methods(Access='protected',Hidden=true)
        function doBrushing(hObj)

            if~isempty(hObj.BrushHandles)
                hObj.BrushHandles.MarkDirty('all');
            else
                hObj.BrushHandles=matlab.graphics.chart.primitive.bar.BarBrushing;
                hObj.addNode(hObj.BrushHandles);
            end
        end
    end
    methods(Access='public',Static=true,Hidden=true)

        varargout=doloadobj(hObj)
    end
    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden=true)

        varargout=copyElement(hObj)
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'BarLayout','BarWidth','FaceColor','EdgeColor',...
            'BaseValue','XData','YData'});
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
        function varargout=getDimensionData(hObj,dim)

            dimNames=hObj.DimensionNames;
            if strcmp(hObj.Horizontal,'on')
                dimNames=dimNames([2,1,3]);
            end
            prop=[dimNames{dim},'Data'];
            if dim<3
                data=hObj.(prop);
            else
                data=[];
            end
            varargout{1}=data;
        end
    end
    methods(Access={?tBar_computeLayout},Hidden=true)

        computeLayout(hObj,basevalue)
    end
    methods(Access='private',Hidden=true)

        updatePeersAndMarkAllSeriesDirty(hObj,obj,evd)
    end
    methods(Access='private',Hidden=true)

        markAllSeriesDirty(hObj)
    end
    methods(Access='private',Hidden=true)

        deleteBar(hObj,obj,evd)
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end




end
