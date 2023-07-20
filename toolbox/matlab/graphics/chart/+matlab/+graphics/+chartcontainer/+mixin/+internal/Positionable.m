classdef(Hidden)Positionable<matlab.graphics.chartcontainer.mixin.Mixin&...
    matlab.graphics.chartcontainer.mixin.internal.OuterPositionChangedEventMixin




    properties(Dependent,AffectsObject,Resettable=false,AbortSet)
        Units matlab.internal.datatype.matlab.graphics.datatype.Units=get(groot,'FactoryAxesUnits')
    end

    properties(Dependent,AffectsObject,Resettable=false)
        OuterPosition matlab.internal.datatype.matlab.graphics.datatype.Position=get(groot,'FactoryAxesOuterPosition')
        InnerPosition matlab.internal.datatype.matlab.graphics.datatype.Position=get(groot,'FactoryAxesInnerPosition')
        Position matlab.internal.datatype.matlab.graphics.datatype.Position=get(groot,'FactoryAxesInnerPosition')
    end

    properties(Dependent,AffectsObject,Resettable=false,AbortSet,NeverAmbiguous)
        PositionConstraint matlab.internal.datatype.matlab.graphics.datatype.PositionConstraint='outerposition';
    end

    properties(Dependent,AffectsObject,Resettable=false,AbortSet,Hidden)
        ActivePositionProperty matlab.graphics.chart.datatype.ChartActivePositionType='outerposition';
    end

    properties(Dependent,AffectsObject,SetAccess=private,Hidden)
        OuterPosition_I matlab.internal.datatype.matlab.graphics.datatype.Position
        InnerPosition_I matlab.internal.datatype.matlab.graphics.datatype.Position
        TightInset matlab.internal.datatype.matlab.graphics.datatype.Inset
        LooseInset matlab.internal.datatype.matlab.graphics.datatype.Inset
    end

    properties(Transient,NonCopyable,Access=private,Resettable=false,AbortSet)
        PositionConstraint_I matlab.internal.datatype.matlab.graphics.datatype.PositionConstraint='outerposition';
    end

    properties(Transient,NonCopyable,Access=private,Resettable=false)
        OuterUnitPosition matlab.graphics.general.UnitPosition=matlab.graphics.general.UnitPosition
        InnerUnitPosition matlab.graphics.general.UnitPosition=matlab.graphics.general.UnitPosition
        LooseInsetUnitPosition matlab.graphics.general.UnitPosition=initializeDefaultLooseInset()
        HaveReferenceData(1,1)logical=false
        UnitConversionWithoutReferenceData='';
        CanvasMarkedCleanListener event.listener=event.listener.empty;
    end

    properties(Access=protected)


