function res=evalDec(this,val)



    try
        res=false(1,numel(this.m_handles));

        for idx=1:numel(this.m_handles)
            cp=this.m_handles{idx};
            if isa(cp,'Sldv.Point')
                val=reshape(val,size(cp.getFlatValue));
                res(idx)=isequal(val,cp.getFlatValue);
            else
                lVal=cp.getFlatLow;
                hVal=cp.getFlatHigh;
                val=reshape(val,size(lVal));



                numElem=numel(lVal);
                lVal=reshape(lVal,1,numElem);
                hVal=reshape(hVal,1,numElem);
                val=reshape(val,1,numElem);



                tr=zeros(1,numElem);
                for vectIdx=1:numElem
                    tr(vectIdx)=(((lVal(vectIdx)<val(vectIdx))&&(val(vectIdx)<hVal(vectIdx)))||...
                    (cp.highIncluded&&isequal(val(vectIdx),hVal(vectIdx)))||...
                    (cp.lowIncluded&&isequal(val(vectIdx),lVal(vectIdx))));
                end
                res(idx)=all(tr);
            end
        end
    catch Mex
        Mex.message;
    end

