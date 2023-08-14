classdef SpreadSheetDataManager<handle


    properties
        appmgr;


        SpreadSheetDataMap=containers.Map('KeyType','double','ValueType','Any');
    end

    methods
        function this=SpreadSheetDataManager(appmgr)
            this.appmgr=appmgr;
        end

        function delete(this)

            modelHs=this.SpreadSheetDataMap.keys;
            for n=1:length(modelHs)
                spObj=this.SpreadSheetDataMap(modelHs{n});
                spObj.delete;
                if isKey(this.SpreadSheetDataMap,modelHs{n})






                    this.SpreadSheetDataMap.remove(modelHs{n});
                end
            end
        end

        function spDataObj=getOrCreateDataObj(this,targetModelHandle)


            modelH=rmisl.getOwnerModelFromHarness(targetModelHandle);

            if isKey(this.SpreadSheetDataMap,modelH)
                spDataObj=this.SpreadSheetDataMap(modelH);
            else
                spDataObj=this.createSpreadSheetDataObject(modelH);
                this.SpreadSheetDataMap(modelH)=spDataObj;
            end

        end

        function spDataObj=getSpreadSheetDataObject(this,targetModelHandle)
            modelH=rmisl.getOwnerModelFromHarness(targetModelHandle);
            if isKey(this.SpreadSheetDataMap,modelH)
                spDataObj=this.SpreadSheetDataMap(modelH);
                slreq.utils.assertValid(spDataObj);
            else
                spDataObj=slreq.gui.SpreadSheetData.empty;
            end
        end

        function spDataObj=createSpreadSheetDataObject(this,targetModelHandle)
            modelH=rmisl.getOwnerModelFromHarness(targetModelHandle);
            spDataObj=slreq.gui.SpreadSheetData(modelH);
        end

        function deleteSpreadSheetDataObject(this,target)
            modelH=rmisl.getOwnerModelFromHarness(target);
            if isKey(this.SpreadSheetDataMap,modelH)
                spDataObj=this.SpreadSheetDataMap(modelH);
                this.SpreadSheetDataMap.remove(modelH);
                if isvalid(spDataObj)
                    spDataObj.delete;
                end
            end
        end

        function hdls=getAllModelHandles(this)

            hdls=cell2mat(this.SpreadSheetDataMap.keys);
        end

        function out=hasData(this)
            out=this.SpreadSheetDataMap.Count~=0;
        end

        function removeReqLinkSetFromSpreadSheetData(this,reqLinkSetObj)
            allSpDataObj=this.SpreadSheetDataMap.values;
            for index=1:length(allSpDataObj)
                cSpDataObj=allSpDataObj{index};
                cSpDataObj.removeReqLinkSet(reqLinkSetObj);
            end

        end
    end
end