PositionStorage
    end

    methods
        function obj=Positionable()

            assert(isa(obj,'matlab.graphics.Graphics'));
        end
    end

    methods(Hidden)
        function pos=getOuterPositionInUnits(obj,units)



            obj.updateReferenceData();


            pos=getOuterPositionInUnitsInternal(obj,units);
        end

        function pos=getInnerPositionInUnits(obj,units)



            obj.updateReferenceData();


            pos=getInnerPositionInUnitsInternal(obj,units);
        end

        function inset=getLooseInsetInUnits(obj,units)



            obj.updateReferenceData();


            inset=getLooseInsetInUnitsInternal(obj,units);
        end

        function inset=getTightInsetInUnits(obj,units)



            obj.updateReferenceData();


            inset=getTightInsetInUnitsInternal(obj,units);
        end
    end

    methods(Access=protected)

        function postSetUnits(~)
        end
    end

    methods(Abstract,Access=protected)






        [pos,units]=getTightInset(obj)


        postSetOuterPosition(obj)


        postSetInnerPosition(obj)



        forceUpdate(obj,msg)

        val=getPositionManager(obj);
    end

    methods(Access=private)
        function pos=getOuterPositionInUnitsInternal(obj,units)




            app=obj.PositionConstraint;
            if strcmp(app,'innerposition')



                updateOuterPositionFromInnerPosition(obj)
            end


            pos=getOuterPositionInUnitsFromCache(obj,units);
        end

        function pos=getOuterPositionInUnitsFromCache(obj,units)




            unitPos=obj.OuterUnitPosition;
            unitPos.Units=units;
            pos=unitPos.Position;
        end

        function updateOuterPositionFromInnerPosition(obj)





            units=obj.InnerUnitPosition.Units;
            innerPos=obj.InnerUnitPosition.Position;


            looseInset=getLooseInsetInUnitsInternal(obj,units);





            if strcmp(units,'normalized')
                scale=innerPos(3:4)./(1-looseInset(3:4)-looseInset(1:2));
                looseInset=looseInset.*scale([1,2,1,2]);
            end


            tightInset=getTightInsetInUnitsInternal(obj,units);


            inset=max(tightInset,looseInset);


            pos=innerPos+[-inset(1:2),inset(1:2)+inset(3:4)];


            obj.OuterUnitPosition.Units=units;
            obj.OuterUnitPosition.Position=pos;
        end

        function pos=getInnerPositionInUnitsInternal(obj,units)




            app=obj.PositionConstraint;
            if strcmp(app,'outerposition')



                updateInnerPositionFromOuterPosition(obj)
            end


            pos=getInnerPositionInUnitsFromCache(obj,units);
        end

        function pos=getInnerPositionInUnitsFromCache(obj,units)




            unitPos=obj.InnerUnitPosition;
            unitPos.Units=units;
            pos=unitPos.Position;
        end

        function updateInnerPositionFromOuterPosition(obj)





            units=obj.OuterUnitPosition.Units;
            outerPos=obj.OuterUnitPosition.Position;


            looseInset=getLooseInsetInUnitsInternal(obj,units);




            if strcmp(units,'normalized')
                looseInset=looseInset.*outerPos([3,4,3,4]);
            end



            if looseInset(1)+looseInset(3)>outerPos(3)
                looseInset([1,3])=0;
            end
            if looseInset(2)+looseInset(4)>outerPos(4)
                looseInset([2,4])=0;
            end


            tightInset=getTightInsetInUnitsInternal(obj,units);



            if tightInset(1)+tightInset(3)>outerPos(3)
                tightInset([1,3])=0;
            end
            if tightInset(2)+tightInset(4)>outerPos(4)
                tightInset([2,4])=0;
            end


            inset=max(tightInset,looseInset);



            if inset(1)+inset(3)>outerPos(3)
                inset([1,3])=0;
            end
            if inset(2)+inset(4)>outerPos(4)
                inset([2,4])=0;
            end


            pos=outerPos+[inset(1:2),-(inset(1:2)+inset(3:4))];


            obj.InnerUnitPosition.Units=units;
            obj.InnerUnitPosition.Position=pos;
        end

        function inset=getLooseInsetInUnitsInternal(obj,units)




            insetStorage=obj.LooseInsetUnitPosition;
            inset=insetStorage.Position;
            fromUnits=insetStorage.Units;


            if endsWith(fromUnits,'pixels')




                inset=inset-[1,1,0,0];
            end


            if~strcmp(units,fromUnits)
                if strcmp(units,'normalized')




                    outerPos=getOuterPositionInUnitsInternal(obj,fromUnits);



                    inset=inset./outerPos([3,4,3,4]);
                elseif strcmp(fromUnits,'normalized')






                    outerPos=getOuterPositionInUnitsInternal(obj,units);




                    inset=inset.*outerPos([3,4,3,4]);
                else


                    insetStorage.Units=units;
                    inset=insetStorage.Position;


                    if endsWith(units,'pixels')




                        inset=inset-[1,1,0,0];
                    end
                end
            end
        end

        function inset=getTightInsetInUnitsInternal(obj,units)





            if obj.HaveReferenceData

                [inset,calcUnits]=getTightInset(obj);
            else
                inset=[0,0,0,0];
                calcUnits=units;
            end


            if~strcmp(calcUnits,units)

                if endsWith(calcUnits,'pixels')




                    inset=inset+[1,1,0,0];
                end


                unitPos=obj.OuterUnitPosition;
                unitPos.Units=calcUnits;
                unitPos.Position=inset;
                unitPos.Units=units;
                inset=unitPos.Position;


                if endsWith(units,'pixels')




                    inset=inset-[1,1,0,0];
                end
            end
        end

        function updateReferenceData(obj)



            cv=ancestor(obj,'matlab.graphics.primitive.canvas.Canvas','node');

            if isscalar(cv)
                updateReferenceDataFromCanvas(obj,cv);
            end
        end

        function updateReferenceDataFromCanvas(obj,cv)
            if isvalid(obj)&&any(cv.ReferenceViewport>0)

                characterSize=cv.getCharacterSize();
                referenceData=struct(...
                'ScreenResolution',cv.ScreenPixelsPerInch,...
                'RefFrame',cv.ReferenceViewport,...
                'CharacterWidth',characterSize(1),...
                'CharacterHeight',characterSize(2));


                obj.OuterUnitPosition=updateUnitPositionReferenceData(...
                obj.OuterUnitPosition,referenceData);


                obj.InnerUnitPosition=updateUnitPositionReferenceData(...
                obj.InnerUnitPosition,referenceData);


                obj.LooseInsetUnitPosition=updateUnitPositionReferenceData(...
                obj.LooseInsetUnitPosition,referenceData);



                obj.HaveReferenceData=true;
                obj.CanvasMarkedCleanListener=event.listener.empty();



                updateUnits(obj)
            elseif isempty(obj.CanvasMarkedCleanListener)
                obj.CanvasMarkedCleanListener=event.listener(cv,...
                'MarkedClean',@(~,~)updateReferenceDataFromCanvas(obj,cv));
            end
        end

        function updateUnits(obj)
            toUnits=obj.UnitConversionWithoutReferenceData;
            obj.UnitConversionWithoutReferenceData='';
            if~isempty(toUnits)

                fromUnits=obj.OuterUnitPosition.Units;





                if xor(strcmp(fromUnits,'normalized'),strcmp(toUnits,'normalized'))

                    pos=getOuterPositionInUnitsInternal(obj,'devicepixels');
                    obj.LooseInsetUnitPosition.RefFrame=pos;
                end


                obj.OuterUnitPosition.Units=toUnits;
                obj.InnerUnitPosition.Units=toUnits;
                obj.LooseInsetUnitPosition.Units=toUnits;


                postSetUnits(obj)
            end
        end
    end

    methods
        function units=get.Units(obj)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                units=posManager.Units;
            else

                if~isempty(obj.UnitConversionWithoutReferenceData)
                    obj.updateReferenceData();
                end


                if strcmp(obj.PositionConstraint,'outerposition')
                    units=obj.OuterUnitPosition.Units;
                else
                    units=obj.InnerUnitPosition.Units;
                end
            end
        end

        function set.Units(obj,units)

            posManager=getPositionManager(obj);
            if~isempty(posManager)
                posManager.Units=units;
            else

                obj.updateReferenceData();


                obj.UnitConversionWithoutReferenceData=units;




                if obj.HaveReferenceData
                    updateUnits(obj)
                end
            end
        end

        function pos=get.OuterPosition(obj)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                pos=posManager.OuterPosition;
            else

                if~isempty(obj.UnitConversionWithoutReferenceData)
                    obj.updateReferenceData();
                end

                if strcmp(obj.PositionConstraint,'outerposition')

                    pos=obj.OuterUnitPosition.Position;
                else


                    forceUpdate(obj,'OuterPosition');
                    pos=getOuterPositionInUnits(obj,obj.OuterUnitPosition.Units);
                end
            end

            if~isempty(obj.Parent)
                if obj.isInLayout()
                    pos=obj.getRelativePosition(obj.Parent,pos,obj.Units);
                end
            end
        end

        function pos=get.OuterPosition_I(obj)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                pos=posManager.OuterPosition_I;
            else

                pos=obj.OuterUnitPosition.Position;
            end
        end

        function set.OuterPosition(obj,pos)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                posManager.OuterPosition=pos;
            else

                updateUnits(obj)


                obj.OuterUnitPosition.Position=pos;
                obj.PositionConstraint_I='outerposition';


                postSetOuterPosition(obj)
            end
            firePostSetOuterPositionEvent(obj,pos);
        end

        function pos=get.InnerPosition(obj)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                pos=posManager.InnerPosition;
            else

                if~isempty(obj.UnitConversionWithoutReferenceData)
                    obj.updateReferenceData();
                end

                if strcmp(obj.PositionConstraint,'innerposition')

                    pos=obj.InnerUnitPosition.Position;
                else


                    forceUpdate(obj,'InnerPosition');
                    pos=getInnerPositionInUnits(obj,obj.InnerUnitPosition.Units);
                end
            end

            if~isempty(obj.Parent)&&obj.isInLayout()
                pos=obj.getRelativePosition(obj.Parent,pos,obj.Units);
            end
        end

        function pos=get.InnerPosition_I(obj)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                pos=posManager.InnerPosition_I;
            else

                pos=obj.InnerUnitPosition.Position;
            end
        end

        function setAbsoluteGraphicsLayoutPosition(hObj,pos)
            posManager=getPositionManager(hObj);
            if~isempty(posManager)
                posManager.InnerPosition=pos;
            else

                updateUnits(hObj)


                hObj.InnerUnitPosition.Position=pos;
                hObj.PositionConstraint_I='innerposition';


                postSetInnerPosition(hObj)
            end
        end

        function set.InnerPosition(obj,pos)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                posManager.InnerPosition=pos;
            else

                updateUnits(obj)


                obj.InnerUnitPosition.Position=pos;
                obj.PositionConstraint_I='innerposition';


                postSetInnerPosition(obj)
            end
            firePostSetOuterPositionEvent(obj,obj.OuterPosition);
        end

        function pos=get.Position(obj)

            pos=obj.InnerPosition;
        end

        function set.Position(obj,pos)

            obj.InnerPosition=pos;
        end

        function inset=get.TightInset(obj)
            inset=getTightInsetInUnits(obj,obj.Units);
        end

        function inset=get.LooseInset(obj)


            if~isempty(obj.UnitConversionWithoutReferenceData)
                forceUpdate(obj,'OuterPosition');
            end

            inset=getLooseInsetInUnits(obj,obj.Units);
        end

        function set.PositionConstraint(obj,pc)


            posManager=getPositionManager(obj);
            if~isempty(posManager)
                posManager.PositionConstraint=pc;
            else

                obj.updateReferenceData();




                if strcmp(pc,'outerposition')

                    updateOuterPositionFromInnerPosition(obj);
                else

                    updateInnerPositionFromOuterPosition(obj)
                end

                obj.PositionConstraint_I=pc;
            end
        end

        function set.PositionConstraint_I(obj,pc)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                posManager.PositionConstraint_I=pc;
            else
                obj.PositionConstraint_I=pc;
            end
        end

        function pc=get.PositionConstraint(obj)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                pc=posManager.PositionConstraint;
            else
                pc=obj.PositionConstraint_I;
            end
        end

        function pc=get.PositionConstraint_I(obj)
            posManager=getPositionManager(obj);
            if~isempty(posManager)
                pc=posManager.PositionConstraint_I;
            else
                pc=obj.PositionConstraint_I;
            end
        end

        function set.ActivePositionProperty(obj,app)



            obj.PositionConstraint=char(app);
        end

        function app=get.ActivePositionProperty(obj)
            app=matlab.graphics.chart.datatype.ChartActivePositionType(obj.PositionConstraint);
        end

        function set.PositionStorage(obj,data)



            setPositionStorageImpl(obj,data);
        end

        function data=get.PositionStorage(obj)



            data=getPositionStorageImpl(obj);
        end
    end


    methods(Access=protected)

        function setPositionStorageImpl(obj,data)






            expFields={'Units','OuterPosition','InnerPosition'};
            expPositionConstraintFields={'PositionConstraint','ActivePositionProperty'};
            if~all(isfield(data,expFields))||~any(isfield(data,expPositionConstraintFields))
                return
            end

            posManager=getPositionManager(obj);
            if~isempty(posManager)
                posManager.Units=data.Units;
                if strcmpi(data.PositionConstraint,'outerposition')
                    posManager.OuterPosition=data.OuterPosition;
                else
                    posManager.InnerPosition=data.InnerPosition;
                end
            else




                obj.OuterUnitPosition.Units=data.Units;
                obj.InnerUnitPosition.Units=data.Units;
                obj.LooseInsetUnitPosition.Units=data.Units;






                if~isfield(data,'PositionConstraint')
                    if strcmpi(data.ActivePositionProperty,'outerposition')
                        data.PositionConstraint='outerposition';
                    else
                        data.PositionConstraint='innerposition';
                    end
                end




                if strcmpi(data.PositionConstraint,'outerposition')
                    obj.OuterUnitPosition.Position=data.OuterPosition;
                    obj.PositionConstraint_I='outerposition';
                else
                    obj.InnerUnitPosition.Position=data.InnerPosition;
                    obj.PositionConstraint_I='innerposition';
                end


                if isfield(data,'LooseInset')

                    inset=data.LooseInset;

                    if endsWith(data.Units,'pixels')




                        inset=inset+[1,1,0,0];
                    end


                    obj.LooseInsetUnitPosition.Position=inset;
                end
            end


            postSetUnits(obj)


            if strcmpi(data.PositionConstraint,'outerposition')
                postSetOuterPosition(obj)
            else
                postSetInnerPosition(obj)
            end
        end

        function data=getPositionStorageImpl(obj)





            data.Units=obj.Units;
            data.ActivePositionProperty=char(obj.ActivePositionProperty);
            data.PositionConstraint=obj.PositionConstraint;
            data.OuterPosition=obj.OuterPosition;
            data.InnerPosition=obj.InnerPosition;
            data.LooseInset=obj.LooseInset;
            data.Version=version;
        end
    end
end

function looseInsetUnitPosition=initializeDefaultLooseInset()

    looseInsetUnitPosition=matlab.graphics.general.UnitPosition;
    looseInsetUnitPosition.Units=get(groot,'FactoryAxesUnits');
    looseInsetUnitPosition.Position=get(groot,'FactoryAxesLooseInset');

end

function unitPos=updateUnitPositionReferenceData(unitPos,newRefData)



    unitPos.ScreenResolution=newRefData.ScreenResolution;
    unitPos.RefFrame=newRefData.RefFrame;
    unitPos.CharacterWidth=newRefData.CharacterWidth;
    unitPos.CharacterHeight=newRefData.CharacterHeight;

end
