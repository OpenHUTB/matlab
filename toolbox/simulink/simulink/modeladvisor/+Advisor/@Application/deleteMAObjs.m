



function deleteMAObjs(this)

    for n=1:length(this.MAObjs)

        maObj=this.MAObjs{n};

        if isa(maObj,'Simulink.ModelAdvisor')




            idx=regexp(maObj.SystemName,'/','once');
            if isempty(idx)
                bdname=maObj.SystemName;
            else
                bdname=maObj.SystemName(1:idx-1);
            end

            if bdIsLoaded(bdname)
                bdObj=get_param(bdname,'object');

                if bdObj.hasCallback('PostNameChange',this.ID)
                    Simulink.removeBlockDiagramCallback(...
                    bdname,...
                    'PostNameChange',this.ID);
                end
            end


            deleteObj(maObj);
        end

        this.MAObjs{n}=[];
    end


    this.MAObjs={};


    this.CompId2MAObjIdxMap=containers.Map('KeyType','char','ValueType','any');


    this.RootMAObj=[];
end