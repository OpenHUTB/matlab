classdef(Abstract)Shape<cad.TreeNode

    properties
Name


Operations
Triangulation
        AntennaShape=[];

Selected
ReindexListener

    end


    methods
        function self=Shape(Id,varargin)

            self.Id=Id;
        end


        function set.Triangulation(self,val)

            self.Triangulation=val;
        end


        function set.AntennaShape(self,val)

            self.AntennaShape=val;
            if~isempty(val)

                self.updateTriangulation();
            end
        end


        function childrenChanged(self)

            reindexOperations(self);
        end


        function addOperation(self,opnObj,varargin)

            indx=numel(self.Operations);
            opnObj.setIndex(indx);
            addChild(self,opnObj);
            if~isempty(varargin)
                indx=varargin{1};
                opnObj.setIndex(indx);

                if indx==1
                    self.Children=[self.Children(end),self.Children(1:end-1)];
                    reindexOperations(self);
                elseif indx==numel(self.Children)
                else
                    self.Children=[self.Children(1:indx-1),self.Children(end),self.Children(indx:end-1)];
                    reindexOperations(self);
                end

                updateShape(self);
            else
                updateShape(self,opnObj);
            end

        end


        function updateShape(self,varargin)

            if isempty(varargin)

                generatePolygon(self);
                dummyShape=self.AntennaShape;
                booleanOpnsindx=arrayfun(@(x)isa(x,'cad.BooleanOperation'),self.Children);
                otherOpns=self.Children(~booleanOpnsindx);
                boolOpns=self.Children(booleanOpnsindx);
                for i=1:numel(otherOpns)

                    dummyShape=performOperation(otherOpns(i));
                end
                for i=1:numel(boolOpns)

                    try
                        dummyShape=performOperation(boolOpns(i),dummyShape);
                    catch
                        error(['Cannot perform ',boolOpns(i).Name,...
                        ' operation between ',self.Name,' and ',strjoin({boolOpns(i).Children.Name})]);
                    end
                end
            else
                if isa(varargin{1},'cad.BooleanOperation')
                    dummyShape=self.AntennaShape;
                    dummyShape=performOperation(varargin{1},dummyShape);
                end
            end

            if isempty(dummyShape)
                self.AntennaShape=self.getShape();
            else
                self.AntennaShape=dummyShape;
            end

            updated(self);

            parentChanged(self);
        end


        function translateShape(self)

        end


        function resizeShape(self)

        end


        function revertShape(self)

            self.AntennaShape=[];
        end


        function childUpdated(self,~)

            self.updateShape();
        end


        function updateTriangulation(self)
            [p,t]=getInitialMesh(self.AntennaShape);
            tri=triangulation(t(:,1:3),p);
            self.Triangulation=tri;
        end


        function vert=genLineVertices(self)
            vert=self.Triangulation.Points;
        end


        function sout=getShape(self)
            sout=[];

        end


        function sout=getOperatedShape(self)

            if isempty(self.AntennaShape)
                sout=getShape(self);
            else
                sout=copy(self.AntennaShape);
            end
        end


        function val=getChildrenShapes(self)

            val=[];
            if~isempty(self.Children)
                for i=1:numel(self.Children)
                    val=[val,self.Children(i).Children];
                end
            end
        end


        function val=getChildrenOperations(self)

            val=[];
            if~isempty(self.Children)
                val=self.Children;
            end
        end


        function removeChild(self,oldChild)

            self.removeChild@cad.TreeNode(oldChild);
            reindexOperations(self);
        end

        function reindexOperations(self)

            for i=1:numel(self.Children)
                self.Children(i).setIndex(i);
            end
        end


        function deleteListeners(self)
            self.deleteListeners@cad.TreeNode();
        end

        function[hasVariableForPos,hasVariableForDim,hasVariableForAngle]=checkChildrenHaveVariableForProperty(obj)
            hasVariableForPos=0;
            hasVariableForDim=0;
            hasVariableForAngle=0;

            childShapes=getChildrenShapes(obj);

            for i=1:numel(childShapes)
                posVar=0;dimVar=0;angVar=0;
                [posVar,dimVar,angVar]=checkChildrenHaveVariableForProperty(childShapes(i));
                [posVarObj,dimVarObj,angVarObj]=checkVarForProps(childShapes(i));

                FinalArr=[hasVariableForPos,hasVariableForDim,hasVariableForAngle]...
                |[posVar,dimVar,angVar]|[posVarObj,dimVarObj,angVarObj];
                hasVariableForPos=FinalArr(1);hasVariableForDim=FinalArr(2);hasVariableForAngle=FinalArr(3);
            end
        end

        function[hasvarPos,hasVarDim,hasVarAng]=checkVarForProps(obj)
            hasvarPos=0;
            hasVarDim=0;
            hasVarAng=0;
            props=fields(obj.PropertyValueMap);
            for i=1:numel(props)
                if strcmpi(props{i},'Center')
                    if~isempty(obj.PropertyValueMap.Center)
                        hasvarPos=1;
                    end
                elseif strcmpi(props{i},'Angle')
                    if~isempty(obj.PropertyValueMap.Angle)
                        hasVarAng=1;
                    end
                else
                    if~isempty(obj.PropertyValueMap.(props{i}))
                        hasVarDim=1;
                    end
                end
            end
        end

    end
    events
SelectionChanged
    end
end

