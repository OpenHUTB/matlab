classdef MaterialAttributes<sim3d.internal.BaseAttributes


    properties

        Color(1,3)double;


        Transparency(1,1)double=0;


        Shininess(1,1)double=0.7;


        Metallic(1,1)double=0.7;


        Flat(1,1)double=0;


        Tessellation(1,1)double=0;

        TextureTransform(1,1)sim3d.internal.TextureTransform;

        TextureMapping(1,1)sim3d.internal.TextureMapping;


        VertexBlend(1,1)double=0;




        Shadows(1,1)logical=false;

        Texture="";

    end

    properties(Hidden)
        Masked(1,1)logical=false;


        TwoSided(1,1)logical=false;


        Refraction(1,1)double=1;
    end

    properties(Hidden,Constant)
        ColorID=1;
        MaskedID=2;
        TransparencyID=3;
        TwoSidedID=4;
        ShininessID=5;
        MetallicID=6;
        RefractionID=7;
        FlatID=8;
        TessellationID=9;
        VertexBlendID=10;
        ShadowsID=11;
        TextureID=12;
        TextureMappingID=13;
        TextureTransformID=14;
        Full=14;
        Suffix_Out='MaterialAttributes_OUT';
        Suffix_In='MaterialAttributes_IN';
    end

    methods

        function self=MaterialAttributes(varargin)
            self@sim3d.internal.BaseAttributes();
            r=sim3d.internal.MaterialAttributes.parseInputs(varargin{:});
            self.setAttributes(r);
        end

        function setup(self,actorName)
            messageTopic=[actorName,self.Suffix_Out];
            setup@sim3d.internal.BaseAttributes(self,messageTopic);
        end

        function MaterialAttribs=getAttributes(self)
            MaterialAttribs=self.createMaterialStruct(self);
        end

        function setAttributes(self,MaterialStruct)
            if(isfield(MaterialStruct,'Color'))
                self.Color=MaterialStruct.Color;
            end
            if(isfield(MaterialStruct,'Masked'))
                self.Masked=MaterialStruct.Masked;
            end
            if(isfield(MaterialStruct,'Transparency'))
                self.Transparency=MaterialStruct.Transparency;
            end
            if(isfield(MaterialStruct,'TwoSided'))
                self.TwoSided=MaterialStruct.TwoSided;
            end
            if(isfield(MaterialStruct,'Shininess'))
                self.Shininess=MaterialStruct.Shininess;
            end
            if(isfield(MaterialStruct,'Metallic'))
                self.Metallic=MaterialStruct.Metallic;
            end
            if(isfield(MaterialStruct,'Refraction'))
                self.Refraction=MaterialStruct.Refraction;
            end
            if(isfield(MaterialStruct,'Flat'))
                self.Flat=MaterialStruct.Flat;
            end
            if(isfield(MaterialStruct,'Tessellation'))
                self.Tessellation=MaterialStruct.Tessellation;
            end
            if(isfield(MaterialStruct,'VertexBlend'))
                self.VertexBlend=MaterialStruct.VertexBlend;
            end
            if(isfield(MaterialStruct,'Shadows'))
                self.Shadows=MaterialStruct.Shadows;
            end
            if(isfield(MaterialStruct,'Texture'))
                self.Texture=MaterialStruct.Texture;
            end
            if(isfield(MaterialStruct,'TextureMapping'))
                if isa(MaterialStruct.TextureMapping,'sim3d.internal.TextureMapping')
                    self.TextureMapping=MaterialStruct.TextureMapping;
                elseif isa(MaterialStruct.TextureMapping,'struct')
                    self.TextureMapping.Blend=MaterialStruct.TextureMapping.Blend;
                    self.TextureMapping.Displacement=MaterialStruct.TextureMapping.Displacement;
                    self.TextureMapping.Bumps=MaterialStruct.TextureMapping.Bumps;
                    self.TextureMapping.Roughness=MaterialStruct.TextureMapping.Roughness;
                else
                    self.TextureMapping.Blend=MaterialStruct.TextureMapping(1:3);
                    self.TextureMapping.Displacement=MaterialStruct.TextureMapping(4:6);
                    self.TextureMapping.Bumps=MaterialStruct.TextureMapping(7:9);
                    self.TextureMapping.Roughness=MaterialStruct.TextureMapping(10:12);
                end
            end
            if(isfield(MaterialStruct,'TextureTransform'))
                if isa(MaterialStruct.TextureTransform,'sim3d.internal.TextureTransform')
                    self.TextureTransform=MaterialStruct.TextureTransform;
                elseif isa(MaterialStruct.TextureTransform,'struct')
                    self.TextureTransform.Position=MaterialStruct.TextureTransform.Position;
                    self.TextureTransform.Velocity=MaterialStruct.TextureTransform.Velocity;
                    self.TextureTransform.Scale=MaterialStruct.TextureTransform.Scale;
                    self.TextureTransform.Angle=MaterialStruct.TextureTransform.Angle;
                else
                    self.TextureTransform.Position=MaterialStruct.TextureTransform(1:2);
                    self.TextureTransform.Velocity=MaterialStruct.TextureTransform(3:4);
                    self.TextureTransform.Scale=MaterialStruct.TextureTransform(5:6);
                    self.TextureTransform.Angle=MaterialStruct.TextureTransform(7);
                end
            end
        end


        function set.Color(self,Color)
            self.Color=Color;
            self.add2Buffer(self.ColorID)
        end

        function set.Transparency(self,Transparency)
            self.Transparency=Transparency;
            self.add2Buffer(self.TransparencyID);
        end

        function set.Masked(self,Masked)
            self.Masked=Masked;
            self.add2Buffer(self.MaskedID);
        end

        function set.TwoSided(self,TwoSided)
            self.TwoSided=TwoSided;
            self.add2Buffer(self.TwoSidedID);
        end

        function set.Shininess(self,Shininess)
            self.Shininess=Shininess;
            self.add2Buffer(self.ShininessID);

        end
        function set.Flat(self,Flat)
            self.Flat=Flat;
            self.add2Buffer(self.FlatID);
        end

        function set.Tessellation(self,Tessellation)
            self.Tessellation=Tessellation;
            self.add2Buffer(self.TessellationID);
        end

        function set.Metallic(self,Metallic)
            self.Metallic=Metallic;
            self.add2Buffer(self.MetallicID);
        end

        function set.Refraction(self,Refraction)
            self.Refraction=Refraction;
            self.add2Buffer(self.RefractionID);
        end

        function set.Shadows(self,Shadows)
            self.Shadows=Shadows;
            self.add2Buffer(self.ShadowsID);
        end

        function set.VertexBlend(self,VertexBlend)
            self.VertexBlend=VertexBlend;
            self.add2Buffer(self.VertexBlendID);
        end
        function set.Texture(self,Texture)
            if(ischar(Texture))
                Texture=string(Texture);
            end
            self.Texture=Texture;
            self.setBlend();
            self.add2Buffer(self.TextureID);
        end

        function set.TextureMapping(self,textureMapping)
            self.TextureMapping=textureMapping;
            self.add2Buffer(self.TextureMappingID);
        end

        function set.TextureTransform(self,textureTransform)
            self.TextureTransform=textureTransform;
            self.add2Buffer(self.TextureTransformID);
        end

        function setBlend(self)
            self.TextureMapping.Blend=1;
        end

        function copy(self,other)

            self.Color=other.Color;
            self.Masked=other.Masked;
            self.Transparency=other.Transparency;
            self.TwoSided=other.TwoSided;
            self.Shininess=other.Shininess;
            self.Metallic=other.Metallic;
            self.Refraction=other.Refraction;
            self.Flat=other.Flat;
            self.Tessellation=other.Tessellation;
            self.VertexBlend=other.VertexBlend;
            self.Shadows=other.Shadows;
            self.Texture=other.Texture;
            self.TextureMapping=other.TextureMapping;
            self.TextureTransform=other.TextureTransform;
        end

    end

    methods(Access=private,Static)
        function r=parseInputs(varargin)


            defaultParams=struct(...
            'Color',[1,1,1],...
            'Masked',false,...
            'Transparency',0,...
            'TwoSided',false,...
            'Shininess',0.7,...
            'Metallic',0.7,...
            'Refraction',1,...
            'Flat',0,...
            'Tessellation',0,...
            'VertexBlend',0,...
            'Shadows',false,...
            'Texture',"",...
            'TextureMapping',sim3d.internal.TextureMapping(),...
            'TextureTransform',sim3d.internal.TextureTransform());




            parser=inputParser;
            parser.addParameter('Color',defaultParams.Color);
            parser.addParameter('Masked',defaultParams.Masked);
            parser.addParameter('Transparency',defaultParams.Transparency);
            parser.addParameter('TwoSided',defaultParams.TwoSided);
            parser.addParameter('Shininess',defaultParams.Shininess);
            parser.addParameter('Metallic',defaultParams.Metallic);
            parser.addParameter('Refraction',defaultParams.Refraction);
            parser.addParameter('Flat',defaultParams.Flat);
            parser.addParameter('Tessellation',defaultParams.Tessellation);
            parser.addParameter('VertexBlend',defaultParams.VertexBlend);
            parser.addParameter('Shadows',defaultParams.Shadows);
            parser.addParameter('Texture',defaultParams.Texture);
            parser.addParameter('TextureMapping',defaultParams.TextureMapping);
            parser.addParameter('TextureTransform',defaultParams.TextureTransform);


            parser.parse(varargin{:});
            r=parser.Results;
        end

        function MaterialStruct=createMaterialStruct(self)







            textureMap=self.TextureMapping.getData();
            textureTfm=self.TextureTransform.getData();

            MaterialStruct=struct('Color',self.Color,'Masked',self.Masked,'Transparency',self.Transparency,...
            'TwoSided',self.TwoSided,'Shininess',self.Shininess,'Metallic',self.Metallic,...
            'Refraction',self.Refraction,'Flat',self.Flat,'Tessellation',self.Tessellation,...
            'VertexBlend',self.VertexBlend,'Shadows',self.Shadows,'Texture',self.Texture,...
            'TextureMapping',textureMap,'TextureTransform',textureTfm);
        end

    end


    methods(Hidden)
        function totalAttributes=getTotalAttributes(self)
            totalAttributes=self.Full;
        end

        function selectedAttributes=getSelectedAttributes(self,messageIds)
            selectedAttributes=struct();
            if(messageIds(self.Full)==1)

                selectedAttributes=self.getAttributes();
                return;
            end

            if(messageIds(self.ColorID)==1)
                selectedAttributes.Color=self.Color;
            end
            if(messageIds(self.MaskedID)==1)
                selectedAttributes.Masked=self.Masked;
            end
            if(messageIds(self.TransparencyID)==1)
                selectedAttributes.Transparency=self.Transparency;
            end

            if(messageIds(self.TwoSidedID)==1)
                selectedAttributes.TwoSided=self.TwoSided;
            end
            if(messageIds(self.ShininessID)==1)
                selectedAttributes.Shininess=self.Shininess;
            end
            if(messageIds(self.MetallicID)==1)
                selectedAttributes.Metallic=self.Metallic;
            end
            if(messageIds(self.RefractionID)==1)
                selectedAttributes.Refraction=self.Refraction;
            end
            if(messageIds(self.FlatID)==1)
                selectedAttributes.Flat=self.Flat;
            end
            if(messageIds(self.TessellationID)==1)
                selectedAttributes.Tessellation=self.Tessellation;
            end
            if(messageIds(self.VertexBlendID)==1)
                selectedAttributes.VertexBlend=self.VertexBlend;
            end
            if(messageIds(self.ShadowsID)==1)
                selectedAttributes.Shadows=self.Shadows;
            end
            if(messageIds(self.TextureID)==1)
                selectedAttributes.Texture=self.Texture;
            end
            if(messageIds(self.TextureMappingID)==1)


                selectedAttributes.TextureMapping=self.TextureMapping.getData();
            end
            if(messageIds(self.TextureTransformID)==1)


                selectedAttributes.TextureTransform=self.TextureTransform.getData();
            end


        end

    end


end
