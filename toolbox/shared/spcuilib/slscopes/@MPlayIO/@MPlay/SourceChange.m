function SourceChange(hMPlay)





    selectedSigs=source(hMPlay.hMPlay);




    if isempty(selectedSigs)||size(selectedSigs{1},2)~=2




        newioSigs=struct('Handle',-1,'RelativePath','');
    else

        selectedSigs=selectedSigs{1};

        newioSigs=[];
        for indx=1:size(selectedSigs,1)


            block_name=selectedSigs{indx,1};
            portIndexArray=selectedSigs{indx,2};


            if~isempty(block_name)&&~isempty(portIndexArray)
                hSig=get_param(block_name,'handle');
                hPorts=get_param(hSig,'porthandles');
                hOutports=hPorts.Outport;
                nMPlaySigs=length(portIndexArray);
                for jndx=1:nMPlaySigs

                    newioSigs=[newioSigs,struct('Handle',hOutports(portIndexArray(jndx)),'RelativePath','')];
                end
            end
        end
    end


    set_param(hMPlay.hBlk,'IOSignals',{newioSigs});


