classdef ROIAnnotationStruct<vision.internal.labeler.annotation.ROIAnnotationStruct




    properties(Access=private)
LabelSet
SublabelSet
AttributeSet
    end

    properties(Access=protected)
IsVoxelLabelChanged
    end

    methods
        function this=ROIAnnotationStruct(varargin)

            if nargin<6
                that=varargin{1};
                signalName=that.SignalName;
                numImages=that.NumImages;
                labelSet=varargin{2};
                sublabelSet=varargin{3};
                attributeSet=varargin{4};
                signalType=that.SignalType;

            else
                signalName=varargin{1};
                numImages=varargin{2};
                labelSet=varargin{3};
                sublabelSet=varargin{4};
                attributeSet=varargin{5};
                signalType=varargin{6};
            end

            if strcmp(signalType,'PointCloud')
                signalType=vision.labeler.loading.SignalType.PointCloud;
            end

            this=this@vision.internal.labeler.annotation.ROIAnnotationStruct(signalName,numImages,labelSet,sublabelSet,attributeSet,signalType);
            this.LabelSet=labelSet;
            this.SublabelSet=sublabelSet;
            this.AttributeSet=attributeSet;





            for n=1:this.LabelSet.NumLabels
                labelDef=this.LabelSet.DefinitionStruct(n);
                if labelDef.Type==lidarLabelType.Voxel&&isfield(this.AnnotationStruct_,labelDef.Name)
                    this.AnnotationStruct_=rmfield(this.AnnotationStruct_,labelDef.Name);
                end
            end

            if nargin<6
                this.AnnotationStruct_=that.AnnotationStruct_;
            end
        end

        function[positions,labelNames,sublabelNames,selfUIDs,parentUIDs,colors,shapes,roiOrder,roiVisibility]=...
            queryAnnotation(this,frameIdx)



            frameIdx=max(frameIdx,1);

            positions={};
            labelNames={};
            sublabelNames={};
            colors={};
            selfUIDs={};
            parentUIDs={};
            shapes=labelType([]);
            roiOrder={};
            roiVisibility={};



            s=getAnnotationStructPerFrame(this,frameIdx);

            if isempty(s)||isempty(fieldnames(s))
                return;
            end

            labelSet=this.LabelSet;


            allLabelNames=fieldnames(s);

            for lInx=1:numel(allLabelNames)
                label=allLabelNames{lInx};
                if~strcmp(label,'VoxelLabelData')
                    if isfield(s.(label),'Position')
                        numLabelROIs=getNumLabelROIsInAnnotation(s,label);

                        for i=1:numLabelROIs
                            allSublabelNames=getSublabelNames(this,s.(label)(i));
                            roiPos_label_i=s.(label)(i).Position;
                            roiUIDs_label_i=s.(label)(i).LabelUIDs;
                            if isfield(s.(label),'ROIOrder')
                                roiOrder_label_i=s.(label)(i).ROIOrder;
                            else
                                roiOrder_label_i=[];
                            end


                            positions{end+1}=roiPos_label_i;%#ok<AGROW>
                            labelNames{end+1}=label;%#ok<AGROW>
                            sublabelNames{end+1}='';%#ok<AGROW>
                            selfUIDs{end+1}=roiUIDs_label_i;%#ok<AGROW>
                            parentUIDs{end+1}='';%#ok<AGROW> % labels don't have a parent

                            labelID=labelSet.labelNameToID(label);
                            labelColor=labelSet.queryLabelColor(labelID);
                            colors{end+1}=labelColor;%#ok<AGROW>

                            labelShape=labelSet.queryLabelShape(labelID);
                            shapes(end+1)=labelShape;%#ok<AGROW>
                            roiOrder(end+1)={roiOrder_label_i};%#ok<AGROW>

                            isROIVisible=labelSet.queryROIVisible(labelID);
                            roiVisibility{end+1}=isROIVisible;%#ok<AGROW>

                        end
                    end
                end
            end
        end


        function addAnnotation(this,frameIdx,doAppend,isVoxelLabel,...
            labelNames,sublabelNames,labelUIDs,sublabelUIDs,positions)


            frameIdx=max(frameIdx,1);

            if~isVoxelLabel
                numRois=numel(labelNames);


                s=this.AnnotationStruct_(frameIdx);
                hasAttributeDef=isfield(s,this.ATTRIB_NS);

                if~doAppend
                    s=resetAnnotationStruct(this,s);
                end

                if isfield(this.AnnotationStruct_,'VoxelLabelData')
                    labelMatrixValue=this.AnnotationStruct_(frameIdx).VoxelLabelData;
                    s.VoxelLabelData=labelMatrixValue;
                end

                isLabels=cellfun(@isempty,sublabelNames);

                for n=1:numRois
                    roiPos=positions{n};
                    if~isempty(roiPos)
                        if isLabels(n)


                            s=appendLabelToStruct(this,s,labelNames{n},labelUIDs{n},positions{n},n);
                            if hasAttributeDef
                                s=updateAttributeOfLabelIfNotYetSet(this,s,labelNames{n},labelUIDs{n});
                            end
                        end
                    end
                end


                if numRois>0
                    this.FrameHasAnnotations(frameIdx)=true;
                else
                    this.FrameHasAnnotations(frameIdx)=false;
                end
            end


            this.AnnotationStruct_(frameIdx)=s;

        end


        function[allUIDs,allPositions,allNames,allColors,allShapes,...
            allAttributes]=queryAnnotationsInInterval(this,indices)

            indices=max(indices,1);
            allUIDs=repmat({{}},size(indices));
            allPositions=repmat({{}},size(indices));
            allNames=repmat({{}},size(indices));
            allColors=repmat({{}},size(indices));
            allShapes=repmat({labelType([])},size(indices));
            allAttributes=repmat({{}},size(indices));


            allS=this.AnnotationStruct_(indices);


            allLabelNames=fieldnames(allS);
            voxelLabelIndex=find(strcmpi(allLabelNames,'VoxelLabelData'));

            if~isempty(voxelLabelIndex)
                allLabelNames(voxelLabelIndex)=[];
            end

            attribNSIndex=find(strcmpi(allLabelNames,this.ATTRIB_NS));
            hasAttrib=false;
            if~isempty(attribNSIndex)
                allLabelNames(attribNSIndex)=[];
                hasAttrib=true;


            end

            numLabels=numel(allLabelNames);
            labelIDs=cellfun(@(lname)this.LabelSet.labelNameToID(lname),allLabelNames,'UniformOutput',false);
            labelColors=cellfun(@(lid)this.LabelSet.queryLabelColor(lid),labelIDs,'UniformOutput',false);
            labelShapes=cellfun(@(lid)this.LabelSet.queryLabelShape(lid),labelIDs,'UniformOutput',false);
            for n=1:numel(indices)
                s=allS(n);
                if hasAttrib
                    sAttrib=s.(this.ATTRIB_NS);
                end

                if isempty(s)
                    continue;
                end

                uids=allUIDs{n};
                positions=allPositions{n};
                names=allNames{n};
                colors=allColors{n};
                shapes=allShapes{n};
                attributes=allAttributes{n};

                for lInx=1:numLabels
                    label=allLabelNames{lInx};
                    if isfield(s.(label),'Position')
                        roiPos={s.(label).Position};
                        selfUIDs={s.(label).LabelUIDs};
                        if hasAttrib&&isfield(sAttrib,label)
                            attribs=sAttrib.(label);
                        end
                        for i=1:numel(selfUIDs)
                            if~isempty(roiPos)
                                uids{end+1}=selfUIDs{i};%#ok<AGROW>
                                positions{end+1}=roiPos{i};%#ok<AGROW>
                                names{end+1}=label;%#ok<AGROW>
                                colors{end+1}=labelColors{lInx};%#ok<AGROW>
                                shapes{end+1}=labelShapes{lInx};%#ok<AGROW>

                                if hasAttrib&&isfield(sAttrib,label)
                                    [attribNames,attribValues]=getAttribInfoForLabels(this,attribs,selfUIDs{i});
                                    attribS=[];
                                    for j=1:numel(attribNames)
                                        attribS.(attribNames{j})=attribValues{j};
                                    end
                                    attributes{end+1}=attribS;%#ok<AGROW>
                                else
                                    attributes{end+1}=[];%#ok<AGROW>
                                end
                            end
                        end
                    end
                end

                allUIDs{n}=uids;
                allPositions{n}=positions;
                allNames{n}=names;
                allColors{n}=colors;
                allShapes{n}=shapes;
                allAttributes{n}=attributes;
            end
        end


        function newS=formatAnnotationStructure(this)
            if hasAnyAttribDefinition(this)||hasSublabels(this)
                newS=formatAnnotationStructForAll(this);
                newS=convertCellToStruct(this,newS);
            else
                newS=formatAnnotationStructForLabelsOnly(this);
            end
        end


        function labelMatrixValue=getVoxelLabelAnnotation(this,index)

            if isfield(this.AnnotationStruct_,'VoxelLabelData')
                labelMatrixValue=this.AnnotationStruct_(index).VoxelLabelData;
            else
                labelMatrixValue='';
            end

        end


        function numAnnotations=queryVoxelSummary(this,voxelLabelIndex,indices)


            indices=max(indices,1);
            numAnnotations=zeros(size(indices));
            for i=1:numel(indices)
                idx=indices(i);
                try
                    data=load(this.AnnotationStruct_(idx).VoxelLabelData);
                    if numel(size(data.L))==3
                        numAnnotations(i)=sum(sum(data.L(:,:,4)==voxelLabelIndex))/numel(data.L(:,:,4));
                    else
                        numAnnotations(i)=sum(data.L(:,4)==voxelLabelIndex)/length(data.L(:,4));
                    end
                catch


                    numAnnotations(i)=0;
                end
            end
        end


        function setVoxelLabelAnnotation(this,index,labelPath)

            if~isfield(this.AnnotationStruct_,'VoxelLabelData')

                this.AnnotationStruct_(end).VoxelLabelData='';
            end

            s=this.AnnotationStruct_(index);
            s.VoxelLabelData=labelPath;
            this.AnnotationStruct_(index)=s;
        end


        function tf=hasVoxelAnnotation(this)
            tf=isfield(this.AnnotationStruct_,'VoxelLabelData');
        end


        function structIn=dropPolygonROIsOrder(this,structIn)

            numStructs=numel(structIn);

            for i=1:numStructs
                currentStruct=structIn(i);
                currentFields=fields(currentStruct);



                voxelIdx=cellfun(@(x)strcmp(x,'VoxelLabelData'),currentFields);

                currentFields(voxelIdx)=[];

                for j=1:numel(currentFields)

                    if(isstruct(currentStruct.(currentFields{j})))


                        if(isfield(structIn(i).(currentFields{j}),'ROIOrder'))
                            structIn(i).(currentFields{j})=...
                            rmfield(structIn(i).(currentFields{j}),'ROIOrder');
                        end
                    end
                end
            end
        end

        function uncache(this)
            this.AnnotationStruct_=this.Cache.AnnotationStruct_;
        end

        function mergeWithCache(this,indices,varargin)

            ATTRIB_NAME_SPACE=this.ATTRIB_NS;


            newAnnotationsInterval=this.AnnotationStruct_(indices);

            uncache(this);





            hasAttribDef=isfield(this.AnnotationStruct_,this.ATTRIB_NS);
            if hasAttribDef
                for i=1:numel(indices)
                    idx=indices(i);
                    this.AnnotationStruct_(idx).(ATTRIB_NAME_SPACE)=newAnnotationsInterval(i).(ATTRIB_NAME_SPACE);
                end
            end







            fieldNames=excludeAttribNameSpace(this,fieldnames(this.AnnotationStruct_));

            unimportedROIs=varargin{1};


            mergedAnnoS_i1=this.AnnotationStruct_(indices(1));

            for n=1:numel(unimportedROIs)
                labelID=unimportedROIs(n).ID;
                labelName=unimportedROIs(n).Label;
                labelPos=unimportedROIs(n).Position;
                parentUID=unimportedROIs(n).ParentUID;

                if isempty(parentUID)
                    S_loc_id.Position=labelPos;
                    S_loc_id.LabelUIDs=labelID;
                    mergedAnnoS_i1=mergeLabelInfoInAnnotationS(this,mergedAnnoS_i1,labelName,S_loc_id);






                end
            end



            newAnnotations=newAnnotationsInterval(1);
            for n=1:numel(fieldNames)
                labelName=fieldNames{n};
                if~strcmp(labelName,'VoxelLabelData')
                    mergedAnnoS_i1=mergeLabelInfoInAnnotationS(this,mergedAnnoS_i1,labelName,newAnnotations.(labelName));



                    if(isfield(mergedAnnoS_i1,labelName)&&...
                        isfield(mergedAnnoS_i1.(labelName),'Position'))
                        this.FrameHasAnnotations(indices(1))=true;
                    end
                end
            end
            this.AnnotationStruct_(indices(1))=mergedAnnoS_i1;


            for idx=2:numel(indices)

                mergedAnnoS_ii=this.AnnotationStruct_(indices(idx));
                newAnnotations=newAnnotationsInterval(idx);

                for n=1:numel(fieldNames)
                    labelName=fieldNames{n};
                    if~strcmp(labelName,'VoxelLabelData')
                        mergedAnnoS_ii=mergeLabelInfoInAnnotationS(this,mergedAnnoS_ii,labelName,newAnnotations.(labelName));



                        if(isfield(mergedAnnoS_ii,labelName)&&...
                            isfield(mergedAnnoS_ii.(labelName),'Position'))
                            this.FrameHasAnnotations(indices(idx))=true;
                        end




                    end
                end
                this.AnnotationStruct_(indices(idx))=mergedAnnoS_ii;
            end
        end
    end

    methods(Access=private)


        function TF=hasAnyAttribDefinition(this)
            TF=isfield(this.AnnotationStruct_,this.ATTRIB_NS);
        end


        function TF=hasSublabels(this)
            TF=this.SublabelSet.hasSublabels();
        end


        function matchingOrNextLabelCellID=getMatchingOrNextLabelCellID(~,labelUIDs,labelUID)

            matchingOrNextLabelCellID=find(contains(labelUIDs,labelUID));
            if isempty(matchingOrNextLabelCellID)
                matchingOrNextLabelCellID=numel(labelUIDs)+1;
            end
        end


        function[attribNames,attribValues]=getAttribInfoForLabels(~,attribs,labelUID)
            f=fieldnames(attribs);
            attribNames={};
            attribValues={};

            for i=1:numel(f)
                thisF=f{i};
                if isfield(attribs.(thisF),'AttributeValues')&&isfield(attribs.(thisF),'LabelUIDs')
                    attribNames{end+1}=thisF;%#ok<AGROW>
                    labelUIDs4Attrib={attribs.(thisF).LabelUIDs};
                    matchIdx=find(contains(labelUIDs4Attrib,labelUID));
                    if isempty(matchIdx)
                        attribValues{end+1}=[];%#ok<AGROW>
                    else
                        attribValues{end+1}=attribs.(thisF)(matchIdx).AttributeValues;%#ok<AGROW>
                    end
                end
            end
        end



        function mergedAnnoS_ii=mergeLabelInfoInAnnotationS(this,mergedAnnoS_ii,labelName,S_loc_id)
            for j=1:numel(S_loc_id)
                labelPos=S_loc_id(j).Position;
                labelID=S_loc_id(j).LabelUIDs;
                if(isfield(mergedAnnoS_ii,labelName)&&...
                    isfield(mergedAnnoS_ii.(labelName),'Position'))
                    matchingOrNextLabelCellID=getMatchingOrNextLabelCellID(this,{mergedAnnoS_ii.(labelName).LabelUIDs},labelID);
                    mergedAnnoS_ii.(labelName)(matchingOrNextLabelCellID).Position=labelPos;
                    mergedAnnoS_ii.(labelName)(matchingOrNextLabelCellID).LabelUIDs=labelID;
                    mergedAnnoS_ii.(labelName)(matchingOrNextLabelCellID).ROIOrder=-1;
                else
                    mergedAnnoS_ii.(labelName).Position=labelPos;
                    mergedAnnoS_ii.(labelName).LabelUIDs=labelID;
                    mergedAnnoS_ii.(labelName).ROIOrder=-1;

                end
            end
        end
    end

    methods

        function resetIsVoxelLabelChanged(this)
            this.IsVoxelLabelChanged=false(this.NumImages,1);
        end

        function setIsVoxelLabelChanged(this)
            this.IsVoxelLabelChanged=true(this.NumImages,1);
        end

        function setIsVoxelLabelChangedByIdx(this,idx)
            this.IsVoxelLabelChanged(idx)=true;
        end

        function flagV=getIsVoxelLabelChanged(this)
            flagV=this.IsVoxelLabelChanged;
        end
    end

    methods(Access=private)

        function newS=formatAnnotationStructForLabelsOnly(this)

            newS=this.AnnotationStruct_;
            labelNames=fieldnames(this.AnnotationStruct_(1));
            labelNames=excludeVoxelLabelData(labelNames);
            [labelNames,unsuppLabelNames]=getSupportedLabelNamesForSignal(this,labelNames);

            newS=rmfield(newS,unsuppLabelNames);

            numImages=length(this.AnnotationStruct_);

            for frameIdx=1:numImages
                thisFramesOrigAnnoS=newS(frameIdx);


                if~this.FrameHasAnnotations(frameIdx)
                    continue;
                end


                for lbl=1:numel(labelNames)
                    label_lbl=labelNames{lbl};
                    thisFramesLabel_lbl=thisFramesOrigAnnoS.(label_lbl);
                    numROIs_label_lbl=numel(thisFramesLabel_lbl);
                    if numROIs_label_lbl==0
                        roiValues=[];
                    else
                        labelShape_lbl=queryLabelShapeFromName(this,label_lbl);


                        if(labelShape_lbl==labelType.Line)
                            roiValues=cell(numROIs_label_lbl,1);
                            for r=1:numROIs_label_lbl
                                thisLabelInstanceS=thisFramesLabel_lbl(r);
                                roiValues{r}=thisLabelInstanceS.Position;
                            end
                        elseif(labelShape_lbl==labelType.Rectangle)&&...
                            this.SignalType==vision.labeler.loading.SignalType.PointCloud
                            roiValues=zeros(numROIs_label_lbl,9);
                            for r=1:numROIs_label_lbl
                                thisLabelInstanceS=thisFramesLabel_lbl(r);
                                roiValues(r,1:9)=thisLabelInstanceS.Position;
                            end
                        else
                            assert(false,'ROIAnnotationSet: unknown labelType.');
                        end
                    end
                    thisFramesOrigAnnoS.(label_lbl)=roiValues;
                end
                newS(frameIdx)=thisFramesOrigAnnoS;
            end
        end


        function s=resetAnnotationStruct(~,s)
            allLabelNames=fieldnames(s);
            for lInx=1:numel(allLabelNames)
                label=allLabelNames{lInx};
                if~strcmp(label,'VoxelLabelData')
                    if isfield(s.(label),'Position')
                        s.(label)=[];
                        s.(label)=[];
                    end
                end
            end
        end


        function sublabelNames=getSublabelNames(~,~)


            sublabelNames={};
        end


        function s=appendLabelToStruct(this,s,labelName,labelUID,labelPos,labelOrder)

            labelSet=this.LabelSet;

            labelID=labelSet.labelNameToID(labelName);
            labelShape=labelSet.queryLabelShape(labelID);

            numLabelROIs=getNumLabelROIsInAnnotation(s,labelName);

            order=getNumROIsInAnnotation(s)+1;
            idx=numLabelROIs+1;
            switch labelShape
            case{labelType.Line,labelType.Rectangle,labelType.Polygon,labelType.ProjectedCuboid}
                if iscell(labelPos)
                    labelPos=labelPos{1};
                end
                s.(labelName)(idx).Position=labelPos;
                s.(labelName)(idx).LabelUIDs=labelUID;
                s.(labelName)(idx).ROIOrder=order;
            case lidarLabelType.Voxel

            otherwise
                error('Unhandled Case');
            end
        end


        function labelNames=queryLabelNamesFromDef(this)
            labelNames={this.LabelSet.DefinitionStruct.Name};
        end


        function labelShape=queryLabelShapeFromName(this,labelName)
            labelID=this.LabelSet.labelNameToID(labelName);
            labelShape=this.LabelSet.queryLabelShape(labelID);
        end


        function[supportedLabelNames,unsupportedLabelNames]=getSupportedLabelNamesForSignal(this,inputLabelNames)

            supportedLabelTypes={labelType.Cuboid,labelType.Line,lidarLabelType.Voxel};

            idx=findLabelTypeIndex(supportedLabelTypes,labelType.Cuboid);
            if~isempty(idx)
                supportedLabelTypes{idx}=labelType.Rectangle;
            end

            labelNamesInLabelSet=string({this.LabelSet.DefinitionStruct.Name});
            labelNames=string(inputLabelNames);

            indices=ismember(labelNamesInLabelSet,labelNames);
            labelTypesInLabelSet={this.LabelSet.DefinitionStruct.Type};

            labelTypes=labelTypesInLabelSet(indices);

            idx=isValidLabels(labelTypes,supportedLabelTypes);
            supportedLabelNames=inputLabelNames(idx);

            unsupIdx=1:numel(labelTypes);
            unsupIdx(idx)=[];
            unsupportedLabelNames=inputLabelNames(unsupIdx);

        end



        function outCell=excludeAttribNameSpace(this,inCell)
            outCell=inCell;
            matchIdx=contains(inCell,this.ATTRIB_NS);
            outCell(matchIdx)=[];
        end


        function newS=formatAnnotationStructForAll(this)

            numImages=this.NumImages;
            [newS,hasAnyAttribDef]=removeAttribFromAnnotationStruct(this);

            labelNames=fieldnames(newS(1));
            labelNames=excludeVoxelLabelData(labelNames);

            [labelNames,unsuppLabelNames]=getSupportedLabelNamesForSignal(this,labelNames);

            newS=rmfield(newS,unsuppLabelNames);

            for frameIdx=1:numImages
                thisFramesOrigAnnoS=newS(frameIdx);


                if~this.FrameHasAnnotations(frameIdx)
                    continue;
                end

                for lbl=1:numel(labelNames)
                    label_lbl=labelNames{lbl};
                    thisFramesLabel_lbl=thisFramesOrigAnnoS.(label_lbl);
                    numROIs_label_lbl=numel(thisFramesLabel_lbl);
                    thisLabelS=[];

                    for r=1:numROIs_label_lbl
                        thisLabelInstanceS=thisFramesLabel_lbl(r);
                        thisLabelIntsanceS_orig=thisFramesLabel_lbl(r);
                        if~isstruct(thisLabelInstanceS)

                            continue;
                        end
                        thisLabelInstanceS=appendAttributeToThisLabelInstance(this,...
                        thisLabelInstanceS,label_lbl,frameIdx,...
                        hasAnyAttribDef);

                        if isempty(thisLabelS)
                            thisLabelS{1}=thisLabelInstanceS;
                        else
                            thisLabelS{end+1}=thisLabelInstanceS;%#ok<AGROW>
                        end
                    end

                    if iscell(thisLabelS)&&(numel(thisLabelS)==1)&&isempty(thisLabelS{1})
                        thisLabelS=[];
                    end
                    thisFramesOrigAnnoS.(label_lbl)=thisLabelS;
                end
                newS(frameIdx)=thisFramesOrigAnnoS;
            end

        end


        function outLabelIntsanceS=appendAttributeToThisLabelInstance(this,...
            thisLabelIntsanceS,labelName,frameIdx,hasAnyAttribDef)

            if isfield(thisLabelIntsanceS,'Position')
                outLabelIntsanceS.Position=thisLabelIntsanceS.Position;
                if isfield(thisLabelIntsanceS,'ROIOrder')
                    outLabelIntsanceS.ROIOrder=thisLabelIntsanceS.ROIOrder;
                end
            else
                outLabelIntsanceS=[];
            end
            if hasAnyAttribDef
                if isfield(thisLabelIntsanceS,'LabelUIDs')
                    roiUID=thisLabelIntsanceS.LabelUIDs;
                else
                    roiUID='';
                end
                [hasThisAttrib,attribNames,attribVals]=getAttributeDataForThisLabelROI(...
                this,labelName,roiUID,frameIdx);
                if hasThisAttrib
                    for i=1:numel(attribNames)
                        outLabelIntsanceS.(attribNames{i})=attribVals{i};
                    end
                end
            end
        end


        function outS=convertCellToStruct(this,inS)

            emptyS=createEmptyStructWithDefault(this);
            outS=copyCellStructToNonCell(this,inS,emptyS);
        end


        function outStruct=copyCellStructToNonCell(this,inStruct,emptyStruct)

            outStruct=emptyStruct;


            if isfield(inStruct,'VoxelLabelData')
                for frameIdx=1:numel(inStruct)
                    outStruct(frameIdx).VoxelLabelData=inStruct(frameIdx).VoxelLabelData;
                end
            end


            labelDefs=getLabelDefInfo(this);
            if this.isPointCloudSignal
                [labelNames,~]=getSupportedLabelNamesForSignal(this,labelDefs.labelNames);
            end
            isVoxelLabelFlag=labelDefs.isVoxelLabelFlag;
            labelAttribList=labelDefs.labelAttribList;
            sublabelList=labelDefs.sublabelList;
            sublabelAttribList=labelDefs.sublabelAttribList;




            numImages=this.NumImages;
            for frameIdx=1:numImages


                if~this.FrameHasAnnotations(frameIdx)
                    continue;
                end

                for labelIdx=1:numel(labelNames)


                    if isVoxelLabelFlag(labelIdx)
                        continue;
                    end

                    labelName=labelNames{labelIdx};

                    labelInstanceID=numel(outStruct(frameIdx).(labelName))+1;


                    if isfield(inStruct(frameIdx),labelName)&&...
                        (numel(inStruct(frameIdx).(labelName))>=labelInstanceID)&&...
                        isfield(inStruct(frameIdx).(labelName){labelInstanceID},'Position')

                        for labelInstanceIdx=1:numel(inStruct(frameIdx).(labelName))

                            assert(isfield(inStruct(frameIdx).(labelName){labelInstanceIdx},'Position'));


                            outStruct(frameIdx).(labelName)(labelInstanceID).Position=inStruct(frameIdx).(labelName){labelInstanceIdx}.Position;
                            if(isfield(inStruct(frameIdx).(labelName){labelInstanceIdx},'ROIOrder'))
                                outStruct(frameIdx).(labelName)(labelInstanceID).ROIOrder=inStruct(frameIdx).(labelName){labelInstanceIdx}.ROIOrder;
                            end

                            labelAttribs=labelAttribList{labelIdx};

                            for attribIdx=1:numel(labelAttribs)
                                attributeName=labelAttribs{attribIdx}.Name;
                                if isfield(inStruct(frameIdx).(labelName){labelInstanceIdx},attributeName)
                                    attribInstanceVal=inStruct(frameIdx).(labelName){labelInstanceIdx}.(attributeName);
                                    outStruct(frameIdx).(labelName)(labelInstanceID).(attributeName)=attribInstanceVal;
                                end
                            end

                            labelInstanceID=labelInstanceID+1;
                        end
                    end
                end
            end
        end



        function outStruct=createEmptyStructWithDefault(this)


            labelDefs=getLabelDefInfo(this);
            if this.isPointCloudSignal
                [labelNames,~]=getSupportedLabelNamesForSignal(this,labelDefs.labelNames);
            end
            isVoxelLabelFlag=labelDefs.isVoxelLabelFlag;
            labelAttribList=labelDefs.labelAttribList;
            sublabelList=labelDefs.sublabelList;
            sublabelAttribList=labelDefs.sublabelAttribList;




            numImages=this.NumImages;
            structTemplate=struct();


            for labelIdx=1:numel(labelNames)


                if isVoxelLabelFlag(labelIdx)
                    continue;
                end

                thisLabelName=labelNames{labelIdx};

                labelStruct=[];
                labelStruct.Position=[];
                labelStruct.ROIOrder=[];


                labelAttribs=labelAttribList{labelIdx};
                for attribIdx=1:numel(labelAttribs)
                    attributeName=labelAttribs{attribIdx}.Name;
                    labelStruct.(attributeName)=getAttributeDefaultValue(this,labelAttribs{attribIdx});
                end

                structTemplate.(thisLabelName)=repmat(labelStruct,[1,0]);
            end


            outStruct=repmat(structTemplate,[1,numImages]);
        end


        function labelDefs=getLabelDefInfo(this)

            labelNames=queryLabelNamesFromDef(this);

            isVoxelLabelFlag=false(1,numel(labelNames));
            labelAttribList=cell(1,numel(labelNames));
            sublabelList=cell(1,numel(labelNames));
            sublabelAttribList=cell(1,numel(labelNames));

            for labelIdx=1:numel(labelNames)
                thisLabelName=labelNames{labelIdx};

                if isVoxelLabel(this,thisLabelName)
                    isVoxelLabelFlag(labelIdx)=true;
                else

                    labelAttribList{labelIdx}=queryLabelAttributesFromDef(this,thisLabelName);

                    sublabelList{labelIdx}=querySublabelNamesFromDef(this,thisLabelName);

                    thisSublabelList=sublabelList{labelIdx};
                    sublabelAttribList{labelIdx}=cell(1,numel(thisSublabelList));
                end
            end

            labelDefs=struct();
            labelDefs.labelNames=labelNames;
            labelDefs.isVoxelLabelFlag=isVoxelLabelFlag;
            labelDefs.labelAttribList=labelAttribList;
            labelDefs.sublabelList=sublabelList;
            labelDefs.sublabelAttribList=sublabelAttribList;
        end


        function TF=isVoxelLabel(this,labelName)
            labelID=this.LabelSet.labelNameToID(labelName);
            TF=this.LabelSet.isaVoxelLabel(labelName);
        end


        function sublabelNames=querySublabelNamesFromDef(this,labelName)
            sublabelNames=this.SublabelSet.querySublabelNames(labelName);
        end


        function attribDefData=queryLabelAttributesFromDef(this,labelName)
            attribDefData=this.AttributeSet.queryAttributeFamily(labelName,'');
        end


        function defVal=getAttributeDefaultValue(~,attribData)
            if(attribData.Type==attributeType.List)
                defVal=attribData.Value{1};
            else
                defVal=attribData.Value;
            end
        end


        function s=updateAttributeOfLabelIfNotYetSet(this,s,labelName,roiUID)

            attributeSet=this.AttributeSet;
            roiAttributeFamily=attributeSet.queryAttributeFamily(labelName,'');
            ATTRIB_NAME_SPACE=this.ATTRIB_NS;

            for i=1:numel(roiAttributeFamily)
                attributeName=roiAttributeFamily{i}.Name;
                if isempty(s.(ATTRIB_NAME_SPACE))||...
                    ~isfield(s.(ATTRIB_NAME_SPACE),labelName)||...
                    isempty(s.(ATTRIB_NAME_SPACE).(labelName))||...
                    ~(isfield(s.(ATTRIB_NAME_SPACE).(labelName),attributeName))
                    matchingAttribCellID=[];
                    nextAttribCellID=1;
                else
                    matchingAttribCellID=getMatchingAttribCellID(this,s.(ATTRIB_NAME_SPACE).(labelName).(attributeName),roiUID,true);
                    nextAttribCellID=numel(s.(ATTRIB_NAME_SPACE).(labelName).(attributeName))+1;
                end
                if isempty(matchingAttribCellID)
                    attributeDefValue=getAttributeDefaultValue(this,roiAttributeFamily{i});
                    s.(ATTRIB_NAME_SPACE).(labelName).(attributeName)(nextAttribCellID).AttributeValues=attributeDefValue;
                    s.(ATTRIB_NAME_SPACE).(labelName).(attributeName)(nextAttribCellID).LabelUIDs=roiUID;
                end
            end
        end


        function matchingAttribCellID=getMatchingAttribCellID(~,labelSublabelAttribStruct,roiUID,isLabel)

            matchingAttribCellID=[];
            for i=1:numel(labelSublabelAttribStruct)
                if isLabel
                    thisROIUID=labelSublabelAttribStruct(i).LabelUIDs;
                end
                if~isempty(thisROIUID)&&(strcmp(thisROIUID,roiUID))
                    matchingAttribCellID=i;
                    return;
                end
            end
        end
    end
