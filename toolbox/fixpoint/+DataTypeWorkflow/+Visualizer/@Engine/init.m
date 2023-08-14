function init(this)




    this.LastIndex=0;






    this.NumRecordsToPublish=min(this.DataThreshold,size(this.TableData,1));

    this.RGBData=cell(size(this.TableData,1),1);
    this.YLimits=cell(size(this.TableData,1),1);
    this.GlobalYLimits=[];
end