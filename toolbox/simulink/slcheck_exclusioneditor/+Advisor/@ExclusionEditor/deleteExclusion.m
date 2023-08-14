function result=deleteExclusion(this,rowNum)

    rowNum=rowNum+1;

    this.TableData(rowNum)=[];

    result=this.TableData;

    this.setDialogDirty(true);
end