function stmt=sldvPickMcdcObjectives(hdl,portNo)




    stmt=[];
    if nargin<2
        portNo=0;
    end

    if~strcmp(get_param(hdl,'Type'),'block')||...
        ~strcmp(get_param(hdl,'BlockType'),'Logic')
        return;
    end
    if portNo
        stmt=sldvPickMcdcForPort(hdl,portNo);
    else
        portHs=get_param(hdl,'PortHandles');
        numInp=length(portHs.Inport);

        for i=1:numInp
            thisstmt=Sldv.ObjectiveSelection.sldvPickMcdcForPort(hdl,i);
            stmt=[stmt,thisstmt];%#ok<*AGROW>
        end
    end
end
