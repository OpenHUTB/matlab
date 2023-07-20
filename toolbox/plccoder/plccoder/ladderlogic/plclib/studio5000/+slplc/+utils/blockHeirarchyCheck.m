function blockHeirarchyCheck(block)



    if plcfeature('PLCLadderBlockHierarchyCheck')
        import plccore.common.plcThrowError;
        err_id='plccoder:plccore:InvalidInstructionBlockLevel';
        blockPOUInfo=slplc.api.getPOU(block);


        switch blockPOUInfo.PLCPOUType
        case{'Contact','Coil','stdFB','stdEC','stdFC','BranchJunction'}

            parentblock=slplc.utils.getParentPOU(block,'Scoped');
            if isempty(parentblock)
                plcThrowError(err_id,getfullname(block));
            end
            parentPOUInfo=slplc.api.getPOU(parentblock);
            if~ismember(parentPOUInfo.PLCPOUType,{'Function Block','Subroutine','Program'})
                plcThrowError(err_id,getfullname(block));
            end

        case{'PLC Controller'}
            err_id='plccoder:plccore:InvalidControllerBlockLevel';
            parentblock=slplc.utils.getParentPOU(block,'Scoped');
            if~isempty(parentblock)
                plcThrowError(err_id,getfullname(block));
            end

        case{'Task'}
            err_id='plccoder:plccore:InvalidTaskBlockLevel';
            parentblock=slplc.utils.getParentPOU(block,'Scoped');
            if isempty(parentblock)
                plcThrowError(err_id,getfullname(block));
            end
            parentBlkType=slplc.utils.getParam(parentblock,'PLCBlockType');
            if~ismember(parentBlkType,{'PLCController'})
                plcThrowError(err_id,getfullname(block));
            end

        case{'Function Block'}
            err_id='plccoder:plccore:InvalidFunctionBlockLevel';
            parentblock=slplc.utils.getParentPOU(block,'Scoped');
            if isempty(parentblock)
                plcThrowError(err_id,getfullname(block));
            end
            parentBlkType=slplc.utils.getParam(parentblock,'PLCBlockType');
            if~ismember(parentBlkType,{'FunctionBlock','LDFunctionBlock','Subroutine','LDProgram','AOIRunner'})
                plcThrowError(err_id,getfullname(block));
            end

        case{'Subroutine'}
            err_id='plccoder:plccore:InvalidSubroutineBlockLevel';
            parentblock=slplc.utils.getParentPOU(block,'Scoped');
            if isempty(parentblock)
                plcThrowError(err_id,getfullname(block));
            end
            parentBlkType=slplc.utils.getParam(parentblock,'PLCBlockType');
            if~ismember(parentBlkType,{'LDProgram','Subroutine'})
                plcThrowError(err_id,getfullname(block));
            end

        case{'Program'}
            err_id='plccoder:plccore:InvalidLDprogramBlockLevel';
            parentblock=slplc.utils.getParentPOU(block,'Scoped');
            if isempty(parentblock)
                plcThrowError(err_id,getfullname(block));
            end
            parentBlkType=slplc.utils.getParam(parentblock,'PLCBlockType');
            if~ismember(parentBlkType,{'Task'})
                plcThrowError(err_id,getfullname(block));
            end
        end
    end
end