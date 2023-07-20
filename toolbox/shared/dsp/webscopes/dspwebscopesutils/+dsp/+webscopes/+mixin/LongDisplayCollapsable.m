classdef LongDisplayCollapsable<handle&matlab.mixin.CustomDisplay





    properties(Access=protected)

        ShowAllProperties=false;
    end



    methods(Access=public,Hidden)

        function showAllProperties(this)
            this.ShowAllProperties=true;
            disp(this);
            this.ShowAllProperties=false;
        end
    end



    methods(Access=protected)

        function header=getHeader(this)
            header=matlab.mixin.CustomDisplay.getDetailedHeader(this);
            expression='<a href="matlab:helpPopup handle">handle</a> ';
            [~,noMatch]=regexp(header,expression,'match','split');
            header=[noMatch{:}];
        end

        function footer=getFooter(this)
            if(~this.ShowAllProperties)
                objName=string(inputname(1));
                cmd=strcat("matlab:",objName,".showAllProperties()");
                msg=getString(message('MATLAB:system:ShowAllPropertiesText'));
                footer=convertStringsToChars(strcat('  <a href="',cmd,'">',msg,'</a>'));
                footer=[footer,newline];
            else
                footer='';
            end
        end
    end
end

