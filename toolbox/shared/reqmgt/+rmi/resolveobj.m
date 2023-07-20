function[isSf,objH,errMsg]=resolveobj(obj)





    isSf=false;
    objH=[];
    errMsg='';

    className=class(obj);

    if strncmp(className,'Simulink.',length('Simulink.'))
        if isa(obj,'Simulink.Block')||isa(obj,'Simulink.BlockDiagram')||isa(obj,'Simulink.Annotation')
            objH=obj.handle;
        elseif isa(obj,'Simulink.DDEAdapter')
            objH={obj};
        elseif rmifa.isFaultInfoObj(obj)
            isSf=false;
            objH=obj;
        else
            errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidClass',className));
        end
    elseif startsWith(className,'sm.')

        isSf=false;
        objH=obj;
    elseif strncmp(className,'Stateflow.',length('Stateflow.'))
        if any(strcmp(className,rmisf.sfisa('supportedTypes')))
            isSf=true;
            objH=obj.Id;
        else
            errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidClass',className));
        end

    elseif isa(obj,'double')
        if~isscalar(obj)
            errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidHandle',num2str(obj)));
        elseif obj>0&&floor(obj)==obj

            isSf=true;
            [objH,errMsg]=is_valid_stateflow_handle(obj);
        else

            [objH,errMsg]=is_valid_simulink_handle(obj);
        end

    elseif isa(obj,'char')
        if strncmp(obj,'rmimdladvobj',12)

            try
                objH=eval(obj);
                [isSf,objH,errMsg]=resolveobj(objH);
            catch Mex %#ok<NASGU>
                errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidBlockReference'));
            end
        elseif rmisl.isHarnessIdString(obj)
            [isSf,objH]=rmisl.resolveObjInHarness(obj);
            if isempty(objH)
                errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidPath',obj));
            end
        else
            if rmide.isDataEntry(obj)
                objH=obj;
            else
                if isempty(Simulink.ID.checkSyntax(obj))
                    objH=rmisl.getHandleFromFullSID(obj);
                    if objH==-1
                        objH=[];
                        errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidPath',obj));
                    end
                else
                    try





                        objH=get_param(obj,'Handle');
                    catch
                        objH=[];
                        errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidPath',obj));
                    end
                end


                if isempty(errMsg)
                    if isa(objH,'Stateflow.Object')
                        objH=objH.Id;
                        isSf=true;
                    elseif rmisf.isStateflowLoaded()&&slprivate('is_stateflow_based_block',objH)




                        [isSf,objH]=resolveInSf(objH);
                    end
                    if~isSf
                        [objH,errMsg]=is_valid_simulink_handle(objH);
                    end
                end
            end
        end
    else
        errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidClass',className));
    end

end

function[isSf,objH]=resolveInSf(objH)
    isSf=false;
    slInSfObj=get_param(objH,'Object');
    if strcmp(slInSfObj.SFBlockType,'Chart')

        if slInSfObj.isLinked



            parentChart=get_param(slInSfObj.Parent,'Object');
            sfObj=find(parentChart,'-isa','Stateflow.AtomicSubchart','Name',slInSfObj.Name);
            if length(sfObj)==1
                objH=sfObj.Id;
                isSf=true;
            end
        else

            chartId=sfprivate('block2chart',slInSfObj.Handle);
            stateId=sfprivate('get_state_for_atomic_subchart',chartId);
            if stateId~=0
                objH=stateId;
                isSf=true;
            end
        end
    end
end

function[objH,errMsg]=is_valid_simulink_handle(obj)
    errMsg='';
    objH=[];

    if~ishandle(obj)
        errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidHandle',num2str(obj)));
        return;
    end

    try
        slType=get_param(obj,'type');
        switch slType
        case{'block','block_diagram','annotation'}
            objH=obj;
        case 'port'

            if Simulink.internal.isArchitectureModel(bdroot(obj))
                objH=obj;
            else
                errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidType',slType));
            end
        otherwise
            errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidType',slType));
        end
    catch Mex %#ok<NASGU>
        errMsg=getString(message('Slvnv:rmi:resolveobj:ExpectedHandle',num2str(obj)));
    end
end


function[objH,errMsg]=is_valid_stateflow_handle(obj)
    errMsg='';
    objH=[];
    sfisa=rmisf.sfisa();

    if sf('ishandle',obj)
        objsSfIsa=sf('get',obj,'.isa');
        for objSfIsa=objsSfIsa(:)'
            switch(objSfIsa)
            case{sfisa.chart,sfisa.state,sfisa.transition}
                objH=obj;
            otherwise
                errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidStateflow'));
            end
        end
    else
        errMsg=getString(message('Slvnv:rmi:resolveobj:InvalidHandle',num2str(obj)));
    end
end
