classdef(ConstructOnLoad,UseClassDefaultsOnLoad,...
    AllowedSubclasses=?TestUIAxesSubclass)...
    UIAxes<...
    matlab.graphics.axis.Axes&...
    matlab.ui.internal.mixin.OuterPositionable




    properties(Dependent,Hidden)

        BackgroundColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none'
    end

    properties(Hidden)

        BackgroundColorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        BackgroundColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none'
    end

    properties(Access=protected,NonCopyable)


        SavedInVersion(1,1)string=missing





Axes
    end

    properties(Access=protected,Transient,NonCopyable)



        SavedInVersion_I(1,1)string=missing


        BeingCopied(1,1)logical=false
    end

    methods
        function obj=UIAxes(varargin)



            obj=obj@matlab.graphics.axis.Axes();


            obj.setIsUIAxes(true);
            obj.setDefaultUIAxesProperties();


            matlab.graphics.chart.internal.ctorHelper(obj,varargin);
        end

        function tf=isequal(varargin)










            narginchk(2,Inf)
            tf=true;
            sz=size(varargin{1});
            cls=class(varargin{1});
            for n=2:nargin
                if~isequal(sz,size(varargin{n}))||...
                    ~strcmp(cls,class(varargin{n}))||...
                    any(varargin{1}~=varargin{n},'all')
                    tf=false;
                    return
                end
            end
        end

        function v=get.SavedInVersion(obj)

            v=getSavedInVersion(obj);
        end

        function set.SavedInVersion(obj,v)


            setSavedInVersion(obj,v);
        end

        function ax=get.Axes(ux)





            if ux.BeingCopied
                ax=matlab.graphics.axis.Axes.empty();
            else
                ax=convertToAxes(ux);
            end
        end

        function set.Axes(ux,ax)



            setAxes(ux,ax);
        end

        function color=get.BackgroundColor(obj)
            color=obj.BackgroundColor_I;
        end

        function set.BackgroundColor(obj,color)
            obj.BackgroundColorMode='manual';
            obj.BackgroundColor_I=color;
        end
    end

    methods(Static,Access=private)
        function convertAxes(source,target)




            b=getByteStreamFromArray(source);
            source=getArrayFromByteStream(b);


            matlab.ui.control.UIAxes.copyProperties(source,target);


            matlab.ui.control.UIAxes.fixLayoutPeers(target);


            delete(source)
        end

        function copyProperties(source,target,ignoreProperties)




            if nargin<3
                ignoreProperties={};
            end


            ignoreProperties=unique([ignoreProperties;[
"SerializableChildren"
"TopLevelSerializableObject"
            "Position_I"]]);



            ignoreWhenEmpty=[
"BubbleSizeRange_IS"
"BubbleSizeLimits_IS"
            ];



            remapProperties=[
            "ButtonDownFcn_IS","ButtonDownFcn_IS","ButtonDownFcn_I";
            "CreateFcn_IS","CreateFcn_IS","CreateFcn_I";
            "DeleteFcn_IS","DeleteFcn_IS","DeleteFcn_I";
            "SerializableApplicationData","SerializableApplicationData","ApplicationData";
            "SerializableBehavior","SerializableBehavior","Behavior_I";
            "SerializableUserData","SerializableUserData","UserData"];




            copyAnyway="UIContextMenu";


            inMeta=metaclass(source);
            inPropertyList=inMeta.PropertyList;
            sourcePropNames={inPropertyList(:).Name}';


            outMeta=metaclass(target);
            outPropertyList=outMeta.PropertyList;
            outPropertyNames={outPropertyList(:).Name}';
            outIsPrivate=strcmp({outPropertyList(:).SetAccess}','private');



            copyProperty=~(...
            [inPropertyList.Transient]|...
            [inPropertyList.Dependent]|...
            [inPropertyList.Constant]|...
            [inPropertyList.Abstract])';


            ignore=ismember(sourcePropNames,ignoreProperties);
            copyProperty(ignore)=false;


            copyProperty(sourcePropNames==copyAnyway)=true;


            sourcePropNames=sourcePropNames(copyProperty);
            copyProperty=true(size(sourcePropNames));




            destPropNames=sourcePropNames;
            [remap,loc]=ismember(sourcePropNames,remapProperties(:,1));
            sourcePropNames(remap)=cellstr(remapProperties(loc(remap),2));
            destPropNames(remap)=cellstr(remapProperties(loc(remap),3));


            [onTarget,destPropIndex]=ismember(destPropNames,outPropertyNames);
            copyProperty(~onTarget)=false;
            copyProperty(onTarget)=copyProperty(onTarget)&~outIsPrivate(destPropIndex(onTarget));


            for p=1:numel(sourcePropNames)
                if copyProperty(p)

                    val=source.(sourcePropNames{p});
                    if isa(val,'matlab.graphics.Graphics')



                        isInternal=[val.Internal];
                        set(val(isInternal),'Parent',matlab.graphics.primitive.world.Group.empty)
                    end


                    if isempty(val)&&any(sourcePropNames{p}==ignoreWhenEmpty)
                        continue
                    end


                    target.(destPropNames{p})=val;
                end
            end





            delete(target.TargetManager);
            target.makeDataSpaceCurrent(source.ActiveDataSpaceIndex);
        end

        function fixLayoutPeers(obj)




            if isappdata(obj,'LayoutPeers')
                peers=getappdata(obj,'LayoutPeers');
                for p=peers
                    p.Axes=obj;
                end
            end
        end

        function rebuildYYAxisApplicationData(obj)





            appDataField='Internal_CoordinateSystemData';
            targets=obj.TargetManager.Children;
            if~isappdata(obj,appDataField)&&numel(targets)>1
                appData=struct();
                for t=1:numel(targets)
                    target=targets(t);
                    appData(t).ColorOrder=target.ColorSpace.ColorOrder;
                    appData(t).LineStyleOrder=target.ColorSpace.LineStyleOrder;
                    appData(t).ColorOrderIndex=target.ColorOrderIndex;
                    appData(t).ColorOrderIndexMode=strcmp(target.ColorOrderIndexMode,'auto');
                    appData(t).LineStyleOrderIndex=target.LineStyleOrderIndex;
                    appData(t).LineStyleOrderIndexMode=strcmp(target.LineStyleOrderIndexMode,'auto');
                    appData(t).NextSeriesIndex=target.NextSeriesIndex;
                end
                setappdata(obj,appDataField,appData);
            end
        end
    end

    methods(Static,Access=protected)
        function ux=convertToUIAxes(ax)



            ux=matlab.ui.control.UIAxes();


            matlab.ui.control.UIAxes.convertAxes(ax,ux);
        end
    end

    methods(Static,Hidden)
        function obj=doloadobj(obj)





















            matlab.ui.control.UIAxes.rebuildYYAxisApplicationData(obj)
        end
    end

    methods(Access=protected)
        function ax=convertToAxes(ux)





            ax=matlab.graphics.axis.Axes();


            c=onCleanup(@()set(ux,'BeingCopied',false));
            ux.BeingCopied=true;


            matlab.ui.control.UIAxes.convertAxes(ux,ax);
        end

        function v=getSavedInVersion(~)

            v=version;
        end

        function setSavedInVersion(obj,v)


            obj.SavedInVersion_I=v;
        end

        function setAxes(ux,ax)




            savedBeforeR2020b=ismissing(ux.SavedInVersion_I);
            if isscalar(ax)&&isvalid(ax)
                if savedBeforeR2020b

                    matlab.ui.control.UIAxes.copyProperties(ax,ux,...
                    internalAxesPropertiesToIgnore);


                    matlab.ui.control.UIAxes.fixLayoutPeers(ux);



                    fixModes(ux);
                end


                delete(ax)
            end
        end

        function doSetOuterPositionableOuterPositionStorage(obj,unitPos)






            savedBeforeR2020b=ismissing(obj.SavedInVersion_I);
            if savedBeforeR2020b
                obj.PositionConstraint='outerposition';
                obj.Units=unitPos.Units;
                obj.OuterPosition=unitPos.Position;



                resetModeIfDefault(obj,'OuterPosition','Units')
                resetModeIfDefault(obj,'Units')
            end
        end

        function unitPos=doGetOuterPositionableOuterPositionStorage(obj)






            vp=obj.Camera.Viewport;
            unitPos=matlab.ui.internal.UnitPos;
            unitPos.RefFrame=vp.RefFrame;
            unitPos.CharacterWidth=vp.CharacterWidth;
            unitPos.CharacterHeight=vp.CharacterHeight;


            unitPos.Units=obj.Units;
            unitPos.Position=obj.OuterPosition_I;
        end

        function doSetOuterPositionableInnerPositionStorage(~,~)







        end

        function unitPos=doGetOuterPositionableInnerPositionStorage(obj)






            vp=obj.Camera.Viewport;
            unitPos=matlab.ui.internal.UnitPos;
            unitPos.RefFrame=vp.RefFrame;
            unitPos.CharacterWidth=vp.CharacterWidth;
            unitPos.CharacterHeight=vp.CharacterHeight;


            unitPos.Units=obj.Units;
            unitPos.Position=obj.InnerPosition_I;
        end
    end
end

function fixModes(obj)







    resetModeIfDefault(obj,'Clipping')
    resetModeIfDefault(obj,'FontName')
    resetModeIfDefault(obj,'FontSize','FontUnits')
    resetModeIfDefault(obj,'FontUnits')
    resetModeIfDefault(obj,'LooseInset','Units')
    resetModeIfDefault(obj,'NextPlot')






    obj.BehaviorMode='auto';
    obj.SelectionHighlightMode='auto';

end

function resetModeIfDefault(obj,prop,units)




    defaults.Clipping=matlab.lang.OnOffSwitchState.on;
    defaults.FontName='Helvetica';
    defaults.FontSize=12;
    defaults.FontUnits='pixels';
    defaults.LooseInset=[5,5,5,5];
    defaults.NextPlot='replacechildren';
    defaults.OuterPosition=[10,10,400,300];
    defaults.Units='pixels';


    mode=[prop,'Mode'];
    prop_I=[prop,'_I'];


    isDefault=isequal(obj.(prop_I),defaults.(prop));


    if isDefault&&nargin==3
        units_I=[units,'_I'];
        isDefault=isequal(obj.(units_I),defaults.(units));
    end


    if isDefault
        obj.(mode)='auto';
    end

end

function props=internalAxesPropertiesToIgnore()







    props=[
"BeingDeleted"
"BusyAction"
"ButtonDownFcnMode"
"ButtonDownFcn_IS"
"Copyable"
"CreateFcnMode"
"CreateFcn_IS"
"DeleteFcnMode"
"DeleteFcn_IS"
"FontSmoothingMode"
"FontSmoothing_I"
"HandleVisibilityMode"
"HandleVisibility_I"
"InnerPositionMode"
"InnerPosition_I"
"Internal"
"Interruptible"
"Layout"
"OuterPositionMode"
"OuterPosition_I"
"PositionMode"
"SerializableMode"
"Serializable_I"
"SerializableChildren"
"SerializableUIContextMenu"
"SerializableUserData"
"TagMode"
"Tag_I"
"TopLevelSerializedObject"
"UnitsMode"
"VisibleMode"
"Visible_I"
    ];

end
