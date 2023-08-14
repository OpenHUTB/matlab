classdef Textures<handle
    properties(Access=private)
        TextureCache;
        TextureUniqueId;
    end

    methods
        function self=Textures()
            self.TextureCache=struct();
            self.TextureUniqueId=0;
        end

        function textureName=add(self,texture,textureName)
            if nargin<3
                textureName=[];
            end
            [found,textureName]=self.exists(texture,textureName);
            if~found
                if isempty(textureName)||~isempty(regexp(textureName,'texture\d','once'))
                    self.TextureUniqueId=self.TextureUniqueId+1;
                    textureName=['texture',num2str(self.TextureUniqueId)];
                end
                self.TextureCache.(textureName).Data=texture;
                self.TextureCache.(textureName).Actors={};
            end
        end

        function remove(self,textureName)

            if isfield(self.TextureCache,textureName)
                self.TextureCache=rmfield(self.TextureCache,textureName);
            end
        end

        function reset(self)
            self.TextureCache=struct();
            self.TextureUniqueId=0;
        end

        function[found,textureName]=exists(self,texture,textureName)
            found=false;
            textureNameList=fieldnames(self.TextureCache);

            if~isempty(textureName)

                if any(contains(textureNameList,textureName))
                    if(isequal(texture,self.TextureCache.(textureName).Data))
                        found=true;
                    else
                        found=false;
                        textureName=[];
                    end
                end
            else

                for idx=1:numel(textureNameList)
                    if(isequal(texture,self.TextureCache.(textureNameList{idx}).Data))

                        textureName=textureNameList{idx};
                        found=true;
                    end
                end
            end
        end

        function addTexture(self,texture,actor)
            if(~isempty(actor.ParentWorld))
                if isfield(self.TextureCache,texture)
                    actor.Material.Texture=self.TextureCache.(texture).Data;
                end
            else
                actor.Material.Texture=texture;
            end
        end

        function addActor(self,textureName,actorName)
            if~isfield(self.TextureCache,textureName)
                error("Texturefile not available in cache, add texture first then add actor to use texture");
            end

            if~any(contains(self.TextureCache.(textureName).Actors,actorName))

                self.TextureCache.(textureName).Actors{end+1}=actorName;
            end
        end

        function removeActor(self,textureName,actorName)
            if isfield(self.TextureCache,textureName)

                actorIdx=contains(self.TextureCache.(textureName).Actors,actorName);
                self.TextureCache.(textureName).Actors(actorIdx)=[];
            end
        end

        function textureData=getTextureData(self,textureName)
            textureData=[];
            if isfield(self.TextureCache,textureName)
                textureData=self.TextureCache.(textureName).Data;
            end
        end

        function textureStruct=exportAsStruct(self)
            textureStruct=self.TextureCache;
        end

        function textureMap=importFromStruct(self,textureStruct)
            textureMap=struct();
            if~isempty(textureStruct)
                textureNames=fieldnames(textureStruct);
                for idx=1:numel(textureNames)
                    textureName=textureNames{idx};
                    newTextureName=self.add(textureStruct.(textureName).Data,textureName);
                    textureMap.(textureName)=newTextureName;
                end
            end
        end


    end

end
