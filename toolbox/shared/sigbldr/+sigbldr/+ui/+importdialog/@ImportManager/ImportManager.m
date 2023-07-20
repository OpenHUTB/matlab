

classdef ImportManager<handle



    properties(SetAccess='private',GetAccess='public')
        curSBObj=SigSuite;
        StatusMessage;
    end

    methods
        function this=ImportManager(baseObj)
            if(isa(baseObj,'SigSuite'))
                this.curSBObj=baseObj;
            else
                this.curSBObj='';
            end
        end
    end


    methods
        function startImport(this,tmpSBObj,action,grpList,sigList)

            try

                switch action
                case 'ASA'
                    this.StatusMessage=this.curSBObj.groupSignalAppend(tmpSBObj,grpList,sigList,'S');
                case 'ASD'
                    this.StatusMessage=this.curSBObj.groupSignalAppend(tmpSBObj,grpList,sigList,'P');
                case 'AGR'
                    [~,this.StatusMessage]=this.curSBObj.groupAppend(tmpSBObj,grpList,sigList);
                case 'RED'
                    [this.curSBObj,this.StatusMessage]=tmpSBObj.groupSignalSelect(grpList,sigList);
                end


            catch ME
                ME.throw;
            end
        end




        function newsbobj=getSBObj(this)
            newsbobj=this.curSBObj.copyObj;
        end



        function this=setSBObj(newsbobj)
            this.curSBObj=newsbobj;
        end



        function[status]=getStatusMessage(this)
            status=this.StatusMessage;
        end
    end



end
