function varargout=selection(id,label)



    persistent selectedId selectedLabel

    if nargin==0

        varargout{1}=selectedId;
        varargout{2}=selectedLabel;

    else

        varargout{1}=false;

        if isempty(id)

            selectedId=[];
            selectedLabel='';

        else

            if ischar(id)
                ids=sscanf(id,'%d,');
            else
                ids=id;
            end
            if strncmp(label,'count',5)

                count=str2num(label(6:end));%#ok<ST2NM>
                if length(ids)<count
                    return;
                else
                    selectedId=ids;
                end
            else

                selectedId=ids(1);
                selectedLabel=label;
            end
            varargout{1}=true;



            if ids(1)>0
                projName=oslc.Project.currentProject();
                if isempty(projName)
                    dngDlg=oslc.DlgSelectProject();
                    DAStudio.Dialog(dngDlg);
                end
            end
        end
    end
end



