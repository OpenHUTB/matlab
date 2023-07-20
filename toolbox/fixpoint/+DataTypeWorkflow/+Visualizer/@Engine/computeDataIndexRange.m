function computeDataIndexRange(this)







    selectedResultIndex=this.getRowIndexForId(this.SelectedResultId);



    if selectedResultIndex<0

        this.StartIndex=this.LastIndex+1;
    else

        this.StartIndex=selectedResultIndex;
    end


    this.EndIndex=this.StartIndex+this.DataThreshold-1;



    this.EndIndex=min(this.EndIndex,height(this.TableData));



    if((this.EndIndex-this.StartIndex+1)<this.DataThreshold)
        this.StartIndex=min(this.StartIndex,this.EndIndex-this.DataThreshold+1);



        if(this.StartIndex<1)
            this.StartIndex=1;
        end
    end
end
