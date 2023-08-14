classdef(ConstructOnLoad,Sealed,Hidden)ScribePeer<matlab.graphics.primitive.world.Group&matlab.graphics.mixin.AxesParentable&matlab.graphics.mixin.Selectable











    properties(Transient,AbortSet,NonCopyable)

        DisplayHandle matlab.internal.datatype.matlab.graphics.primitive.world.SceneNode

        PositionProperty{matlab.internal.validation.mustBeASCIICharRowVector(PositionProperty,'PositionProperty')}='';









        PixelPosition=[0,0];








        PerformTransform(1,1)logical=false;





        Tag{matlab.internal.validation.mustBeCharRowVector(Tag,'Tag')}='';
    end

    methods
        function obj=ScribePeer(varargin)





            obj.addDependencyConsumed('view');



            obj.Copyable=false;
            obj.Serializable='off';

            if nargin
                set(obj,varargin{:});
            end
        end

        function set.DisplayHandle(obj,newValue)
            oldValue=obj.DisplayHandle;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)&&oldValue~=newValue
                    obj.replaceChild(obj.DisplayHandle,newValue);
                else



                    if isprop(newValue,'Parent')
                        newValue.Parent=[];
                    end
                    obj.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)
                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            obj.DisplayHandle=newValue;
            obj.MarkDirty('all');
        end

        function set.PixelPosition(obj,val)
            obj.PixelPosition=val;
            obj.MarkDirty('all');
        end

        function set.PositionProperty(obj,val)
            val=matlab.internal.validation.makeCharRowVector(val);
            obj.PositionProperty=val;
            obj.MarkDirty('all');
        end

        function set.PerformTransform(obj,val)
            obj.PerformTransform=val;
            obj.MarkDirty('all');
        end
    end

    methods(Hidden)
        function doUpdate(obj,updateState)








            if~isempty(obj.DisplayHandle)&&isvalid(obj.DisplayHandle)&&~isempty(obj.PositionProperty)



                loc=obj.PixelPosition;
                if isnumeric(loc)&&ismatrix(loc)&&(size(loc,2)==2||size(loc,2)==3||size(loc,1)==3)





                    if size(loc,2)==2||size(loc,2)==3
                        loc(:,1:2)=updateState.convertUnits('camera','normalized','pixels',loc(:,1:2));



                        loc(:,3)=0;

                        if obj.PerformTransform


                            iter=matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices',loc);
                            try
                                loc=TransformPoints(updateState.DataSpace,...
                                updateState.TransformUnderDataSpace,iter);

                                if any(~isfinite(loc))
                                    loc=single(zeros(3,0));
                                end
                            catch E %#ok<NASGU>
                                loc=single(zeros(3,0));
                            end
                        end
                    end


                    obj.DisplayHandle.(obj.PositionProperty)=loc;







                    obj.DisplayHandle.Visible=obj.Visible;

                end
            end
        end

        function firstChild=doGetChildren(~)


            firstChild=matlab.graphics.GraphicsPlaceholder.empty;
        end
    end

    methods
        function set.Tag(obj,value)
            obj.Tag=matlab.internal.validation.makeCharRowVector(value);
        end
    end
end
