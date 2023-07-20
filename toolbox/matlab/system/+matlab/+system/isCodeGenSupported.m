function out=isCodeGenSupported(className,codeGenOption)















    out=true;

    fcn=[className,'.generatesCode'];
    if~isempty(which(fcn))&&~feval(fcn)
        out=false;
        return;
    end

    if nargin>1&&islogical(codeGenOption)

        p=which(className);
        if~strncmp(p,matlabroot,numel(matlabroot))&&...
            ~(ispc&&strncmpi(p,matlabroot,numel(matlabroot)))
            out=false;
            return;
        end
    end



    if nargin==1


        out=false;
        classFile=which(className);
        if~isempty(classFile)
            classFile=regexprep(classFile,'\.p$','.m');
            [fid,msg]=fopen(classFile);
            if fid==-1

                matlab.system.internal.error('MATLAB:system:fileOpenFailed',...
                strrep(classFile,'\','\\'),msg);
            end
            buf=fread(fid,inf,'*char')';
            fclose(fid);
            idx1=regexp(buf,'(?m)^ *%#codegen','once');
            idx2=regexp(buf,'coder.allowpcode','once');
            out=~isempty(idx1)||~isempty(idx2);
        end
    end

end
