function tf=isLibrary(this)







    tf=isempty(this.JavaHandle)&&~isempty(this.ID);

