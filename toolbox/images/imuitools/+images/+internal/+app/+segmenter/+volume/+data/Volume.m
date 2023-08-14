classdef Volume<handle&matlab.mixin.SetGet




    events


VolumeUpdated



RGBAUpdated

RGBLimitsUpdated

    end


    properties(Dependent)


Data


Colormap


Alphamap

    end


    properties(SetAccess=private,Dependent)

OriginalData

    end


    properties(SetAccess=private)

        Size(1,3)double=[0,0,0];
        HasData(1,1)logical=false;
        Datatype char='';

        RedLimit single
        GreenLimit single
        BlueLimit single

    end


    properties(Access=private,Hidden,Transient)


        DataInternal uint8


OriginalDataInternal




        AlphamapInternal(256,1)single{mustBeGreaterThanOrEqual(AlphamapInternal,0),mustBeLessThanOrEqual(AlphamapInternal,1)}
        ColormapInternal(256,3)single{mustBeGreaterThanOrEqual(ColormapInternal,0),mustBeLessThanOrEqual(ColormapInternal,1)}

    end

    methods




        function self=Volume()




            self.ColormapInternal=single(gray(256));



            self.AlphamapInternal=[zeros([78,1],'single');ones([178,1],'single')*0.25];

        end




        function slice=getSlice(self,idx,dim)





            if idx>0&&idx<=self.Size(dim)&&idx==round(idx)

                switch dim
                case 1
                    if size(self.DataInternal,4)>1
                        slice=permute(squeeze(self.DataInternal(idx,:,:,:)),[2,1,3,4]);
                    else
                        slice=squeeze(self.DataInternal(idx,:,:,:))';
                    end
                case 2
                    slice=squeeze(self.DataInternal(:,idx,:,:));
                case 3
                    slice=squeeze(self.DataInternal(:,:,idx,:));
                otherwise
                    slice=uint8.empty;
                end

            else
                slice=uint8.empty;
            end

        end




        function slice=getOriginalSlice(self,idx,dim)





            if idx>0&&idx<=self.Size(dim)&&idx==round(idx)

                switch dim
                case 1
                    if size(self.DataInternal,4)>1
                        slice=permute(squeeze(self.OriginalDataInternal(idx,:,:,:)),[2,1,3,4]);
                    else
                        slice=squeeze(self.OriginalDataInternal(idx,:,:,:))';
                    end
                case 2
                    slice=squeeze(self.OriginalDataInternal(:,idx,:,:));
                case 3
                    slice=squeeze(self.OriginalDataInternal(:,:,idx,:));
                otherwise
                    slice=uint8.empty;
                end

            else
                slice=uint8.empty;
            end

        end




        function clear(self)


            self.DataInternal=uint8.empty;
            self.OriginalDataInternal=[];

            self.Size=[0,0,0];
            self.HasData=false;

        end




        function updateRendering(self,thresh,alpha)




            thresh=round(thresh*255);

            self.Alphamap=[zeros([thresh+1,1],'single');ones([255-thresh,1],'single')*alpha];

        end




        function[val,pos]=getVoxel(self,pos,idx,dim)

            try
                switch dim
                case 1
                    pos=[idx,pos(1),pos(2)];
                    val=self.OriginalData(pos(1),pos(2),pos(3),:);
                case 2
                    pos=[idx,pos(2),pos(1)];
                    val=self.OriginalData(pos(2),pos(1),pos(3),:);
                case 3
                    pos=[pos(1),pos(2),idx];
                    val=self.OriginalData(pos(2),pos(1),pos(3),:);
                end

            catch
                val=[];
                pos=[];
            end

        end




        function updateRGBLimits(self,R,G,B)

            if R(1)<=R(2)&&all(isfinite(R))
                self.RedLimit=R;
            end

            if G(1)<=G(2)&&all(isfinite(G))
                self.GreenLimit=G;
            end

            if B(1)<=B(2)&&all(isfinite(B))
                self.BlueLimit=B;
            end

            notify(self,'RGBLimitsUpdated',images.internal.app.segmenter.volume.events.RGBLimitsEventData(self.RedLimit,self.GreenLimit,self.BlueLimit));

            self.DataInternal=images.internal.app.segmenter.volume.data.rescaleVolume(self.OriginalData,self.RedLimit,self.GreenLimit,self.BlueLimit);

        end

    end


    methods(Access=private)


        function update(self)




            notify(self,'VolumeUpdated',images.internal.app.segmenter.volume.events.VolumeEventData(...
            self.Data));

        end


        function updateRGBA(self)


            notify(self,'RGBAUpdated');

        end


        function assignRGBLimits(self,datatype)



            if~strcmp(self.Datatype,datatype)||isempty(self.RedLimit)
                switch datatype

                case{'double','single'}
                    limits=[0,1];
                case 'logical'

                    limits=[0,1];
                otherwise
                    limits=[intmin(datatype),intmax(datatype)];

                end

                self.RedLimit=limits;
                self.GreenLimit=limits;
                self.BlueLimit=limits;

                notify(self,'RGBLimitsUpdated',images.internal.app.segmenter.volume.events.RGBLimitsEventData(self.RedLimit,self.GreenLimit,self.BlueLimit));

            end

        end

    end


    methods




        function set.Data(self,vol)


            validateattributes(vol,{'numeric'},{'finite','nonsparse'});


            if~images.internal.app.segmenter.volume.data.isVolume(vol)
                error(message('images:segmenter:invalidVolume'));
            end

            datatype=class(vol);
            self.OriginalDataInternal=vol;




            sz=size(vol,1:3);

            if ndims(vol)==4
                assignRGBLimits(self,datatype);
            end

            self.DataInternal=images.internal.app.segmenter.volume.data.rescaleVolume(vol,self.RedLimit,self.GreenLimit,self.BlueLimit);

            self.Size=sz;
            self.HasData=true;
            self.Datatype=datatype;

            update(self);

        end

        function v=get.Data(self)

            v=self.DataInternal;

        end




        function set.Colormap(self,cmap)



            self.ColormapInternal=cmap;

            updateRGBA(self);

        end

        function cmap=get.Colormap(self)

            cmap=self.ColormapInternal;

        end




        function set.Alphamap(self,amap)



            self.AlphamapInternal=amap;

            updateRGBA(self);

        end

        function amap=get.Alphamap(self)

            amap=self.AlphamapInternal;

        end




        function data=get.OriginalData(self)

            data=self.OriginalDataInternal;

        end

    end

end