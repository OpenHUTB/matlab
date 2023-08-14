classdef Label<handle&matlab.mixin.SetGet




    events



LabelsUpdated




NamesUpdated



RGBAUpdated



ErrorThrown

    end


    properties(Dependent)


Data


Alphamap


Colormap

    end


    properties(SetAccess=private,Dependent)


CurrentName


CurrentColor



NumberOfLabels





Names




NumericData

    end


    properties(SetAccess=private,Hidden,Transient)


        CurrentIndex(1,1)double=0;

        HoleMask logical=logical.empty;
        HoleData categorical=categorical.empty;
        ParentMask uint8=uint8.empty;
        Offset double=[0,0];

        PreserveColors(1,1)logical=true;

    end


    properties(Access=private,Hidden,Transient)


        DataInternal categorical=categorical.empty;





        MaxLabelsAllowed(1,1)double=255;

        AlphamapInternal(256,1)single{mustBeGreaterThanOrEqual(AlphamapInternal,0),mustBeLessThanOrEqual(AlphamapInternal,1)}

        ColormapInternal(256,3)single{mustBeGreaterThanOrEqual(ColormapInternal,0),mustBeLessThanOrEqual(ColormapInternal,1)}

    end


    methods




        function self=Label()


            resetDefaultView(self);

        end




        function slice=getSlice(self,idx,dim)




            slice=uint8(getCategoricalSlice(self,idx,dim));

        end




        function setSlice(self,slice,idx,dim)






            if validateIndex(self,idx,dim)

                if iscategorical(slice)

                    switch dim
                    case 1
                        self.DataInternal(idx,:,:)=slice';
                    case 2
                        self.DataInternal(:,idx,:)=slice;
                    case 3
                        self.DataInternal(:,:,idx)=slice;
                    otherwise
                        return;
                    end

                else

                    switch dim
                    case 1
                        self.DataInternal(idx,:,:)=categorical(slice,1:self.NumberOfLabels,self.Names)';
                    case 2
                        self.DataInternal(:,idx,:)=categorical(slice,1:self.NumberOfLabels,self.Names);
                    case 3
                        self.DataInternal(:,:,idx)=categorical(slice,1:self.NumberOfLabels,self.Names);
                    otherwise
                        return;
                    end
                end

                update(self);
            end

        end




        function slice=getCategoricalSlice(self,idx,dim)





            if validateIndex(self,idx,dim)

                switch dim
                case 1
                    slice=squeeze(self.DataInternal(idx,:,:))';
                case 2
                    slice=squeeze(self.DataInternal(:,idx,:));
                case 3
                    slice=self.DataInternal(:,:,idx);
                otherwise
                    slice=categorical.empty;
                end

            else
                slice=categorical.empty;
            end

        end




        function setMask(self,mask,val,prior,priorval,idx,dim,offset)


















            if validateIndex(self,idx,dim)


                if isnumeric(val)
                    if val==0
                        val=missing;
                    else
                        val=self.Names{val};
                    end
                end

                switch dim
                case 1

                    mask=mask';




                    slice=self.DataInternal(idx,:,:);
                    slice(mask)=val;

                    if~isempty(prior)






                        prior=prior';
                        if isempty(priorval)
                            slice(prior&(~mask))=missing;
                        else
                            priorval=priorval';
                            slice(prior&(~mask))=priorval(prior&(~mask));
                        end







                        if~isempty(self.ParentMask)
                            parentMask=self.ParentMask';
                            linearidx=find(parentMask~=0,1);
                            if parentMask(linearidx)>0
                                slice((parentMask~=0)&prior&(~mask))=self.Names{parentMask(linearidx)};
                            end
                        end

                    end

                    slice=accountForHoles(self,slice,offset,dim);

                    self.DataInternal(idx,:,:)=slice;

                case 2

                    slice=self.DataInternal(:,idx,:);
                    slice(mask)=val;

                    if~isempty(prior)
                        if isempty(priorval)
                            slice(prior&(~mask))=missing;
                        else
                            slice(prior&(~mask))=priorval(prior&(~mask));
                        end
                        if~isempty(self.ParentMask)
                            linearidx=find(self.ParentMask~=0,1);
                            if self.ParentMask(linearidx)>0
                                slice((self.ParentMask~=0)&prior&(~mask))=self.Names{self.ParentMask(linearidx)};
                            end
                        end
                    end





                    slice=accountForHoles(self,slice,offset,dim);

                    self.DataInternal(:,idx,:)=slice;

                case 3

                    slice=self.DataInternal(:,:,idx);
                    slice(mask)=val;

                    if~isempty(prior)
                        if isempty(priorval)
                            slice(prior&(~mask))=missing;
                        else
                            slice(prior&(~mask))=priorval(prior&(~mask));
                        end
                        if~isempty(self.ParentMask)
                            linearidx=find(self.ParentMask~=0,1);
                            if self.ParentMask(linearidx)>0
                                slice((self.ParentMask~=0)&prior&(~mask))=self.Names{self.ParentMask(linearidx)};
                            end
                        end
                    end

                    slice=accountForHoles(self,slice,offset,dim);

                    self.DataInternal(:,:,idx)=slice;
                otherwise
                    return;
                end

                update(self);
            end

        end




        function setMaskSection(self,mask,val,idx1,dim)





            idx2=idx1+size(mask,dim)-1;
            if validateIndexRange(self,idx1,idx2,dim)


                if isnumeric(val)
                    if val==0
                        val=missing;
                    else
                        val=self.Names{val};
                    end
                end

                switch dim
                case 1

                    slice=self.DataInternal(idx1:idx2,:,:);
                    slice(mask)=val;

                    self.DataInternal(idx1:idx2,:,:)=slice;

                case 2

                    slice=self.DataInternal(:,idx1:idx2,:);
                    slice(mask)=val;

                    self.DataInternal(:,idx1:idx2,:)=slice;

                case 3

                    slice=self.DataInternal(:,:,idx1:idx2);
                    slice(mask)=val;

                    self.DataInternal(:,:,idx1:idx2)=slice;

                otherwise
                    return;
                end

                update(self);
            end

        end




        function addLabel(self,label)


            if self.NumberOfLabels==self.MaxLabelsAllowed
                throwError(self,getString(message('images:segmenter:maxNumberExceeded')));
            end


            if~iscategory(self.DataInternal,label)

                self.DataInternal=addcats(self.DataInternal,label);

                self.CurrentIndex=self.NumberOfLabels;

            else



                throwError(self,getString(message('images:segmenter:uniqueLabels')));

            end

            updateNames(self);

        end




        function newLabel(self)



            if self.NumberOfLabels==self.MaxLabelsAllowed
                throwError(self,getString(message('images:segmenter:maxNumberExceeded')));
            end


            self.DataInternal=addcats(self.DataInternal,createUniqueLabelName(self));

            self.CurrentIndex=self.NumberOfLabels;

            updateNames(self);

        end




        function removeLabel(self,label)



            if strcmp(label,self.CurrentName)

                if self.CurrentIndex>1


                    self.CurrentIndex=self.CurrentIndex-1;

                elseif self.NumberOfLabels>1


                    self.CurrentIndex=1;

                else

                    self.CurrentIndex=0;

                end

            end

            idx=getLabelIndex(self,label);

            self.DataInternal=removecats(self.DataInternal,label);

            cmap=self.ColormapInternal;
            cmap(idx+1,:)=[];
            cmap(256,:)=rand([1,3],'single');

            amap=self.AlphamapInternal;
            amap(idx+1)=[];
            if any(amap)
                amap(256)=1;
            else
                amap(256)=0;
            end

            self.AlphamapInternal=amap;

            self.Colormap=cmap;

            saveColormap(self);

            updateNames(self);
            update(self);

        end




        function importLabels(self,label)




            try
                switch class(label)
                case 'categorical'


                case 'cell'
                    label=categorical(label);

                case 'char'
                    label=categorical(cellstr(label));

                case 'string'
                    label=categorical(label);

                otherwise
                    return;
                end

            catch
                throwError(self,getString(message('images:segmenter:invalidLabelVariable')));
                return;
            end

            label=categories(label);
            numLabels=numel(label);

            if numLabels>self.MaxLabelsAllowed
                error(message('images:segmenter:maxNumberExceeded'));
            end

            if self.NumberOfLabels~=0

                if numLabels<self.NumberOfLabels

                    self.DataInternal=renamecats(self.DataInternal,self.Names(1:numel(label)),label);

                elseif self.NumberOfLabels<numLabels

                    self.DataInternal=renamecats(self.DataInternal,self.Names,label(1:numel(self.Names)));
                    self.DataInternal=addcats(self.DataInternal,label(numel(self.Names):end));

                else

                    self.DataInternal=renamecats(self.DataInternal,self.Names,label);

                end

            else

                self.DataInternal=label;

            end

            self.CurrentIndex=self.NumberOfLabels;

            updateNames(self);

        end




        function setColor(self,label,color)





            self.ColormapInternal(getLabelIndex(self,label)+1,:)=color;

            saveColormap(self);

            updateRGBA(self);



            updateNames(self);

        end




        function resetColors(self)



            self.ColormapInternal=images.internal.app.segmenter.volume.data.colorOrder();

            saveColormap(self);

            updateRGBA(self);

            updateNames(self);

        end




        function setName(self,label,name)




            if~iscategory(self.DataInternal,name)


                try
                    self.DataInternal=renamecats(self.DataInternal,label,name);
                catch
                    throwError(self,getString(message('images:segmenter:invalidLabelName',name)));
                end

            elseif strcmp(label,name)



            else


                throwError(self,getString(message('images:segmenter:uniqueLabels')));

            end

            updateNames(self);

        end




        function setCurrent(self,label)


            self.CurrentIndex=getLabelIndex(self,label);

        end




        function setOpacity(self,label,alpha)





            self.AlphamapInternal(getLabelIndex(self,label)+1,:)=alpha;

            updateRGBA(self);



            updateNames(self);

        end




        function clear(self)

            self.DataInternal=categorical.empty;
            clearNestingMasks(self);

        end




        function clearButRetainNames(self)




            cats=categories(self.DataInternal);
            self.DataInternal=categorical([],1:numel(cats),cats);

        end




        function[slice,idx]=findNeighboringSliceWithLabel(self,val,currentSlice,dim)





            idx=searchForNeighboringSlice(self,val,currentSlice,dim);

            if isempty(idx)
                slice=uint8.empty;
            else
                slice=getSlice(self,idx,dim);
            end

        end




        function setAlphamap(self,amap)



            if isscalar(amap)
                if amap

                    self.Alphamap=[0;ones([self.MaxLabelsAllowed,1],'single')];
                else

                    self.Alphamap=zeros([self.MaxLabelsAllowed+1,1],'single');
                end
            else
                try %#ok<TRYNC>

                    self.Alphamap=amap;
                end
            end

        end




        function setColormap(self,cmap)



            if size(cmap,1)==1
                self.Colormap=[0,0,0;repmat(cmap,[self.MaxLabelsAllowed,1])];
            else
                try %#ok<TRYNC>

                    self.Colormap=cmap;
                end
            end

        end




        function setEmptyData(self,sz)




            self.DataInternal(1:sz(1),1:sz(2),1:sz(3))=missing;




            addDefaultLabel(self);

        end




        function updateNestingMasks(self,holeMask,parentMask,idx,dim)




            self.HoleMask=holeMask;
            if isempty(self.HoleMask)
                self.HoleData=categorical.empty;
            else
                self.HoleData=getCategoricalSlice(self,idx,dim);
            end
            self.Offset=[0,0];
            self.ParentMask=parentMask;

        end




        function clearNestingMasks(self)


            self.HoleMask=logical.empty;
            self.HoleData=categorical.empty;
            self.ParentMask=uint8.empty;
            self.Offset=[0,0];

        end




        function setCategories(self,cats)



            clear(self);

            if isnumeric(cats)

                cats=createLabelNames(self,cats);
            end

            self.DataInternal=addcats(self.DataInternal,cats);

            self.CurrentIndex=self.NumberOfLabels;

            updateNames(self);

        end




        function setPreserveLabelColors(self,TF)
            self.PreserveColors=TF;
        end

    end


    methods(Access=private)


        function throwError(self,msg)
            notify(self,'ErrorThrown',images.internal.app.segmenter.volume.events.ErrorEventData(msg));
        end


        function update(self)


            notify(self,'LabelsUpdated');

        end


        function updateNames(self)


            notify(self,'NamesUpdated',images.internal.app.segmenter.volume.events.NamesUpdatedEventData(...
            self.Names,self.ColormapInternal,self.AlphamapInternal,self.CurrentIndex));

        end


        function updateRGBA(self)


            notify(self,'RGBAUpdated');

        end


        function saveColormap(self)

            if self.PreserveColors

                try %#ok<TRYNC>
                    s=settings;
                    s.images.VolumeSegmenter.ColorOrder.PersonalValue=double(reshape(self.ColormapInternal,[768,1]));
                end

            end

        end


        function resetDefaultView(self)




            self.ColormapInternal=images.internal.app.segmenter.volume.data.colorOrder();

            s=settings;
            if self.PreserveColors
                try %#ok<*TRYNC> 
                    self.ColormapInternal=single(reshape(s.images.VolumeSegmenter.ColorOrder.ActiveValue,[256,3]));
                end
            end

            saveColormap(self);



            self.AlphamapInternal=[0;ones([self.MaxLabelsAllowed,1],'single')];

        end


        function labels=createLabelNames(~,numLabels)



            labels=cell(numLabels,1);

            for idx=1:numLabels
                labels{idx}=['Label',num2str(idx)];
            end

        end


        function label=createUniqueLabelName(self)

            for idx=1:self.MaxLabelsAllowed


                label=['Label',num2str(idx)];


                if~iscategory(self.DataInternal,label)


                    break;
                end

            end

        end


        function idx=getLabelIndex(self,label)

            idx=find(cellfun(@(x)strcmp(x,label),self.Names));

        end


        function TF=validateIndex(self,idx,dim)

            TF=idx>0&&...
            idx<=size(self.DataInternal,dim)&&...
            idx==round(idx);

        end


        function TF=validateIndexRange(self,idx1,idx2,dim)

            TF=validateIndex(self,idx1,dim)&&validateIndex(self,idx2,dim);

        end


        function addDefaultLabel(self)

            if self.NumberOfLabels==0
                addLabel(self,'Label1');
            end

        end


        function neighboridx=searchForNeighboringSlice(self,val,currentSlice,dim)



            mask=self.NumericData==val;

            switch dim

            case 1
                TF=squeeze(any(any(mask,2),3))';
            case 2
                TF=squeeze(any(any(mask,1),3));
            case 3
                TF=squeeze(any(any(mask,1),2));

            end

            TF(currentSlice)=false;

            idx=find(TF);

            if~isempty(idx)

                if currentSlice~=1&&~TF(currentSlice-1)
                    loweridx=idx(idx<currentSlice-1);
                else
                    loweridx=[];
                end

                if isempty(loweridx)

                    if currentSlice~=numel(TF)&&~TF(currentSlice+1)
                        upperidx=idx(idx>currentSlice+1);
                    else
                        upperidx=[];
                    end

                    if isempty(upperidx)

                        throwError(self,getString(message('images:segmenter:noGapFound')));
                        neighboridx=[];

                    else

                        neighboridx=min(upperidx);

                    end

                else

                    neighboridx=max(loweridx);

                end

            else

                throwError(self,getString(message('images:segmenter:noNeighborFound')));
                neighboridx=[];

            end

        end


        function slice=accountForHoles(self,slice,offset,dim)



            if~isempty(self.HoleMask)

                mask=self.HoleMask;
                tempslice=self.HoleData;



                self.Offset=offset+self.Offset;
                offset=round(self.Offset);

                if any(offset~=0)



                    if offset(1)~=0
                        if offset(1)>0
                            mask=padarray(mask,[0,offset(1)],'pre');
                            tempslice=padarray(tempslice,[0,offset(1)],'pre');
                            dim2=1:size(self.HoleMask,2);
                        else
                            mask=padarray(mask,[0,abs(offset(1))],'post');
                            tempslice=padarray(tempslice,[0,abs(offset(1))],'post');
                            dim2=size(mask,2)-size(self.HoleMask,2)+1:size(mask,2);
                        end
                    else
                        dim2=1:size(self.HoleMask,2);
                    end



                    if offset(2)~=0
                        if offset(2)>0
                            mask=padarray(mask,[offset(2),0],'pre');
                            tempslice=padarray(tempslice,[offset(2),0],'pre');
                            dim1=1:size(self.HoleMask,1);
                        else
                            mask=padarray(mask,[abs(offset(2)),0],'post');
                            tempslice=padarray(tempslice,[abs(offset(2)),0],'post');
                            dim1=size(mask,1)-size(self.HoleMask,1)+1:size(mask,1);
                        end
                    else
                        dim1=1:size(self.HoleMask,1);
                    end







                    mask=mask(dim1,dim2);
                    tempslice=tempslice(dim1,dim2);

                end

                if dim==1
                    mask=mask';
                    tempslice=tempslice';
                end

                slice(mask)=tempslice(mask);

            end

        end

    end


    methods




        function set.Data(self,lab)

            try

                validLabels=ndims(lab)>=2&&ndims(lab)<=3;

                if~validLabels
                    error(message('images:volumeViewer:requireVolumeData'));
                end

                supportedClasses={'numeric','categorical','logical'};

                if iscategorical(lab)

                    numLabels=numel(categories(lab));
                    supportedAttributes={'nonsparse','real','nonempty'};

                elseif islogical(lab)

                    numLabels=1;
                    supportedAttributes={'nonsparse','real','nonempty'};

                else

                    if any(lab,'all')
                        labelVals=unique(lab(:));
                        labelVals=labelVals(labelVals~=0);
                    else


                        labelVals=[];
                    end
                    numLabels=numel(labelVals);
                    labels=createLabelNames(self,numLabels);
                    supportedAttributes={'real','nonsparse','nonempty','integer','nonnegative'};

                end

                validateattributes(lab,supportedClasses,supportedAttributes,mfilename,'Labels');

                if numLabels>self.MaxLabelsAllowed
                    error(message('images:segmenter:maxNumberExceeded'));
                end

                priorNumberOfLabels=self.NumberOfLabels;

                if iscategorical(lab)


                    self.DataInternal=lab;

                elseif islogical(lab)


                    self.DataInternal=categorical(lab,1,'Foreground');

                else



                    if max(lab(:))>0
                        self.DataInternal=images.internal.app.segmenter.volume.data.stitchedCategorical(lab,labelVals,labels);
                    else




                        sz=size(lab,1:3);
                        self.DataInternal=categorical([],labelVals,labels);
                        self.DataInternal(1:sz(1),1:sz(2),1:sz(3))=missing;
                    end

                end

                if numLabels>0





                    resetSelectedLabel=priorNumberOfLabels~=numLabels;

                    if resetSelectedLabel
                        self.CurrentIndex=self.NumberOfLabels;
                    end

                    updateNames(self);

                end




                addDefaultLabel(self);

            catch ME
                throwError(self,ME.message);
            end

        end

        function labels=get.Data(self)


            labels=self.DataInternal;

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




        function name=get.CurrentName(self)

            if self.CurrentIndex>0
                name=self.Names{self.CurrentIndex};
            else
                name='';
            end

        end




        function color=get.CurrentColor(self)

            if self.CurrentIndex>0
                color=self.Colormap(self.CurrentIndex+1,:);
            else
                color=[];
            end

        end




        function labels=get.NumericData(self)

            labels=uint8(self.DataInternal);

        end




        function n=get.NumberOfLabels(self)

            n=numel(categories(self.DataInternal));

        end




        function names=get.Names(self)

            names=categories(self.DataInternal);

        end




        function set.CurrentIndex(self,idx)

            self.CurrentIndex=idx;

        end

    end

end