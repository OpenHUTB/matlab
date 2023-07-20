function varargout=rmidlg_hasChanges(dlgTitle,value)








    persistent myValue myTitle;

    if nargin==2

        myTitle=dlgTitle;
        myValue=value;
        varargout{1}=[];

    elseif nargin==1

        if isempty(myTitle)||~strcmp(myTitle,dlgTitle)

            varargout{1}=true;
        else
            myTitle='';
            varargout{1}=~isempty(myValue)&&myValue;
        end

    else




        varargout{1}=~isempty(myTitle);

    end

end

