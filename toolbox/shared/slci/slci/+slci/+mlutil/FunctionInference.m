



classdef FunctionInference<handle

    properties(Access=private)

        fID=[];


        fPosToData=[];


        fPosToCalledFunctionID=[];


        fDroppedOutputs={};


        fDroppedInputs={};
    end

    methods


        function obj=FunctionInference(funcID,coderInferenceData,scriptInfo)
            obj.fPosToData=containers.Map;
            obj.fPosToCalledFunctionID=containers.Map;
            obj.fID=funcID;
            obj.populate(coderInferenceData,scriptInfo);
        end


        function droppedOutputs=getDroppedOutputs(obj)
            droppedOutputs=obj.fDroppedOutputs;
        end


        function droppedInputs=getDroppedInputs(obj)
            droppedInputs=obj.fDroppedInputs;
        end


        function flag=hasType(obj,startPos,endPos)
            pos=obj.getKey(startPos,endPos);
            flag=isKey(obj.fPosToData,pos)&&...
            ~isempty(obj.fPosToData(pos).Type);
        end


        function type=getType(obj,startPos,endPos)
            pos=obj.getKey(startPos,endPos);
            type=obj.fPosToData(pos).Type;
        end


        function flag=hasSize(obj,startPos,endPos)
            pos=obj.getKey(startPos,endPos);
            flag=isKey(obj.fPosToData,pos)&&...
            ~isempty(obj.fPosToData(pos).Size);
        end


        function size=getSize(obj,startPos,endPos)
            pos=obj.getKey(startPos,endPos);
            size=obj.fPosToData(pos).Size;
        end


        function flag=hasComplex(obj,startPos,endPos)
            pos=obj.getKey(startPos,endPos);
            flag=isKey(obj.fPosToData,pos)&&...
            ~isempty(obj.fPosToData(pos).Complex);
        end


        function complexity=getComplex(obj,startPos,endPos)
            pos=obj.getKey(startPos,endPos);
            complexity=obj.fPosToData(pos).Complex;
        end


        function flag=hasCalledFunctionID(obj,startPos,endPos)
            pos=obj.getKey(startPos,endPos);
            flag=isKey(obj.fPosToCalledFunctionID,pos)&&...
            ~isempty(obj.fPosToCalledFunctionID(pos));
        end


        function data=getCalledFunctionID(obj,startPos,endPos)
            pos=obj.getKey(startPos,endPos);
            data=obj.fPosToCalledFunctionID(pos);
        end

    end

    methods(Access=private)


        function populate(obj,coderInferenceData,scriptInfo)

            functionInference=coderInferenceData.Functions(obj.fID);


            mxInfoMap=obj.getLocMap(functionInference.MxInfoLocations);

            obj.filterMxInfoMap(mxInfoMap);
            obj.populateMxInfo(mxInfoMap,coderInferenceData);


            callSiteMap=obj.getLocMap(functionInference.CallSites);
            obj.populateCallSites(callSiteMap,scriptInfo);
            obj.populateDroppedInfo(coderInferenceData);
        end


        function locToData=getLocMap(aObj,inputData)
            locToData=containers.Map;
            for k=1:numel(inputData)
                data=inputData(k);

                startPos=data.TextStart+1;

                endPos=startPos+data.TextLength-1;
                locKey=aObj.getKey(startPos,endPos);
                if isKey(locToData,locKey)
                    locToData(locKey)=[locToData(locKey),data];
                else
                    locToData(locKey)=data;
                end
            end
        end




        function filterMxInfoMap(~,mxInfoMap)
            locs=keys(mxInfoMap);
            numlocs=numel(locs);
            for k=1:numlocs
                values=mxInfoMap(locs{k});
                hasdups=numel(values)>1;
                if hasdups



                    const_indices=strcmp({values(:).NodeTypeName},'const');
                    if~all(const_indices)
                        values(const_indices)=[];

                        mxInfoMap(locs{k})=values;
                    end
                end
            end

        end


        function locKey=getKey(~,startPos,endPos)
            locKey=[sprintf('%ld',startPos),':'...
            ,sprintf('%ld',endPos)];
        end




        function populateMxInfo(obj,mxInfoMap,coderInferenceData)


            locToMxID=obj.getMxId(mxInfoMap);


            obj.translateMxTypeInfo(locToMxID,coderInferenceData);

        end


        function locToMxID=getMxId(~,mxInfoMap)
            locKeys=keys(mxInfoMap);
            locToMxID=containers.Map;
            for k=1:numel(locKeys)

                locKey=locKeys{k};
                mxInfo=mxInfoMap(locKey);


                mxInfoIDs=unique([mxInfo(:).MxInfoID],'stable');
                assert(numel(mxInfoIDs)>0);


                assert(~isKey(locToMxID,locKey));
                locToMxID(locKey)=mxInfoIDs;
            end
        end



        function translateMxTypeInfo(obj,locToMxID,coderInferenceData)

            locKeys=keys(locToMxID);
            processed=containers.Map();

            for k=1:numel(locKeys)

                locKey=locKeys{k};
                mxIds=locToMxID(locKey);


                num=numel(mxIds);
                assert(num>0);
                data.Type=cell(1,num);
                data.Size=cell(1,num);
                data.Complex=cell(1,num);


                for p=1:num
                    mxId=mxIds(p);
                    typeInfo=obj.translate(mxId,...
                    coderInferenceData.MxInfos,...
                    processed);

                    if(strcmpi(typeInfo.Type,'embedded.fi'))
                        try
                            [dt,~]=fixed.internal.mxInfoToDataTypeString(mxId,...
                            coderInferenceData.MxInfos,...
                            coderInferenceData.MxArrays);
                            t=eval(dt);
                        catch




                            t=typeInfo.Type;
                        end

                        ret=slci.internal.getNumericalType(t);
                        isValid=ret(1);
                        isSigned=ret(2);
                        wordLen=ret(3);
                        fracLen=ret(4);
                        if isValid&&(wordLen==64)&&(fracLen==0)
                            if isSigned
                                data.Type{1,p}='sfix64';
                            else
                                data.Type{1,p}='ufix64';
                            end
                        else
                            data.Type{1,p}=typeInfo.Type;
                        end
                    else
                        data.Type{1,p}=typeInfo.Type;
                    end

                    data.Size{1,p}=typeInfo.Size;
                    data.Complex{1,p}=typeInfo.Complex;
                end


                data.Type=obj.getUnique(data.Type);
                data.Complex={unique(cell2mat(data.Complex))};
                data.Size=obj.getUnique(data.Size);

                assert(~isKey(obj.fPosToData,locKey));
                obj.fPosToData(locKey)=data;
            end
        end


        function[typeInfo,processed]=translate(aObj,...
            mxId,...
            mxTypeInfos,...
            processed)

            if isKey(processed,num2str(mxId))
                typeInfo=processed(num2str(mxId));
                return;
            end


            mxTypeInfo=mxTypeInfos{mxId};


            if~isempty(mxTypeInfo.SizeDynamic)



                typeInfo.Size=[];
            else
                typeInfo.Size=(mxTypeInfo.Size)';
            end


            if isa(mxTypeInfo,'eml.MxNumericInfo')
                if strcmp(mxTypeInfo.Class,'coder.internal.indexInt')


                    typeInfo.Type=coder.internal.indexIntClass;
                else
                    typeInfo.Type=mxTypeInfo.Class;
                end
                typeInfo.Complex=mxTypeInfo.Complex;
            elseif(isa(mxTypeInfo,'eml.MxInfo')&&...
                (isequal(mxTypeInfo.Class,'logical')||...
                isequal(mxTypeInfo.Class,'char')))

                typeInfo.Type=mxTypeInfo.Class;
                typeInfo.Complex=false;
            elseif isa(mxTypeInfo,'eml.MxStructInfo')



                structName=['mxId',num2str(mxId)];
                structType=slci.mlutil.MLStructType(structName);
                typeInfo.Type=structType;
                typeInfo.Complex=false;


                fieldVals=mxTypeInfo.StructFields;
                for k=1:numel(fieldVals)
                    fieldName=fieldVals(k).FieldName;
                    fieldTypeInfo=aObj.translate(...
                    fieldVals(k).MxInfoID,...
                    mxTypeInfos,...
                    processed);
                    typeInfo.Type.addField(fieldName,fieldTypeInfo);
                end
            elseif isa(mxTypeInfo,'eml.MxEnumInfo')
                typeInfo.Type=mxTypeInfo.Class;
                typeInfo.Complex=false;
            else

                typeInfo.Type=mxTypeInfo;
                typeInfo.Complex=false;

            end
            processed(num2str(mxId))=typeInfo;
        end




        function populateCallSites(obj,callSiteMap,scriptInfo)

            locKeys=keys(callSiteMap);

            for k=1:numel(locKeys)

                posKey=locKeys{k};
                callSiteInfo=callSiteMap(posKey);


                callFunctionIDs=unique([callSiteInfo(:).CalledFunctionID],...
                'stable');


                num=numel(callFunctionIDs);
                callSite={};
                for p=1:num
                    fid=callFunctionIDs(p);
                    if(scriptInfo.hasUserVisible(fid)...
                        &&scriptInfo.isUserVisible(fid))
                        callSite{1,end+1}=fid;%#ok
                    end
                end

                assert(~isKey(obj.fPosToCalledFunctionID,posKey));
                obj.fPosToCalledFunctionID(posKey)=callSite;
            end
        end



        function output=getUnique(~,input)
            assert(iscell(input));
            output{1}=input{1};
            for k=2:numel(input)
                found=cellfun(@(x)isequal(x,input{k}),output);
                if~any(found)
                    output{end+1}=input{k};%#ok
                end
            end
        end


        function populateDroppedInfo(obj,coderInferenceData)

            inputs=coderInferenceData.Functions(obj.fID).Inputs;
            for i=1:numel(inputs)
                input=inputs(i);





                if input.IsRemoved
                    if input.MxValueID~=0
                        droppedInput.value=coderInferenceData.MxArrays{input.MxValueID};
                    else

                        droppedInput.value=[];
                    end
                    droppedInput.id=i;
                    obj.fDroppedInputs{end+1}=droppedInput;
                end
            end


            outputs=coderInferenceData.Functions(obj.fID).Outputs;
            for i=1:numel(outputs)
                output=outputs(i);





                if output.IsRemoved
                    if output.MxValueID~=0
                        droppedOutput.value=coderInferenceData.MxArrays{output.MxValueID};
                    else

                        droppedOutput.value=[];
                    end
                    droppedOutput.id=i;
                    obj.fDroppedOutputs{end+1}=droppedOutput;
                end
            end
        end
    end

end