end


function numLabelROIs=getNumLabelROIsInAnnotation(s,labelName)
    if isfield(s.(labelName),'Position')
        numLabelROIs=length(s.(labelName));

        if(numLabelROIs==1)&&isempty(s.(labelName).Position)
            numLabelROIs=0;
        else


            for i=1:numLabelROIs
                assert(~isempty(s.(labelName)(i).Position));
            end
        end
    else

        numLabelROIs=0;
    end
end


function outList=excludeVoxelLabelData(inList)

    idx=strcmp(inList,'VoxelLabelData');
    outList=inList;
    outList(idx)=[];

end

function idx=findLabelTypeIndex(labelTypeChoicesEnum,labels)
    idx=[];
    for i=1:numel(labelTypeChoicesEnum)
        if labelTypeChoicesEnum{i}==labels
            idx=[idx;i];
            return;
        end
    end
end

function idx=isValidLabels(labels,labelTypeChoicesEnum)
    idx=[];
    for i=1:numel(labels)
        for j=1:numel(labelTypeChoicesEnum)
            if labels{i}==labelTypeChoicesEnum{j}
                idx=[idx;i];
                break;
            end
        end
    end
end


function numROIs=getNumROIsInAnnotation(s)

    fields=fieldnames(s);

    numROIs=0;

    for i=1:numel(fields)
        labelName=fields{i};
        if isfield(s.(labelName),'Position')
            numLabelROIs=length(s.(labelName));

            if(numLabelROIs==1)&&isempty(s.(labelName).Position)
                numLabelROIs=0;
            else


                for j=1:numLabelROIs
                    assert(~isempty(s.(labelName)(j).Position));
                end
            end
        else

            numLabelROIs=0;
        end
        numROIs=numROIs+numLabelROIs;
    end
end
