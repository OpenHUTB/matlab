function success=viewLink(obj,varargin)




    success=true;

    if ischar(obj)&&~isempty(regexp(obj,'\:.+\|\d+\.\d+$','once'))
        isFromCode=true;


        if dig.isProductInstalled('Simulink')&&is_simulink_loaded()
            mdlName=strtok(obj,':');
            try
                get_param(mdlName,'FileName');
            catch ex %#ok<NASGU>
                warning(message('Slvnv:rmiml:ModelMustBeLoaded',mdlName));
                success=false;
                return;
            end
        else
            warning(message('Slvnv:rmiml:ModelMustBeLoadedInSimulink'));
            success=false;
            return;
        end
    else
        isFromCode=false;
    end

    switch length(varargin)
    case 0
        if isFromCode

            reqs=rmiml.getReqs(obj);

            if length(reqs)>1
                rmiml.editLinks(obj);
            elseif length(reqs)==1
                rmiml.navigateToReq(1,obj);
            end
        else

            reqs=rmi.getReqs(obj);

            if length(reqs)>1
                rmi.editReqs(obj);
            elseif length(reqs)==1
                rmi.navigateToReq(obj,1);
            end
        end

    case 1
        if isFromCode

            rmiml.navigateToReq(varargin{1},obj);
        else

            rmi.navigateToReq(obj,varargin{1});
        end

    otherwise
        error(message('Slvnv:reqmgt:rmi:InvalidArgumentNumber'));
    end

end
