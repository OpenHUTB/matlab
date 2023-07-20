




classdef SequenceMerger<handle







    properties(Access=private)
        originalSeq;
        originalSeqLUT;
        m3iMetaClass;
        m3iModel;
        newSeq;
        newSeqLUT;
    end

    methods(Access=public)
        function this=SequenceMerger(m3iModel,seq,metaClass)

            this.m3iMetaClass=metaClass;
            this.m3iModel=m3iModel;

            this.originalSeq=M3I.SequenceOfClassObject.make(m3iModel);
            this.originalSeq.addAll(seq);
            this.originalSeqLUT=containers.Map();
            this.populateLUTFromSeq(this.originalSeq,this.originalSeqLUT);

            this.newSeq=seq;
            this.newSeq.clear();
            this.newSeqLUT=containers.Map();
        end



        function[m3iObj,action_taken]=mergeByName(this,name)






















            if this.newSeqLUT.isKey(name)
                action_taken='preexisting';
                m3iObj=this.newSeqLUT(name);
                return;
            end

            if this.originalSeqLUT.isKey(name)
                action_taken='merged';
                m3iObj=this.originalSeqLUT(name);
            else
                action_taken='created';
                m3iObj=eval([this.m3iMetaClass,'(this.m3iModel)']);
                m3iObj.Name=this.getShortName(name);
            end
            this.newSeq.append(m3iObj);
            this.newSeqLUT(name)=m3iObj;
        end




        function delete(obj)
            tmpIndex=1;
            while tmpIndex<=obj.originalSeq.size
                seqItem=obj.originalSeq.at(tmpIndex);
                lutKey=obj.getLUTKeyFromM3iObj(seqItem);
                if~obj.newSeqLUT.isKey(lutKey)
                    seqItem.destroy();
                end
                tmpIndex=tmpIndex+1;
            end
        end
    end

    methods(Access=protected,Static=true)


        function lutKey=getLUTKeyFromM3iObj(m3iObj)
            lutKey=m3iObj.Name;
        end

        function shortName=getShortName(name)
            shortName=name;
        end
    end

    methods(Access=private)
        function populateLUTFromSeq(this,seq,lut)






            currIt=seq.begin();
            endIt=seq.end();
            while currIt~=endIt
                currItem=currIt.item();
                lutKey=this.getLUTKeyFromM3iObj(currItem);
                lut(lutKey)=currItem;
                currIt.getNext();
            end
        end
    end
end


