function deleteAll(varargin)




    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:setReqs:NoLicense'));
    end


    obj=varargin{1};
    if nargin>1&&strcmp(varargin{2},'force')
        force=true;
    else
        force=false;
    end

    if~force


        [dName,~,label]=rmide.resolveEntry(obj);
        dialogTitle=getString(message('Slvnv:rmiml:DeleteAllLinksTitle'));
        confirmMessage=getString(message('Slvnv:rmide:DeleteAllLinksQuestion',label,dName));
        result=questdlg(confirmMessage,dialogTitle,...
        getString(message('Slvnv:rmi:clearAll:OK')),...
        getString(message('Slvnv:rmi:clearAll:Cancel')),...
        getString(message('Slvnv:rmi:clearAll:Cancel')));
        if isempty(result)||strcmp(result,getString(message('Slvnv:rmi:clearAll:Cancel')))
            return;
        end
    end


    rmide.setReqs(obj,[]);

end


