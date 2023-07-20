function[sfId,blockH,errormsg]=getBlockIds(block,sfId,blockH,errormsg)



    switch(class(block))
    case 'char'
        try
            try

                blockH=get_param(block,'Handle');
            catch

                ssid=block;
                block=Simulink.ID.getHandle(ssid);
                [sfId,blockH,errormsg]=chekcSimulinStateflowClasses(block,sfId,blockH,errormsg,ssid);
            end
        catch MEx %#ok<NASGU>
            errormsg=getString(message('Slvnv:simcoverage:private:BlkInvalidPath',block));
        end
    case 'cell'
        if length(block)>2
            errormsg=getString(message('Slvnv:simcoverage:private:BlkParameterOneTwoElements'));
        end
        [sfId,blockH,errormsg]=SlCov.CoverageAPI.getBlockIds(block{1},sfId,blockH,errormsg);
        if length(block)>1
            [sfId,blockH,errormsg]=SlCov.CoverageAPI.getBlockIds(block{2},sfId,blockH,errormsg);
        end

    case 'double'
        switch(length(block))
        case 1
            if floor(block)==block
                sfId=block;
            else
                blockH=block(1);
            end
        case 2
            blockH=block(1);
            if floor(block(2))~=block(2)
                errormsg=getString(message('Slvnv:simcoverage:private:BlkParameterElementTwoInt'));
            end
            sfId=block(2);
        otherwise
            errormsg=getString(message('Slvnv:simcoverage:private:BlkParameterOneTwoElements'));
        end
    otherwise
        [sfId,blockH,errormsg]=chekcSimulinStateflowClasses(block,sfId,blockH,errormsg,[]);
    end

    function[sfId,blockH,errormsg]=chekcSimulinStateflowClasses(block,sfId,blockH,errormsg,ssid)
        if strncmp(class(block),'Simulink.',9)
            blockH=block.Handle;
        elseif strncmp(class(block),'Stateflow.',10)
            sfId=block.Id;
            if~isempty(ssid)
                blockH=Simulink.ID.getHandle(Simulink.ID.getSimulinkParent(ssid));
            end
        else
            errormsg=getString(message('Slvnv:simcoverage:private:BlkParameterWrongType'));
        end

