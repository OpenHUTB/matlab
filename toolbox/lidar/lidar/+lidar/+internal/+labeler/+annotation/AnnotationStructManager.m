classdef AnnotationStructManager<handle




    properties
AnnotationStructs
NumAnnotationStructs
    end

    properties(Access=private)
AnnotationStructFactoryObj
    end




    methods

        function this=AnnotationStructManager()

            this.AnnotationStructFactoryObj=lidar.internal.labeler.annotation.AnnotationStructFactory();

        end

        function num=get.NumAnnotationStructs(this)
            num=numel(this.AnnotationStructs);
        end


        function removeAllAnnotations(this,indices)

            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=this.AnnotationStructs{i};
                removeAllAnnotations(thisAnnotationStructObj,indices);
            end

            if this.NumAnnotationStructs==1&&...
                this.AnnotationStructs{1}.NumImages==0
                this.AnnotationStructs=[];
            end
        end

    end





    methods

        function annotationStructObj=getAnnotationStructFromId(this,id)
            if(id>0)&&(id<=this.NumAnnotationStructs)
                annotationStructObj=this.AnnotationStructs{id};
            else
                annotationStructObj=[];
            end
        end

        function annotationStructObj=getAnnotationStructFromIdNoCheck(this,id)
            annotationStructObj=this.AnnotationStructs{id};
        end

        function annotationStructObj=getAnnotationStructFromName(this,signalName)
            [dispExists,dispIdx]=doesNameExist(this,signalName);
            if dispExists
                annotationStructObj=this.AnnotationStructs{dispIdx};
            else
                annotationStructObj=[];
            end
        end

        function annotationStructObj=getAnnotationStruct(this,nameOrId)
            if~isempty(nameOrId)
                if isnumeric(nameOrId)
                    dispIdx=nameOrId;
                    dispExists=(dispIdx<=this.NumAnnotationStructs);
                else
                    signalName=nameOrId;
                    [dispExists,dispIdx]=doesNameExist(this,signalName);
                end

                if dispExists
                    annotationStructObj=this.AnnotationStructs{dispIdx};
                else
                    if this.NumAnnotationStructs>0
                        annotationStructObj=this.AnnotationStructs{1};
                    else
                        annotationStructObj=[];
                    end
                end
            else
                if this.NumAnnotationStructs>0
                    annotationStructObj=this.AnnotationStructs{1};
                else
                    annotationStructObj=[];
                end
            end
        end

        function N=getNumImages(this,signalName)
            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            N=thisAnnotationStruct.NumImages;
        end

    end
    methods

        function addLabel(this,labelName,scalarV)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=this.AnnotationStructs{i};
                thisAnnotationStructObj.addLabel(labelName,scalarV);
            end
        end

        function removeLabel(this,labelName)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=this.AnnotationStructs{i};
                thisAnnotationStructObj.removeLabel(labelName);
            end
        end

        function changeLabel(this,oldLabemName,newLabelName)
            for i=1:this.NumAnnotationStructs
                thisAnnotationStructObj=this.AnnotationStructs{i};
                thisAnnotationStructObj.changeLabel(oldLabemName,newLabelName);
            end
        end
    end

    methods

        function newAnnotationStruct=createAndAddAnnotationStruct(this,annotType,signalName,numImages,labelSet,varargin)
            newAnnotationStruct=[];
            if isNameUnused(this,signalName)
                newAnnotationStruct=this.AnnotationStructFactoryObj.createAnnotationStruct(annotType,signalName,numImages,labelSet,varargin{:});

                this.AnnotationStructs{end+1}=newAnnotationStruct;
            end
        end

        function appendAnnotationStruct(this,annoS)
            if~isempty(annoS)
                this.AnnotationStructs{end+1}=annoS;
            end
        end

        function removeAnnotationStruct(this,signalName)
            [dispExists,dispIdx]=doesNameExist(this,signalName);
            if dispExists
                this.AnnotationStructs(dispIdx)=[];
            end
        end

        function resetFrameHasAnnotations(this,signalName)
            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            resetFrameHasAnnotations(thisAnnotationStruct);
        end

        function repeatLastAnnotationStruct(this,signalName,numImages,defaultValue)
            thisAnnotationStruct=getAnnotationStruct(this,signalName);
            if isempty(thisAnnotationStruct)

                return;
            end
            repeatLastAnnotationStruct(thisAnnotationStruct,numImages,defaultValue);
            repeatHasAnnotationField(thisAnnotationStruct,numImages);
            thisAnnotationStruct.NumImages=numImages;
        end

        function replaceAnnotationStruct(this,signalName,annotationStruct)
            annotationStructObj=getAnnotationStructFromName(this,signalName);
            annotationStructObj.replaceAnnotationStruct(annotationStruct);
        end

        function tf=hasAnnotation(this,signalName)
            [tf,~]=doesNameExist(this,signalName);
        end


        function updateSignalName(this,oldName,newName)

            success=isNameUnused(this,newName);
            if success
                if this.NumAnnotationStructs>0
                    thisAnnotationStruct=getAnnotationStruct(this,oldName);
                    setSignalName(thisAnnotationStruct,newName);
                end
            end
        end
    end




    methods(Access=private)

        function tf=isNameUnused(this,signalName)

            tf=true;
            for i=1:this.NumAnnotationStructs
                if hasSameName(this.AnnotationStructs{i},signalName)
                    tf=false;
                    return;
                end
            end
        end

        function[tf,dispIdx]=doesNameExist(this,signalName)

            tf=false;
            dispIdx=0;
            for i=1:this.NumAnnotationStructs
                if hasSameName(this.AnnotationStructs{i},signalName)
                    tf=true;
                    dispIdx=i;
                    return;
                end
            end
        end

    end

end
