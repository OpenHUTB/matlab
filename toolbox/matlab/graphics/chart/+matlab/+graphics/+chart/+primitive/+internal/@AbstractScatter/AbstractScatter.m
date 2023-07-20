
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Hidden=true,AllowedSubclasses={?matlab.graphics.chart.primitive.Scatter,?matlab.graphics.chart.primitive.BubbleChart,?hTestAbstractScatter})AbstractScatter<matlab.graphics.primitive.Data&matlab.graphics.mixin.DataProperties&matlab.graphics.internal.Legacy&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Selectable&matlab.graphics.mixin.Legendable&matlab.graphics.mixin.ColorOrderUser&matlab.graphics.chart.interaction.DataAnnotatable&matlab.graphics.mixin.PolarAxesParentable&matlab.graphics.mixin.GeographicAxesParentable&matlab.graphics.mixin.MapAxesParentable






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




    properties(Dependent,SetObservable,GetObservable)
        ZData=zeros(1,0)
    end

    properties(SetObservable,NeverAmbiguous)
        ZDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden)
        ZData_I=zeros(1,0)
    end

    properties(Hidden,Dependent,SetAccess=private)
ZDataCache
    end

    properties(Dependent)
        ZVariable=''
    end

    properties(Hidden,Dependent)
        ZVariable_I=''
    end

    methods
        function set.ZData(hObj,value)
            hObj.setDataPropertyValue("Z",value,false);
        end
        function set.ZDataMode(hObj,mode)
            hObj.setDataPropertyMode("Z",mode);
        end
        function set.ZData_I(hObj,value)
            hObj.setDataPropertyValue("Z",value,true);
        end
        function set.ZVariable(hObj,value)
            hObj.setVariablePropertyValue("Z",value,false);
        end
        function set.ZVariable_I(hObj,value)
            hObj.setVariablePropertyValue("Z",value,true);
        end
        function value=get.ZData(hObj)
            value=hObj.getDataPropertyValue("Z",false);
        end
        function mode=get.ZDataMode(hObj)
            mode=hObj.getDataPropertyMode("Z");
        end
        function value=get.ZData_I(hObj)
            value=hObj.getDataPropertyValue("Z",true);
        end
        function value=get.ZVariable(hObj)
            value=hObj.getVariablePropertyValue("Z",false);
        end
        function value=get.ZVariable_I(hObj)
            value=hObj.getVariablePropertyValue("Z",true);
        end
        function value=get.ZDataCache(hObj)
            value=hObj.getDataPropertyNumericValue("Z",false);
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


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

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

    properties(SetObservable=true,SetAccess='protected',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        BrushHandles;
    end

    methods
        function valueToCaller=get.BrushHandles(hObj)


            valueToCaller=hObj.BrushHandles_I;

        end

        function set.BrushHandles(hObj,newValue)



            hObj.BrushHandlesMode='manual';


            hObj.BrushHandles_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BrushHandlesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BrushHandlesMode(hObj)
            storedValue=hObj.BrushHandlesMode;
        end

        function set.BrushHandlesMode(hObj,newValue)

            oldValue=hObj.BrushHandlesMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BrushHandlesMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='public',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        BrushHandles_I;
    end

    methods
        function storedValue=get.BrushHandles_I(hObj)
            storedValue=hObj.BrushHandles_I;
        end

        function set.BrushHandles_I(hObj,newValue)



            hObj.BrushHandles_I=newValue;

        end
    end


    properties(Dependent,SetObservable,GetObservable)
        SizeData=zeros(1,0)
    end

    properties(SetObservable,NeverAmbiguous)
        SizeDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden)
        SizeData_I=zeros(1,0)
    end

    properties(Hidden,Dependent,SetAccess=private)
