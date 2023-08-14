
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,Sealed)Surface<matlab.graphics.chart.mixin.SurfaceBrushable&matlab.graphics.chart.interaction.DataAnnotatable





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


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

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


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
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



    methods
        function hObj=Surface(varargin)








            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end



    methods(Access='private',Hidden=true)
        function doSetup(hObj)
            addlistener(hObj,{'ZData','ZData_I'},'PostSet',@localZDataChanged);
            addlistener(hObj,'XDataMode','PostSet',@localXDataModeChanged);
            addlistener(hObj,'YDataMode','PostSet',@localYDataModeChanged);
            addlistener(hObj,'CDataMode','PostSet',@localCDataModeChanged);


            addlistener(hObj,{'XData','YData','ZData'},'PostSet',@(obj,evd)(hObj.sendDataChangedEvent));


            function localZDataChanged(src,evd)%#ok<INUSD>


                zData=hObj.ZData;
                if~isnumeric(zData)

                    p=hObj.Parent;
                    if isgraphics(p)
                        zData=hObj.ZDataCache;
                    end
                end
                if strcmpi(hObj.XDataMode,'auto')
                    hObj.XData_I=1:size(zData,2);
                end
                if strcmpi(hObj.YDataMode,'auto')
                    hObj.YData_I=(1:size(zData,1)).';
                end
                if strcmpi(hObj.CDataMode,'auto')&&isnumeric(zData)
                    hObj.CData_I=zData;
                end
            end


            function localXDataModeChanged(src,evd)%#ok<INUSD>
                if strcmpi(hObj.XDataMode,'auto')
                    hObj.XData_I=1:size(hObj.ZData,2);
                end
            end


            function localYDataModeChanged(src,evd)%#ok<INUSD>
                if strcmpi(hObj.YDataMode,'auto')
                    hObj.YData_I=(1:size(hObj.ZData,1)).';
                end
            end


            function localCDataModeChanged(src,evd)%#ok<INUSD>
                if strcmpi(hObj.CDataMode,'auto')
                    hObj.CData_I=hObj.ZDataCache;
                end
            end
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetDataDescriptors(hObj,index,interpolationFactor)

            varargout{1}=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getDataDescriptors(hObj,index,interpolationFactor);
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetNearestIndex(hObj,index)

            varargout{1}=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getNearestIndex(hObj,index);
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetNearestPoint(hObj,position)

            varargout{1}=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getNearestPoint(hObj,position);
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetEnclosedPoints(hObj,polygon)

            varargout{1}=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getEnclosedPoints(hObj,polygon);
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetDisplayAnchorPoint(hObj,index,interpolationFactor)

            varargout{1}=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getDisplayAnchorPoint(hObj,index,interpolationFactor);
        end
    end
    methods(Access='protected',Hidden=true)
        function varargout=doGetReportedPosition(hObj,index,interpolationFactor)

            varargout{1}=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getReportedPosition(hObj,index,interpolationFactor);
        end
    end
    methods(Access='protected',Hidden=true)

        varargout=getPropertyGroups(hObj)
    end
    methods(Access='protected',Hidden=true)

        varargout=getDescriptiveLabelForDisplay(hObj)
    end
    methods(Access='public',Hidden=true)

        mcodeConstructor(hObj,hCode)
    end




end
