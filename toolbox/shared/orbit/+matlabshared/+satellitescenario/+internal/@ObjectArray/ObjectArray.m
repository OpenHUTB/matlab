classdef ObjectArray<matlab.mixin.indexing.RedefinesParen




    properties(Dependent,Hidden)
ZoomHeight
ColorConverter
    end

    properties(Hidden,SetAccess={?satelliteScenario,?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.Access,...
        ?satcom.satellitescenario.internal.Link,...
        ?satcom.satellitescenario.Link})
Handles
    end

    methods(Hidden,Static)
        asset=empty(varargin)
    end

    methods(Hidden)
        asset=horzcat(asset,varargin)
        asset=vertcat(asset,varargin)
        asset=cat(dim,varargin)
        n=numel(asset)
        e=end(asset,k,n)
        varargout=size(asset,varargin)
        asset=permute(asset,order)
        asset=transpose(asset)
        asset=ctranspose(asset)
        asset=reshape(asset,varargin)
        asset=repmat(asset,varargin)
        tf=isscalar(asset)
        tf=isvector(asset)
        tf=ismatrix(asset)
        tf=isempty(asset)
        tf=iscolumn(asset)
        tf=isrow(asset)
        l=length(asset)
        tf=isvalid(asset)
        tf=eq(asset1,asset2)
    end

    methods(Access=protected)
        varargout=parenReference(asset,s)
        asset=parenAssign(asset,s,varargin)
        asset=parenDelete(asset,s)
        n=parenListLength(asset,indexingOperation,indexingContext)
    end

    methods
        function delete(obj)


            for idx=1:numel(obj.Handles)
                delete(obj.Handles{idx});
            end
        end



        function set(obj,propertyName,propertyValue)

            if isprop(obj,propertyName)
                obj.(propertyName)=propertyValue;
            else
                error(message('MATLAB:class:InvalidProperty',propertyName,class(obj)));
            end
        end

        function prop=get(obj,propertyName)

            if isprop(obj,propertyName)
                prop=obj.(propertyName);
            else
                error(message('MATLAB:class:InvalidProperty',propertyName,class(obj)));
            end
        end

        function h=get.ZoomHeight(obj)


            handles=[obj.Handles{:}];

            if isempty(handles)
                h=[];
            else
                h=[handles.ZoomHeight];
            end
        end

        function obj=set.ZoomHeight(obj,h)


            handles=[obj.Handles{:}];
            handles.ZoomHeight=h;
        end

        function c=get.ColorConverter(obj)


            handles=[obj.Handles{:}];

            if isempty(handles)
                c=matlabshared.satellitescenario.internal.ColorConverter.empty;
            else
                c=[handles.ColorConverter];
            end
        end

        function obj=set.ColorConverter(obj,c)


            handles=[obj.Handles{:}];
            handles.ColorConverter=c;
        end
    end

    methods(Hidden)
        function updateVisualizations(obj,viewer)


            updateVisualizations([obj.Handles{:}],viewer)
        end

        function ID=getGraphicID(obj)


            ID=getGraphicID([obj.Handles{:}]);
        end

        function addCZMLGraphic(obj,writer,times,initiallyVisible)


            addCZMLGraphic([obj.Handles{:}],writer,times,initiallyVisible);
        end

        function IDs=getChildGraphicsIDs(obj)


            IDs=getChildGraphicsIDs([obj.Handles{:}]);
        end

        function objs=getChildObjects(obj)


            objs=getChildObjects([obj.Handles{:}]);
        end

        function removeGraphic(obj)


            removeGraphic([obj.Handles{:}]);
        end

        function ids=hideInViewerState(obj,viewer)


            ids=hideInViewerState([obj.Handles{:}],viewer);
        end

        function[lat,lon]=getGeodeticLocation(obj)


            [lat,lon]=getGeodeticLocation([obj.Handles{:}]);
        end

        function hideGraphicIfParentInvisible(obj,parent,viewer)


            hideGraphicIfParentInvisible([obj.Handles{:}],parent,viewer)
        end

        function showIfAutoShow(objs,scenario,viewer)


            showIfAutoShow([objs.Handles{:}],scenario,viewer)
        end

        function updateViewersIfAutoShow(obj)


            updateViewersIfAutoShow([obj.Handles{:}]);
        end

        function color=convertColor(obj,value,property,classname)


            color=convertColor([obj.Handles{:}],value,property,classname);
        end

        function addGraphicToClutterMap(obj,viewer)
            for k=1:numel(obj.Handles)
                obj.Handles{k}.addGraphicToClutterMap(viewer);
            end
        end
    end

    methods
        function show(objs,varargin)


















































            validateattributes(objs,{'matlabshared.satellitescenario.Satellite',...
            'matlabshared.satellitescenario.GroundStation',...
            'matlabshared.satellitescenario.Gimbal',...
            'matlabshared.satellitescenario.ConicalSensor',...
            'matlabshared.satellitescenario.Access',...
            'satcom.satellitescenario.Transmitter',...
            'satcom.satellitescenario.Receiver',...
            'satcom.satellitescenario.Link'},...
            {'nonempty'},'show','OBJ');
            show([objs.Handles{:}],varargin{:});
        end

        function hide(objs,varargin)











































            validateattributes(objs,{'matlabshared.satellitescenario.Satellite',...
            'matlabshared.satellitescenario.GroundStation',...
            'matlabshared.satellitescenario.Gimbal',...
            'matlabshared.satellitescenario.ConicalSensor',...
            'matlabshared.satellitescenario.Access',...
            'satcom.satellitescenario.Transmitter',...
            'satcom.satellitescenario.Receiver',...
            'satcom.satellitescenario.Link'},...
            {'nonempty'},'show','OBJ')
            hide([objs.Handles{:}],varargin{:});
        end
    end

    methods(Access=protected)
        function updateViewers(objs,viewers,setVisible,forceUpdate)


            updateViewers([objs.Handles{:}],viewers,setVisible,forceUpdate);
        end
    end

    methods(Static,Access={?satelliteScenario,?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.Viewer,?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})
        function[viewer,args]=parseViewerInput(viewers,scenario,varargin)


            [viewer,args]=matlabshared.satellitescenario.ScenarioGraphics.parseViewerInput(viewers,scenario,varargin{:});
        end

        function validateViewerScenario(viewer,scenario)


            matlabshared.satellitescenario.ScenarioGraphics.validateViewerScenario(viewer,scenario);
        end

        function[paramValue,otherArgs]=extractParamFromVarargin(paramName,defaultValue,validationFcn,varargin)


            [paramValue,otherArgs]=matlabshared.satellitescenario.ScenarioGraphics.extractParamFromVarargin(paramName,defaultValue,validationFcn,varargin{:});
        end

        function flyToGraphic(viewer,objs,ids)


            matlabshared.satellitescenario.ScenarioGraphics.flyToGraphic(viewer,[objs.Handles{:}],ids);
        end

        function acs=getAllRelatedAccesses(obj)

            acs=getAllRelatedAccesses([obj.Handles{:}]);
        end
    end

    methods(Hidden,Static)
        function name=matlabCodegenRedirect(~)


            name='matlabshared.satellitescenario.coder.internal.ObjectArrayCG';
        end
    end
end

