
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Contour<matlab.graphics.primitive.Data&matlab.graphics.internal.Legacy&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.Legendable&matlab.graphics.chart.interaction.DataAnnotatable





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        FacePrims(:,1)matlab.graphics.primitive.world.TriangleStrip=matlab.graphics.primitive.world.TriangleStrip.empty;
    end

    methods
        function valueToCaller=get.FacePrims(hObj)


            valueToCaller=hObj.FacePrims_I;

        end

        function set.FacePrims(hObj,newValue)



            hObj.FacePrimsMode='manual';


            hObj.FacePrims_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        FacePrimsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FacePrimsMode(hObj)
            storedValue=hObj.FacePrimsMode;
        end

        function set.FacePrimsMode(hObj,newValue)

            oldValue=hObj.FacePrimsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FacePrimsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        FacePrims_I(:,1)matlab.graphics.primitive.world.TriangleStrip=matlab.graphics.primitive.world.TriangleStrip.empty;
    end

    methods
        function storedValue=get.FacePrims_I(hObj)
            storedValue=hObj.FacePrims_I;
        end

        function set.FacePrims_I(hObj,newValue)



            hObj.FacePrims_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        EdgePrims(:,1)matlab.graphics.primitive.world.LineStrip=matlab.graphics.primitive.world.LineStrip.empty;
    end

    methods
        function valueToCaller=get.EdgePrims(hObj)


            valueToCaller=hObj.EdgePrims_I;

        end

        function set.EdgePrims(hObj,newValue)



            hObj.EdgePrimsMode='manual';


            hObj.EdgePrims_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        EdgePrimsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgePrimsMode(hObj)
            storedValue=hObj.EdgePrimsMode;
        end

        function set.EdgePrimsMode(hObj,newValue)

            oldValue=hObj.EdgePrimsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgePrimsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        EdgePrims_I(:,1)matlab.graphics.primitive.world.LineStrip=matlab.graphics.primitive.world.LineStrip.empty;
    end

    methods
        function storedValue=get.EdgePrims_I(hObj)
            storedValue=hObj.EdgePrims_I;
        end

        function set.EdgePrims_I(hObj,newValue)



            hObj.EdgePrims_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        EdgeLoopPrims(:,1)matlab.graphics.primitive.world.LineLoop=matlab.graphics.primitive.world.LineLoop.empty;
    end

    methods
        function valueToCaller=get.EdgeLoopPrims(hObj)


            valueToCaller=hObj.EdgeLoopPrims_I;

        end

        function set.EdgeLoopPrims(hObj,newValue)



            hObj.EdgeLoopPrimsMode='manual';


            hObj.EdgeLoopPrims_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        EdgeLoopPrimsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.EdgeLoopPrimsMode(hObj)
            storedValue=hObj.EdgeLoopPrimsMode;
        end

        function set.EdgeLoopPrimsMode(hObj,newValue)

            oldValue=hObj.EdgeLoopPrimsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.EdgeLoopPrimsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        EdgeLoopPrims_I(:,1)matlab.graphics.primitive.world.LineLoop=matlab.graphics.primitive.world.LineLoop.empty;
    end

    methods
        function storedValue=get.EdgeLoopPrims_I(hObj)
            storedValue=hObj.EdgeLoopPrims_I;
        end

        function set.EdgeLoopPrims_I(hObj,newValue)



            hObj.EdgeLoopPrims_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        TextPrims(:,1)matlab.graphics.primitive.world.Text=matlab.graphics.primitive.world.Text.empty;
    end

    methods
        function valueToCaller=get.TextPrims(hObj)


            valueToCaller=hObj.TextPrims_I;

        end

        function set.TextPrims(hObj,newValue)



            hObj.TextPrimsMode='manual';


            hObj.TextPrims_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        TextPrimsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextPrimsMode(hObj)
            storedValue=hObj.TextPrimsMode;
        end

        function set.TextPrimsMode(hObj,newValue)

            oldValue=hObj.TextPrimsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.TextPrimsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        TextPrims_I(:,1)matlab.graphics.primitive.world.Text=matlab.graphics.primitive.world.Text.empty;
    end

    methods
        function storedValue=get.TextPrims_I(hObj)
            storedValue=hObj.TextPrims_I;
        end

        function set.TextPrims_I(hObj,newValue)



            hObj.TextPrims_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=false)

        ContourMatrix matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=[];
    end

    methods
        function valueToCaller=get.ContourMatrix(hObj)



            if strcmp(hObj.ContourMatrixMode,'auto')
                hObj.ContourMatrix_I=hObj.getContourMatrixImpl();
            end
            valueToCaller=hObj.ContourMatrix_I;


        end

        function set.ContourMatrix(hObj,newValue)



            hObj.ContourMatrixMode='manual';



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ContourMatrixMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ContourMatrixMode(hObj)
            storedValue=hObj.ContourMatrixMode;
        end

        function set.ContourMatrixMode(hObj,newValue)

            oldValue=hObj.ContourMatrixMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                if~manualToAuto
                    hObj.ContourMatrix_I=hObj.getContourMatrixImpl();%#ok<MCSUP>
                end
                hObj.ContourMatrixMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true)

        ContourMatrix_I matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=[];
    end

    methods



        function set.ContourMatrix_I(hObj,newValue)
            oldValue=hObj.ContourMatrix_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.ContourMatrix_I=newValue;
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        ContourZLevel(1,1)double=0.0;
    end

    methods
        function valueToCaller=get.ContourZLevel(hObj)


            valueToCaller=hObj.ContourZLevel_I;

        end

        function set.ContourZLevel(hObj,newValue)



            hObj.ContourZLevelMode='manual';


            hObj.ContourZLevel_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ContourZLevelMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ContourZLevelMode(hObj)
            storedValue=hObj.ContourZLevelMode;
        end

        function set.ContourZLevelMode(hObj,newValue)

            oldValue=hObj.ContourZLevelMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ContourZLevelMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ContourZLevel_I(1,1)double=0.0;
    end

    methods
        function storedValue=get.ContourZLevel_I(hObj)
            storedValue=hObj.ContourZLevel_I;
        end

        function set.ContourZLevel_I(hObj,newValue)



            hObj.ContourZLevel_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ZLocation matlab.internal.datatype.matlab.graphics.datatype.ZLocation=0;
    end

    methods
        function valueToCaller=get.ZLocation(hObj)

            if strcmpi(get(hObj,'ZLocationMode'),'auto')
                forceFullUpdate(hObj,'all','ZLocation');
            end


            valueToCaller=hObj.ZLocation_I;

        end

        function set.ZLocation(hObj,newValue)



            hObj.ZLocationMode='manual';


            hObj.ZLocation_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ZLocationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ZLocationMode(hObj)
            storedValue=hObj.ZLocationMode;
        end

        function set.ZLocationMode(hObj,newValue)

            oldValue=hObj.ZLocationMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ZLocationMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ZLocation_I matlab.internal.datatype.matlab.graphics.datatype.ZLocation=0;
    end

    methods
        function storedValue=get.ZLocation_I(hObj)
            storedValue=hObj.ZLocation_I;
        end

        function set.ZLocation_I(hObj,newValue)



            hObj.ZLocation_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Fill matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function valueToCaller=get.Fill(hObj)




            valueToCaller=hObj.Fill_I;

        end

        function set.Fill(hObj,newValue)



            hObj.FillMode='manual';


            hObj.Fill_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        FillMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.FillMode(hObj)
            storedValue=hObj.FillMode;
        end

        function set.FillMode(hObj,newValue)

            oldValue=hObj.FillMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.FillMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Fill_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.Fill_I(hObj)
            storedValue=hObj.Fill_I;
        end

        function set.Fill_I(hObj,newValue)
            oldValue=hObj.Fill_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Fill_I=hObj.setFillImpl(newValue);
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Is3D matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function valueToCaller=get.Is3D(hObj)


            valueToCaller=hObj.Is3D_I;

        end

        function set.Is3D(hObj,newValue)



            hObj.Is3DMode='manual';


            hObj.Is3D_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        Is3DMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.Is3DMode(hObj)
            storedValue=hObj.Is3DMode;
        end

        function set.Is3DMode(hObj,newValue)

            oldValue=hObj.Is3DMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.Is3DMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Is3D_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.Is3D_I(hObj)
            storedValue=hObj.Is3D_I;
        end

        function set.Is3D_I(hObj,newValue)



            hObj.Is3D_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LabelSpacing(1,1)double=144;
    end

    methods
        function valueToCaller=get.LabelSpacing(hObj)


            valueToCaller=hObj.LabelSpacing_I;

        end

        function set.LabelSpacing(hObj,newValue)



            hObj.LabelSpacingMode='manual';


            hObj.LabelSpacing_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LabelSpacingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LabelSpacingMode(hObj)
            storedValue=hObj.LabelSpacingMode;
        end

        function set.LabelSpacingMode(hObj,newValue)

            oldValue=hObj.LabelSpacingMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LabelSpacingMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LabelSpacing_I(1,1)double=144;
    end

    methods
        function storedValue=get.LabelSpacing_I(hObj)
            storedValue=hObj.LabelSpacing_I;
        end

        function set.LabelSpacing_I(hObj,newValue)



            hObj.LabelSpacing_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LabelFormat=@string;
    end

    methods
        function valueToCaller=get.LabelFormat(hObj)



            valueToCaller=hObj.LabelFormat_I;

        end

        function set.LabelFormat(hObj,newValue)



            hObj.LabelFormatMode='manual';



            reallyDoCopy=~isequal(hObj.LabelFormat_I,newValue);

            if reallyDoCopy
                hObj.LabelFormat_I=hObj.setLabelFormatImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LabelFormatMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LabelFormatMode(hObj)
            storedValue=hObj.LabelFormatMode;
        end

        function set.LabelFormatMode(hObj,newValue)

            oldValue=hObj.LabelFormatMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LabelFormatMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LabelFormat_I=@string;
    end

    methods
        function storedValue=get.LabelFormat_I(hObj)
            storedValue=hObj.LabelFormat_I;
        end



    end


    properties(SetObservable=false,SetAccess={?tContour},GetAccess={?tContour},Dependent=false,Hidden=true,Transient=true)

        LabelCache struct;
    end

    methods
        function storedValue=get.LabelCache(hObj)
            storedValue=hObj.LabelCache;
        end

        function set.LabelCache(hObj,newValue)



            hObj.LabelCache=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LevelList matlab.internal.datatype.matlab.graphics.datatype.VectorData=[];
    end

    methods
        function valueToCaller=get.LevelList(hObj)



            if strcmp(hObj.LevelListMode,'auto')
                hObj.LevelList_I=hObj.getLevelListImpl();
            end
            valueToCaller=hObj.LevelList_I;


        end

        function set.LevelList(hObj,newValue)



            hObj.LevelListMode='manual';



            reallyDoCopy=~isequal(hObj.LevelList_I,newValue);

            if reallyDoCopy
                hObj.LevelList_I=hObj.setLevelListImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        LevelListMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LevelListMode(hObj)
            storedValue=hObj.LevelListMode;
        end

        function set.LevelListMode(hObj,newValue)

            oldValue=hObj.LevelListMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                if~manualToAuto
                    hObj.LevelList_I=hObj.getLevelListImpl();%#ok<MCSUP>
                end
                hObj.LevelListMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LevelList_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=[];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LevelStep(1,1)double=0;
    end

    methods
        function valueToCaller=get.LevelStep(hObj)



            if strcmp(hObj.LevelStepMode,'auto')
                hObj.LevelStep_I=hObj.getLevelStepImpl();
            end
            valueToCaller=hObj.LevelStep_I;


        end

        function set.LevelStep(hObj,newValue)



            hObj.LevelStepMode='manual';



            reallyDoCopy=~isequal(hObj.LevelStep_I,newValue);

            if reallyDoCopy
                hObj.LevelStep_I=hObj.setLevelStepImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        LevelStepMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LevelStepMode(hObj)
            storedValue=hObj.LevelStepMode;
        end

        function set.LevelStepMode(hObj,newValue)

            oldValue=hObj.LevelStepMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                if~manualToAuto
                    hObj.LevelStep_I=hObj.getLevelStepImpl();%#ok<MCSUP>
                end
                hObj.LevelStepMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LevelStep_I(1,1)double=0;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        LineColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='flat';
    end

    methods
        function valueToCaller=get.LineColor(hObj)




            valueToCaller=hObj.LineColor_I;

        end

        function set.LineColor(hObj,newValue)



            hObj.LineColorMode='manual';


            hObj.LineColor_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LineColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LineColorMode(hObj)
            storedValue=hObj.LineColorMode;
        end

        function set.LineColorMode(hObj,newValue)

            oldValue=hObj.LineColorMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LineColorMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LineColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='flat';
    end

    methods
        function storedValue=get.LineColor_I(hObj)
            storedValue=hObj.getLineColorImpl(hObj.LineColor_I);
        end

        function set.LineColor_I(hObj,newValue)
            oldValue=hObj.LineColor_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.LineColor_I=hObj.setLineColorImpl(newValue);
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        FaceColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='none';
    end

    methods
        function valueToCaller=get.FaceColor(hObj)



            valueToCaller=hObj.FaceColor_I;

        end

        function set.FaceColor(hObj,newValue)



            hObj.FaceColorMode='manual';



            reallyDoCopy=~isequal(hObj.FaceColor_I,newValue);

            if reallyDoCopy
                hObj.FaceColor_I=hObj.setFaceColorImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

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


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='none';
    end

    methods
        function storedValue=get.FaceColor_I(hObj)
            storedValue=hObj.FaceColor_I;
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


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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

        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='flat';
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

        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='flat';
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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Color;
    end

    methods
        function valueToCaller=get.Color(hObj)

            valueToCaller=hObj.EdgeColor;
        end

        function set.Color(hObj,newValue)

            hObj.EdgeColor=newValue;
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



            hObj.LineWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ShowText matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function valueToCaller=get.ShowText(hObj)


            valueToCaller=hObj.ShowText_I;

        end

        function set.ShowText(hObj,newValue)



            hObj.ShowTextMode='manual';


            hObj.ShowText_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ShowTextMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ShowTextMode(hObj)
            storedValue=hObj.ShowTextMode;
        end

        function set.ShowTextMode(hObj,newValue)

            oldValue=hObj.ShowTextMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ShowTextMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ShowText_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.ShowText_I(hObj)
            storedValue=hObj.ShowText_I;
        end

        function set.ShowText_I(hObj,newValue)



            hObj.ShowText_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextList matlab.internal.datatype.matlab.graphics.datatype.VectorData=[];
    end

    methods
        function valueToCaller=get.TextList(hObj)



            if strcmp(hObj.TextListMode,'auto')
                hObj.TextList_I=hObj.getTextListImpl();
            end
            valueToCaller=hObj.TextList_I;


        end

        function set.TextList(hObj,newValue)



            hObj.TextListMode='manual';



            reallyDoCopy=~isequal(hObj.TextList_I,newValue);

            if reallyDoCopy
                hObj.TextList_I=hObj.setTextListImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        TextListMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextListMode(hObj)
            storedValue=hObj.TextListMode;
        end

        function set.TextListMode(hObj,newValue)

            oldValue=hObj.TextListMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                if~manualToAuto
                    hObj.TextList_I=hObj.getTextListImpl();%#ok<MCSUP>
                end
                hObj.TextListMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        TextList_I matlab.internal.datatype.matlab.graphics.datatype.VectorData=[];
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        TextStep(1,1)double=0;
    end

    methods
        function valueToCaller=get.TextStep(hObj)



            if strcmp(hObj.TextStepMode,'auto')
                hObj.TextStep_I=hObj.getTextStepImpl();
            end
            valueToCaller=hObj.TextStep_I;


        end

        function set.TextStep(hObj,newValue)



            hObj.TextStepMode='manual';



            reallyDoCopy=~isequal(hObj.TextStep_I,newValue);

            if reallyDoCopy
                hObj.TextStep_I=hObj.setTextStepImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        TextStepMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.TextStepMode(hObj)
            storedValue=hObj.TextStepMode;
        end

        function set.TextStepMode(hObj,newValue)

            oldValue=hObj.TextStepMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                if~manualToAuto
                    hObj.TextStep_I=hObj.getTextStepImpl();%#ok<MCSUP>
                end
                hObj.TextStepMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        TextStep_I(1,1)double=0;
    end

    methods





    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XData matlab.internal.datatype.matlab.graphics.datatype.SurfaceXYData=[];
    end

    methods
        function valueToCaller=get.XData(hObj)



            if strcmp(hObj.XDataMode,'auto')
                hObj.XData_I=hObj.getXDataImpl();
            end
            valueToCaller=hObj.XData_I;


        end

        function set.XData(hObj,newValue)



            hObj.XDataMode='manual';



            reallyDoCopy=~isequal(hObj.XData_I,newValue);

            if reallyDoCopy
                hObj.XData_I=hObj.setXDataImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        XDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XDataMode(hObj)
            storedValue=hObj.XDataMode;
        end

        function set.XDataMode(hObj,newValue)

            oldValue=hObj.XDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                if~manualToAuto
                    hObj.XData_I=hObj.getXDataImpl();%#ok<MCSUP>
                end
                hObj.XDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XData_I matlab.internal.datatype.matlab.graphics.datatype.SurfaceXYData=[];
    end

    methods





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


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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

        YData matlab.internal.datatype.matlab.graphics.datatype.SurfaceXYData=[];
    end

    methods
        function valueToCaller=get.YData(hObj)



            if strcmp(hObj.YDataMode,'auto')
                hObj.YData_I=hObj.getYDataImpl();
            end
            valueToCaller=hObj.YData_I;


        end

        function set.YData(hObj,newValue)



            hObj.YDataMode='manual';



            reallyDoCopy=~isequal(hObj.YData_I,newValue);

            if reallyDoCopy
                hObj.YData_I=hObj.setYDataImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=false,Hidden=false,NeverAmbiguous=true)

        YDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YDataMode(hObj)
            storedValue=hObj.YDataMode;
        end

        function set.YDataMode(hObj,newValue)

            oldValue=hObj.YDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                if~manualToAuto
                    hObj.YData_I=hObj.getYDataImpl();%#ok<MCSUP>
                end
                hObj.YDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YData_I matlab.internal.datatype.matlab.graphics.datatype.SurfaceXYData=[];
    end

    methods





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


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ZData matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=[];
    end

    methods
        function valueToCaller=get.ZData(hObj)



            valueToCaller=hObj.ZData_I;

        end

        function set.ZData(hObj,newValue)



            hObj.ZDataMode='manual';



            reallyDoCopy=~isequal(hObj.ZData_I,newValue);

            if reallyDoCopy
                hObj.ZData_I=hObj.setZDataImpl(newValue);
            end

            hObj.MarkDirty('limits');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ZDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ZDataMode(hObj)
            storedValue=hObj.ZDataMode;
        end

        function set.ZDataMode(hObj,newValue)

            oldValue=hObj.ZDataMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ZDataMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ZData_I matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=[];
    end

    methods
        function storedValue=get.ZData_I(hObj)
            storedValue=hObj.ZData_I;
        end



    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ZDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.ZDataSource(hObj)


            valueToCaller=hObj.ZDataSource_I;

        end

        function set.ZDataSource(hObj,newValue)



            hObj.ZDataSourceMode='manual';


            hObj.ZDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ZDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ZDataSourceMode(hObj)
            storedValue=hObj.ZDataSourceMode;
        end

        function set.ZDataSourceMode(hObj,newValue)

            oldValue=hObj.ZDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ZDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ZDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.ZDataSource_I(hObj)
            storedValue=hObj.ZDataSource_I;
        end

        function set.ZDataSource_I(hObj,newValue)



            hObj.ZDataSource_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        XDataCache;
    end

    methods
        function valueToCaller=get.XDataCache(hObj)

            valueToCaller=hObj.XData;
        end

        function set.XDataCache(hObj,newValue)

            hObj.XData=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        YDataCache;
    end

    methods
        function valueToCaller=get.YDataCache(hObj)

            valueToCaller=hObj.YData;
        end

        function set.YDataCache(hObj,newValue)

            hObj.YData=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        ZDataCache;
    end

    methods
        function valueToCaller=get.ZDataCache(hObj)

            valueToCaller=hObj.ZData;
        end

        function set.ZDataCache(hObj,newValue)

            hObj.ZData=newValue;
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        SelectionHandle;
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



            fanChild=hObj.SelectionHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            hObj.Clipping_I=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,AffectsLegend)

        LabelTextProperties=matlab.graphics.chart.primitive.Contour.defaultLabelTextProperties();
    end

    methods
        function storedValue=get.LabelTextProperties(hObj)
            storedValue=hObj.LabelTextProperties;
        end

        function set.LabelTextProperties(hObj,newValue)



            hObj.LabelTextProperties=newValue;

        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,Transient=true)

        ContourDataCache matlab.graphics.chart.internal.contour.ContourDataCache=matlab.graphics.chart.internal.contour.ContourDataCache.empty();
    end

    methods
        function storedValue=get.ContourDataCache(hObj)
            storedValue=hObj.ContourDataCache;
        end

        function set.ContourDataCache(hObj,newValue)



            hObj.ContourDataCache=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
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
        [index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
    end






    methods(Access='protected')
        [index,interpolationFactor]=doIncrementIndex(hObj,index,direction,interpolationStep)
    end






    methods(Access={?tContour_checkOutOfRangeVertices},Static=true)
        [xout,yout,zout]=checkOutOfRangeVertices(hObj,ds,xfm,xin,yin,zin,filterZ)
    end



    methods
        function hObj=Contour(varargin)






            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','Contour SelectionHandle');

            set(hObj.SelectionHandle,'Internal',true);



            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setSelectionHandle_IFanoutProps(hObj)

            try
                mode=hObj.SelectionHandle.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.SelectionHandle,'Clipping_I',hObj.Clipping_I);
            end

        end
    end


    methods(Access='public',Hidden=true)

        updateLabelTextProperties(hObj,labelTextPropertyInput)
    end
    methods(Access='private',Hidden=true)
        function doSetup(hObj)


            hObj.Type='contour';

            addDependencyConsumed(hObj,{'figurecolormap','colorspace','dataspace'});

            setInteractionHint(hObj,'DataBrushing',false);

        end
    end
    methods(Access='public',Hidden=true)

        varargout=getXYZDataExtents(hObj,transform,constraints)
    end
    methods(Access='public',Hidden=true)

        varargout=getColorAlphaDataExtents(hObj)
    end
    methods(Access='private',Hidden=true)

        varargout=useZRange(hObj)
    end
    methods(Access='private',Hidden=true)
        function varargout=getContourDataCache(hObj)

            cache=hObj.ContourDataCache;
            if isempty(cache)

                cache=matlab.graphics.chart.internal.contour.ContourDataCache;
                hObj.ContourDataCache=cache;
            end
            varargout{1}=cache;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setFillImpl(hObj,newValue)




            if~newValue

                hObj.FaceColor_I='none';
                hObj.FaceColorMode='auto';
            elseif hObj.FaceColor_I=="none"
                hObj.FaceColor_I='flat';
                hObj.FaceColorMode='auto';
            end

            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setFaceColorImpl(hObj,newValue)





            hObj.Fill_I=~isequal(newValue,'none');
            hObj.FillMode='auto';


            hObj.FaceColorMode='manual';

            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getLineColorImpl(hObj,~)
            varargout{1}=hObj.EdgeColor_I;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setLineColorImpl(hObj,newValue)
            hObj.EdgeColor_I=newValue;
            varargout{1}=newValue;
        end
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='private',Hidden=true)

        updateFill(hObj,updateState)
    end
    methods(Access='private',Hidden=true)

        updateContourZLevel(hObj,updateState)
    end
    methods(Access='private',Hidden=true)

        varargout=updateLines(hObj,updateState,contourLines)
    end
    methods(Access='private',Hidden=true)

        updateLabels(hObj,updateState,label_info)
    end
    methods(Access={?tContour},Hidden=true)

        varargout=createLabelStrings(hObj,levels,format)
    end
    methods(Access='private',Hidden=true)

        updateSelectionHandle(hObj)
    end
    methods(Access='private',Hidden=true)

        varargout=computeContourLines(hObj,updateState,linkStrips)
    end
    methods(Access='private',Static=true,Hidden=true)
        function varargout=defaultLabelFont()

            fontObj=matlab.graphics.general.Font;
            fontObj.Name='Helvetica';
            fontObj.Size=10;
            fontObj.Angle='normal';
            fontObj.Weight='normal';
            varargout{1}=fontObj;
        end
    end
    methods(Access='private',Static=true,Hidden=true)
        function varargout=defaultLabelTextProperties()

            varargout{1}=struct(...
            'Font',matlab.graphics.chart.primitive.Contour.defaultLabelFont(),...
            'ColorData',uint8([]),...
            'BackgroundColor',uint8([]),...
            'EdgeColor',uint8([]),...
            'FontSmoothing','on',...
            'Interpreter','none',...
            'LineStyle','solid',...
            'LineWidth',1,...
            'Margin',1,...
            'Visible','on');
        end
    end
    methods(Access='public',Hidden=true)

        varargout=getLegendGraphic(hObj)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetDataDescriptors(hObj,index,interpfactor)
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

        varargout=doGetDisplayAnchorPoint(hObj,index,interpfactor)
    end
    methods(Access='protected',Hidden=true)

        varargout=doGetReportedPosition(hObj,index,interpfactor)
    end
    methods(Access='public',Hidden=true)

        varargout=getContourList(hObj,zmin,zmax,step)
    end
    methods(Access='public',Static=true,Hidden=true)
        function varargout=doloadobj(hObj)


            matlab.graphics.chart.internal.deleteNonPrimitiveChildren(hObj);
            varargout{1}=hObj;
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'EdgeColor','LineStyle','LineWidth','FaceColor',...
            'LevelList','XData','YData','ZData'});
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

        varargout=getContourMatrixImpl(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=getLevelListImpl(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=setLevelListImpl(hObj,newValue)
    end
    methods(Access='public',Hidden=true)

        varargout=getLevelStepImpl(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=setLevelStepImpl(hObj,newValue)
    end
    methods(Access='public',Hidden=true)

        varargout=getTextListImpl(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=setTextListImpl(hObj,newValue)
    end
    methods(Access='public',Hidden=true)

        varargout=getTextStepImpl(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=setTextStepImpl(hObj,newValue)
    end
    methods(Access='public',Hidden=true)

        varargout=getXDataImpl(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=setXDataImpl(hObj,newValue)
    end
    methods(Access='public',Hidden=true)

        varargout=getYDataImpl(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=setYDataImpl(hObj,newValue)
    end
    methods(Access='public',Hidden=true)

        varargout=getZDataImpl(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=setZDataImpl(hObj,newValue)
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end
    methods(Access='public',Hidden=true)

        varargout=applyThemeValues(hObj,themeInfo)
    end
    methods(Access='public',Hidden=true)

        varargout=getThemeAttributeMap(hObj)
    end




end
