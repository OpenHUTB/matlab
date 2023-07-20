function result=isValidStateOwnerBlock(this,blkObj)




    result=false;
    try


        blk=blkObj.getFullName;
        chartH=blkObj.find('-isa','Stateflow.Chart','-depth',1,'Name',blkObj.Name);
        if~isempty(chartH)&&slfeature('StateflowStateReset')~=0
            result=chartH.StateAccess.Enabled;
        elseif strcmpi(get_param(blk,'IsStateOwnerBlock'),'on')
            if strcmp(bdroot(blk),this.ModelObj.Name)
                result=true;
            end
        end
    catch
    end
