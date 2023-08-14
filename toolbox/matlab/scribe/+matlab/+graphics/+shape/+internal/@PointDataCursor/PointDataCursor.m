classdef PointDataCursor<matlab.mixin.Copyable&...
    matlab.graphics.mixin.internal.GraphicsDataTypeContainer









    properties(Access=public,Dependent,AbortSet)


        DataSource;





        DataIndex;



        Interpolate matlab.internal.datatype.matlab.graphics.datatype.on_off;


        InterpolationFactor;




        Position;
    end

    properties(SetAccess=private,GetAccess=public,Hidden,Dependent)


        Target;
    end

    properties(Access=private)

        DataSourceStorage=[]
        DataIndexStorage=1;
        InterpolationFactorStorage=0;
        InterpolateStorage='off';
    end

    properties(Access=private,Transient)




        DataSourceDataChangedListener=event.listener.empty;


        DataSourceDestroyedListener=event.listener.empty;
    end


    events(ListenAccess=public,NotifyAccess=private)
CursorUpdated
CursorDataSourceChanged
    end


    methods
        function hObj=PointDataCursor(hDataSource)









            narginchk(0,1);

            if nargin

                hObj.DataSource=hDataSource;
            end
        end

        function set.DataSource(hObj,newValue)


            validateDataSource(newValue);



            if isempty(newValue)||isempty(hObj.DataSourceStorage)...
                ||newValue~=hObj.DataSourceStorage


                pos=hObj.Position;


                hObj.DataSourceStorage=newValue;


                if~isempty(newValue)...
                    &&~isempty(newValue.getAnnotationTarget)...
                    &&ishghandle(newValue.getAnnotationTarget)...
                    &&~isempty(hggetbehavior(newValue.getAnnotationTarget,'DataCursor','-peek'))




                    hObj.findDataPoint(pos);
                else

                    hObj.findLocation(hObj.DataIndexStorage,hObj.InterpolationFactorStorage);
                end
                notify(hObj,'CursorDataSourceChanged');
            end
        end

        function value=get.DataSource(hObj)
            value=hObj.DataSourceStorage;
        end


        function set.DataSourceStorage(hObj,newValue)
            hObj.DataSourceStorage=newValue;



            if~isempty(newValue)
                hObj.DataSourceDataChangedListener=event.listener(newValue,'DataChanged',@hObj.sourceUpdatedCallback);%#ok<MCSUP>
                hObj.DataSourceDestroyedListener=event.listener(newValue,'ObjectBeingDestroyed',@hObj.sourceDeletedCallback);%#ok<MCSUP>
            else
                hObj.DataSourceDataChangedListener=event.listener.empty;%#ok<MCSUP>
                hObj.DataSourceDestroyedListener=event.listener.empty;%#ok<MCSUP>
            end
        end


        function set.DataIndex(hObj,newValue)

            hObj.DataIndexStorage=hObj.DataSourceStorage.getNearestIndex(newValue);


            notify(hObj,'CursorUpdated');
        end

        function value=get.DataIndex(hObj)
            value=hObj.DataIndexStorage;
        end


        function set.InterpolationFactor(hObj,newValue)


            if strcmpi(hObj.InterpolateStorage,'off')
                hObj.InterpolationFactorStorage=0;
            else
                hObj.InterpolationFactorStorage=newValue;
            end


            notify(hObj,'CursorUpdated');
        end

        function value=get.InterpolationFactor(hObj)
            value=hObj.InterpolationFactorStorage;
        end


        function set.Interpolate(hObj,newValue)
            hObj.InterpolateStorage=newValue;
            if strcmp(newValue,'off')

                factor=hObj.InterpolationFactorStorage;
                index=hObj.DataIndexStorage;
                if isnumeric(factor)&&isscalar(factor)
                    if factor==0


                    elseif factor>0.5





                        hObj.setLocation(index+1,0);
                    else
                        hObj.setLocation(index,0);
                    end
                else

                    hObj.setLocation(index,0);
                end
            end
        end

        function value=get.Interpolate(hObj)
            value=hObj.InterpolateStorage;
        end


        function set.Position(hObj,newValue)
            hObj.findDataPoint(newValue);
        end

        function valueToCaller=get.Position(hObj)


            if~isempty(hObj.DataSourceStorage)
                primPt=getAnchorPosition(hObj);
                valueToCaller=primPt.getLocation(hObj.DataSourceStorage.getAnnotationTarget());
            else
                valueToCaller=[NaN,NaN,NaN];
            end
        end


        function valueToCaller=get.Target(hObj)

            if~isempty(hObj.DataSourceStorage)
                primPt=hObj.getReportedPosition();
                valueToCaller=primPt.getLocation(hObj.DataSourceStorage.getAnnotationTarget());
            else
                valueToCaller=[NaN,NaN,NaN];
            end
        end
    end


    methods(Access=public)
        function output=getDataDescriptors(hObj)





            if~isempty(hObj.DataSourceStorage)
                output=matlab.graphics.datatip.internal.DataTipTemplateHelper.generateContent...
                (hObj.DataSourceStorage,hObj.DataIndexStorage,hObj.InterpolationFactorStorage);
            else
                output=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;
            end
        end

        function output=getReportedPosition(hObj)







            if~isempty(hObj.DataSourceStorage)
                output=hObj.DataSourceStorage.getReportedPosition(hObj.DataIndexStorage,hObj.InterpolationFactorStorage);
            else
                output=matlab.graphics.shape.internal.util.SimplePoint([NaN,NaN,NaN]);
            end
        end

        function output=getAnchorPosition(hObj)






            if~isempty(hObj.DataSourceStorage)
                output=hObj.DataSourceStorage.getDisplayAnchorPoint(hObj.DataIndexStorage,hObj.InterpolationFactorStorage);
            else
                output=matlab.graphics.shape.internal.util.SimplePoint([NaN,NaN,NaN]);
            end
        end

        function increment(hObj,varargin)







            if~isempty(hObj.DataSourceStorage)
                [newIndex,newInterpolationFactor]=hObj.DataSourceStorage.incrementIndex(hObj.DataIndexStorage,varargin{:});
                hObj.setLocation(newIndex,newInterpolationFactor);
            end
        end

        function moveTo(hObj,pixel)








            if~isempty(hObj.DataSourceStorage)



                pixel=pixel+0.5;

                if strcmpi(hObj.InterpolateStorage,'off')
                    newIndex=hObj.DataSourceStorage.getNearestPoint(pixel);
                    newInterpolationFactor=0;
                else
                    [newIndex,newInterpolationFactor]=hObj.DataSourceStorage.getInterpolatedPoint(pixel);
                end
                hObj.setLocation(newIndex,newInterpolationFactor);
            end
        end

        function moveToIndex(hObj,index,interpolationFactor)
            if~isempty(hObj.DataSourceStorage)
                if strcmpi(hObj.InterpolateStorage,'off')||nargin<=2
                    interpolationFactor=0;
                end
                hObj.setLocation(index,interpolationFactor);
            end

        end
    end

    methods(Hidden)

        function handleUIEvent(hObj,source,varargin)




            switch(source)
            case 'mouse'
                narginchk(3,3);
                hObj.moveTo(varargin{1});
            otherwise
                error(message('MATLAB:graphics:pointdatacursor:InvalidEventSource'));
            end
        end
    end


    methods(Access=?matlab.graphics.datatip.DataTip)
        function setLocation(hObj,index,interp)






            if isempty(index)||index<=0
                index=1;
            end

            isChanged=hObj.DataIndexStorage~=index...
            ||~isequal(hObj.InterpolationFactorStorage,interp);

            if isChanged
                hObj.DataIndexStorage=index;
                hObj.InterpolationFactorStorage=interp;
                notify(hObj,'CursorUpdated');
            end
        end

        function findLocation(hObj,index,interp)





            if~isempty(hObj.DataSourceStorage)




                index=hObj.DataSourceStorage.getNearestIndex(index);
                interp=0;
                hObj.setLocation(index,interp);
            end
        end

        function findDataPoint(hObj,point)






            if~isempty(hObj.DataSourceStorage)

                hTarget=hObj.DataSourceStorage.getAnnotationTarget();
                pixPoint=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hTarget,point.');




                offSet=brushing.select.translateToContainer(hObj,[0,0]);
                pixPoint=pixPoint.'-offSet;




                hObj.moveTo(pixPoint-0.5);
            end
        end

        function sourceDeletedCallback(hObj,~,~)
            if isvalid(hObj)
                delete(hObj);
            end
        end

        function sourceUpdatedCallback(hObj,~,~)

            hObj.DataIndexStorage=hObj.DataSourceStorage.getNearestIndex(hObj.DataIndexStorage);

            notify(hObj,'CursorUpdated');
        end
    end
end

function validateDataSource(val)


    if~isempty(val)&&(~isscalar(val)||~isvalid(val)||~isa(val,'matlab.graphics.chart.interaction.DataAnnotatable'))
        me=MException(message('MATLAB:graphics:pointdatacursor:InvalidDataSource'));
        me.throwAsCaller();
    end
end