







classdef EditModeManager<handle

    properties

DataName


OriginalPointCloud






CurrentPointCloud



CurrentIndex


NumFrames



EditStack


EditRedoStack
    end

    events
ExternalTrigger
    end

    methods

        function createEditStack(this,dataName,numFrames,index,ptCldArray)



            this.DataName=dataName;
            this.OriginalPointCloud=ptCldArray;
            this.NumFrames=numFrames;
            this.CurrentIndex=index;
            this.EditStack=cell(numFrames,1);
            this.EditRedoStack=cell(numFrames,1);
            this.CurrentPointCloud=this.getOriginalFrameData(index);
        end


        function deleteEditStack(this)



            this.DataName=[];
            this.OriginalPointCloud={};
            this.CurrentPointCloud={};
            this.CurrentIndex=[];
            this.EditStack={};
            this.NumFrames=[];
            this.EditRedoStack={};

        end


        function updateCurrentIndex(this,frameId)

            this.CurrentIndex=frameId;
            ptCld=getOriginalFrameData(this,frameId);
            this.updateCurrentPointCloudInEditMode(ptCld);





        end


        function saveEditParams(this,editData)

            selectedFrames=editData.SelectedFrames;

            if isempty(selectedFrames)
                frameIdx=this.CurrentIndex;
                this.EditStack{frameIdx}{end+1}=editData;



                this.EditRedoStack{frameIdx}={};
            else
                for frameIdx=1:length(selectedFrames)
                    this.EditStack{selectedFrames(frameIdx)}{end+1}=editData;
                    this.EditRedoStack{selectedFrames(frameIdx)}={};
                end
            end
        end


        function editStack=getEditsOnCurrentFrame(this,toGetLastOp)


            frameIdx=this.CurrentIndex;
            if toGetLastOp

                editStack=this.EditStack{frameIdx}(end);
            else

                editStack=this.EditStack{frameIdx};
            end
        end


        function updateCurrentPointCloudInEditMode(this,ptCld)

            this.CurrentPointCloud=ptCld;
        end


        function data=revertAllEditsOnCurrentFrame(this)

            frameId=this.CurrentIndex;
            data=this.OriginalPointCloud{frameId};
            this.CurrentPointCloud=data.PointCloud;


            for i=1:numel(this.EditStack{frameId})

                this.EditRedoStack{this.CurrentIndex}{end+1}=...
                this.EditStack{this.CurrentIndex}{end};

                this.EditStack{this.CurrentIndex}(end)=[];
            end

            this.EditStack{frameId}={};
        end


        function[originalPtCldArray,editStack]=getDataFromESM(this)

            originalPtCldArray=this.OriginalPointCloud;
            editStack=this.EditStack;
        end
    end




    methods
        function[originalPtCld,editStack]=doUndo(this)





            originalPtCld=this.OriginalPointCloud{this.CurrentIndex};


            this.EditRedoStack{this.CurrentIndex}{end+1}=...
            this.EditStack{this.CurrentIndex}{end};

            this.EditStack{this.CurrentIndex}(end)=[];


            editStack=this.EditStack{this.CurrentIndex};
        end


        function editOp=doRedo(this)





            this.EditStack{this.CurrentIndex}{end+1}=...
            this.EditRedoStack{this.CurrentIndex}{end};

            this.EditRedoStack{this.CurrentIndex}(end)=[];


            editOp=this.EditStack{this.CurrentIndex}{end};
        end

    end




    methods(Access=private)

        function pointCloudOut=getOriginalFrameData(this,index)


            data=this.OriginalPointCloud{index};
            pointCloudOut=data.PointCloud;
        end
    end
end