SizeDataCache
    end

    properties(Dependent)
        SizeVariable=''
    end

    properties(Hidden,Dependent)
        SizeVariable_I=''
    end

    methods
        function set.SizeData(hObj,value)
            hObj.setDataPropertyValue("Size",value,false);
        end
        function set.SizeDataMode(hObj,mode)
            hObj.setDataPropertyMode("Size",mode);
        end
        function set.SizeData_I(hObj,value)
            hObj.setDataPropertyValue("Size",value,true);
        end
        function set.SizeVariable(hObj,value)
            hObj.setVariablePropertyValue("Size",value,false);
        end
        function set.SizeVariable_I(hObj,value)
            hObj.setVariablePropertyValue("Size",value,true);
        end
        function value=get.SizeData(hObj)
            value=hObj.getDataPropertyValue("Size",false);
        end
        function mode=get.SizeDataMode(hObj)
            mode=hObj.getDataPropertyMode("Size");
        end
        function value=get.SizeData_I(hObj)
            value=hObj.getDataPropertyValue("Size",true);
        end
        function value=get.SizeVariable(hObj)
            value=hObj.getVariablePropertyValue("Size",false);
        end
        function value=get.SizeVariable_I(hObj)
            value=hObj.getVariablePropertyValue("Size",true);
        end
        function value=get.SizeDataCache(hObj)
            value=hObj.getDataPropertyNumericValue("Size",false);
        end
    end



    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        SizeDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.SizeDataSource(hObj)


            valueToCaller=hObj.SizeDataSource_I;

        end

        function set.SizeDataSource(hObj,newValue)



            hObj.SizeDataSourceMode='manual';


            hObj.SizeDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        SizeDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.SizeDataSourceMode(hObj)
            storedValue=hObj.SizeDataSourceMode;
        end

        function set.SizeDataSourceMode(hObj,newValue)

            oldValue=hObj.SizeDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.SizeDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        SizeDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.SizeDataSource_I(hObj)
            storedValue=hObj.SizeDataSource_I;
        end

        function set.SizeDataSource_I(hObj,newValue)



            hObj.SizeDataSource_I=newValue;

        end
    end


    properties(Dependent,SetObservable,GetObservable)
        CData=zeros(1,0)
    end

    properties(SetObservable,NeverAmbiguous)
        CDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden)
        CData_I=zeros(1,0)
    end

    properties(Hidden,Dependent,SetAccess=private)
CDataCache
    end

    properties(Dependent)
        ColorVariable=''
    end

    properties(Hidden,Dependent)
        ColorVariable_I=''
    end

    methods
        function set.CData(hObj,value)
            hObj.setDataPropertyValue("Color",value,false);
        end
        function set.CDataMode(hObj,mode)
            hObj.setDataPropertyMode("Color",mode);
        end
        function set.CData_I(hObj,value)
            hObj.setDataPropertyValue("Color",value,true);
        end
        function set.ColorVariable(hObj,value)
            hObj.setVariablePropertyValue("Color",value,false);
        end
        function set.ColorVariable_I(hObj,value)
            hObj.setVariablePropertyValue("Color",value,true);
        end
        function value=get.CData(hObj)
            if strcmpi(hObj.CDataMode,'auto')
                forceFullUpdate(hObj,'all','CData');
            end
            value=hObj.getDataPropertyValue("Color",false);
        end
        function mode=get.CDataMode(hObj)
            mode=hObj.getDataPropertyMode("Color");
        end
        function value=get.CData_I(hObj)
            value=hObj.getDataPropertyValue("Color",true);
        end
        function value=get.ColorVariable(hObj)
            value=hObj.getVariablePropertyValue("Color",false);
        end
        function value=get.ColorVariable_I(hObj)
            value=hObj.getVariablePropertyValue("Color",true);
        end
        function value=get.CDataCache(hObj)
            value=hObj.getDataPropertyNumericValue("Color",false);
        end
    end



    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        CDataSource matlab.internal.datatype.asciiString='';
    end

    methods
        function valueToCaller=get.CDataSource(hObj)


            valueToCaller=hObj.CDataSource_I;

        end

        function set.CDataSource(hObj,newValue)



            hObj.CDataSourceMode='manual';


            hObj.CDataSource_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CDataSourceMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CDataSourceMode(hObj)
            storedValue=hObj.CDataSourceMode;
        end

        function set.CDataSourceMode(hObj,newValue)

            oldValue=hObj.CDataSourceMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CDataSourceMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        CDataSource_I matlab.internal.datatype.asciiString='';
    end

    methods
        function storedValue=get.CDataSource_I(hObj)
            storedValue=hObj.CDataSource_I;
        end

        function set.CDataSource_I(hObj,newValue)



            hObj.CDataSource_I=newValue;

        end
    end


    properties(Dependent,SetObservable,GetObservable)
        AlphaData=zeros(1,0)
    end

    properties(SetObservable,NeverAmbiguous)
        AlphaDataMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Hidden)
        AlphaData_I=zeros(1,0)
    end

    properties(Hidden,Dependent,SetAccess=private)
