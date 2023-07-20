function c=makeComponent(this,varargin)





    libC=RptgenML.LibraryComponent([this.PkgName,'.',this.ClassName]);
    c=libC.makeComponent(varargin{:});

