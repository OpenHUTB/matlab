function saveWorkBook(this)



    if this.HasWorkBook
        this.WorkBook.save(this.FileName);
        this.WorkBook=[];
        this.HasWorkBook=false;
    end
end
