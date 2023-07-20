







function ds=expandDatasetForBusElPorts(...
    this,rootInports,numTriggerEnable,rootInportsInfo)



    if(isempty(rootInportsInfo))
        modelHandle=get_param(this.model,'Handle');
        bepElementNames=...
        Simulink.internal.CompositePorts.TreeNode.getLeafDotStrsForDataInputInterface(...
        modelHandle);
    else
        bepElementNames=rootInportsInfo.bepElementNames;
    end



    for idx=1:numTriggerEnable
        bepElementNames{end+1}={};%#ok<AGROW>
    end
    elemNames=this.ds.getElementNames;

    if~isequal(this.ds.numElements,numel(bepElementNames))
        if isequal(this.ds.numElements,1)


            val=this.ds{1};
            if(isstruct(val)&&~Simulink.SimulationData.utValidSignalOrCompositeData(val))||...
                isnumeric(val)
                isExtInpDatasetFormat=isa(this,...
                'Simulink.SimulationData.SerializeInput.RtInpDatasetSerializer');
                inputStructName=getInputStructName(isExtInpDatasetFormat,...
                this.ds,...
                get_param(this.model,'ExternalInput'),...
                1);
                msg=message(...
                'Simulink:SimInput:BusElementPortNonSupportedStruct',...
                inputStructName,...
                rootInports{1}...
                );
                ex=MSLException(msg);
                throwAsCaller(ex);
            end
        end
        msg=message(...
        'Simulink:Logging:InvInputLoadNameList',...
        numel(bepElementNames),...
        this.ds.numElements...
        );
        ex=MSLException(msg);
        throwAsCaller(ex);
    end

    ds=Simulink.SimulationData.Dataset;










    rootInportsIdx=1;
    for idx=1:this.ds.numElements
        if isempty(bepElementNames{idx})

            ds=ds.addElementWithoutChecking(this.ds.getElement(idx),elemNames{idx});
            rootInportsIdx=rootInportsIdx+1;
        else

            st=this.ds.getElement(idx);
            if isa(st,'Simulink.SimulationData.BlockData')
                st=st.Values;
            end

            isExtInpDatasetFormat=isa(this,...
            'Simulink.SimulationData.SerializeInput.RtInpDatasetSerializer');
            if isempty(st)




                inputStructName='';
            else
                inputStructName=getInputStructName(isExtInpDatasetFormat,...
                this.ds,...
                get_param(this.model,'ExternalInput'),...
                idx);
            end
            validateDataStruct(st,inputStructName,...
            rootInports{rootInportsIdx});
            oneBEP=bepElementNames{idx};
            for jdx=1:numel(oneBEP)
                if isequal(oneBEP{jdx},'')


                    ds=ds.addElementWithoutChecking([],...
                    [elemNames{idx},'.',oneBEP{jdx}]);
                else


                    el=[];
                    try
                        el=eval(['st.',oneBEP{jdx}]);
                    catch







                        if~validateLeadingPath(st,oneBEP{jdx})
                            msg=message(...
                            'Simulink:SimInput:BusElementPortInvalidStructForPartialSpec',...
                            rootInports{rootInportsIdx},...
                            oneBEP{jdx},...
inputStructName...
                            );
                            ex=MSLException(msg);
                            throwAsCaller(ex);
                        end
                    end
                    if isstruct(el)&&isequal(this.portBusTypes{rootInportsIdx},'NOT_BUS')


                        msg=message(...
                        'Simulink:SimInput:BusElementPortNonLeafElement',...
                        rootInports{rootInportsIdx}...
                        );
                        ex=MSLException(msg);
                        throwAsCaller(ex);
                    else
                        ds=ds.addElementWithoutChecking(el,...
                        [elemNames{idx},'.',oneBEP{jdx}]);
                    end
                end
                rootInportsIdx=rootInportsIdx+1;
            end
        end
    end
end

function validateDataStruct(st,name,blockPath)

    if isempty(st)
        return
    end

    if~isstruct(st)||~isscalar(st)
        msg=message(...
        'Simulink:SimInput:BusElementPortNonSupportedStruct',...
        name,...
blockPath...
        );
        ex=MSLException(msg);
        throwAsCaller(ex);
    end
    validateDataStructRecursion(st,name,blockPath);
end

function validateDataStructRecursion(st,name,blockPath)
    fields=fieldnames(st);
    for idx=1:numel(fields)
        child=st.(fields{idx});
        if isempty(child)
            return
        end
        if(isa(child,'timetable')&&~isequal(size(child,2),1))||...
            (~isa(child,'timetable')&&~isscalar(child))
            msg=message(...
            'Simulink:SimInput:BusElementPortNonSupportedStruct',...
            name,...
blockPath...
            );
            ex=MSLException(msg);
            throwAsCaller(ex);
        end
        if isstruct(st.(fields{idx}))
            validateDataStructRecursion(st.(fields{idx}),name,...
            blockPath)
        end
    end
end

function isValid=validateLeadingPath(st,el)





    el=strsplit(el,'.');
    isValid=true;
    for idx=1:numel(el)
        if isfield(st,el{idx})
            st=st.(el{idx});
            if~isstruct(st)
                isValid=false;
                break;
            end
        else
            return;
        end
    end
end

function stName=getInputStructName(isExtInpDataset,ds,extInput,idx)
    if isExtInpDataset
        stName=[extInput,'.get(',num2str(idx),')'];
    else
        stName=ds{idx}.Name;
    end
end

