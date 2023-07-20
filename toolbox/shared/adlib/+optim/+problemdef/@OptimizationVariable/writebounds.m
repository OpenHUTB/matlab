function writebounds(x,varargin)




























































    narginchk(1,2);


    defaultFilename=[x.Name,'_bounds'];


    fid=optim.internal.problemdef.writeInterfaceHandler(defaultFilename,varargin{:});


    showUnboundedMessage=true;
    paddingAmount=4;
    str=getBoundStr(x,showUnboundedMessage,paddingAmount);


    fprintf(fid,'%s\n',str);


    fclose(fid);

