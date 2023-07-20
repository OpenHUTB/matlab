



classdef ProximityDataGenerator<handle






    properties(Access=public)
mProximityTable
mParentToChildData
    end


    properties(Access=private)
mSldvObjectivesData
mGoalIdToDvIdMap
    end


    methods(Access=public)

        function obj=ProximityDataGenerator(sldvObjectivesData,goalIdToDvIdMap)
            obj.mParentToChildData=containers.Map('keyType','uint64','valueType','any');
            obj.mSldvObjectivesData=sldvObjectivesData;
            obj.mGoalIdToDvIdMap=goalIdToDvIdMap;
        end








        function status=canRunProximity(obj)
            status=true;
            if~isfield(obj.mSldvObjectivesData,'Objectives')||isempty(obj.mSldvObjectivesData.Objectives)
                status=false;
                return;
            end

            transMObjFlags=strcmp({obj.mSldvObjectivesData.ModelObjects.sfObjType},'Transition');
            if all(transMObjFlags==0)
                status=false;
                return;
            end

            stateMObjFlags=strcmp({obj.mSldvObjectivesData.ModelObjects.sfObjType},'State');
            chartMObjFlags=strcmp({obj.mSldvObjectivesData.ModelObjects.sfObjType},'Chart');

            if all(chartMObjFlags==0)&&all(stateMObjFlags==0)
                status=false;
                return;
            end
        end


        function run(obj,undecidedObjs)
            if nargin<2
                undecidedObjs=[];
            end
            undecidedObjs=obj.filterUndecidedObjs(undecidedObjs);
            calculate(obj,undecidedObjs);
            populateParentToChildDependency(obj,undecidedObjs);
        end



        function[status,proximityDataFile,proximityDataReadyFile]=saveProximityData(obj,filename,directoryname)

            status=true;

            if nargin<2
                filename='proximitydata';
                directoryname='';
            end
            if nargin<3
                directoryname='';
            end









            keys=obj.mParentToChildData.keys;
            values=obj.mParentToChildData.values;

            proximityStruct=struct('mObjective',{},'mProximalObjectives',{});
            for i=1:length(keys)
                proximityStruct(i).mObjective=keys{i};
                proximityStruct(i).mProximalObjectives=values{i};
            end
            proximityDataFile=[filename,'.mat'];
            proximityDataReadyFile='proximitydataReady.mat';
            if directoryname~=""
                if not(isfolder(directoryname))
                    status=false;
                    return;
                end
                proximityDataFile=fullfile(directoryname,proximityDataFile);
                proximityDataReadyFile=fullfile(directoryname,proximityDataReadyFile);
            end


            modelHasProximityData=~isempty(proximityStruct);

            save(proximityDataFile,'proximityStruct');

            save(proximityDataReadyFile,'modelHasProximityData');
        end




        function writeOrigProximityData(obj,filename)
            fid=fopen(filename,'w+');

            assert(isprop(obj,'mProximityTable'),"mProximityTable property should exist");
            assert(isprop(obj.mProximityTable,'proximityDataArray'),"proximityDataArry property should exist");

            for index=1:length(obj.mProximityTable.proximityDataArray)
                fprintf(fid,"%d:",obj.mProximityTable.proximityDataArray(index).targetObjective);
                for proximalIndex=1:length(obj.mProximityTable.proximityDataArray(index).closestObjIndices)
                    fprintf(fid," %d",obj.mProximityTable.proximityDataArray(index).closestObjIndices(proximalIndex));
                end
                fprintf(fid,"\n");
            end
            fclose(fid);
        end



        function writeParentToChildData(obj,filename)
            fid=fopen(filename,'w+');
            fprintf(fid,"%s\n","DirectParentToChildData");
            parents=obj.mParentToChildData.keys();
            childs=obj.mParentToChildData.values();
            for i=1:length(obj.mParentToChildData)
                fprintf(fid," %d:",parents{i});
                childs_i=childs{i};
                for childIndex=1:length(childs_i)
                    fprintf(fid," %d",childs_i(childIndex));
                end
                fprintf(fid,"\n");
            end
            fclose(fid);
        end



        function writeProximityDotFile(obj,filename)
            fid=fopen(filename,'w+');
            fprintf(fid,"digraph {");
            modelObjects=obj.mSldvObjectivesData.ModelObjects;
            for i=1:length(modelObjects)
                fprintf(fid,"%d ",i);
                descr=modelObjects(i).descr;
                temp1=replace(descr,'"','\"');
                temp2=replace(temp1,'<','\<');
                newdescr=replace(temp2,'>','\>');
                fprintf(fid,'[shape=record,label = "{ModelObjIdx:%d|%s|',i,newdescr);

                fprintf(fid,'{');
                for j=1:length(modelObjects(i).objectives)
                    fprintf(fid,'<f%d> %d ',modelObjects(i).objectives(j),modelObjects(i).objectives(j));
                    if j~=length(modelObjects(i).objectives)
                        fprintf(fid,'|');
                    end
                end
                fprintf(fid,'}');
                fprintf(fid,'}"]\n');
            end


            keys=obj.mParentToChildData.keys();
            values=obj.mParentToChildData.values();
            for i=1:length(keys)

                values_i=values{i};
                for j=1:length(values_i)
                    fprintf(fid,"%d:f%d->",obj.mSldvObjectivesData.Objectives(keys{i}).modelObjectIdx,keys{i});
                    fprintf(fid,"%d:f%d\n",obj.mSldvObjectivesData.Objectives(values_i(j)).modelObjectIdx,values_i(j));
                end
            end

            fprintf(fid,'}');
            fclose(fid);
        end
    end

    methods(Access=private)


        function calculate(obj,undecidedObjs)
            proximityCal=Sldv.Analysis.ProximityData.ProximityDataCalculator();
            proximityCal.initialize(obj.mSldvObjectivesData);

            proximityCal.populateData(undecidedObjs,false);
            obj.mProximityTable=proximityCal.mProximityTable;
        end











        function populateParentToChildDependency(obj,undecidedObjs)
            proximityDataArray=obj.mProximityTable.proximityDataArray;







            for index=1:length(undecidedObjs)
                [dvIdFound,dvId]=obj.getObjectiveDvId(undecidedObjs(index));
                if dvIdFound
                    obj.mParentToChildData(dvId)=[];
                end
            end


            for index=1:length(proximityDataArray)
                targetObjective=proximityDataArray(index).targetObjective;
                closestParentIndices=proximityDataArray(index).closestObjIndices;
                for closestIndex=1:length(closestParentIndices)
                    parentObj=closestParentIndices(closestIndex);
                    [dvIdFound,parentObjDvId]=obj.getObjectiveDvId(parentObj);
                    if~dvIdFound
                        continue;
                    end
                    if obj.mParentToChildData.isKey(parentObjDvId)
                        value=obj.mParentToChildData(parentObjDvId);


                        [dvIdFound,dvId]=obj.getObjectiveDvId(targetObjective);
                        if dvIdFound
                            value(end+1)=dvId;
                            obj.mParentToChildData(parentObjDvId)=value;
                        end
                    end

                end
            end





            keys=obj.mParentToChildData.keys();
            values=obj.mParentToChildData.values();
            emptyKeys=zeros(1,length(keys));
            emptyKeysIndex=1;
            for i=1:length(keys)
                curVal=values{i};
                if isempty(curVal)
                    emptyKeys(emptyKeysIndex)=keys{i};
                    emptyKeysIndex=emptyKeysIndex+1;
                end
                obj.mParentToChildData(keys{i})=unique(curVal);
            end
            emptyKeys(emptyKeysIndex:length(keys))=[];

            for i=1:length(emptyKeys)
                remove(obj.mParentToChildData,emptyKeys(i));
            end

        end

        function[dvIdFound,dvId]=getObjectiveDvId(obj,objId)

            dvIdFound=true;
            dvId=-1;
            goalId=obj.mSldvObjectivesData.Objectives(objId).goal;
            if~isKey(obj.mGoalIdToDvIdMap,goalId)
                dvIdFound=false;
                return;
            end
            dvId=obj.mGoalIdToDvIdMap(goalId);
        end


        function objIndices=getUndecObjIndices(obj,~)



            undecObjIndices=Sldv.Analysis.DataUtils.getUndecObjectives(obj.mSldvObjectivesData.Objectives);
            objIndices=zeros(1,length(undecObjIndices));
            objIndicesIndex=1;
            for idx=1:length(undecObjIndices)
                objIdx=undecObjIndices(idx);
                objIndices(objIndicesIndex)=objIdx;
                objIndicesIndex=objIndicesIndex+1;






            end
            objIndices(objIndicesIndex,length(undecObjIndices))=[];
        end



        function undecidedObjs=filterUndecidedObjs(obj,undecidedObjs)

            sldvData=obj.mSldvObjectivesData;
            modelObjs=sldvData.ModelObjects;
            flags=arrayfun(@(mObj)...
            any(strcmp(mObj.sfObjType,{'State','Transition','Chart'})),...
            modelObjs);
            modelObjs=modelObjs(flags);
            objs=intersect([modelObjs.objectives],undecidedObjs);
            undecidedObjs=objs;
        end
    end
end


