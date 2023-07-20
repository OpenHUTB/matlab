





classdef(Abstract,Hidden,AllowedSubclasses={...
    ?matlab.graphics.chart.internal.ChartBaseProxy}...
    )PositionableChartWithAxes<...
    matlab.graphics.chart.ChartGroup&...
    matlab.graphics.chartcontainer.mixin.internal.Positionable&...
    matlab.graphics.internal.Layoutable&...
    matlab.graphics.mixin.ChartLayoutable

    properties(Dependent,Hidden)




        ChartDecorationInset matlab.internal.datatype.matlab.graphics.datatype.Inset=[0,0,0,0]
    end

    properties(Hidden)
        ChartDecorationInset_I matlab.internal.datatype.matlab.graphics.datatype.Inset=[0,0,0,0]







        MaxInsetForSubplotCell matlab.internal.datatype.matlab.graphics.datatype.Inset=[0,0,0,0]



        SubplotCellOuterPosition matlab.internal.datatype.matlab.graphics.datatype.Position=[0,0,0,0]

        ResponsiveArea_I matlab.internal.datatype.matlab.graphics.datatype.Point2d=[1.0,1.0]
    end

    properties(Dependent,AffectsObject,SetObservable,Hidden)


        Position_I matlab.internal.datatype.matlab.graphics.datatype.Position
    end




    methods(Abstract,Hidden,Access={?ChartUnitTestFriend,?matlab.graphics.chart.Chart,...
        ?matlab.graphics.mixin.Mixin})
        hAx=getAxes(hObj)
    end

    methods(Hidden)
        function mcodeConstructor(hObj,code)



            ignoreProperty(code,'Parent');
            parentArg=codegen.codeargument('Name','parent','Value',hObj.Parent,...
            'IsParameter',true,'Comment','Parent');
            addConstructorArgin(code,parentArg);



            parent=hObj.Parent;
            subplotGrid=cell(0);
            numPeers=0;
            if isscalar(parent)&&isvalid(parent)

                numPeers=sum(parent.Children~=hObj);


                slm=getappdata(parent,'SubplotListenersManager');
                if~isempty(slm)&&slm.isManaged(hObj)
                    subplotGrid=getappdata(hObj,'SubplotGridLocation');
                end
            end


            if numel(subplotGrid)==3




                rowArg=codegen.codeargument('Value',subplotGrid{1});
                colArg=codegen.codeargument('Value',subplotGrid{2});
                indArg=codegen.codeargument('Value',subplotGrid{3});



                subplotCode=codegen.codeblock();
                subplotCode.setConstructorName('subplot');
                subplotCode.addConstructorArgin(rowArg);
                subplotCode.addConstructorArgin(colArg);
                subplotCode.addConstructorArgin(indArg);
                subplotCode.addConstructorArgin(codegen.codeargument('Value','Parent'));
                subplotCode.addConstructorArgin(parentArg);


                code.addPreConstructorFunction(subplotCode);


                ignoreProperty(code,'InnerPosition');
                ignoreProperty(code,'OuterPosition');
            elseif strcmpi(hObj.PositionConstraint,'OuterPosition')
                ignoreProperty(code,'InnerPosition');
                if numPeers~=0




                    addProperty(code,'OuterPosition');
                end
            else
                ignoreProperty(code,'OuterPosition');
            end


            ignoreProperty(code,'Position');
            ignoreProperty(code,'PositionConstraint');



            movePropertyBefore(code,'Units',{'InnerPosition','OuterPosition'});
        end
    end


    methods
        function set.ChartDecorationInset(hObj,ins)
            hObj.ChartDecorationInset_I=ins;
        end

        function ins=get.ChartDecorationInset(hObj)
            forceFullUpdate(hObj,'all','ChartDecorationInsets');
            if any(hObj.ChartDecorationInset_I~=0)
                ins=hObj.ChartDecorationInset_I;
            else
                ins=hObj.TightInset;
            end
        end

        function set.Position_I(hObj,pos)

            hObj.InnerPosition=pos;
        end

        function pos=get.Position_I(hObj)

            pos=hObj.InnerPosition_I;
        end
    end

    methods(Hidden)
        function resetSubplotLayoutInfo(hObj)
            hObj.MaxInsetForSubplotCell=[0,0,0,0];
            hObj.SubplotCellOuterPosition=[0,0,0,0];
        end
    end

    methods(Access=protected)
        function forceUpdate(hObj,msg)
            forceFullUpdate(hObj,'all',msg);
        end

        function postSetUnits(hObj)
            hLayout=hObj.getLayout();
            if~isempty(hLayout)
                hLayout.Units=hObj.Units;
            else

                hAx=hObj.getAxes();
                hAx.Units=hObj.Units;




                hAx.LooseInset=hObj.LooseInset;
            end
        end

        function postSetOuterPosition(hObj)



            hLayout=hObj.getLayout();
            if~isempty(hLayout)
                hLayout.OuterPosition=hObj.OuterPosition;
            else
                hAx=hObj.getAxes();
                hAx.OuterPosition=hObj.OuterPosition;
                hAx.LooseInset=hObj.LooseInset;
            end
        end

        function postSetInnerPosition(hObj)



            hLayout=hObj.getLayout();
            if~isempty(hLayout)
                hLayout.InnerPosition=hObj.InnerPosition;
            else
                hAx=hObj.getAxes();
                hAx.InnerPosition=hObj.InnerPosition;
                hAx.LooseInset=hObj.LooseInset;
            end
        end

        function[inset,units]=getTightInset(hObj)
            hLayout=hObj.getLayout();

            units='normalized';
            inset=[0,0,0,0];

            if~isempty(hLayout)
                units=hLayout.Units;
                inset=hLayout.TightInset;
            else
                hAx=hObj.getAxes();
                if~isscalar(hAx)
                    hAx=hAx(1);
                end
                if isprop(hAx,'LayoutManager')&&isscalar(hAx.LayoutManager)&&isvalid(hAx.LayoutManager)
                    layoutManager=hAx.LayoutManager;
                    [inset,units]=layoutManager.getTightInset();
                else

                    layout=hAx.GetLayoutInformation();
                    pos=layout.Position;
                    decPB=layout.DecoratedPlotBox;

                    inset=[0,0,0,0];
                    inset(1:2)=[...
                    pos(1)-decPB(1),...
                    pos(2)-decPB(2)];
                    inset(3:4)=[...
                    decPB(3)-pos(3)-inset(1),...
                    decPB(4)-pos(4)-inset(2)];

                    inset(inset<0)=0;

                    units='pixels';
                end
            end
        end

        function managed=isInnerPositionManagedBySubplot(hObj)
            managed=any(hObj.SubplotCellOuterPosition~=0);
        end

        function val=getPositionManager(hObj)
            val=hObj.getLayout();
        end
    end
    methods(Access=protected)
        function unitPos=getUnitPositionObject(hObj)





            hAx=hObj.getAxes();
            if isa(hAx,'matlab.graphics.axis.AbstractAxes')&&~isempty(hAx)
                unitPos=hAx(1).Camera.Viewport;
            else
                unitPos=matlab.graphics.general.UnitPosition;
            end
        end
    end

    methods(Access={?matlab.graphics.layout.TiledChartLayout})
        function obj=getTightInsetComputer(hObj)
            obj=hObj.getLayout;
        end
    end

end

