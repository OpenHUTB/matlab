function argout=handleID(cmd,argin)






    narginchk(2,2);
    argout=[];


    if strcmp(cmd,'toID')

        argout=num2str(double(argin),30);


    elseif strcmp(cmd,'toHandle')
        if~ischar(argin)&&~isstring(argin)
            warning('MATLAB:connector:handleID','The specified argument must be a string representation created by mls.internal.handleID');
        end

        h=handle(str2double(argin));


        if ishandle(h)
            argout=h;
        end

    end