AlphaDataCache
    end

    properties(Dependent)
        AlphaVariable=''
    end

    properties(Hidden,Dependent)
        AlphaVariable_I=''
    end

    methods
        function set.AlphaData(hObj,value)
            hObj.setDataPropertyValue("Alpha",value,false);
        end
        function set.AlphaDataMode(hObj,mode)
            hObj.setDataPropertyMode("Alpha",mode);
        end
        function set.AlphaData_I(hObj,value)
            hObj.setDataPropertyValue("Alpha",value,true);
        end
        function set.AlphaVariable(hObj,value)
            hObj.setVariablePropertyValue("Alpha",value,false);
        end
        function set.AlphaVariable_I(hObj,value)
            hObj.setVariablePropertyValue("Alpha",value,true);
        end
        function value=get.AlphaData(hObj)
            value=hObj.getDataPropertyValue("Alpha",false);
        end
        function mode=get.AlphaDataMode(hObj)
            mode=hObj.getDataPropertyMode("Alpha");
        end
        function value=get.AlphaData_I(hObj)
            value=hObj.getDataPropertyValue("Alpha",true);
        end
        function value=get.AlphaVariable(hObj)
            value=hObj.getVariablePropertyValue("Alpha",false);
        end
        function value=get.AlphaVariable_I(hObj)
            value=hObj.getVariablePropertyValue("Alpha",true);
        end
        function value=get.AlphaDataCache(hObj)
            value=hObj.getDataPropertyNumericValue("Alpha",false);
        end
    end



    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        AlphaDataMapping matlab.internal.datatype.matlab.graphics.datatype.AlphaDataMapping='scaled';
    end

    methods
        function valueToCaller=get.AlphaDataMapping(hObj)


            valueToCaller=hObj.AlphaDataMapping_I;

        end

        function set.AlphaDataMapping(hObj,newValue)



            hObj.AlphaDataMappingMode='manual';


            hObj.AlphaDataMapping_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        AlphaDataMappingMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.AlphaDataMappingMode(hObj)
            storedValue=hObj.AlphaDataMappingMode;
        end

        function set.AlphaDataMappingMode(hObj,newValue)

            oldValue=hObj.AlphaDataMappingMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.AlphaDataMappingMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsDataLimits,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        AlphaDataMapping_I matlab.internal.datatype.matlab.graphics.datatype.AlphaDataMapping='scaled';
    end

    methods
        function storedValue=get.AlphaDataMapping_I(hObj)
            storedValue=hObj.AlphaDataMapping_I;
        end

        function set.AlphaDataMapping_I(hObj,newValue)



            hObj.AlphaDataMapping_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=true,Hidden=true,Transient=true)

        CurrentIconColorInfo matlab.graphics.chart.primitive.internal.abstractscatter.IconColorInfoCache;
    end

    methods
        function valueToCaller=get.CurrentIconColorInfo(hObj)


            valueToCaller=hObj.CurrentIconColorInfo_I;

        end

        function set.CurrentIconColorInfo(hObj,newValue)



            hObj.CurrentIconColorInfoMode='manual';


            hObj.CurrentIconColorInfo_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        CurrentIconColorInfoMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.CurrentIconColorInfoMode(hObj)
            storedValue=hObj.CurrentIconColorInfoMode;
        end

        function set.CurrentIconColorInfoMode(hObj,newValue)

            oldValue=hObj.CurrentIconColorInfoMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.CurrentIconColorInfoMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,Transient=true)

        CurrentIconColorInfo_I matlab.graphics.chart.primitive.internal.abstractscatter.IconColorInfoCache;
    end

    methods
        function storedValue=get.CurrentIconColorInfo_I(hObj)
            storedValue=hObj.CurrentIconColorInfo_I;
        end

        function set.CurrentIconColorInfo_I(hObj,newValue)



            hObj.CurrentIconColorInfo_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        Jitter matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function valueToCaller=get.Jitter(hObj)


            valueToCaller=hObj.Jitter_I;

        end

        function set.Jitter(hObj,newValue)



            hObj.JitterMode='manual';


            hObj.Jitter_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        JitterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.JitterMode(hObj)
            storedValue=hObj.JitterMode;
        end

        function set.JitterMode(hObj,newValue)

            oldValue=hObj.JitterMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.JitterMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Jitter_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off';
    end

    methods
        function storedValue=get.Jitter_I(hObj)
            storedValue=hObj.Jitter_I;
        end

        function set.Jitter_I(hObj,newValue)



            hObj.Jitter_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true)

        JitterAmount(1,1)double=.2;
    end

    methods
        function valueToCaller=get.JitterAmount(hObj)


            valueToCaller=hObj.JitterAmount_I;

        end

        function set.JitterAmount(hObj,newValue)



            hObj.JitterAmountMode='manual';


            hObj.JitterAmount_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        JitterAmountMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.JitterAmountMode(hObj)
            storedValue=hObj.JitterAmountMode;
        end

        function set.JitterAmountMode(hObj,newValue)

            oldValue=hObj.JitterAmountMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.JitterAmountMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        JitterAmount_I(1,1)double=.2;
    end

    methods
        function storedValue=get.JitterAmount_I(hObj)
            storedValue=hObj.JitterAmount_I;
        end

        function set.JitterAmount_I(hObj,newValue)



            hObj.JitterAmount_I=newValue;

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



            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            fanChild=hObj.MarkerHandleNaN;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'LineWidthMode'),'auto')
                    set(fanChild,'LineWidth_I',newValue);
                end
            end
            hObj.LineWidth_I=newValue;

        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=true,SetAccess={?tScatter},GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true,NonCopyable=true)

        MarkerHandle;
    end

    methods
        function set.MarkerHandle(hObj,newValue)
            hObj.MarkerHandle=newValue;
            try
                hObj.setMarkerHandleFanoutProps();
            catch
            end
        end
    end

    properties(InternalComponent,AffectsObject,SetObservable=true,SetAccess='private',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true,NonCopyable=true)

        MarkerHandleNaN;
    end

    methods
        function set.MarkerHandleNaN(hObj,newValue)
            hObj.MarkerHandleNaN=newValue;
            try
                hObj.setMarkerHandleNaNFanoutProps();
            catch
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess={?matlab.graphics.chart.primitive.internal.abstractscatter.ScatterBrushing},Dependent=false,Hidden=true,Transient=true)

        MarkerOrder matlab.internal.datatype.matlab.graphics.datatype.VectorData=zeros(1,0);
    end

    methods
        function storedValue=get.MarkerOrder(hObj)
            storedValue=hObj.MarkerOrder;
        end

        function set.MarkerOrder(hObj,newValue)



            hObj.MarkerOrder=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        MarkerEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor='flat';
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

        MarkerEdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBFlatNoneColor='flat';
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

        MarkerEdgeAlpha matlab.internal.datatype.matlab.graphics.datatype.MarkerAlpha=1;
    end

    methods
        function valueToCaller=get.MarkerEdgeAlpha(hObj)


            valueToCaller=hObj.MarkerEdgeAlpha_I;

        end

        function set.MarkerEdgeAlpha(hObj,newValue)



            hObj.MarkerEdgeAlphaMode='manual';


            hObj.MarkerEdgeAlpha_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        MarkerEdgeAlphaMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.MarkerEdgeAlphaMode(hObj)
            storedValue=hObj.MarkerEdgeAlphaMode;
        end

        function set.MarkerEdgeAlphaMode(hObj,newValue)

            oldValue=hObj.MarkerEdgeAlphaMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.MarkerEdgeAlphaMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        MarkerEdgeAlpha_I matlab.internal.datatype.matlab.graphics.datatype.MarkerAlpha=1;
    end

    methods
        function storedValue=get.MarkerEdgeAlpha_I(hObj)
            storedValue=hObj.MarkerEdgeAlpha_I;
        end

        function set.MarkerEdgeAlpha_I(hObj,newValue)



            hObj.MarkerEdgeAlpha_I=newValue;

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



            fanChild=hObj.MarkerHandle;

            if~isempty(fanChild)&&isvalid(fanChild)

                if strcmpi(get(fanChild,'ClippingMode'),'auto')
                    set(fanChild,'Clipping_I',newValue);
                end
            end
            fanChild=hObj.MarkerHandleNaN;

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

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XJitter matlab.internal.datatype.matlab.graphics.chart.datatype.JitterMethodType='none';
    end

    methods
        function valueToCaller=get.XJitter(hObj)


            valueToCaller=hObj.XJitter_I;

        end

        function set.XJitter(hObj,newValue)



            hObj.XJitterMode='manual';


            hObj.XJitter_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XJitterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XJitterMode(hObj)
            storedValue=hObj.XJitterMode;
        end

        function set.XJitterMode(hObj,newValue)

            oldValue=hObj.XJitterMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XJitterMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XJitter_I matlab.internal.datatype.matlab.graphics.chart.datatype.JitterMethodType='none';
    end

    methods
        function storedValue=get.XJitter_I(hObj)
            storedValue=hObj.XJitter_I;
        end

        function set.XJitter_I(hObj,newValue)



            hObj.XJitter_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YJitter matlab.internal.datatype.matlab.graphics.chart.datatype.JitterMethodType='none';
    end

    methods
        function valueToCaller=get.YJitter(hObj)


            valueToCaller=hObj.YJitter_I;

        end

        function set.YJitter(hObj,newValue)



            hObj.YJitterMode='manual';


            hObj.YJitter_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YJitterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YJitterMode(hObj)
            storedValue=hObj.YJitterMode;
        end

        function set.YJitterMode(hObj,newValue)

            oldValue=hObj.YJitterMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YJitterMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YJitter_I matlab.internal.datatype.matlab.graphics.chart.datatype.JitterMethodType='none';
    end

    methods
        function storedValue=get.YJitter_I(hObj)
            storedValue=hObj.YJitter_I;
        end

        function set.YJitter_I(hObj,newValue)



            hObj.YJitter_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ZJitter matlab.internal.datatype.matlab.graphics.chart.datatype.JitterMethodType='none';
    end

    methods
        function valueToCaller=get.ZJitter(hObj)


            valueToCaller=hObj.ZJitter_I;

        end

        function set.ZJitter(hObj,newValue)



            hObj.ZJitterMode='manual';


            hObj.ZJitter_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ZJitterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ZJitterMode(hObj)
            storedValue=hObj.ZJitterMode;
        end

        function set.ZJitterMode(hObj,newValue)

            oldValue=hObj.ZJitterMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ZJitterMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ZJitter_I matlab.internal.datatype.matlab.graphics.chart.datatype.JitterMethodType='none';
    end

    methods
        function storedValue=get.ZJitter_I(hObj)
            storedValue=hObj.ZJitter_I;
        end

        function set.ZJitter_I(hObj,newValue)



            hObj.ZJitter_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        XJitterWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=.9;
    end

    methods
        function valueToCaller=get.XJitterWidth(hObj)


            valueToCaller=hObj.XJitterWidth_I;

        end

        function set.XJitterWidth(hObj,newValue)



            hObj.XJitterWidthMode='manual';


            hObj.XJitterWidth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        XJitterWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XJitterWidthMode(hObj)
            storedValue=hObj.XJitterWidthMode;
        end

        function set.XJitterWidthMode(hObj,newValue)

            oldValue=hObj.XJitterWidthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XJitterWidthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        XJitterWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=.9;
    end

    methods
        function storedValue=get.XJitterWidth_I(hObj)
            storedValue=hObj.XJitterWidth_I;
        end

        function set.XJitterWidth_I(hObj,newValue)



            hObj.XJitterWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        YJitterWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=.9;
    end

    methods
        function valueToCaller=get.YJitterWidth(hObj)


            valueToCaller=hObj.YJitterWidth_I;

        end

        function set.YJitterWidth(hObj,newValue)



            hObj.YJitterWidthMode='manual';


            hObj.YJitterWidth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        YJitterWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.YJitterWidthMode(hObj)
            storedValue=hObj.YJitterWidthMode;
        end

        function set.YJitterWidthMode(hObj,newValue)

            oldValue=hObj.YJitterWidthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.YJitterWidthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        YJitterWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=.9;
    end

    methods
        function storedValue=get.YJitterWidth_I(hObj)
            storedValue=hObj.YJitterWidth_I;
        end

        function set.YJitterWidth_I(hObj,newValue)



            hObj.YJitterWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        ZJitterWidth matlab.internal.datatype.matlab.graphics.datatype.Positive=.9;
    end

    methods
        function valueToCaller=get.ZJitterWidth(hObj)


            valueToCaller=hObj.ZJitterWidth_I;

        end

        function set.ZJitterWidth(hObj,newValue)



            hObj.ZJitterWidthMode='manual';


            hObj.ZJitterWidth_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        ZJitterWidthMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.ZJitterWidthMode(hObj)
            storedValue=hObj.ZJitterWidthMode;
        end

        function set.ZJitterWidthMode(hObj,newValue)

            oldValue=hObj.ZJitterWidthMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.ZJitterWidthMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        ZJitterWidth_I matlab.internal.datatype.matlab.graphics.datatype.Positive=.9;
    end

    methods
        function storedValue=get.ZJitterWidth_I(hObj)
            storedValue=hObj.ZJitterWidth_I;
        end

        function set.ZJitterWidth_I(hObj,newValue)



            hObj.ZJitterWidth_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='private',GetAccess='private',Dependent=true,Hidden=true,Transient=true)

        XYZJitter matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=zeros(0,3);
    end

    methods
        function valueToCaller=get.XYZJitter(hObj)



            valueToCaller=hObj.getXYZJitterImpl(hObj.XYZJitter_I);


        end

        function set.XYZJitter(hObj,newValue)



            hObj.XYZJitterMode='manual';



            reallyDoCopy=~isequal(hObj.XYZJitter_I,newValue);

            if reallyDoCopy
                hObj.XYZJitter_I=hObj.setXYZJitterImpl(newValue);
            end

            hObj.MarkDirty('all');



        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        XYZJitterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.XYZJitterMode(hObj)
            storedValue=hObj.XYZJitterMode;
        end

        function set.XYZJitterMode(hObj,newValue)

            oldValue=hObj.XYZJitterMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.XYZJitterMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(SetObservable=false,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,NonCopyable=true,Transient=true,AffectsLegend)

        XYZJitter_I matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=zeros(0,3);
    end

    methods





    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='protected',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        XYZJittered matlab.internal.datatype.matlab.graphics.datatype.NumericMatrix=zeros(0,3);
    end

    methods
        function storedValue=get.XYZJittered(hObj)
            storedValue=hObj.XYZJittered;
        end

        function set.XYZJittered(hObj,newValue)



            hObj.XYZJittered=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='protected',GetAccess='protected',Dependent=true,Hidden=true,Transient=true)

        JitterDirty(1,1)logical=true;
    end

    methods
        function valueToCaller=get.JitterDirty(hObj)


            valueToCaller=hObj.JitterDirty_I;

        end

        function set.JitterDirty(hObj,newValue)



            hObj.JitterDirtyMode='manual';


            hObj.JitterDirty_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        JitterDirtyMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.JitterDirtyMode(hObj)
            storedValue=hObj.JitterDirtyMode;
        end

        function set.JitterDirtyMode(hObj,newValue)

            oldValue=hObj.JitterDirtyMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.JitterDirtyMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='protected',GetAccess='protected',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        JitterDirty_I(1,1)logical=true;
    end

    methods
        function storedValue=get.JitterDirty_I(hObj)
            storedValue=hObj.JitterDirty_I;
        end

        function set.JitterDirty_I(hObj,newValue)



            hObj.JitterDirty_I=newValue;

        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'MarkerHandle')
                b=true;
                return;
            end
            if strcmp(name,'MarkerHandleNaN')
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








    methods(Access='private')
        [x,y,z]=doJitter(hObj,x,y,z,us)
    end






    methods(Access='protected')
        [order,x,y,z,s,c]=getCleanData(hObj,order,x,y,z,s,c,stripnanc)
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
        function hObj=AbstractScatter(varargin)






            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker;

            set(hObj.MarkerHandle,'Description_I','AbstractScatter MarkerHandle');

            set(hObj.MarkerHandle,'Internal',true);

            hObj.MarkerHandleNaN=matlab.graphics.primitive.world.Marker;

            set(hObj.MarkerHandleNaN,'Description_I','AbstractScatter MarkerHandleNaN');

            set(hObj.MarkerHandleNaN,'Internal',true);

            hObj.SelectionHandle_I=matlab.graphics.interactor.ListOfPointsHighlight;

            set(hObj.SelectionHandle,'Description_I','AbstractScatter SelectionHandle');

            set(hObj.SelectionHandle,'Internal',true);



            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setMarkerHandleFanoutProps(hObj)

            try
                mode=hObj.MarkerHandle.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.MarkerHandle,'LineWidth_I',hObj.LineWidth_I);
            end


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
    methods(Access=private)
        function setMarkerHandleNaNFanoutProps(hObj)

            try
                mode=hObj.MarkerHandleNaN.LineWidthMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.MarkerHandleNaN,'LineWidth_I',hObj.LineWidth_I);
            end


            try
                mode=hObj.MarkerHandleNaN.ClippingMode;
            catch
                mode='auto';
            end
            if strcmp(mode,'auto')
                set(hObj.MarkerHandleNaN,'Clipping_I',hObj.Clipping_I);
            end

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


    methods(Access='protected',Hidden=true)
        function doSetup(hObj)

            error(message('MATLAB:class:abstractAttribute','AbstractScatter'))
        end
    end
    methods(Access='protected',Hidden=true)
        function dataPropertyValueChanged(hObj,channelName)

            if channelName(1)>='X'&&channelName(1)<='Z'
                hObj.JitterDirty_I=true;
            end
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=getXYZJitterImpl(hObj,storedValue)
    end
    methods(Access='public',Hidden=true)
        function varargout=mapSize(hObj,size,updateState)


            varargout{1}=size;
        end
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='private',Hidden=true)

        cacheLegendIconColors(hObj,updateState,cdata)
    end
    methods(Access='public',Hidden=true)

        varargout=getBrushPrimitivesForTesting(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=getColorAlphaDataExtents(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=getHints(hObj)
    end
    methods(Access='public',Hidden=true)

        varargout=getXYZDataExtents(hObj,transform,constraints)
    end
    methods(Access={?matlab.graphics.mixin.Legendable,?matlab.graphics.illustration.Legend,?matlab.unittest.TestCase},Hidden=true)

        updateDisplayNameBasedOnLabelHints(hObj,channelNamesStruct)
    end
    methods(Access='public',Hidden=true)

        varargout=getLegendGraphic(hObj)
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetDataDescriptors(hObj,index,~)



            primpos=hObj.getReportedPosition(index,0);
            location=primpos.getLocation(hObj);

            dnames=hObj.DimensionNames;

            zloc=[];
            if length(location)>2
                zloc=location(3);
            end
            [xloc,yloc,zloc]=matlab.graphics.internal.makeNonNumeric(hObj,location(1),location(2),zloc);


            xVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dnames{1},xloc);
            yVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dnames{2},yloc);
            zVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;
            if~primpos.Is2D
                zVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dnames{3},zloc);
            end

            varargout{1}=[xVal,yVal,zVal];
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetNearestIndex(hObj,index)



            numPoints=numel(hObj.XData_I);


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


            numPoints=numel(hObj.XDataCache);

            if~isempty(index)&&index>0&&index<=numPoints
                zVal=0;
                zData=hObj.ZDataCache;
                if~isempty(zData)
                    zVal=hObj.ZDataCache(index);
                end
                pt=[double(hObj.XDataCache(index)),double(hObj.YDataCache(index)),double(zVal)];
            else
                pt=[NaN,NaN,NaN];
            end
            pt=matlab.graphics.shape.internal.util.SimplePoint(pt);

            if isempty(hObj.ZData)
                pt.Is2D=true;
            end
            varargout{1}=pt;
        end
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
                hObj.BrushHandles=matlab.graphics.chart.primitive.internal.abstractscatter.ScatterBrushing;
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
    methods(Access='protected',Hidden=true)
        function varargout=getPropertyGroups(hObj)

            dnames=hObj.DimensionNames;
            suffix={'Data','Variable'};
            dnames{1}=sprintf('%s%s',dnames{1},suffix{1+hObj.isDataComingFromDataSource('X')});
            dnames{2}=sprintf('%s%s',dnames{2},suffix{1+hObj.isDataComingFromDataSource('Y')});
            dnames{3}=sprintf('%s%s',dnames{3},suffix{1+hObj.isDataComingFromDataSource('Z')});

            if hObj.isDataComingFromDataSource('Size')
                dnames{4}='SizeVariable';
            else
                dnames{4}='SizeData';
            end

            if hObj.isDataComingFromDataSource('Color')
                dnames{5}='ColorVariable';
            else
                dnames{5}='CData';
            end


            if~isempty(hObj.YData)&&isempty(hObj.ZData)...
                &&~hObj.isDataComingFromDataSource('Z')
                dnames(3)=[];
            end

            varargout{1}=matlab.mixin.util.PropertyGroup(...
            ['Marker','MarkerEdgeColor','MarkerFaceColor'...
            ,'LineWidth',dnames]);
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
    methods(Access='public',Static=true,Hidden=true)
        function varargout=doloadobj(hObj)


            matlab.graphics.chart.internal.deleteNonPrimitiveChildren(hObj);





            if hObj.SeriesIndex==0
                hObj.SeriesIndexMode='manual';
            end
            varargout{1}=hObj;
        end
    end
    methods(Access='public',Static=true,Hidden=true)

        varargout=getRenamableProperties()
    end
    methods(Access='protected',Hidden=true)
        function varargout=prepareDataToSave(hObj)

            varargout{1}=prepareDataToSave@matlab.graphics.mixin.DataProperties(hObj);



            if isfield(varargout{1},'DataPropertyValues')
                varargout{1}=rmfield(varargout{1},'DataPropertyValues');
            end
        end
    end
    methods(Access='protected',Static=true,Hidden=true)

        varargout=validateDataPropertyValue(channelName,data)
    end




end
