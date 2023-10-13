classdef(Abstract)BaseObject<handle

    properties(Access=protected)
        Uuid;
        ObjectID;
        Type;
        Name;
        Metadata;
        State=classdiagram.app.core.domain.ElementState.Normal;
        InCanvas=false;
        GlobalSettingsFcn;
    end

    methods
        function setDiagramElementUUID(self,uuid)
            self.Uuid=uuid;
        end

        function uuid=getDiagramElementUUID(self)
            uuid=self.Uuid;
        end

        function setObjectID(self,objectID)
            self.ObjectID=objectID;
        end

        function objectID=getObjectID(self)
            objectID=self.ObjectID;
        end

        function type=getType(self)
            type=self.Type;
        end

        function name=getName(self)
            name=self.Name;
        end

        function hidden=isHidden(self)
            showHidden=self.GlobalSettingsFcn('ShowHidden');
            hidden=~(showHidden||isempty(self.getMetadataByKey("Hidden")));
        end

        function setMetadata(self,metadata)
            self.Metadata=metadata;
        end

        function setMetadataByKey(self,key,value)
            self.Metadata(key)=value;
        end

        function metadata=getMetadata(self)
            metadata=self.Metadata;
        end

        function metadataValue=getMetadataByKey(self,key)
            metadataValue=[];
            metadata=self.Metadata;
            if(~isempty(metadata)&&metadata.isKey(key))
                metadataValue=metadata(key);
            end
        end

        function setState(self,state)
            if isa(state,'classdiagram.app.core.domain.ElementState')
                self.State=state;
            end
        end

        function state=getState(self)
            state=self.State;
        end

        function setInCanvas(self,incanvas)
            if islogical(incanvas)
                self.InCanvas=incanvas;
            end
        end

        function incanvas=isInCanvas(self)
            incanvas=self.InCanvas;
        end

        function clearCaches(~)
        end
    end

    methods(Abstract)
        accept(self,visitor);
    end

    methods(Static,Access=protected)
        function isLoaded=isLoaded(prop)
            isLoaded=numel(prop)~=1||prop~=-1;
        end
    end
end
