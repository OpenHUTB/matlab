function select(this,dlg,row,col)



    if col==0

        return;
    end


    activeIdx=row+1;

    this.Model.selectCriteria(activeIdx);
end