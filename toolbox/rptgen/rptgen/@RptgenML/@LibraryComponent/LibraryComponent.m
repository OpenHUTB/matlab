function obj=LibraryComponent(clsName,compName)












    obj=feval(mfilename('class'));


    if nargin>0



        obj.ClassName=clsName;
        if nargin<2
            try
                c=feval(clsName);
                obj.DisplayName=getName(c);
            catch
                obj.DisplayName=clsName;
            end
        else
            obj.DisplayName=compName;
        end
    end


