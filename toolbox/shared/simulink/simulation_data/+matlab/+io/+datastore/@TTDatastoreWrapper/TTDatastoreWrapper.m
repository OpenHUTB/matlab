



classdef(Sealed=true)TTDatastoreWrapper<handle



    properties(Access=public)
ReadSize
    end

    properties(Access=private)
TTDstObj
        TimeMode=false;




PrevValuesCache
CurrReadTable
CurrReadTableIdx
    end

    methods
        function this=TTDatastoreWrapper(dst,TimeMode)
            this.TTDstObj=dst;
            if isprop(dst,'ReadSize')
                this.ReadSize=dst.ReadSize;
            else



                this.ReadSize=100;
            end
            this.PrevValuesCache=struct.empty;
            this.CurrReadTable=timetable.empty;
            this.CurrReadTableIdx=1;
            this.TimeMode=TimeMode;
        end

        function set.ReadSize(this,rs)
            this.ReadSize=rs;
        end

        function rs=get.ReadSize(this)
            rs=this.ReadSize;
        end

        function ret=getSampleFromTTDatastore(this,idx)



            if isempty(this.PrevValuesCache)
                ret=this.queryDatastore();

                this.PrevValuesCache(1).idx=idx;
                this.PrevValuesCache(1).val=ret;
            else
                for curr=1:length(this.PrevValuesCache)
                    if isequal(this.PrevValuesCache(curr).idx,idx)
                        ret=this.PrevValuesCache(curr).val;
                        return;
                    end
                end

                startIdx=this.PrevValuesCache(end).idx+1;
                for currIdx=startIdx:idx
                    ret=this.queryDatastore();

                    this.PrevValuesCache(end+1).idx=currIdx;
                    this.PrevValuesCache(end).val=ret;
                end
            end
        end

        function[isAvailable,timeLastButOne,timeLast]=...
            getLastTimesIfAvailable(this,~)





            if this.TTDstObj.hasdata
                isAvailable=false;
                timeLastButOne=0;
                timeLast=0;
            else
                isAvailable=true;
                if this.TimeMode
                    timeLastButOne=seconds(this.CurrReadTable(end-1,1).Time);
                    timeLast=seconds(this.CurrReadTable(end,1).Time);
                else
                    timeLastButOne=this.CurrReadTable{end-1,1};
                    timeLast=this.CurrReadTable{end,1};
                end
            end
        end

        function nsamples=getNumSamples(this)
            nsamples=0;
            if isprop(this.TTDstObj,'Signal')&&~isempty(this.TTDstObj.Signal)
                nsamples=double(this.TTDstObj.Signal.NumPoints);
            end
        end

        function numEls=getNumSampleElements(this)
            numEls=1;
            if~this.TimeMode&&isprop(this.TTDstObj,'Signal')&&~isempty(this.TTDstObj.Signal)
                numEls=double(prod(this.TTDstObj.Signal.Dimensions));
            end
        end

        function ret=getSampleSizeInBytes(this)
            ret=8;
            if~this.TimeMode&&isprop(this.TTDstObj,'Signal')&&~isempty(this.TTDstObj.Signal)
                ret=double(this.TTDstObj.Signal.SampleSizeInBytes);
            end
        end
    end

    methods(Access=private)
        function ret=queryDatastore(this)


            if(isempty(this.CurrReadTable)||...
                this.CurrReadTableIdx>this.ReadSize)&&...
                this.TTDstObj.hasdata
                this.CurrReadTable=this.TTDstObj.read;
                this.CurrReadTableIdx=1;
            end

            if this.TimeMode
                ret=seconds(this.CurrReadTable(this.CurrReadTableIdx,1).Time);
            else
                ret=this.CurrReadTable{this.CurrReadTableIdx,1};
            end
            this.CurrReadTableIdx=this.CurrReadTableIdx+1;
        end
    end
end


