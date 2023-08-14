


classdef(Sealed=true)MdfDatastoreWrapper<handle



    properties(Access=public)
ReadSize
    end

    properties(Access=private)
MdfDstObj
PrevValuesCache
CurrReadTable
CurrReadTableIdx
TimeMode
    end

    methods
        function this=MdfDatastoreWrapper(dst,timeMode)
            this.MdfDstObj=dst;
            this.ReadSize=dst.ReadSize;
            this.PrevValuesCache=struct.empty;
            this.CurrReadTable=timetable.empty;
            this.CurrReadTableIdx=1;
            this.TimeMode=timeMode;
        end

        function set.ReadSize(this,rs)


            this.ReadSize=rs;
            this.setMdfReadSize(rs);
        end

        function rs=get.ReadSize(this)
            this.ReadSize=this.getMdfReadSize();
            rs=this.ReadSize;
        end

        function ret=getSampleFromMDFDatastore(this,idx)







            if isempty(this.PrevValuesCache)
                ret=this.queryDatastore();

                this.PrevValuesCache(1).idx=idx;
                this.PrevValuesCache(1).val=ret;
            else



                if isequal(this.PrevValuesCache(end).idx,idx)
                    ret=this.PrevValuesCache(end).val;
                    return;
                end

                if isequal(numel(this.PrevValuesCache),2)&&...
                    isequal(this.PrevValuesCache(1).idx,idx)
                    ret=this.PrevValuesCache(1).val;
                    return;
                end


                if isequal(numel(this.PrevValuesCache),2)
                    assert(idx>this.PrevValuesCache(2).idx);
                end

                for currIdx=(this.PrevValuesCache(end).idx+1):idx
                    ret=this.queryDatastore();

                    this.PrevValuesCache(end+1).idx=currIdx;
                    this.PrevValuesCache(end).val=ret;
                    if numel(this.PrevValuesCache)>2
                        this.PrevValuesCache(1)=[];
                    end
                end
            end
        end

        function[isAvailable,timeLastButOne,timeLast]=...
            getLastTimesIfAvailable(this,~)





            if this.MdfDstObj.hasdata
                isAvailable=false;
                timeLastButOne=0;
                timeLast=0;
            else
                isAvailable=true;
                timeLastButOne=this.CurrReadTable{end-1,1};
                timeLast=this.CurrReadTable{end,1};
            end
        end
    end

    methods(Access=private)
        function ret=queryDatastore(this)


            if(isempty(this.CurrReadTable)||...
                this.CurrReadTableIdx>this.ReadSize)&&...
                this.MdfDstObj.hasdata
                this.CurrReadTable=this.MdfDstObj.read;
                this.CurrReadTableIdx=1;
            end

            if this.TimeMode
                ret=seconds(this.CurrReadTable(this.CurrReadTableIdx,1).Time);
            else
                ret=this.CurrReadTable{this.CurrReadTableIdx,1};
            end
            this.CurrReadTableIdx=this.CurrReadTableIdx+1;
        end

        function this=setMdfReadSize(this,rs)
            this.MdfDstObj.ReadSize=rs;
        end

        function rs=getMdfReadSize(this)
            rs=this.MdfDstObj.ReadSize;
        end
    end
end


