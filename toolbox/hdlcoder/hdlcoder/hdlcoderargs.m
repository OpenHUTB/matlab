function[hC,params]=hdlcoderargs(varargin)





    if mod(length(varargin),2)==0
        params=varargin(:);
        curmodel=bdroot;
        if isempty(curmodel)
            error(message('hdlcoder:makehdl:nodefaultmodel'));
        end

        try
            hD=hdlmodeldriver(curmodel);
            snn=hD.getStartNodeName;
        catch me %#ok<NASGU>
            snn=curmodel;
        end


        snn=removemodelname(snn,curmodel);

        if isempty(snn)
            startnode=curmodel;
        elseif~(isvalidstartnodename(curmodel,snn))
            startnode=curmodel;
        elseif(strcmp(curmodel,snn))
            startnode=snn;
        else
            startnode=getmodelnodename(curmodel,snn);
        end
    else
        startnode=varargin{1};


        if(~ischar(startnode)||(size(startnode,1)~=1))
            error(message('hdlcoder:makehdl:invaliddut'));
        end

        params=varargin(2:end);
        inputModel=strtok(startnode,'/');
        openSystems=find_system('flat');

        if isempty(openSystems)
            error(message('hdlcoder:makehdl:noopenmodelss',startnode));
        end


        if~any(strcmp(openSystems,inputModel))

            inputModel=bdroot;
            startnode=[inputModel,'/',startnode];

            if~(isvalidstartnodename(inputModel,varargin{1}))
                error(message('hdlcoder:makehdl:systemnotfound',varargin{1},inputModel));
            end
        end


        startnode=getmodelnodename(inputModel,startnode);
    end

    blkdiagram=startnode;
    hierarchyLevels=0;
    while~isempty(get_param(blkdiagram,'Parent'))
        blkdiagram=get_param(blkdiagram,'Parent');
        hierarchyLevels=hierarchyLevels+1;
    end


    if(~strcmpi(get_param(blkdiagram,'LibraryType'),'None'))

        error(message('hdlcoder:makehdl:librarymodel'));
    end

    hdlcc=attachhdlcconfig(blkdiagram);
    hC=hdlcc.getHDLCoder;
    if~isempty(hC)
        hC.updateStartNodeName(startnode);
        hC.nonTopDut=logical(hierarchyLevels>1);
    else
        error(message('hdlcoder:makehdl:nohdlcoderui'));
    end


    if~isempty(startnode)
        params={'HDLSubsystem',startnode,params{:}};%#ok<CCAT>
    end
end


function snn=removemodelname(snn,curmodel)


    if strcmp(snn,curmodel)
        snn='';
    else

        modelname=[curmodel,'/'];
        len_snn=length(snn);
        len_modelname=length(modelname);
        if(len_snn>len_modelname)

            if(strcmp(modelname,snn(1:len_modelname)))

                snn=snn(len_modelname+1:end);
            end
        end
    end
end


function isvalid_snn=isvalidstartnodename(curmodel,snn)


    isvalid_snn=~isempty(getmodelnodename(curmodel,snn));
end


