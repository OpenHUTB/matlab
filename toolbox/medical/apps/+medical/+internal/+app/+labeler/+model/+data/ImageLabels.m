classdef ImageLabels<handle&matlab.mixin.SetGet




    properties

DataName
Data
        HasNonEmptyLabels(1,1)logical=false;
IsDirty

    end

    properties

        LabelDataSource=""
IsLabelDataValidated

    end

    properties(Dependent)
RawData
DataType
    end

    properties(Access=protected)
DataSize
    end

    properties(SetAccess=private,Hidden,Transient)

        HoleMask logical=logical.empty;
        HoleData categorical=uint8.empty;
        ParentMask uint8=uint8.empty;
        Offset double=[0,0];

    end

    events
ErrorThrown
LabelsUpdated
UpdateLabelStatus
    end

    methods


        function read(self,dataName,labelSource,isLabelDataValidated,dataSize)

            self.DataName=dataName;
            self.LabelDataSource=labelSource;
            self.IsLabelDataValidated=isLabelDataValidated;
            self.DataSize=dataSize;

            self.readData();

            self.IsDirty=false;
            self.HasNonEmptyLabels=true;

        end


        function clear(self)

            self.LabelDataSource="";
            self.IsLabelDataValidated=false;
            self.Data=[];
            self.DataSize=[];
            self.HasNonEmptyLabels=false;

        end


        function setEmptyData(self,dataSize)

            if numel(dataSize)>2
                dataSize=dataSize(1:3);
            end
            labels=zeros(dataSize,'uint8');
            self.Data=labels;

            self.DataSize=dataSize;
            self.IsLabelDataValidated=true;

            self.HasNonEmptyLabels=false;

        end


        function slice=getSlice(self,idx,~)

            slice=[];
            if isempty(self.Data)
                return;
            end

            slice=self.Data(:,:,idx);

        end


        function setSlice(self,slice,idx,~)

            self.Data(:,:,idx)=slice;

            self.HasNonEmptyLabels=true;
            self.IsDirty=true;

            self.notify('LabelsUpdated');

        end


        function setMask(self,mask,val,prior,priorval,offset,idx,~)





















            slice=self.getSlice(idx);
            slice(mask)=val;

            if~isempty(prior)





                if isempty(priorval)
                    slice(prior&(~mask))=0;
                else
                    slice(prior&(~mask))=priorval(prior&(~mask));
                end






                if~isempty(self.ParentMask)
                    parentMask=self.ParentMask;
                    linearidx=find(parentMask~=0,1);
                    if parentMask(linearidx)>0
                        slice((parentMask~=0)&prior&(~mask))=parentMask(linearidx);
                    end
                end

            end

            slice=accountForHoles(self,slice,offset);
            self.setSlice(slice,idx);

        end



        function setMaskSection(self,mask,val,idx1,~)





            for i=1:size(mask,3)

                slice=self.getSlice(idx1+i-1);
                slice(mask(:,:,i))=val;

                self.setSlice(slice,idx1+i-1);

            end

        end


        function updateNestingMasks(self,holeMask,parentMask,idx,~)




            self.HoleMask=holeMask;
            if isempty(self.HoleMask)
                self.HoleData=uint8.empty;
            else
                self.HoleData=self.getSlice(idx);
            end
            self.Offset=[0,0];
            self.ParentMask=parentMask;

        end


        function clearNestingMasks(self)


            self.HoleMask=logical.empty;
            self.HoleData=uint8.empty;
            self.ParentMask=uint8.empty;
            self.Offset=[0,0];

        end


        function[slice,idx]=findNeighboringSliceWithLabel(self,val,currentSlice,~)





            idx=self.searchForNeighboringSlice(val,currentSlice);

            if isempty(idx)
                slice=uint8.empty;
            else
                slice=self.getSlice(idx);
            end

        end


        function tempValues=getTempValues(self)

            tempValues=struct();
            tempValues.IsLabelDataValidated=self.IsLabelDataValidated;

        end


        function removePixelLabelValue(self,pixId)

            labelData=self.Data;
            pixId=cast(pixId,class(labelData));

            idx=labelData==pixId;

            if any(idx,'all')

                labelData(idx)=0;
                self.Data=labelData;

                self.IsDirty=true;
                self.notify('LabelsUpdated');

            end

        end


        function planeMapping=getPlaneMapping(~)
            planeMapping=3;
        end

    end

    methods(Access=protected)


        function readData(self)

            data=load(self.LabelDataSource);
            self.Data=data.labels;

            if~self.IsLabelDataValidated

                try
                    validateattributes(self.Data,{'numeric'},{'finite','integer',...
                    '>=',0,'<=',255});
                catch
                    error(message('medical:medicalLabeler:invalidLabelData',self.DataName));
                end

                if~isequal(size(self.Data),self.DataSize)
                    error(message('medical:medicalLabeler:invalidLabelDataSize',self.DataName));
                end

                self.IsLabelDataValidated=true;

            end

        end


        function neighboridx=searchForNeighboringSlice(self,val,currentSlice,~)


            mask=self.Data==val;

            TF=squeeze(any(any(mask,1),2));

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

                        evt=medical.internal.app.labeler.events.ErrorEventData(getString(message('images:segmenter:noGapFound')));
                        self.notify('ErrorThrown',evt);
                        neighboridx=[];

                    else

                        neighboridx=min(upperidx);

                    end

                else

                    neighboridx=max(loweridx);

                end

            else

                evt=medical.internal.app.labeler.events.ErrorEventData(getString(message('images:segmenter:noNeighborFound')));
                self.notify('ErrorThrown',evt);

                neighboridx=[];

            end

        end


        function slice=accountForHoles(self,slice,offset)



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

                slice(mask)=tempslice(mask);

            end

        end

    end


    methods


        function labelData=get.RawData(self)
            labelData=self.Data;
        end

        function set.RawData(self,labelData)
            self.Data=labelData;
            self.HasNonEmptyLabels=true;
            self.IsDirty=true;
        end


        function dataType=get.DataType(self)
            dataType='uint8';
            if~isempty(self.Data)
                dataType=class(self.Data);
            end
        end


        function set.HasNonEmptyLabels(self,TF)

            if~self.HasNonEmptyLabels&&TF


                hasLabels=true;
                evt=medical.internal.app.labeler.events.DataEventData(self.DataName,hasLabels);%#ok<MCSUP> 
                self.notify('UpdateLabelStatus',evt);



                self.HasNonEmptyLabels=true;

            end

            self.HasNonEmptyLabels=TF;

        end

    end

end
